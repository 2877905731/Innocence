import 'package:flutter/material.dart';

class SurfacePalette {
  static const Color canvas = Colors.white;
  static const Color surface = Colors.white;
  static const Color softSurface = Color(0xFFF6F7F9);
  static const Color tintSurface = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFD4DAE3);
  static const Color borderSoft = Color(0xFFE3E8EF);
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF5F6673);
  static const Color subtle = Color(0xFF7A8391);
  static const Color dangerSurface = Color(0xFFF8EDEE);
  static const Color dangerBorder = Color(0xFFE4C7C9);
  static const Color dangerInk = Color(0xFF8D4C56);
  static const Color warmSurface = Color(0xFFF6F0E3);
  static const Color warmBorder = Color(0xFFE4D7B4);
  static const Color warmInk = Color(0xFF75613A);
  static const Color accentSurface = Color(0xFFECEFF3);

  static List<BoxShadow> get shadows => const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 24,
          offset: Offset(0, 14),
        ),
      ];

  static BoxDecoration cardDecoration({
    double radius = 34,
    Color color = surface,
    Color borderColor = border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: shadows,
    );
  }

  static BoxDecoration insetDecoration({
    double radius = 22,
    Color color = softSurface,
    Color borderColor = border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
    );
  }

  static BoxDecoration pillDecoration({
    Color color = softSurface,
    Color borderColor = border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: borderColor),
    );
  }

  static BoxDecoration dangerDecoration({
    double radius = 22,
  }) {
    return BoxDecoration(
      color: dangerSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: dangerBorder),
    );
  }

  static ThemeData homeTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ink,
      brightness: Brightness.light,
    ).copyWith(
      primary: ink,
      onPrimary: Colors.white,
      secondary: ink,
      surface: surface,
      onSurface: ink,
    );

    final borderShape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: borderSoft,
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ink,
        linearTrackColor: Color(0xFFE6EBF0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: subtle),
        labelStyle: const TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: borderShape,
        enabledBorder: borderShape,
        focusedBorder: borderShape.copyWith(
          borderSide: const BorderSide(
            color: ink,
            width: 1.2,
          ),
        ),
        errorBorder: borderShape.copyWith(
          borderSide: const BorderSide(color: dangerInk),
        ),
        focusedErrorBorder: borderShape.copyWith(
          borderSide: const BorderSide(
            color: dangerInk,
            width: 1.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: ink,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: ink,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: surface,
          foregroundColor: ink,
          side: const BorderSide(color: border),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return tintSurface;
            }
            return surface;
          }),
          overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: const BorderSide(color: border),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ink;
          }
          return surface;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softSurface,
        selectedColor: ink,
        secondarySelectedColor: ink,
        disabledColor: softSurface,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        labelStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        showCheckmark: false,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: ink,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: muted,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: muted,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: subtle,
          height: 1.4,
        ),
      ),
    );
  }
}
