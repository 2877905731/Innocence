import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:innocence_flutter/core/config/app_config.dart';

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
        AppVisualTheme.minimalism => isChinese ? '简约白色' : 'Minimal white',
        AppVisualTheme.wabiSabi => isChinese ? '侘寂' : 'Wabi-sabi',
        AppVisualTheme.midCentury => isChinese ? '中世纪' : 'Mid-century',
        AppVisualTheme.glass => isChinese ? '液态玻璃' : 'Liquid glass',
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
            canvas: Color(0xFFF2F2F2),
            panel: Color(0xFFFFFFFF),
            softPanel: Color(0xFFF5F5F5),
            ink: Color(0xFF1A1A1A),
            muted: Color(0xFF666666),
            line: Color(0xFFD6D6D6),
            accent: Color(0xFF000000),
            onAccent: Colors.white,
            artOne: Color(0xFF404040),
            artTwo: Color(0xFF999999),
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
        AppVisualTheme.glass => AppVisualTokens(
            canvas: const Color(0xFF03042C),
            panel: AppConfig.capabilities.usesPcLayout
                ? const Color(0x0AFFFFFF)
                : const Color(0x33000000),
            softPanel: const Color(0x22000000),
            ink: const Color(0xFFF0F1F4),
            muted: const Color(0xFFD4D6E0),
            line: const Color(0x29FFFFFF),
            accent: const Color(0xFFC2C9E0),
            onAccent: const Color(0xFF202127),
            artOne: const Color(0xFF2D2CFF),
            artTwo: const Color(0xFFB629F5),
            isDark: true,
            isGlass: true,
          ),
      };

  ThemeData toThemeData(AppVisualTheme visualTheme) {
    final minimal = visualTheme == AppVisualTheme.minimalism;
    final windowsGlass = isGlass && AppConfig.capabilities.usesPcLayout;
    final componentRadius = switch (visualTheme) {
      AppVisualTheme.minimalism =>
        AppConfig.capabilities.usesPcLayout ? 0.0 : 4.0,
      AppVisualTheme.wabiSabi => 4.0,
      AppVisualTheme.midCentury => 12.0,
      AppVisualTheme.glass => 10.0,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: minimal ? softPanel : null,
      onPrimaryContainer: minimal ? ink : null,
      secondary: minimal ? ink : null,
      onSecondary: minimal ? onAccent : null,
      secondaryContainer: minimal ? softPanel : null,
      onSecondaryContainer: minimal ? ink : null,
      tertiary: minimal ? ink : null,
      onTertiary: minimal ? onAccent : null,
      tertiaryContainer: minimal ? softPanel : null,
      onTertiaryContainer: minimal ? ink : null,
      onSurfaceVariant: minimal ? muted : null,
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
        componentRadius,
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
              backgroundColor: Color(0xD1181A24),
              barrierColor: Color(0x73000000),
              surfaceTintColor: Colors.transparent,
              elevation: 24,
              shadowColor: Color(0x66000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                side: BorderSide(
                  color: Color(0x52FFFFFF),
                  width: 1,
                ),
              ),
            )
          : minimal
              ? DialogThemeData(
                  backgroundColor: panel,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(componentRadius),
                    side: BorderSide(color: line),
                  ),
                )
              : null,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: ink,
          fontSize: 64,
          height: 0.94,
          letterSpacing: -3.4,
          fontWeight: minimal ? FontWeight.w300 : FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 34,
          height: 1.04,
          letterSpacing: -1.4,
          fontWeight: minimal ? FontWeight.w400 : FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 22,
          height: 1.16,
          fontWeight: minimal ? FontWeight.w500 : FontWeight.w700,
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
      textButtonTheme: minimal
          ? TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: ink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(componentRadius))))
          : null,
      checkboxTheme: minimal
          ? CheckboxThemeData(
              shape: const RoundedRectangleBorder(),
              side: BorderSide(color: muted),
              fillColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? accent : null),
              checkColor: const WidgetStatePropertyAll(Colors.white))
          : null,
      segmentedButtonTheme: minimal
          ? SegmentedButtonThemeData(
              style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(componentRadius))),
                  backgroundColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? softPanel
                          : panel),
                  foregroundColor: WidgetStatePropertyAll(ink)))
          : null,
      progressIndicatorTheme: minimal
          ? ProgressIndicatorThemeData(color: accent, linearTrackColor: line)
          : null,
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
          backgroundColor: minimal ? ink : accent,
          foregroundColor: minimal ? Colors.white : onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentRadius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: minimal ? ink : accent,
          foregroundColor: minimal ? Colors.white : onAccent,
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
      cardTheme: minimal || isGlass
          ? CardThemeData(
              elevation: 0,
              color: panel,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(isGlass ? 15 : componentRadius),
                side: BorderSide(color: line),
              ),
            )
          : const CardThemeData(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: isGlass ? Colors.transparent : canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: isGlass
            ? const Color(0x99000000)
            : minimal
                ? const Color(0xFFFFFFFF)
                : panel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isGlass
            ? const Color(0x18FFFFFF)
            : minimal
                ? const Color(0xFF1A1A1A)
                : softPanel,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(minimal ? componentRadius : 8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: windowsGlass
            ? const Color(0x80121318)
            : isGlass
                ? const Color(0xB8000000)
                : ink,
        contentTextStyle: TextStyle(color: isGlass ? ink : canvas),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(componentRadius),
        ),
      ),
      tooltipTheme: isGlass
          ? TooltipThemeData(
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
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
          : minimal
              ? TooltipThemeData(
                  decoration: BoxDecoration(
                    color: const Color(0xF217181B),
                    borderRadius: BorderRadius.circular(componentRadius),
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
