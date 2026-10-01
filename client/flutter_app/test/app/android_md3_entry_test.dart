import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/android_md3_theme.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/features/auth/presentation/pages/android_language_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Android Material 3 baseline follows light and dark brightness', () {
    expect(AndroidMd3Theme.light.useMaterial3, isTrue);
    expect(AndroidMd3Theme.dark.useMaterial3, isTrue);
    expect(AndroidMd3Theme.light.colorScheme.brightness, Brightness.light);
    expect(AndroidMd3Theme.dark.colorScheme.brightness, Brightness.dark);
  });

  testWidgets('Android language entry persists the selected language',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = AppLanguageController(preferences);
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          theme: AndroidMd3Theme.light,
          home: AndroidLanguageSelectionPage(controller: controller),
        ),
      ),
    );

    expect(find.text('选择显示语言'), findsOneWidget);
    await tester.tap(find.text('English').last);
    await tester.pump();
    expect(find.text('Choose display language'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(controller.startupConfirmed, isTrue);
    expect(preferences.getString('app.language'), 'en_US');
  });
}
