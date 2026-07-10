class StatsOverview {
  const StatsOverview({
    required this.rangeDays,
    required this.activePlanDays,
    required this.totalStudyDurationMinutes,
    required this.totalPomodoroCompleted,
    required this.totalCheckInDays,
    required this.totalFailedCheckInAttempts,
    required this.planCompletionRate,
    required this.checkInSuccessRate,
    required this.trend,
    required this.failures,
    required this.teammates,
  });

  final int rangeDays;
  final int activePlanDays;
  final int totalStudyDurationMinutes;
  final int totalPomodoroCompleted;
  final int totalCheckInDays;
  final int totalFailedCheckInAttempts;
  final int planCompletionRate;
  final int checkInSuccessRate;
  final List<StatsTrendPoint> trend;
  final List<StatsFailureRecord> failures;
  final List<TeammateStats> teammates;

  factory StatsOverview.empty([int rangeDays = 7]) {
    return StatsOverview(
      rangeDays: rangeDays,
      activePlanDays: 0,
      totalStudyDurationMinutes: 0,
      totalPomodoroCompleted: 0,
      totalCheckInDays: 0,
      totalFailedCheckInAttempts: 0,
      planCompletionRate: 0,
      checkInSuccessRate: 0,
      trend: const [],
      failures: const [],
      teammates: const [],
    );
  }

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    final trendJson = json['trend'] as List<dynamic>? ?? const [];
    final failuresJson = json['failures'] as List<dynamic>? ?? const [];
    final teammatesJson = json['teammates'] as List<dynamic>? ?? const [];
    return StatsOverview(
      rangeDays: _toInt(json['rangeDays'], fallback: 7),
      activePlanDays: _toInt(json['activePlanDays']),
      totalStudyDurationMinutes: _toInt(json['totalStudyDurationMinutes']),
      totalPomodoroCompleted: _toInt(json['totalPomodoroCompleted']),
      totalCheckInDays: _toInt(json['totalCheckInDays']),
      totalFailedCheckInAttempts: _toInt(json['totalFailedCheckInAttempts']),
      planCompletionRate: _toInt(json['planCompletionRate']),
      checkInSuccessRate: _toInt(json['checkInSuccessRate']),
      trend: trendJson
          .whereType<Map<String, dynamic>>()
          .map(StatsTrendPoint.fromJson)
          .toList(),
      failures: failuresJson
          .whereType<Map<String, dynamic>>()
          .map(StatsFailureRecord.fromJson)
          .toList(),
      teammates: teammatesJson
          .whereType<Map<String, dynamic>>()
          .map(TeammateStats.fromJson)
          .toList(),
    );
  }

  String get totalStudyDurationLabel => _formatMinutes(totalStudyDurationMinutes);

  bool get hasTrendData => trend.isNotEmpty;

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
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
}

class StatsFailureRecord {
  const StatsFailureRecord({
    required this.date,
    required this.label,
    required this.attemptCount,
    required this.latestReason,
    required this.planCompletedCount,
    required this.planTotalCount,
    required this.studyDurationMinutes,
    required this.lastAttemptTime,
  });

  final String date;
  final String label;
  final int attemptCount;
  final String latestReason;
  final int planCompletedCount;
  final int planTotalCount;
  final int studyDurationMinutes;
  final String lastAttemptTime;

  factory StatsFailureRecord.fromJson(Map<String, dynamic> json) {
    return StatsFailureRecord(
      date: '${json['date'] ?? ''}',
      label: '${json['label'] ?? ''}',
      attemptCount: StatsOverview._toInt(json['attemptCount']),
      latestReason: '${json['latestReason'] ?? ''}',
      planCompletedCount: StatsOverview._toInt(json['planCompletedCount']),
      planTotalCount: StatsOverview._toInt(json['planTotalCount']),
      studyDurationMinutes: StatsOverview._toInt(json['studyDurationMinutes']),
      lastAttemptTime: '${json['lastAttemptTime'] ?? ''}',
    );
  }

  String get studyDurationLabel => StatsOverview._formatMinutes(studyDurationMinutes);

  String get planProgressLabel => '$planCompletedCount/$planTotalCount';
}

