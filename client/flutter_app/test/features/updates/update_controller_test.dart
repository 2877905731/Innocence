import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/updates/update_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttp = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = previousHttp);
  late HttpServer server;
  late Directory directory;
  late UpdateController controller;
  AppSession? owner;
  var tamper = false, active = false, reachable = true, installerCalls = 0;
  final bytes = List<int>.generate(8192, (i) => i % 256);
  Map<String, Object> metadata() => {
        'id': '12345678-1234-1234-1234-123456789abc',
        'platform': 'windows',
        'arch': 'x64',
        'version': '1.3.4',
        'build': 16,
        'notes': '更新内容',
        'size': bytes.length,
        'sha256': sha256.convert(bytes).toString(),
        'installMethod': 'windows_installer'
      };
  AppSession account(int id) => AppSession(
      accessToken: 'qa-$id',
      tokenType: 'Bearer',
      userId: id,
      deviceType: 'windows',
      deviceSlot: 'desktop',
      deviceId: 'qa-device');
  setUp(() async {
    tamper = false;
    active = false;
    reachable = true;
    installerCalls = 0;
    owner = account(7);
    directory = await Directory.systemTemp.createTemp('update-qa-');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((r) async {
      if (!reachable) {
        r.response.statusCode = 503;
        await r.response.close();
        return;
      }
      expect(r.headers.value('authorization'), 'Bearer qa-7');
      if (r.uri.path.endsWith('/download')) {
        r.response.contentLength = bytes.length;
        r.response.add(tamper ? List<int>.filled(bytes.length, 0) : bytes);
      } else {
        r.response.headers.contentType = ContentType.json;
        r.response.write(jsonEncode({
          'code': 0,
          'data': r.uri.path.endsWith('/latest')
              ? {'update': metadata()}
              : metadata()
        }));
      }
      await r.response.close();
    });
    controller = UpdateController(
        session: () => owner,
        hasActiveTimer: () => active,
        prepareInstall: () async {},
        base: Uri.parse('http://127.0.0.1:${server.port}/api/app/v1/'),
        directory: () async => directory,
        info: () async => {
              'build': 15,
              'version': '1.3.3',
              'platform': 'windows',
              'arch': 'x64'
            });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('innocence/updates'),
            (call) async {
      installerCalls++;
      return 'installerOpened';
    });
  });
  tearDown(() async {
    controller.dispose();
    await server.close(force: true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await directory.delete(recursive: true);
  });
  test(
      'authenticated metadata and exact file digest allow installation only after timer ends',
      () async {
    await controller.check();
    expect(controller.release?.build, 16);
    await controller.download();
    expect(controller.verified, isTrue);
    active = true;
    await controller.install();
    expect(installerCalls, 0);
    active = false;
    await controller.install();
    expect(installerCalls, 1);
  });
  test('tampered payload cannot become installable', () async {
    await controller.check();
    tamper = true;
    await controller.download();
    expect(controller.verified, isFalse);
    await controller.install();
    expect(installerCalls, 0);
  });
  test('owner switch discards verified packages and offline mode cannot check',
      () async {
    await controller.check();
    await controller.download();
    owner = account(9);
    controller.identityChanged();
    expect(controller.verified, isFalse);
    expect(controller.release, isNull);
    owner = null;
    controller.identityChanged();
    await controller.check();
    expect(controller.release, isNull);
    expect(installerCalls, 0);
  });
  test(
      'server must still authorize a previously downloaded package before installation',
      () async {
    await controller.check();
    await controller.download();
    reachable = false;
    await controller.install();
    expect(installerCalls, 0);
    expect(controller.message, contains('无法安装'));
  });
}
