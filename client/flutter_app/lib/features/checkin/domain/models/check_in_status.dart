class CheckInStatus {
  const CheckInStatus({
    required this.checkInDate,
    required this.checkedInToday,
    required this.canCheckInToday,
    required this.todayPlanCompleted,
    required this.todayPlanCompletedCount,
    required this.todayPlanTotalCount,
    required this.consecutiveDays,
    required this.totalDays,
    required this.totalStudyDurationMinutes,
    required this.todayFailedAttempts,
    required this.latestFailureReason,
    required this.lastCheckInTime,
    required this.lastFailureTime,
  });

  final String checkInDate;
  final bool checkedInToday;
  final bool canCheckInToday;
  final bool todayPlanCompleted;
  final int todayPlanCompletedCount;
  final int todayPlanTotalCount;
  final int consecutiveDays;
  final int totalDays;
  final int totalStudyDurationMinutes;
  final int todayFailedAttempts;
  final String latestFailureReason;
  final String lastCheckInTime;
  final String lastFailureTime;

  factory CheckInStatus.empty() {
    return CheckInStatus(
      checkInDate: _todayDateString(),
      checkedInToday: false,
      canCheckInToday: false,
      todayPlanCompleted: false,
      todayPlanCompletedCount: 0,
      todayPlanTotalCount: 0,
      consecutiveDays: 0,
      totalDays: 0,
      totalStudyDurationMinutes: 0,
      todayFailedAttempts: 0,
      latestFailureReason: '',
      lastCheckInTime: '',
      lastFailureTime: '',
    );
  }

  factory CheckInStatus.fromJson(Map<String, dynamic> json) {
    return CheckInStatus(
      checkInDate: '${json['checkInDate'] ?? _todayDateString()}',
      checkedInToday: _toBool(json['checkedInToday']),
      canCheckInToday: _toBool(json['canCheckInToday']),
      todayPlanCompleted: _toBool(json['todayPlanCompleted']),
      todayPlanCompletedCount: _toInt(json['todayPlanCompletedCount']),
      todayPlanTotalCount: _toInt(json['todayPlanTotalCount']),
      consecutiveDays: _toInt(json['consecutiveDays']),
      totalDays: _toInt(json['totalDays']),
      totalStudyDurationMinutes: _toInt(json['totalStudyDurationMinutes']),
      todayFailedAttempts: _toInt(json['todayFailedAttempts']),
      latestFailureReason: '${json['latestFailureReason'] ?? ''}',
      lastCheckInTime: '${json['lastCheckInTime'] ?? ''}',
      lastFailureTime: '${json['lastFailureTime'] ?? ''}',
    );
  }

  String get headline {
    if (checkedInToday) {
      return 'Checked in today';
    }
    if (todayPlanCompleted) {
      return 'Ready for check-in';
    }
    if (todayPlanTotalCount <= 0) {
      return 'No plan yet';
    }
    return 'Plan still in progress';
  }

  String get description {
    if (checkedInToday) {
      return lastCheckInTime.isEmpty
          ? 'Today is already counted into your streak.'
          : 'Completed at ${_friendlyDateTime(lastCheckInTime)}.';
    }
    if (todayPlanCompleted) {
      return 'Today plan is done. Tap once to record the day.';
    }
    if (todayPlanTotalCount <= 0) {
      return 'Create today tasks first, then finish them before check-in.';
    }
    return 'Complete all today tasks before the streak can continue.';
  }

  String get actionLabel {
    if (checkedInToday) {
      return 'Completed';
    }
    if (todayPlanCompleted) {
      return 'Check in now';
    }
    return 'Try check-in';
  }

  String get planProgressLabel => '$todayPlanCompletedCount/$todayPlanTotalCount';

  String get totalStudyDurationLabel =>
      _formatMinutes(totalStudyDurationMinutes);

  bool get hasFailureHint =>
      todayFailedAttempts > 0 && latestFailureReason.trim().isNotEmpty;

  String get failureSummary {
    if (!hasFailureHint) {
      return '';
    }
    final attempts = todayFailedAttempts == 1
        ? '1 failed attempt today'
        : '$todayFailedAttempts failed attempts today';
    return '$attempts | $latestFailureReason';
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = '$value'.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }

  static String _formatMinutes(int minutes) {
    final normalized = minutes < 0 ? 0 : minutes;
    final hours = normalized ~/ 60;
    final remainingMinutes = normalized % 60;
    if (hours == 0) {
      return '$remainingMinutes min';
    }
    if (remainingMinutes == 0) {
      return '$hours h';
    }
    return '$hours h $remainingMinutes min';
  }

  static String _friendlyDateTime(String raw) {
    final dateTime = DateTime.tryParse(raw);
    if (dateTime == null) {
      return raw;
    }
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  static String _todayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
