class AppearanceSetting {
  const AppearanceSetting({
    required this.themeMode,
    required this.desktopEffect,
  });

  final String themeMode;
  final String desktopEffect;

  factory AppearanceSetting.empty() {
    return const AppearanceSetting(
      themeMode: 'dark',
      desktopEffect: 'immersive_glass',
    );
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) {
    return AppearanceSetting(
      themeMode: _normalizeThemeMode(json['themeMode']),
      desktopEffect: _normalizeDesktopEffect(json['desktopEffect']),
    );
  }

  AppearanceSetting copyWith({
    String? themeMode,
    String? desktopEffect,
  }) {
    return AppearanceSetting(
      themeMode: _normalizeThemeMode(themeMode ?? this.themeMode),
      desktopEffect: _normalizeDesktopEffect(
        desktopEffect ?? this.desktopEffect,
      ),
    );
  }

  bool get isLightMode => themeMode == 'light';

  String get themeModeLabel => isLightMode ? 'Light' : 'Dark';

  String get desktopEffectLabel {
    switch (desktopEffect) {
      case 'soft_glass':
        return 'Soft glass';
      case 'focus_glow':
        return 'Focus glow';
      default:
        return 'Immersive glass';
    }
  }

  static String _normalizeThemeMode(dynamic value) {
    final normalized = '$value'.trim().toLowerCase();
    return normalized == 'light' ? 'light' : 'dark';
  }

  static String _normalizeDesktopEffect(dynamic value) {
    final normalized = '$value'.trim().toLowerCase();
    switch (normalized) {
      case 'soft_glass':
      case 'focus_glow':
      case 'immersive_glass':
        return normalized;
      default:
        return 'immersive_glass';
    }
  }
}
