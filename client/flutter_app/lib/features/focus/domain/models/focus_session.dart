class FocusSession {
  const FocusSession({
    required this.sessionId,
    required this.active,
    this.paused = false,
    required this.taskName,
    required this.stageName,
    required this.startTime,
    required this.plannedEndTime,
    required this.actualEndTime,
    required this.plannedMinutes,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.bindPomodoro,
    required this.pomodoroStudyMinutes,
    required this.pomodoroBreakMinutes,
    required this.currentCycleNo,
    required this.completedPomodoroCount,
    required this.stageRemainingSeconds,
    required this.referenceTime,
    this.pomodoroElapsedOffsetSeconds = 0,
    this.pomodoroCompletedBaseCount = 0,
  });

  final int sessionId;
  final bool active;
  final bool paused;
  final String taskName;
  final String stageName;
  final String startTime;
  final String plannedEndTime;
  final String actualEndTime;
  final int plannedMinutes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool bindPomodoro;
  final int pomodoroStudyMinutes;
  final int pomodoroBreakMinutes;
  final int currentCycleNo;
  final int completedPomodoroCount;
  final int stageRemainingSeconds;
  final DateTime referenceTime;
  final int pomodoroElapsedOffsetSeconds;
  final int pomodoroCompletedBaseCount;

  factory FocusSession.empty() {
    return FocusSession(
      sessionId: 0,
      active: false,
      paused: false,
      taskName: '',
      stageName: 'idle',
      startTime: '',
      plannedEndTime: '',
      actualEndTime: '',
      plannedMinutes: 0,
      elapsedSeconds: 0,
      remainingSeconds: 0,
      bindPomodoro: false,
      pomodoroStudyMinutes: 0,
      pomodoroBreakMinutes: 0,
      currentCycleNo: 0,
      completedPomodoroCount: 0,
      stageRemainingSeconds: 0,
      referenceTime: DateTime.now(),
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    final active = json['active'] == true;
    final elapsed = _toInt(json['elapsedSeconds']);
    final offset = _toInt(json['pomodoroElapsedOffsetSeconds']);
    final base = _toInt(json['pomodoroCompletedBaseCount']);
    final stage = _resolveStageState(
      bindPomodoro: json['bindPomodoro'] == true,
      elapsedSeconds: (elapsed - offset).clamp(0, elapsed),
      remainingSeconds: _toInt(json['remainingSeconds']),
      pomodoroStudyMinutes: _toInt(json['pomodoroStudyMinutes']),
      pomodoroBreakMinutes: _toInt(json['pomodoroBreakMinutes']),
    );
    return FocusSession(
      sessionId: _toInt(json['sessionId']),
      active: json['active'] == true,
      paused: json['paused'] == true,
      taskName: '${json['taskName'] ?? ''}',
      stageName: active ? stage.stageName : '${json['stageName'] ?? 'idle'}',
      startTime: '${json['startTime'] ?? ''}',
      plannedEndTime: '${json['plannedEndTime'] ?? ''}',
      actualEndTime: '${json['actualEndTime'] ?? ''}',
      plannedMinutes: _toInt(json['plannedMinutes']),
      elapsedSeconds: _toInt(json['elapsedSeconds']),
      remainingSeconds: _toInt(json['remainingSeconds']),
      bindPomodoro: json['bindPomodoro'] == true,
      pomodoroStudyMinutes: _toInt(json['pomodoroStudyMinutes']),
      pomodoroBreakMinutes: _toInt(json['pomodoroBreakMinutes']),
      currentCycleNo:
          active ? stage.currentCycleNo : _toInt(json['currentCycleNo']),
      completedPomodoroCount: active
          ? base + stage.completedPomodoroCount
          : _toInt(json['completedPomodoroCount']),
      stageRemainingSeconds: active
          ? stage.stageRemainingSeconds
          : _toInt(json['stageRemainingSeconds']),
      referenceTime: DateTime.now(),
      pomodoroElapsedOffsetSeconds: offset,
      pomodoroCompletedBaseCount: base,
    );
  }

  FocusSession tick() {
    return advanceTo(referenceTime.add(const Duration(seconds: 1)));
  }

  /// Catch up after background suspension without counting paused time.
  FocusSession advanceTo(DateTime now) {
    if (!active || paused) {
      return this;
    }
    final delta = now.difference(referenceTime).inSeconds;
    if (delta <= 0 && remainingSeconds > 0) return this;
    final consumed = delta.clamp(0, remainingSeconds);
    final nextRemainingSeconds = remainingSeconds - consumed;
    final nextElapsedSeconds = elapsedSeconds + consumed;
    final nextStageState = _resolveStageState(
      bindPomodoro: bindPomodoro,
      elapsedSeconds: (nextElapsedSeconds - pomodoroElapsedOffsetSeconds)
          .clamp(0, nextElapsedSeconds),
      remainingSeconds: nextRemainingSeconds,
      pomodoroStudyMinutes: pomodoroStudyMinutes,
      pomodoroBreakMinutes: pomodoroBreakMinutes,
    );
    return FocusSession(
      sessionId: sessionId,
      active: nextRemainingSeconds > 0,
      paused: false,
      taskName: taskName,
      stageName:
          nextRemainingSeconds > 0 ? nextStageState.stageName : 'finished',
      startTime: startTime,
      plannedEndTime: plannedEndTime,
      actualEndTime: actualEndTime,
      plannedMinutes: plannedMinutes,
      elapsedSeconds: nextElapsedSeconds,
      remainingSeconds: nextRemainingSeconds,
      bindPomodoro: bindPomodoro,
      pomodoroStudyMinutes: pomodoroStudyMinutes,
      pomodoroBreakMinutes: pomodoroBreakMinutes,
      currentCycleNo: nextRemainingSeconds > 0
          ? nextStageState.currentCycleNo
          : currentCycleNo,
      completedPomodoroCount:
          pomodoroCompletedBaseCount + nextStageState.completedPomodoroCount,
      stageRemainingSeconds:
          nextRemainingSeconds > 0 ? nextStageState.stageRemainingSeconds : 0,
      referenceTime: referenceTime.add(Duration(seconds: consumed)),
      pomodoroElapsedOffsetSeconds: pomodoroElapsedOffsetSeconds,
      pomodoroCompletedBaseCount: pomodoroCompletedBaseCount,
    );
  }

  String get stageLabel {
    if (paused) {
      return 'Paused';
    }
    switch (stageName) {
      case 'study':
        return 'Studying';
      case 'break':
        return 'Break';
      case 'finished':
        return 'Finished';
      default:
        return 'Idle';
    }
  }

  String get remainingLabel => formatDuration(remainingSeconds);

  String get elapsedLabel => formatDuration(elapsedSeconds);

  String get stageRemainingLabel => formatDuration(stageRemainingSeconds);

  String get plannedDurationLabel => formatMinutes(plannedMinutes);

  String get endTimeLabel {
    final time = DateTime.tryParse(plannedEndTime);
    if (time == null) {
      return '--:--';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatMinutes(int minutes) {
    if (minutes <= 0) {
      return '0 min';
    }
    final hours = minutes ~/ 60;
    final remainMinutes = minutes % 60;
    if (hours == 0) {
      return '$remainMinutes min';
    }
    if (remainMinutes == 0) {
      return '$hours h';
    }
    return '$hours h $remainMinutes min';
  }

  static String formatDuration(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final remainSeconds = safeSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainSeconds.toString().padLeft(2, '0')}';
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }

  static _StageState _resolveStageState({
    required bool bindPomodoro,
    required int elapsedSeconds,
    required int remainingSeconds,
    required int pomodoroStudyMinutes,
    required int pomodoroBreakMinutes,
  }) {
    if (!bindPomodoro || pomodoroStudyMinutes <= 0) {
      return _StageState(
        stageName: 'study',
        currentCycleNo: 1,
        completedPomodoroCount: 0,
        stageRemainingSeconds: remainingSeconds,
      );
    }

    final studySeconds = pomodoroStudyMinutes * 60;
    final breakSeconds = pomodoroBreakMinutes * 60;
    if (breakSeconds <= 0) {
      final completedCount = elapsedSeconds ~/ studySeconds;
      final currentCycleNo = completedCount + 1;
      final slotOffset = elapsedSeconds % studySeconds;
      final stageRemainingSeconds =
          slotOffset == 0 ? studySeconds : studySeconds - slotOffset;
      return _StageState(
        stageName: 'study',
        currentCycleNo: currentCycleNo,
        completedPomodoroCount: completedCount,
        stageRemainingSeconds: stageRemainingSeconds < remainingSeconds
            ? stageRemainingSeconds
            : remainingSeconds,
      );
    }

    final cycleSeconds = studySeconds + breakSeconds;
    final cycleIndex = elapsedSeconds ~/ cycleSeconds;
    final cyclePosition = elapsedSeconds % cycleSeconds;
    if (cyclePosition < studySeconds) {
      final stageRemainingSeconds = studySeconds - cyclePosition;
      return _StageState(
        stageName: 'study',
        currentCycleNo: cycleIndex + 1,
        completedPomodoroCount: cycleIndex,
        stageRemainingSeconds: stageRemainingSeconds < remainingSeconds
            ? stageRemainingSeconds
            : remainingSeconds,
      );
    }

    final stageRemainingSeconds = cycleSeconds - cyclePosition;
    return _StageState(
      stageName: 'break',
      currentCycleNo: cycleIndex + 1,
      completedPomodoroCount: cycleIndex + 1,
      stageRemainingSeconds: stageRemainingSeconds < remainingSeconds
          ? stageRemainingSeconds
          : remainingSeconds,
    );
  }
}

class _StageState {
  const _StageState({
    required this.stageName,
    required this.currentCycleNo,
    required this.completedPomodoroCount,
    required this.stageRemainingSeconds,
  });

  final String stageName;
  final int currentCycleNo;
  final int completedPomodoroCount;
  final int stageRemainingSeconds;
}
