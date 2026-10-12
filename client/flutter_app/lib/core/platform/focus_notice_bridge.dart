import 'dart:async';

import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

enum FocusNoticeStatus {
  available,
  permissionRequired,
  exactPermissionRequired,
  liveCountdownUnavailable,
  backgroundReminderUnavailable,
  backgroundAndLiveUnavailable,
  liveCountdownRightsRequired,
  backgroundAndLiveRightsRequired,
  unavailable,
}

/// Serialize native operations so an old start cannot overtake pause/logout.
class FocusNoticeBridge {
  FocusNoticeBridge({String? platform})
      : _platform = platform ?? AppConfig.deviceType;

  final String _platform;
  Future<void> _pending = Future.value();
  String? _signature;
  String? _completedKey;
  FocusNoticeStatus _status = FocusNoticeStatus.available;

  Future<FocusNoticeStatus> sync({
    required FocusSession session,
    required String? owner,
    required bool isChinese,
    bool completed = false,
    bool requestPermission = false,
    bool force = false,
  }) {
    final key = owner == null || session.sessionId <= 0
        ? ''
        : '$owner/${session.sessionId}';
    final active = owner != null && session.active;
    final deadline = session.referenceTime.millisecondsSinceEpoch +
        session.remainingSeconds * 1000;
    final pomodoroDeadline = session.referenceTime.millisecondsSinceEpoch +
        session.stageRemainingSeconds * 1000;
    final signature = '$key|$active|${session.paused}|$deadline|'
        '$completed|$isChinese|${session.bindPomodoro}|${session.pomodoroStudyMinutes}|${session.pomodoroBreakMinutes}|'
        '${session.stageName}|${session.currentCycleNo}|$pomodoroDeadline';
    if (!force && !requestPermission && signature == _signature) {
      return _pending.then((_) => _status);
    }
    _signature = signature;
    final result = Completer<FocusNoticeStatus>();
    _pending = _pending.then((_) async {
      try {
        if (_platform == 'windows') {
          if (completed && key.isNotEmpty && key != _completedKey) {
            await const MethodChannel('innocence/desktop_widget')
                .invokeMethod<void>('showFocusCompletion', {
              'isChinese': isChinese,
            });
            _completedKey = key;
          }
          _status = FocusNoticeStatus.available;
        } else if (_platform == 'android' || _platform == 'harmonyos') {
          const channel = MethodChannel('innocence/focus_notice');
          if (requestPermission) {
            await channel.invokeMethod<void>('requestPermission');
          }
          final status = await channel.invokeMethod<String>('sync', {
            'owner': owner ?? '',
            'key': key,
            'active': active,
            'paused': session.paused,
            'remainingSeconds': session.remainingSeconds,
            'deadlineMs': deadline,
            'completed': completed,
            'isChinese': isChinese,
            'bindPomodoro': session.bindPomodoro && active,
            'pomodoroStudyMinutes': session.pomodoroStudyMinutes,
            'pomodoroBreakMinutes': session.pomodoroBreakMinutes,
            'pomodoroStage': session.stageName,
            'pomodoroCycle': session.currentCycleNo,
            'pomodoroDeadlineMs': pomodoroDeadline,
            'pomodoroRemainingSeconds': session.stageRemainingSeconds,
          });
          _status = switch (status) {
            'available' => FocusNoticeStatus.available,
            'permissionRequired' => FocusNoticeStatus.permissionRequired,
            'exactPermissionRequired' =>
              FocusNoticeStatus.exactPermissionRequired,
            'liveCountdownUnavailable' =>
              FocusNoticeStatus.liveCountdownUnavailable,
            'backgroundReminderUnavailable' =>
              FocusNoticeStatus.backgroundReminderUnavailable,
            'backgroundAndLiveUnavailable' =>
              FocusNoticeStatus.backgroundAndLiveUnavailable,
            'liveCountdownRightsRequired' =>
              FocusNoticeStatus.liveCountdownRightsRequired,
            'backgroundAndLiveRightsRequired' =>
              FocusNoticeStatus.backgroundAndLiveRightsRequired,
            _ => FocusNoticeStatus.unavailable,
          };
        }
      } on PlatformException {
        _status = FocusNoticeStatus.unavailable;
      } on MissingPluginException {
        _status = FocusNoticeStatus.unavailable;
      }
      result.complete(_status);
    });
    return result.future;
  }

  Future<void> openSettings() => const MethodChannel('innocence/focus_notice')
      .invokeMethod<void>('openSettings');
}
