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
    required this.revision,
    required this.updateTime,
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
  final int revision;
  final String updateTime;

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
      revision: AnnualPlanOverview._toInt(json['revision']),
      updateTime: '${json['updateTime'] ?? ''}',
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
    int? revision,
    String? updateTime,
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
      revision: revision ?? this.revision,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toSaveJson() => {
        'clientEntityId': clientEntityId,
        'year': year,
        'title': title,
        'startMonth': startMonth,
        'endMonth': endMonth,
        'colorKey': colorKey,
        'sortOrder': sortOrder,
        'note': note,
        'revision': revision,
      };
}

enum PlanApplyStrategy { overwrite, skip }
