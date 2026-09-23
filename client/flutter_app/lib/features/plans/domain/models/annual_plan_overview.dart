import 'month_plan_overview.dart';

class AnnualPlanOverview {
  const AnnualPlanOverview({
    required this.year,
    required this.months,
    required this.segments,
  });

  final int year;
  final List<AnnualMonthSummary> months;
  final List<AnnualPlanSegment> segments;

  factory AnnualPlanOverview.empty([int? year]) {
    final resolvedYear = year ?? DateTime.now().year;
    return AnnualPlanOverview(
      year: resolvedYear,
      months: List.generate(
        12,
        (index) => AnnualMonthSummary.empty(index + 1),
      ),
      segments: const [],
    );
  }

  factory AnnualPlanOverview.fromJson(Map<String, dynamic> json) {
    final resolvedYear = _toInt(json['year'], fallback: DateTime.now().year);
    final monthJson = json['months'] as List<dynamic>? ?? const [];
    final parsedMonths = monthJson
        .whereType<Map<String, dynamic>>()
        .map(AnnualMonthSummary.fromJson)
        .toList();
    final byMonth = {for (final month in parsedMonths) month.month: month};
    final segmentJson = json['segments'] as List<dynamic>? ?? const [];
    return AnnualPlanOverview(
      year: resolvedYear,
      months: List.generate(
        12,
        (index) => byMonth[index + 1] ?? AnnualMonthSummary.empty(index + 1),
      ),
      segments: segmentJson
          .whereType<Map<String, dynamic>>()
          .map(AnnualPlanSegment.fromJson)
          .toList(),
    );
  }

  AnnualMonthSummary monthAt(int month) => months.firstWhere(
        (item) => item.month == month,
        orElse: () => AnnualMonthSummary.empty(month),
      );

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class AnnualMonthSummary {
  const AnnualMonthSummary({
    required this.month,
    required this.plannedDayCount,
    required this.completedTaskCount,
    required this.totalTaskCount,
    required this.totalPlannedMinutes,
  });

  final int month;
  final int plannedDayCount;
  final int completedTaskCount;
  final int totalTaskCount;
  final int totalPlannedMinutes;

  factory AnnualMonthSummary.empty(int month) => AnnualMonthSummary(
        month: month,
        plannedDayCount: 0,
        completedTaskCount: 0,
        totalTaskCount: 0,
        totalPlannedMinutes: 0,
      );

  factory AnnualMonthSummary.fromJson(Map<String, dynamic> json) =>
      AnnualMonthSummary(
        month: AnnualPlanOverview._toInt(json['month']),
        plannedDayCount: AnnualPlanOverview._toInt(json['plannedDayCount']),
        completedTaskCount:
            AnnualPlanOverview._toInt(json['completedTaskCount']),
        totalTaskCount: AnnualPlanOverview._toInt(json['totalTaskCount']),
        totalPlannedMinutes:
            AnnualPlanOverview._toInt(json['totalPlannedMinutes']),
      );

  double get completionRatio =>
      totalTaskCount <= 0 ? 0 : completedTaskCount / totalTaskCount;

  String get plannedDurationLabel =>
      FocusDurationLabel.format(totalPlannedMinutes);
}

class AnnualPlanSegment {
  const AnnualPlanSegment({
    required this.id,
    required this.clientEntityId,
    required this.year,
    required this.title,
    required this.startMonth,
    required this.endMonth,
    required this.colorKey,
    required this.sortOrder,
    required this.note,
    this.progressPercent = 0,
    required this.revision,
    required this.updateTime,
    required this.subtasks,
  });

  final String id;
  final String clientEntityId;
  final int year;
  final String title;
  final int startMonth;
  final int endMonth;
  final String colorKey;
  final int sortOrder;
  final String note;
  final int progressPercent;
  final int revision;
  final String updateTime;
  final List<AnnualPlanSubtask> subtasks;

