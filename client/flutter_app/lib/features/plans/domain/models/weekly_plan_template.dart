import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

class WeeklyPlanTemplate {
  const WeeklyPlanTemplate({
    required this.id,
    required this.templateName,
    required this.sourcePlanName,
    required this.itemCount,
    required this.totalPlannedMinutes,
    required this.items,
  });

  final int id;
  final String templateName;
  final String sourcePlanName;
  final int itemCount;
  final int totalPlannedMinutes;
  final List<TodayPlanItem> items;

  factory WeeklyPlanTemplate.fromJson(Map<String, dynamic> json) {
    final itemJson = json['items'] as List<dynamic>? ?? const [];
    final items = itemJson
        .whereType<Map<String, dynamic>>()
        .map(TodayPlanItem.fromJson)
        .toList();

    return WeeklyPlanTemplate(
      id: _toInt(json['id']),
      templateName: '${json['templateName'] ?? 'Unnamed template'}',
      sourcePlanName: '${json['sourcePlanName'] ?? 'Today'}',
      itemCount: _toInt(json['itemCount'], fallback: items.length),
      totalPlannedMinutes: _toInt(
        json['totalPlannedMinutes'],
        fallback: items.fold(0, (sum, item) => sum + item.plannedMinutes),
      ),
      items: items,
    );
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

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}
