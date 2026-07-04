class TodayPlan {
  const TodayPlan({
    required this.planDate,
    required this.planName,
    required this.completedCount,
    required this.totalCount,
    required this.totalPlannedMinutes,
    required this.completedPlannedMinutes,
    required this.items,
  });

  final String planDate;
  final String planName;
  final int completedCount;
  final int totalCount;
  final int totalPlannedMinutes;
  final int completedPlannedMinutes;
  final List<TodayPlanItem> items;

  factory TodayPlan.empty([String? planDate]) {
    return TodayPlan(
      planDate: planDate ?? _todayDateString(),
      planName: 'Today',
      completedCount: 0,
      totalCount: 0,
      totalPlannedMinutes: 0,
      completedPlannedMinutes: 0,
      items: const [],
    );
  }

  factory TodayPlan.fromJson(Map<String, dynamic> json) {
    final itemJson = json['items'] as List<dynamic>? ?? const [];
    final items = itemJson
        .whereType<Map<String, dynamic>>()
        .map(TodayPlanItem.fromJson)
        .toList();

    return TodayPlan(
      planDate: '${json['planDate'] ?? _todayDateString()}',
      planName: '${json['planName'] ?? 'Today'}',
      completedCount: _toInt(json['completedCount'], fallback: _completedCount(items)),
      totalCount: _toInt(json['totalCount'], fallback: items.length),
      totalPlannedMinutes: _toInt(
        json['totalPlannedMinutes'],
        fallback: items.fold(0, (sum, item) => sum + item.plannedMinutes),
      ),
      completedPlannedMinutes: _toInt(
        json['completedPlannedMinutes'],
        fallback: items
            .where((item) => item.completed)
            .fold(0, (sum, item) => sum + item.plannedMinutes),
      ),
      items: items,
    );
  }

  bool get hasItems => items.isNotEmpty;

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

  String get completedDurationLabel {
    if (completedPlannedMinutes <= 0) {
      return '0 min';
    }
    final hours = completedPlannedMinutes ~/ 60;
    final minutes = completedPlannedMinutes % 60;
    if (hours == 0) {
      return '$minutes min';
    }
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  TodayPlan copyWith({
    String? planDate,
    String? planName,
    List<TodayPlanItem>? items,
  }) {
    final nextItems = items ?? this.items;
    final nextCompletedCount = _completedCount(nextItems);
    final nextTotalPlannedMinutes =
        nextItems.fold(0, (sum, item) => sum + item.plannedMinutes);
    final nextCompletedPlannedMinutes = nextItems
        .where((item) => item.completed)
        .fold(0, (sum, item) => sum + item.plannedMinutes);

    return TodayPlan(
      planDate: planDate ?? this.planDate,
      planName: planName ?? this.planName,
      completedCount: nextCompletedCount,
      totalCount: nextItems.length,
      totalPlannedMinutes: nextTotalPlannedMinutes,
      completedPlannedMinutes: nextCompletedPlannedMinutes,
      items: nextItems,
    );
  }

  TodayPlan toggleAt(int index, bool completed) {
    final updatedItems = List<TodayPlanItem>.from(items);
    updatedItems[index] = updatedItems[index].copyWith(completed: completed);
    return copyWith(items: updatedItems);
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'planDate': planDate,
      'planName': planName,
      'items': items.map((item) => item.toSaveJson()).toList(),
    };
  }

  static int _completedCount(List<TodayPlanItem> items) {
    return items.where((item) => item.completed).length;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }

  static String _todayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.plannedMinutes,
    required this.actualMinutes,
    required this.sortOrder,
  });

  final int id;
  final String title;
  final bool completed;
  final int plannedMinutes;
  final int actualMinutes;
  final int sortOrder;

  factory TodayPlanItem.fromJson(Map<String, dynamic> json) {
    return TodayPlanItem(
      id: TodayPlan._toInt(json['id']),
      title: '${json['title'] ?? ''}',
      completed: json['completed'] == true || json['completed'] == 1,
      plannedMinutes: TodayPlan._toInt(json['plannedMinutes']),
      actualMinutes: TodayPlan._toInt(json['actualMinutes']),
      sortOrder: TodayPlan._toInt(json['sortOrder']),
    );
  }

  TodayPlanItem copyWith({
    bool? completed,
    String? title,
    int? plannedMinutes,
    int? actualMinutes,
    int? sortOrder,
  }) {
    return TodayPlanItem(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'title': title,
      'completed': completed,
      'plannedMinutes': plannedMinutes,
      'actualMinutes': actualMinutes,
    };
  }
}
