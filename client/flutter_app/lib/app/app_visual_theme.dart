import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppVisualTheme {
  minimalism,
  wabiSabi,
  midCentury,
  glass,
}

@immutable
class AppVisualThemeMarker extends ThemeExtension<AppVisualThemeMarker> {
  const AppVisualThemeMarker(this.visualTheme);

  final AppVisualTheme visualTheme;

  @override
  AppVisualThemeMarker copyWith({AppVisualTheme? visualTheme}) {
    return AppVisualThemeMarker(visualTheme ?? this.visualTheme);
  }

  @override
  AppVisualThemeMarker lerp(
    covariant AppVisualThemeMarker? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

extension AppVisualThemeX on AppVisualTheme {
  String get storageValue => switch (this) {
        AppVisualTheme.minimalism => 'minimalism',
        AppVisualTheme.wabiSabi => 'wabi_sabi',
        AppVisualTheme.midCentury => 'mid_century',
        AppVisualTheme.glass => 'glass',
      };

  String label({required bool isChinese}) => switch (this) {
        AppVisualTheme.minimalism => isChinese ? '柔彩' : 'Soft spectrum',
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
    notifyListeners();
    await _preferences.setString(_themeKey, theme.storageValue);
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
            canvas: Color(0xFFF4F4F7),
            panel: Color(0xFFFCFCFE),
            softPanel: Color(0xFFEEEAF9),
            ink: Color(0xFF17181B),
            muted: Color(0xFF686A72),
            line: Color(0xFFDADAE2),
            accent: Color(0xFF8E7DFF),
            onAccent: Colors.white,
            artOne: Color(0xFFFF9CA9),
            artTwo: Color(0xFFE7E2FF),
            isDark: false,
            isGlass: false,
          ),
        AppVisualTheme.wabiSabi => const AppVisualTokens(
            canvas: Color(0xFFECE3D3),
            panel: Color(0xFFF6F0E4),
            softPanel: Color(0xFFDDD0BC),
            ink: Color(0xFF3D332A),
            muted: Color(0xFF766858),
            line: Color(0xFFC9B99F),
            accent: Color(0xFF76533C),
            onAccent: Color(0xFFFFFAEF),
            artOne: Color(0xFF5E4736),
            artTwo: Color(0xFFB69D7D),
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
            panel: Color(0x3D101D3B),
            softPanel: Color(0x3014264A),
            ink: Color(0xFFF5F8FF),
            muted: Color(0xFFD2DDF0),
            line: Color(0x5CBCD3F2),
            accent: Color(0xFFA7B5FF),
            onAccent: Color(0xFF11183A),
            artOne: Color(0xFF789BFF),
            artTwo: Color(0xFFD798FF),
            isDark: true,
            isGlass: true,
          ),
      };

  ThemeData toThemeData(AppVisualTheme visualTheme) {
    final softSpectrum = visualTheme == AppVisualTheme.minimalism;
    final componentRadius = switch (visualTheme) {
      AppVisualTheme.minimalism => 14.0,
      AppVisualTheme.wabiSabi => 4.0,
      AppVisualTheme.midCentury => 12.0,
      AppVisualTheme.glass => 14.0,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: accent,
      onPrimary: onAccent,
      surface: panel,
      surfaceContainerLowest: canvas,
      surfaceContainerLow: softPanel,
      surfaceContainer: softPanel,
      surfaceContainerHigh: softPanel,
      onSurface: ink,
      outline: line,
      outlineVariant: line.withValues(alpha: 0.62),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        softSpectrum ? 16 : componentRadius,
      ),
      borderSide: BorderSide(color: line),
    );

    return ThemeData(
      useMaterial3: true,
      extensions: [AppVisualThemeMarker(visualTheme)],
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: line,
      fontFamily: 'Segoe UI',
      dialogTheme: isGlass
          ? const DialogThemeData(
              backgroundColor: Color(0xE6132146),
              surfaceTintColor: Colors.transparent,
              elevation: 28,
              shadowColor: Color(0xCC071027),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
                side: BorderSide(
                  color: Color(0x78FFFFFF),
                  width: 1.2,
                ),
              ),
            )
          : softSpectrum
              ? DialogThemeData(
                  backgroundColor: const Color(0xFFFCFCFE),
                  surfaceTintColor: Colors.transparent,
                  elevation: 20,
                  shadowColor: const Color(0x26252635),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Color(0xBFFFFFFF)),
                  ),
                )
              : null,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentRadius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentRadius),
          ),
        ),
      ),
      cardTheme: softSpectrum
          ? CardThemeData(
              elevation: 0,
              color: panel,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: line.withValues(alpha: 0.72)),
              ),
            )
          : const CardThemeData(),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: canvas),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(componentRadius),
        ),
      ),
      tooltipTheme: isGlass
          ? TooltipThemeData(
              decoration: BoxDecoration(
                color: const Color(0xE6101D3B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x5CFFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x551F2687),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              textStyle: TextStyle(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          : softSpectrum
              ? TooltipThemeData(
                  decoration: BoxDecoration(
                    color: const Color(0xF217181B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26252635),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
    );
  }
}
