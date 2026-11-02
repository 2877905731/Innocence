import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';

class AppRelease {
  AppRelease.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        platform = j['platform'] as String,
        version = j['version'] as String,
        build = j['build'] as int,
        notes = j['notes'] as String,
        size = j['size'] as int,
        sha = j['sha256'] as String,
        method = j['installMethod'] as String {
    if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(id) ||
        !RegExp(r'^\d{1,4}\.\d{1,4}\.\d{1,4}$').hasMatch(version) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha) ||
        build < 1 ||
        size < 1 ||
        size > 300 * 1048576 ||
        !{
          'windows/windows_installer',
          'android/android_apk',
          'harmonyos/manual_hdc'
        }.contains('$platform/$method')) {
      throw const FormatException('Invalid update metadata');
    }
  }
  final String id, platform, version, notes, sha, method;
  final int build, size;
  bool get manual => method == 'manual_hdc';
  String get extension => platform == 'windows'
      ? 'exe'
      : platform == 'android'
          ? 'apk'
          : 'hap';
}

class UpdateController extends ChangeNotifier {
  UpdateController(
      {required this.session,
      required this.hasActiveTimer,
      required this.prepareInstall,
      Uri? base,
      Future<Map<String, dynamic>> Function()? info,
      Future<Directory> Function()? directory})
      : _base = base ?? Uri.parse(AppConfig.apiBaseUrl),
        _info = info ??
            (() async => Map<String, dynamic>.from(
                await _channel.invokeMethod<Map>('info') ?? {})),
        _directory = directory ?? getTemporaryDirectory;
  static const _channel = MethodChannel('innocence/updates');
  final AppSession? Function() session;
  final bool Function() hasActiveTimer;
  final Future<void> Function() prepareInstall;
  final Uri _base;
  final Future<Map<String, dynamic>> Function() _info;
  final Future<Directory> Function() _directory;
  AppRelease? release;
  bool busy = false, verified = false;
  double progress = 0;
  String? message;
  String currentVersion = '';
  AppSession? _owner;
  int _epoch = 0;
  HttpClient? _client;
  File? _part, _ready;
  bool _disposed = false;
  void identityChanged() {
    final next = session();
    if (identical(next, _owner)) return;
    _owner = next;
    _epoch++;
    _client?.close(force: true);
    release = null;
    verified = false;
    busy = false;
    progress = 0;
    message = null;
    unawaited(_cleanFiles());
    if (!_disposed) notifyListeners();
  }

