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
}
