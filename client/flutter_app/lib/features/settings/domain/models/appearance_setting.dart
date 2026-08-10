class AppearanceSetting {
  const AppearanceSetting({
    required this.themeMode,
  });

  final String themeMode;

  factory AppearanceSetting.empty() {
    return const AppearanceSetting(
      themeMode: 'dark',
    );
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) {
    return AppearanceSetting(
      themeMode: _normalizeThemeMode(json['themeMode']),
    );
  }

  AppearanceSetting copyWith({
    String? themeMode,
  }) {
    return AppearanceSetting(
      themeMode: _normalizeThemeMode(themeMode ?? this.themeMode),
    );
  }

  bool get isLightMode => themeMode == 'light';

  String get themeModeLabel => isLightMode ? 'Light' : 'Dark';

  static String _normalizeThemeMode(dynamic value) {
    final normalized = '$value'.trim().toLowerCase();
    return normalized == 'light' ? 'light' : 'dark';
  }
}
