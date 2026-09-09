import 'today_plan.dart';

class MonthPlanOverview {
  const MonthPlanOverview({
    required this.month,
    required this.days,
  });

  final String month;
  final List<MonthPlanDay> days;

  factory MonthPlanOverview.empty([String? month]) {
    final now = DateTime.now();
    return MonthPlanOverview(
      month: month ?? formatMonth(now),
      days: const [],
    );
  }

  factory MonthPlanOverview.fromJson(Map<String, dynamic> json) {
    final dayJson = json['days'] as List<dynamic>? ?? const [];
    return MonthPlanOverview(
      month: '${json['month'] ?? formatMonth(DateTime.now())}',
      days: dayJson
          .whereType<Map<String, dynamic>>()
          .map(MonthPlanDay.fromJson)
          .toList(),
    );
  }

  MonthPlanDay dayFor(String date) {
    return days.firstWhere(
      (day) => day.planDate == date,
      orElse: () => MonthPlanDay.empty(date),
    );
  }

  int get plannedDayCount => days.where((day) => day.hasPlan).length;

  int get totalTaskCount => days.fold(0, (sum, day) => sum + day.totalCount);

  int get completedTaskCount =>
      days.fold(0, (sum, day) => sum + day.completedCount);

  static String formatMonth(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
}

class MonthPlanDay {
  const MonthPlanDay({
    required this.planDate,
    required this.hasPlan,
    required this.planName,
    required this.completedCount,
    required this.totalCount,
    required this.totalPlannedMinutes,
    required this.templateApplied,
  });

  final String planDate;
  final bool hasPlan;
  final String planName;
  final int completedCount;
  final int totalCount;
  final int totalPlannedMinutes;
  final bool templateApplied;

  factory MonthPlanDay.empty(String planDate) {
    return MonthPlanDay(
      planDate: planDate,
      hasPlan: false,
      planName: '',
      completedCount: 0,
      totalCount: 0,
      totalPlannedMinutes: 0,
      templateApplied: false,
    );
  }

  factory MonthPlanDay.fromJson(Map<String, dynamic> json) {
    return MonthPlanDay(
      planDate: '${json['planDate'] ?? ''}',
      hasPlan: _toBool(json['hasPlan']),
      planName: '${json['planName'] ?? ''}',
      completedCount: _toInt(json['completedCount']),
      totalCount: _toInt(json['totalCount']),
      totalPlannedMinutes: _toInt(json['totalPlannedMinutes']),
      templateApplied: _toBool(json['templateApplied']),
    );
  }

  factory MonthPlanDay.fromPlan(TodayPlan plan,
      {bool templateApplied = false}) {
    return MonthPlanDay(
      planDate: plan.planDate,
      hasPlan: plan.hasItems,
      planName: plan.planName,
      completedCount: plan.completedCount,
      totalCount: plan.totalCount,
      totalPlannedMinutes: plan.totalPlannedMinutes,
      templateApplied: templateApplied,
    );
  }

  double get completionRatio =>
      totalCount <= 0 ? 0 : completedCount / totalCount;

  String get plannedDurationLabel =>
      FocusDurationLabel.format(totalPlannedMinutes);

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }

  static bool _toBool(dynamic value) =>
      value == true || value == 1 || '$value'.toLowerCase() == 'true';
}

class FocusDurationLabel {
  const FocusDurationLabel._();

  static String format(int minutes) {
    if (minutes <= 0) {
      return '0 min';
    }
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) {
      return '$remainder min';
    }
    if (remainder == 0) {
      return '$hours h';
    }
    return '$hours h $remainder min';
  }
}
