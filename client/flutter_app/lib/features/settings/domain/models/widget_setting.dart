class WidgetSetting {
  const WidgetSetting({
    required this.autoStart,
    required this.alwaysOnTop,
    required this.showPlan,
    required this.showTimer,
    required this.showMemo,
  });

  final bool autoStart;
  final bool alwaysOnTop;
  final bool showPlan;
  final bool showTimer;
  final bool showMemo;

  factory WidgetSetting.empty() {
    return const WidgetSetting(
      autoStart: false,
      alwaysOnTop: false,
      showPlan: true,
      showTimer: true,
      showMemo: true,
    );
  }

  factory WidgetSetting.fromJson(Map<String, dynamic> json) {
    return WidgetSetting(
      autoStart: _toBool(json['autoStart']),
      alwaysOnTop: _toBool(json['alwaysOnTop']),
      showPlan: _toBool(json['showPlan'], fallback: true),
      showTimer: _toBool(json['showTimer'], fallback: true),
      showMemo: _toBool(json['showMemo'], fallback: true),
    );
  }

  WidgetSetting copyWith({
    bool? autoStart,
    bool? alwaysOnTop,
    bool? showPlan,
    bool? showTimer,
    bool? showMemo,
  }) {
    return WidgetSetting(
      autoStart: autoStart ?? this.autoStart,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      showPlan: showPlan ?? this.showPlan,
      showTimer: showTimer ?? this.showTimer,
      showMemo: showMemo ?? this.showMemo,
    );
  }

  int get enabledCount {
    var count = 0;
    if (autoStart) {
      count++;
    }
    if (alwaysOnTop) {
      count++;
    }
    if (showPlan) {
      count++;
    }
    if (showTimer) {
      count++;
    }
    if (showMemo) {
      count++;
    }
    return count;
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = '$value'.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return fallback;
  }
}
