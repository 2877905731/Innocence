import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import '../domain/models/pomodoro_timer.dart';

class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroController(
      {required this.store,
      required this.owner,
      required this.chinese,
      String? platform,
      int Function()? now})
      : platform = platform ?? AppConfig.deviceType,
        _now = now ?? (() => DateTime.now().millisecondsSinceEpoch) {
    WidgetsBinding.instance.addObserver(this);
  }
  final OfflineStore store;
  final String? Function() owner;
  final bool Function() chinese;
  final String platform;
  final int Function() _now;
  PomodoroTimer timer = const PomodoroTimer();
  bool busy = false;
  String? error;
  String noticeStatus = 'available';
  String? _owner;
  bool _disposed = false;
  bool _identityInitialized = false;
  int _generation = 0;
  Timer? _ticker;
  Future<void> _nativeQueue = Future.value();
  String? _signature;

  Future<void> updateIdentity() async {
    final next = owner();
    if ((_identityInitialized && next == _owner) || _disposed) return;
    _identityInitialized = true;
    final generation = ++_generation;
    _owner = next;
    _ticker?.cancel();
    timer = const PomodoroTimer();
    busy = true;
    error = null;
    notifyListeners();
    await _sync(force: true); // Cancel the previous owner's native timer first.
    try {
      final restored =
          next == null ? const PomodoroTimer() : await store.loadPomodoro(next);
      if (_disposed || generation != _generation || next != owner()) return;
      timer = restored.advance(_now());
      _schedule();
    } catch (_) {
      if (generation == _generation) {
        error =
            chinese() ? '番茄计时恢复失败，请重试。' : 'Could not restore the timer. Retry.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
        await _sync(force: true);
      }
    }
  }

  Future<void> start(int study, int rest, bool notices) async {
    if (study < 1 || study > 1440 || rest < 0 || rest > 1440) {
      throw ArgumentError('Invalid durations');
    }
    if (timer.active) return;
    final now = _now();
    await _save(
        PomodoroTimer(
            id: '$now-${Random.secure().nextInt(1 << 30)}',
            active: true,
            studyMinutes: study,
            breakMinutes: rest,
            referenceMs: now,
            notices: notices),
        requestPermission: notices);
  }

  Future<void> togglePause() async {
    if (!timer.active) return;
    final now = _now();
    final current = timer.advance(now);
    await _save(current.copy(paused: !current.paused, referenceMs: now));
  }

  Future<void> finish() async {
    if (!timer.active) return;
    await _save(timer.advance(_now()).copy(active: false, paused: false));
  }

  Future<void> _save(PomodoroTimer next,
      {bool requestPermission = false}) async {
    if (busy || _owner == null || _owner != owner()) return;
    final captured = _owner!;
    final generation = _generation;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await store.savePomodoro(captured, next);
      if (_disposed || generation != _generation || captured != owner()) return;
      timer = next.advance(_now());
      _schedule();
      await _sync(force: true, requestPermission: requestPermission);
    } catch (_) {
      if (!_disposed && generation == _generation) {
        error =
            chinese() ? '保存番茄计时失败，请重试。' : 'Could not save the timer. Retry.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void _schedule() {
    _ticker?.cancel();
    if (timer.active && !timer.paused) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _advance());
    }
  }

  void _advance() {
    if (_disposed || _owner != owner()) return;
    final old = timer;
    timer = timer.advance(_now());
    notifyListeners();
    if (old.stage != timer.stage || old.cycle != timer.cycle) {
      unawaited(_sync(transition: true));
    }
  }

  Future<void> refreshNotices() => _sync(force: true);
  Future<void> retryRestore() async {
    if (busy) return;
    _identityInitialized = false;
    await updateIdentity();
  }

  Future<void> openSettings() async {
    try {
      await const MethodChannel('innocence/focus_notice')
          .invokeMethod<void>('openSettings', {'independent': true});
    } on PlatformException {
      noticeStatus = 'unavailable';
      notifyListeners();
    } on MissingPluginException {
      noticeStatus = 'unavailable';
      notifyListeners();
    }
  }

  Future<void> _sync(
      {bool force = false,
      bool requestPermission = false,
      bool transition = false}) {
    final snapshot = timer;
    final captured = _owner;
    final active = captured != null &&
        snapshot.active &&
        snapshot.notices &&
        captured == owner();
    final payload = <String, dynamic>{
      'owner': captured ?? '',
      'key': active ? '$captured/pomodoro/${snapshot.id}' : '',
      'active': active,
      'paused': snapshot.paused,
      'studyMinutes': snapshot.studyMinutes,
      'breakMinutes': snapshot.breakMinutes,
      'elapsedMs': snapshot.elapsedMs,
      'referenceMs': snapshot.referenceMs,
      'isChinese': chinese()
    };
    final signature =
        '$captured/${snapshot.id}/$active/${snapshot.paused}/${snapshot.referenceMs - snapshot.elapsedMs}/${snapshot.stage}/${snapshot.cycle}/${chinese()}';
    if (!force && signature == _signature) return _nativeQueue;
    _signature = signature;
    _nativeQueue = _nativeQueue.then((_) async {
      if (_disposed) return;
      try {
        if (platform == 'android' || platform == 'harmonyos') {
          const channel = MethodChannel('innocence/focus_notice');
          if (requestPermission) {
            await channel.invokeMethod<void>('requestPermission');
          }
          final status =
              await channel.invokeMethod<String>('syncPomodoro', payload);
          if (!_disposed && captured == _owner) {
            noticeStatus = status ?? 'unavailable';
            notifyListeners();
          }
        } else if (platform == 'windows' && transition && active) {
          await const MethodChannel('innocence/desktop_widget')
              .invokeMethod<void>('showPomodoroTransition',
                  {'isChinese': chinese(), 'isBreak': snapshot.resting});
        }
      } on PlatformException {
        if (captured == _owner) noticeStatus = 'unavailable';
      } on MissingPluginException {
        if (captured == _owner) noticeStatus = 'unavailable';
      } finally {
        if (!_disposed && captured == _owner) notifyListeners();
      }
    });
    return _nativeQueue;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _advance();
      unawaited(_sync(force: true));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
