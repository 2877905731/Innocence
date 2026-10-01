import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('visual theme defaults to citrus white without changing its storage id',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final controller = AppVisualThemeController(preferences);

    expect(controller.currentTheme, AppVisualTheme.minimalism);
    expect(
      AppVisualTokens.of(controller.currentTheme).canvas,
      const Color(0xFFEEEDE9),
    );
    expect(
      AppVisualTokens.of(controller.currentTheme).accent,
      const Color(0xFFED762C),
    );
    expect(
      controller.currentTheme.label(isChinese: true),
      '简约白色',
    );
    expect(
      controller.currentTheme.label(isChinese: false),
      'Citrus white',
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

  test('glass dialogs use a visible modal surface and edge', () {
    final theme = AppVisualTokens.of(
      AppVisualTheme.glass,
    ).toThemeData(AppVisualTheme.glass);
    final shape = theme.dialogTheme.shape! as RoundedRectangleBorder;

    expect(theme.dialogTheme.backgroundColor, const Color(0xD1181A24));
    expect(theme.dialogTheme.barrierColor, const Color(0x73000000));
    expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
    expect(theme.dialogTheme.elevation, 24);
    expect(shape.borderRadius, BorderRadius.circular(24));
    expect(shape.side.color, const Color(0x52FFFFFF));
    expect(shape.side.width, 1);
  });

  test('glass controls stay neutral so background light provides color', () {
    final tokens = AppVisualTokens.of(AppVisualTheme.glass);

    expect(tokens.accent, const Color(0xFFC2C9E0));
    expect(tokens.onAccent, const Color(0xFF202127));
    expect(
        tokens.panel,
        AppConfig.deviceType == 'windows'
            ? const Color(0x0AFFFFFF)
            : const Color(0x33000000));
  });

  test('Android status bar icons follow the selected theme brightness', () {
    final white = AppVisualTokens.of(AppVisualTheme.minimalism)
        .toThemeData(AppVisualTheme.minimalism);
    final glass = AppVisualTokens.of(AppVisualTheme.glass)
        .toThemeData(AppVisualTheme.glass);

    expect(white.appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
        Brightness.dark);
    expect(glass.appBarTheme.systemOverlayStyle?.statusBarIconBrightness,
        Brightness.light);
    expect(white.appBarTheme.systemOverlayStyle?.statusBarColor,
        Colors.transparent);
  });
}
