class WeekPlanOverview {
  const WeekPlanOverview({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.days,
  });

  final String weekStartDate;
  final String weekEndDate;
  final List<WeekPlanDay> days;

  factory WeekPlanOverview.empty() {
    return const WeekPlanOverview(
      weekStartDate: '',
      weekEndDate: '',
      days: [],
    );
  }

  factory WeekPlanOverview.fromJson(Map<String, dynamic> json) {
    final dayJson = json['days'] as List<dynamic>? ?? const [];
    final days = dayJson
        .whereType<Map<String, dynamic>>()
        .map(WeekPlanDay.fromJson)
        .toList();

    return WeekPlanOverview(
      weekStartDate: '${json['weekStartDate'] ?? ''}',
      weekEndDate: '${json['weekEndDate'] ?? ''}',
      days: days,
    );
  }
}

class WeekPlanDay {
  const WeekPlanDay({
    required this.planDate,
    required this.weekdayLabel,
    required this.today,
    required this.hasPlan,
    required this.planName,
    required this.completedCount,
    required this.totalCount,
    required this.totalPlannedMinutes,
    required this.completedPlannedMinutes,
  });

  final String planDate;
  final String weekdayLabel;
  final bool today;
  final bool hasPlan;
  final String planName;
  final int completedCount;
  final int totalCount;
  final int totalPlannedMinutes;
  final int completedPlannedMinutes;

  factory WeekPlanDay.fromJson(Map<String, dynamic> json) {
    return WeekPlanDay(
      planDate: '${json['planDate'] ?? ''}',
      weekdayLabel: '${json['weekdayLabel'] ?? ''}',
      today: json['today'] == true,
      hasPlan: json['hasPlan'] == true,
      planName: '${json['planName'] ?? 'No plan'}',
      completedCount: _toInt(json['completedCount']),
      totalCount: _toInt(json['totalCount']),
      totalPlannedMinutes: _toInt(json['totalPlannedMinutes']),
      completedPlannedMinutes: _toInt(json['completedPlannedMinutes']),
    );
  }

  double get completionRatio {
    if (totalCount <= 0) {
      return 0;
    }
    return completedCount / totalCount;
  }

  String get plannedDurationLabel {
    if (totalPlannedMinutes <= 0) {
      return '0 min';
    }
    final hours = totalPlannedMinutes ~/ 60;
    final minutes = totalPlannedMinutes % 60;
    if (hours == 0) {
      return '$minutes min';
    }
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }
}