  Future<void> _cleanFiles() async {
    final files = [_part, _ready];
    _part = null;
    _ready = null;
    for (final file in files.whereType<File>()) {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  void _require(AppSession captured, int epoch) {
    if (_disposed || epoch != _epoch || !identical(captured, session())) {
      throw const FormatException('Session changed');
    }
  }

  HttpClient _http() =>
      _client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  Future<HttpClientResponse> _get(
      HttpClient client, String path, AppSession owner,
      {int offset = 0}) async {
    final request = await client
        .getUrl(_base.resolve(path))
        .timeout(const Duration(seconds: 25));
    request.followRedirects = false;
    owner.authHeaders.forEach(request.headers.set);
    request.headers.set('Accept', 'application/json, application/octet-stream');
    if (offset > 0) request.headers.set('Range', 'bytes=$offset-');
    return request.close().timeout(const Duration(seconds: 30));
  }

  Future<void> check() async {
    identityChanged();
    final owner = session();
    if (owner == null || busy) return;
    final epoch = _epoch;
    busy = true;
    message = null;
    notifyListeners();
    try {
      final info = await _info();
      _require(owner, epoch);
      final build = info['build'] as int,
          platform = info['platform'] as String,
          arch = info['arch'] as String;
      currentVersion = '${info['version']} ($build)';
      final response = await _get(
          _http(),
          'updates/latest?platform=${Uri.encodeComponent(platform)}&arch=${Uri.encodeComponent(arch)}&currentBuild=$build',
          owner);
      if (response.statusCode != 200) {
        throw HttpException('update_check_${response.statusCode}');
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        _require(owner, epoch);
        bytes.addAll(chunk);
        if (bytes.length > 32768) {
          throw const FormatException('Response too large');
        }
      }
      final body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (body['code'] != 0) throw const FormatException('Update check failed');
      final value = (body['data'] as Map<String, dynamic>)['update'];
      final next = value == null
          ? null
          : AppRelease.fromJson(Map<String, dynamic>.from(value as Map));
      if (next != null && (next.platform != platform || next.build <= build)) {
        throw const FormatException('Update platform or build mismatch');
      }
      _require(owner, epoch);
      if (next?.id != release?.id) {
        await _cleanFiles();
        verified = false;
        progress = 0;
      }
      release = next;
      message = next == null ? '当前已是最新版本。' : null;
    } catch (_) {
      if (epoch == _epoch) message = '检查更新失败，请确认已登录且服务器可连接，然后重试。';
    } finally {
      if (epoch == _epoch && !_disposed) {
        busy = false;
        _client?.close(force: true);
        notifyListeners();
      }
    }
  }

  Future<void> download() async {
    final owner = session(), item = release;
    if (owner == null || item == null || busy) return;
    final epoch = _epoch;
    busy = true;
    message = null;
    notifyListeners();
    RandomAccessFile? output;
    try {
      final dir = Directory(
          '${(await _directory()).path}${Platform.pathSeparator}innocence-updates');
      await dir.create(recursive: true);
      _require(owner, epoch);
      _part ??= File('${dir.path}${Platform.pathSeparator}${item.id}.part');
      var offset = await _part!.exists() ? await _part!.length() : 0;
      if (offset >= item.size) {
        await _part!.delete();
        offset = 0;
      }
      final response = await _get(_http(), 'updates/${item.id}/download', owner,
          offset: offset);
      if (response.statusCode == 200) {
        offset = 0;
      } else if (response.statusCode != 206 ||
          offset == 0 ||
          response.headers.value('content-range') !=
              'bytes $offset-${item.size - 1}/${item.size}') {
        throw HttpException('download_${response.statusCode}');
      }
      if (response.contentLength != item.size - offset) {
        throw const FormatException('Invalid download size');
      }
      output = await _part!
          .open(mode: offset == 0 ? FileMode.write : FileMode.append);
      var count = offset;
      await for (final bytes in response.timeout(const Duration(seconds: 30))) {
        _require(owner, epoch);
        count += bytes.length;
        if (count > item.size) {
          throw const FormatException('Invalid download size');
        }
        await output.writeFrom(bytes);
        progress = count / item.size;
        notifyListeners();
      }
      await output.flush();
      await output.close();
      output = null;
      if (count != item.size) {
        throw const FormatException('Incomplete download');
      }
      final digest = await sha256.bind(_part!.openRead()).first;
      _require(owner, epoch);
      if (digest.toString() != item.sha) {
        await _cleanFiles();
        throw const FormatException('Package integrity failure');
      }
      _ready = await _part!.rename(
          '${dir.path}${Platform.pathSeparator}${item.id}.${item.extension}');
      _part = null;
      verified = true;
      message = item.manual ? '安装包已校验。此鸿蒙开发版需在电脑上签名后覆盖安装。' : '安装包校验通过，可以开始安装。';
    } catch (_) {
      if (epoch == _epoch) message = '下载或校验失败，请重试。未校验的安装包不会执行。';
    } finally {
      await output?.close();
      if (epoch == _epoch && !_disposed) {
        busy = false;
        _client?.close(force: true);
        notifyListeners();
      }
    }
  }

  Future<void> install() async {
    final owner = session(), item = release, file = _ready;
    if (owner == null ||
        item == null ||
        file == null ||
        busy ||
        !verified ||
        item.manual) {
      return;
    }
    if (hasActiveTimer()) {
      message = '请先结束正在进行的专注或番茄，再安装更新。';
      notifyListeners();
      return;
    }
    final epoch = _epoch;
    busy = true;
    message = null;
    notifyListeners();
    try {
      // Revalidate after an arbitrary wait between download and installation.
      final response = await _get(_http(), 'updates/${item.id}', owner);
      if (response.statusCode != 200) {
        throw const FormatException('Update unavailable');
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        _require(owner, epoch);
        bytes.addAll(chunk);
        if (bytes.length > 32768) {
          throw const FormatException('Response too large');
        }
      }
      final body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final current =
          AppRelease.fromJson(Map<String, dynamic>.from(body['data'] as Map));
      if (body['code'] != 0 ||
          current.id != item.id ||
          current.sha != item.sha ||
          current.build != item.build ||
          current.platform != item.platform) {
        throw const FormatException('Update metadata changed');
      }
      if (await file.length() != item.size ||
          (await sha256.bind(file.openRead()).first).toString() != item.sha) {
        verified = false;
        await _cleanFiles();
        throw const FormatException('Package changed');
      }
      await prepareInstall();
      _require(owner, epoch);
      if (hasActiveTimer()) throw StateError('A timer started while preparing the update');
      final result = await _channel.invokeMethod<String>('install',
          {'path': file.path, 'version': item.version, 'build': item.build});
      _require(owner, epoch);
      message = result == 'permissionRequired'
          ? '请在系统中允许此应用安装更新，然后返回并再次点击安装。'
          : '已打开系统安装器，请按系统提示完成更新。';
    } catch (_) {
      if (epoch == _epoch) message = '无法安装此更新。请确认安装包、版本与原应用签名一致后重试。';
    } finally {
      if (epoch == _epoch && !_disposed) {
        busy = false;
        _client?.close(force: true);
        notifyListeners();
      }
    }
  }

  Future<bool> exportManual(String path) async {
    final owner = session(), file = _ready;
    if (owner == null || file == null || !verified || release?.manual != true) {
      return false;
    }
    final epoch = _epoch;
    try {
      if ((await sha256.bind(file.openRead()).first).toString() != release!.sha) {
        throw const FormatException('Package changed');
      }
      _require(owner, epoch);
      await file.copy(path);
      return true;
    } catch (_) {
      if (epoch == _epoch) {
        message = '导出失败，请重新下载或选择其他位置。';
        notifyListeners();
      }
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _client?.close(force: true);
    unawaited(_cleanFiles());
    super.dispose();
  }
}
