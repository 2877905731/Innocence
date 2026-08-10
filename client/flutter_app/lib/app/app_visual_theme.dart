import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppVisualTheme {
  minimalism,
  wabiSabi,
  midCentury,
  glass,
}

extension AppVisualThemeX on AppVisualTheme {
  String get storageValue => switch (this) {
        AppVisualTheme.minimalism => 'minimalism',
        AppVisualTheme.wabiSabi => 'wabi_sabi',
        AppVisualTheme.midCentury => 'mid_century',
        AppVisualTheme.glass => 'glass',
      };

  String label({required bool isChinese}) => switch (this) {
        AppVisualTheme.minimalism => isChinese ? '纯白' : 'Pure white',
        AppVisualTheme.wabiSabi => isChinese ? '侘寂' : 'Wabi-sabi',
        AppVisualTheme.midCentury => isChinese ? '中世纪' : 'Mid-century',
        AppVisualTheme.glass => isChinese ? '玻璃态' : 'Glass',
      };
}

AppVisualTheme appVisualThemeFromStorage(String? value) {
  return switch (value) {
    'wabi_sabi' => AppVisualTheme.wabiSabi,
    'mid_century' => AppVisualTheme.midCentury,
    'glass' => AppVisualTheme.glass,
    _ => AppVisualTheme.minimalism,
  };
}

class AppVisualThemeController extends ChangeNotifier {
  AppVisualThemeController(this._preferences)
      : _currentTheme = appVisualThemeFromStorage(
          _preferences.getString(_themeKey),
        );

  static const String _themeKey = 'app.visual_theme';

  final SharedPreferences _preferences;
  AppVisualTheme _currentTheme;

  AppVisualTheme get currentTheme => _currentTheme;

  Future<void> updateTheme(AppVisualTheme theme) async {
    if (_currentTheme == theme) {
      return;
    }
    _currentTheme = theme;
    await _preferences.setString(_themeKey, theme.storageValue);
    notifyListeners();
  }
}

class AppVisualTokens {
  const AppVisualTokens({
    required this.canvas,
    required this.panel,
    required this.softPanel,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.artOne,
    required this.artTwo,
    required this.isDark,
    required this.isGlass,
  });

  final Color canvas;
  final Color panel;
  final Color softPanel;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color onAccent;
  final Color artOne;
  final Color artTwo;
  final bool isDark;
  final bool isGlass;

  static AppVisualTokens of(AppVisualTheme theme) => switch (theme) {
        AppVisualTheme.minimalism => const AppVisualTokens(
            canvas: Color(0xFFFFFFFF),
            panel: Color(0xFFFFFFFF),
            softPanel: Color(0xFFF4F4F2),
            ink: Color(0xFF111111),
            muted: Color(0xFF696966),
            line: Color(0xFFE3E3DF),
            accent: Color(0xFF3157D5),
            onAccent: Colors.white,
            artOne: Color(0xFF111111),
            artTwo: Color(0xFFDCE4FF),
            isDark: false,
            isGlass: false,
          ),
        AppVisualTheme.wabiSabi => const AppVisualTokens(
            canvas: Color(0xFFF1ECE2),
            panel: Color(0xFFF8F4EB),
            softPanel: Color(0xFFE6DED0),
            ink: Color(0xFF332F2A),
            muted: Color(0xFF746B60),
            line: Color(0xFFD4C9B9),
            accent: Color(0xFFA7563A),
            onAccent: Color(0xFFFFFAF1),
            artOne: Color(0xFF6D7966),
            artTwo: Color(0xFFD6BBA2),
            isDark: false,
            isGlass: false,
          ),
        AppVisualTheme.midCentury => const AppVisualTokens(
            canvas: Color(0xFFF6E7CD),
            panel: Color(0xFFFFF7E8),
            softPanel: Color(0xFFE8C98E),
            ink: Color(0xFF173E43),
            muted: Color(0xFF6A5945),
            line: Color(0xFFD6B98B),
            accent: Color(0xFFD45632),
            onAccent: Color(0xFFFFF8E9),
            artOne: Color(0xFF2E7771),
            artTwo: Color(0xFFE5A536),
            isDark: false,
            isGlass: false,
          ),
        AppVisualTheme.glass => const AppVisualTokens(
            canvas: Color(0xFF08111F),
            panel: Color(0xE619273A),
            softPanel: Color(0xB622324A),
            ink: Color(0xFFF5F8FF),
            muted: Color(0xFFA9B8CE),
            line: Color(0x4DABC6EC),
            accent: Color(0xFF88E3D0),
            onAccent: Color(0xFF0B1E26),
            artOne: Color(0xFF789BFF),
            artTwo: Color(0xFFD798FF),
            isDark: true,
            isGlass: true,
          ),
      };

  ThemeData toThemeData() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: accent,
      onPrimary: onAccent,
      surface: panel,
      onSurface: ink,
      outline: line,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: line),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: line,
      fontFamily: 'Segoe UI',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: ink,
          fontSize: 64,
          height: 0.94,
          letterSpacing: -3.4,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 34,
          height: 1.04,
          letterSpacing: -1.4,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 22,
          height: 1.16,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: muted, fontSize: 16, height: 1.55),
        bodyMedium: TextStyle(color: muted, fontSize: 14, height: 1.5),
        labelLarge: TextStyle(
          color: ink,
          fontSize: 14,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.72)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: onAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: canvas),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