class StatsTrendPoint {
  const StatsTrendPoint({
    required this.date,
    required this.label,
    required this.hasPlan,
    required this.studyDurationMinutes,
    required this.pomodoroCompletedCount,
    required this.checkInSuccessCount,
    required this.failedCheckInAttempts,
    required this.planCompletedCount,
    required this.planTotalCount,
    required this.planCompletionRate,
    required this.checkInSuccessRate,
  });

  final String date;
  final String label;
  final bool hasPlan;
  final int studyDurationMinutes;
  final int pomodoroCompletedCount;
  final int checkInSuccessCount;
  final int failedCheckInAttempts;
  final int planCompletedCount;
  final int planTotalCount;
  final int planCompletionRate;
  final int checkInSuccessRate;

  factory StatsTrendPoint.fromJson(Map<String, dynamic> json) {
    return StatsTrendPoint(
      date: '${json['date'] ?? ''}',
      label: '${json['label'] ?? ''}',
      hasPlan: json['hasPlan'] == true || json['hasPlan'] == 1,
      studyDurationMinutes: StatsOverview._toInt(json['studyDurationMinutes']),
      pomodoroCompletedCount:
          StatsOverview._toInt(json['pomodoroCompletedCount']),
      checkInSuccessCount: StatsOverview._toInt(json['checkInSuccessCount']),
      failedCheckInAttempts:
          StatsOverview._toInt(json['failedCheckInAttempts']),
      planCompletedCount: StatsOverview._toInt(json['planCompletedCount']),
      planTotalCount: StatsOverview._toInt(json['planTotalCount']),
      planCompletionRate: StatsOverview._toInt(json['planCompletionRate']),
      checkInSuccessRate: StatsOverview._toInt(json['checkInSuccessRate']),
    );
  }
}

class TeammateStats {
  const TeammateStats({
    required this.teamId,
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.allowStudyView,
    required this.totalStudyDurationMinutes,
    required this.totalCheckInDays,
    required this.todayCompletedCount,
    required this.todayTotalCount,
    required this.todayStudyDurationMinutes,
    required this.activeStudy,
    required this.activeTaskName,
    required this.activeStageName,
    required this.reminderCountToday,
    required this.remindable,
  });

  final int teamId;
  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final bool allowStudyView;
  final int totalStudyDurationMinutes;
  final int totalCheckInDays;
  final int todayCompletedCount;
  final int todayTotalCount;
  final int todayStudyDurationMinutes;
  final bool activeStudy;
  final String activeTaskName;
  final String activeStageName;
  final int reminderCountToday;
  final bool remindable;

  factory TeammateStats.fromJson(Map<String, dynamic> json) {
    return TeammateStats(
      teamId: StatsOverview._toInt(json['teamId']),
      userId: StatsOverview._toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      allowStudyView: json['allowStudyView'] == true || json['allowStudyView'] == 1,
      totalStudyDurationMinutes:
          StatsOverview._toInt(json['totalStudyDurationMinutes']),
      totalCheckInDays: StatsOverview._toInt(json['totalCheckInDays']),
      todayCompletedCount: StatsOverview._toInt(json['todayCompletedCount']),
      todayTotalCount: StatsOverview._toInt(json['todayTotalCount']),
      todayStudyDurationMinutes:
          StatsOverview._toInt(json['todayStudyDurationMinutes']),
      activeStudy: json['activeStudy'] == true || json['activeStudy'] == 1,
      activeTaskName: '${json['activeTaskName'] ?? ''}',
      activeStageName: '${json['activeStageName'] ?? ''}',
      reminderCountToday: StatsOverview._toInt(json['reminderCountToday']),
      remindable: json['remindable'] == true || json['remindable'] == 1,
    );
  }

  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (userNo.trim().isNotEmpty) {
      return userNo.trim();
    }
    return 'Teammate';
  }

  String get totalStudyDurationLabel =>
      StatsOverview._formatMinutes(totalStudyDurationMinutes);

  String get todayStudyDurationLabel =>
      StatsOverview._formatMinutes(todayStudyDurationMinutes);

  String get todayPlanProgressLabel => '$todayCompletedCount/$todayTotalCount';

  String get stageLabel {
    switch (activeStageName) {
      case 'study':
        return 'Studying';
      case 'break':
        return 'Break';
      case 'finished':
        return 'Finished';
      default:
        return activeStudy ? 'Studying' : 'Idle';
    }
  }
}
