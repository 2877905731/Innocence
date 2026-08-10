import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('visual theme defaults to pure white minimalism', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final controller = AppVisualThemeController(preferences);

    expect(controller.currentTheme, AppVisualTheme.minimalism);
    expect(
      AppVisualTokens.of(controller.currentTheme).canvas,
      const Color(0xFFFFFFFF),
    );
  });

  test('visual theme is restored on the next launch', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppVisualThemeController(preferences);

    await controller.updateTheme(AppVisualTheme.midCentury);
    final restored = AppVisualThemeController(preferences);

    expect(restored.currentTheme, AppVisualTheme.midCentury);
  });

  testWidgets('theme changes rebuild the global ThemeData immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppVisualThemeController(preferences);

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final visualTheme = controller.currentTheme;
          return MaterialApp(
            theme: AppVisualTokens.of(visualTheme).toThemeData(visualTheme),
            home: Builder(
              builder: (context) {
                final marker = Theme.of(
                  context,
                ).extension<AppVisualThemeMarker>();
                return Text(marker!.visualTheme.storageValue);
              },
            ),
          );
        },
      ),
    );
    expect(find.text('minimalism'), findsOneWidget);

    await controller.updateTheme(AppVisualTheme.wabiSabi);
    await tester.pumpAndSettle();
    expect(find.text('wabi_sabi'), findsOneWidget);
  });

  test('wabi-sabi stays within the brown and deep-beige palette', () {
    final tokens = AppVisualTokens.of(AppVisualTheme.wabiSabi);

    expect(tokens.canvas, const Color(0xFFECE3D3));
    expect(tokens.accent, const Color(0xFF76533C));
    expect(tokens.artOne, const Color(0xFF5E4736));
    expect(tokens.artTwo, const Color(0xFFB69D7D));
    expect(tokens.isDark, isFalse);
    expect(tokens.isGlass, isFalse);
  });

  test('ThemeData keeps the selected visual theme marker', () {
    final theme = AppVisualTokens.of(
      AppVisualTheme.wabiSabi,
    ).toThemeData(AppVisualTheme.wabiSabi);

    expect(
      theme.extension<AppVisualThemeMarker>()?.visualTheme,
      AppVisualTheme.wabiSabi,
    );
    expect(theme.scaffoldBackgroundColor, const Color(0xFFECE3D3));
  });
}
