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
      this.coveredMs,
      this.focusWindow,
      this.onRecorded,
      String? platform,
      int Function()? now})
      : platform = platform ?? AppConfig.deviceType,
        _now = now ?? (() => DateTime.now().millisecondsSinceEpoch) {
    WidgetsBinding.instance.addObserver(this);
  }
  final OfflineStore store;
  final String? Function() owner;
  final bool Function() chinese;
  final int Function(int start, int end)? coveredMs;
  final List<int> Function()? focusWindow;
  final Future<void> Function(String owner)? onRecorded;
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
  Completer<void>? _writing;

  PomodoroTimer _at(int now, [PomodoroTimer? value]) =>
      (value ?? timer).advance(now, coveredMs: coveredMs);

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
    var recoveredCompletion = false;
    try {
      final restored =
          next == null ? const PomodoroTimer() : await store.loadPomodoro(next);
      if (_disposed || generation != _generation || next != owner()) return;
      timer = _at(_now(), restored);
      recoveredCompletion = restored.running && timer.awaitingNext;
      if (next != null) await store.savePomodoro(next, timer);
      _schedule();
      if (next != null) await _report(next);
    } catch (_) {
      if (generation == _generation) {
        error =
            chinese() ? '番茄计时恢复失败，请重试。' : 'Could not restore the timer. Retry.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
        await _sync(force: true, transition: recoveredCompletion);
      }
    }
  }

  Future<void> start(int study, int rest, bool notices) async {
    if (study < 1 || study > 1440 || rest < 0 || rest > 1440) {
      throw ArgumentError('Invalid durations');
    }
    if (timer.active) return;
    final now = _now();
    final window = focusWindow?.call() ?? [0, 0];
    await _save(
        PomodoroTimer(
            id: '$now-${Random.secure().nextInt(1 << 30)}',
            active: true,
            studyMinutes: study,
            breakMinutes: rest,
            coveredFromMs: window[0],
            coveredUntilMs: window[1],
            referenceMs: now,
            notices: notices),
        requestPermission: notices);
  }

  Future<void> togglePause() async {
    if (!timer.active || timer.awaitingNext) return;
    final now = _now();
    final current = _at(now);
    await _save(
        current.awaitingNext
            ? current
            : current.copy(paused: !current.paused, referenceMs: now),
        transition: current.awaitingNext);
  }

  Future<void> startNextStage() async {
    await checkpoint();
    if (!timer.active || !timer.awaitingNext) return;
    await _save(timer.beginNextStage(_now()));
  }

  /// Also called before changing the ordinary focus clock, preserving overlap.
  Future<void> checkpoint() async {
    if (busy) await _writing?.future;
    if (!timer.active || _disposed) return;
    final next = _at(_now());
    await _save(next, transition: !timer.awaitingNext && next.awaitingNext);
  }

  Future<void> updateFocusCoverage() async {
    if (!timer.active || focusWindow == null || _disposed) return;
    if (busy) await _writing?.future;
    if (!timer.active || _disposed) return;
    final window = focusWindow!();
    if (timer.coveredFromMs == window[0] && timer.coveredUntilMs == window[1]) {
      return;
    }
    final current = timer;
    int overlap(int from, int until, int start, int end) =>
        (min(until, end) - max(from, start)).clamp(0, until - from).toInt();
    final next = current.advance(_now(),
        coveredMs: coveredMs ??
            (from, until) {
              final old = overlap(
                  from, until, current.coveredFromMs, current.coveredUntilMs);
              final added = overlap(from, until, window[0], window[1]);
              final both = overlap(
                  from,
                  until,
                  max(current.coveredFromMs, window[0]),
                  min(current.coveredUntilMs, window[1]));
              return old + added - both;
            });
    await _save(next.copy(coveredFromMs: window[0], coveredUntilMs: window[1]),
        transition: !current.awaitingNext && next.awaitingNext);
  }

  Future<void> _report(String captured) async {
    try {
      await onRecorded?.call(captured);
    } catch (_) {
      if (!_disposed && captured == _owner) {
        error = chinese()
            ? '学习记录已保存在本机，联网后重试同步。'
            : 'Study is saved on this device. Reconnect and retry syncing.';
      }
    }
  }

  Future<void> retryRecords() async {
    final captured = _owner;
    if (captured == null || busy) return;
    error = null;
    await _report(captured);
    if (!_disposed) notifyListeners();
  }

  Future<void> finish() async {
    if (!timer.active) return;
    await checkpoint();
    await _save(timer.copy(active: false, paused: false));
  }

  Future<void> _save(PomodoroTimer next,
      {bool requestPermission = false, bool transition = false}) async {
    if (busy || _owner == null || _owner != owner()) return;
    final captured = _owner!;
    final generation = _generation;
    busy = true;
    final writing = Completer<void>();
    _writing = writing;
    error = null;
    notifyListeners();
    try {
      await store.savePomodoro(captured, next);
      if (_disposed || generation != _generation || captured != owner()) return;
      timer = next;
      _schedule();
      await _sync(
          force: true,
          requestPermission: requestPermission,
          transition: transition);
      await _report(captured);
    } catch (_) {
      if (!_disposed && generation == _generation) {
        error =
            chinese() ? '保存番茄计时失败，请重试。' : 'Could not save the timer. Retry.';
      }
    } finally {
      writing.complete();
      if (identical(_writing, writing)) _writing = null;
      if (!_disposed && generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void _schedule() {
    _ticker?.cancel();
    if (timer.running) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _advance());
    }
  }

  void _advance() {
    if (_disposed || busy || _owner != owner()) return;
    final old = timer;
    timer = _at(_now());
    notifyListeners();
    if (!old.awaitingNext && timer.awaitingNext) {
      _ticker?.cancel();
      unawaited(_save(timer, transition: true));
    }
  }

  Future<void> refreshNotices() async {
    if (busy) await _writing?.future;
    await _sync(force: true);
  }

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
      'stage': snapshot.stage,
      'cycle': snapshot.cycle,
      'awaitingNext': snapshot.awaitingNext,
      'isChinese': chinese()
    };
    final signature =
        '$captured/${snapshot.id}/$active/${snapshot.paused}/${snapshot.awaitingNext}/${snapshot.referenceMs - snapshot.elapsedMs}/${snapshot.stage}/${snapshot.cycle}/${chinese()}';
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
                  {'isChinese': chinese(), 'isBreak': !snapshot.resting});
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
      unawaited(retryRecords());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(checkpoint());
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
