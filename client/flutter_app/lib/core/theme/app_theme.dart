import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.glow,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.glow,
      secondary: AppColors.mint,
      surface: const Color(0xFF10192A),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(26),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.10),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      cardColor: Colors.white.withValues(alpha: 0.08),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF18253A),
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: AppColors.glow,
            width: 1.2,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFFFFA4A4)),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(0xFFFFA4A4),
            width: 1.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.glow,
          foregroundColor: AppColors.night,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ).copyWith(
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: Colors.white.withValues(alpha: 0.06));
            }
            if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.selected)) {
              return const BorderSide(
                color: AppColors.glow,
                width: 1.3,
              );
            }
            return BorderSide(color: Colors.white.withValues(alpha: 0.14));
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.10);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return Colors.white.withValues(alpha: 0.08);
            }
            return Colors.white.withValues(alpha: 0.04);
          }),
          shadowColor: const WidgetStatePropertyAll(AppColors.glow),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStatePropertyAll(
            AppColors.glow.withValues(alpha: 0.08),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textPrimary;
            }
            return AppColors.textPrimary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white.withValues(alpha: 0.10);
            }
            return Colors.white.withValues(alpha: 0.06);
          }),
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(
                color: AppColors.glow,
                width: 1.3,
              );
            }
            return BorderSide(color: Colors.white.withValues(alpha: 0.10));
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
          shadowColor: const WidgetStatePropertyAll(AppColors.glow),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        brightness: Brightness.dark,
        secondaryColor: AppColors.glow,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        showCheckmark: false,
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        selectedColor: Colors.white.withValues(alpha: 0.10),
        secondarySelectedColor: Colors.white.withValues(alpha: 0.10),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(
              color: AppColors.glow,
              width: 1.25,
            );
          }
          return BorderSide(color: Colors.white.withValues(alpha: 0.12));
        }),
        shadowColor: AppColors.glow,
        selectedShadowColor: AppColors.glow,
        elevation: 0,
        pressElevation: 0,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.glow,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF3C73AF),
      secondary: const Color(0xFF73B0A2),
      surface: const Color(0xFFF6FAFF),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(26),
      borderSide: const BorderSide(
        color: Color(0x220C2646),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF3F7FD),
      cardColor: Colors.white.withValues(alpha: 0.78),
      dividerColor: const Color(0x120C2646),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFFEDF5FF),
        contentTextStyle: const TextStyle(color: Color(0xFF16314F)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        hintStyle: const TextStyle(color: Color(0xFF667B96)),
        labelStyle: const TextStyle(color: Color(0xFF526A86)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(0xFF3C73AF),
            width: 1.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: const Color(0xFF3C73AF),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: const Color(0xFF15304F),
          side: const BorderSide(color: Color(0x220C2646)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ).copyWith(
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: Color(0x140C2646));
            }
            if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.selected)) {
              return const BorderSide(
                color: Color(0xFF3C73AF),
                width: 1.3,
              );
            }
            return const BorderSide(color: Color(0x220C2646));
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.94);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return Colors.white.withValues(alpha: 0.90);
            }
            return Colors.white.withValues(alpha: 0.78);
          }),
          shadowColor: const WidgetStatePropertyAll(Color(0xFF3C73AF)),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStatePropertyAll(
            const Color(0xFF3C73AF).withValues(alpha: 0.08),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF15304F);
            }
            return const Color(0xFF15304F);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white.withValues(alpha: 0.98);
            }
            return Colors.white.withValues(alpha: 0.66);
          }),
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(
                color: Color(0xFF3C73AF),
                width: 1.3,
              );
            }
            return const BorderSide(color: Color(0x220C2646));
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w600),
          ),
          shadowColor: const WidgetStatePropertyAll(Color(0xFF3C73AF)),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        brightness: Brightness.light,
        secondaryColor: const Color(0xFF3C73AF),
        labelStyle: const TextStyle(
          color: Color(0xFF15304F),
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        showCheckmark: false,
        backgroundColor: Colors.white.withValues(alpha: 0.80),
        selectedColor: Colors.white,
        secondarySelectedColor: Colors.white,
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(
              color: Color(0xFF3C73AF),
              width: 1.25,
            );
          }
          return const BorderSide(color: Color(0x220C2646));
        }),
        shadowColor: const Color(0xFF3C73AF),
        selectedShadowColor: const Color(0xFF3C73AF),
        elevation: 0,
        pressElevation: 0,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15304F),
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15304F),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15304F),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF15304F),
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF15304F),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF526A86),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF667B96),
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF74879F),
          height: 1.4,
        ),
      ),
    );
  }
}