  factory AnnualPlanSegment.fromJson(Map<String, dynamic> json) {
    return AnnualPlanSegment(
      id: '${json['id'] ?? json['clientEntityId'] ?? ''}',
      clientEntityId: '${json['clientEntityId'] ?? json['id'] ?? ''}',
      year: AnnualPlanOverview._toInt(json['year']),
      title: '${json['title'] ?? ''}',
      startMonth: AnnualPlanOverview._toInt(json['startMonth'], fallback: 1),
      endMonth: AnnualPlanOverview._toInt(json['endMonth'], fallback: 1),
      colorKey: '${json['colorKey'] ?? 'accent'}',
      sortOrder: AnnualPlanOverview._toInt(json['sortOrder']),
      note: '${json['note'] ?? ''}',
      progressPercent: AnnualPlanOverview._toInt(json['progressPercent'])
          .clamp(0, 100)
          .toInt(),
      revision: AnnualPlanOverview._toInt(json['revision']),
      updateTime: '${json['updateTime'] ?? ''}',
      subtasks: (json['subtasks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AnnualPlanSubtask.fromJson)
          .toList(),
    );
  }

  AnnualPlanSegment copyWith({
    String? id,
    String? clientEntityId,
    int? year,
    String? title,
    int? startMonth,
    int? endMonth,
    String? colorKey,
    int? sortOrder,
    String? note,
    int? progressPercent,
    int? revision,
    String? updateTime,
    List<AnnualPlanSubtask>? subtasks,
  }) {
    return AnnualPlanSegment(
      id: id ?? this.id,
      clientEntityId: clientEntityId ?? this.clientEntityId,
      year: year ?? this.year,
      title: title ?? this.title,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      colorKey: colorKey ?? this.colorKey,
      sortOrder: sortOrder ?? this.sortOrder,
      note: note ?? this.note,
      progressPercent: progressPercent ?? this.progressPercent,
      revision: revision ?? this.revision,
      updateTime: updateTime ?? this.updateTime,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  int get completedSubtaskCount =>
      subtasks.where((subtask) => subtask.completed).length;

  double get completionRatio =>
      subtasks.isEmpty ? 0 : completedSubtaskCount / subtasks.length;

  bool get isCompleted => progressPercent == 100;

  AnnualPlanSegment adjustProgress(int delta) => copyWith(
        progressPercent: (progressPercent + delta).clamp(0, 100).toInt(),
      );

  Map<String, dynamic> toSaveJson() => {
        'clientEntityId': clientEntityId,
        'year': year,
        'title': title,
        'startMonth': startMonth,
        'endMonth': endMonth,
        'colorKey': colorKey,
        'sortOrder': sortOrder,
        'note': note,
        'progressPercent': progressPercent,
        'revision': revision,
        'subtasks': subtasks.map((subtask) => subtask.toSaveJson()).toList(),
      };
}

class AnnualPlanSubtask {
  const AnnualPlanSubtask({
    required this.id,
    required this.title,
    required this.detail,
    required this.completed,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String detail;
  final bool completed;
  final int sortOrder;

  factory AnnualPlanSubtask.fromJson(Map<String, dynamic> json) {
    final completedValue = json['completed'];
    return AnnualPlanSubtask(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      detail: '${json['detail'] ?? ''}',
      completed: completedValue == true ||
          completedValue == 1 ||
          '$completedValue' == '1',
      sortOrder: AnnualPlanOverview._toInt(json['sortOrder']),
    );
  }

  AnnualPlanSubtask copyWith({
    String? id,
    String? title,
    String? detail,
    bool? completed,
    int? sortOrder,
  }) {
    return AnnualPlanSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      completed: completed ?? this.completed,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toSaveJson() => {
        'title': title,
        'detail': detail,
        'completed': completed,
        'sortOrder': sortOrder,
      };
}

enum PlanApplyStrategy { overwrite, skip }
