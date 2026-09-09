import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:innocence_flutter/app/app.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';

void main() {
  testWidgets('app renders the unauthenticated shell', (tester) async {
    const desktopChannel = MethodChannel('innocence/desktop_widget');
    final desktopCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(desktopChannel, (call) async {
      desktopCalls.add(call.method);
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(desktopChannel, null);
    });
    SharedPreferences.setMockInitialValues({
      'app.language': 'en_US',
      'app.language.startup_confirmed': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final languageController = AppLanguageController(preferences);
    final visualThemeController = AppVisualThemeController(preferences);
    final sessionController = SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(preferences),
      languageController: languageController,
    );

    await tester.pumpWidget(
      InnocenceApp(
        sessionController: sessionController,
        languageController: languageController,
        visualThemeController: visualThemeController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Password login'), findsOneWidget);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('auth-titlebar-drag-region')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('auth-editorial-drag-region')),
      findsOneWidget,
    );
    desktopCalls.clear();
    await tester.drag(
      find.byKey(const ValueKey('auth-titlebar-drag-region')),
      const Offset(32, 0),
    );
    await tester.pump();
    expect(desktopCalls, contains('startWindowDrag'));

    final forgotPasswordLink = find.text('Forgot password?');
    await tester.ensureVisible(forgotPasswordLink);
    await tester.tap(forgotPasswordLink);
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsNWidgets(2));
    expect(find.text('Send reset code'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);

    final resetPasswordButton = find.widgetWithText(
      ElevatedButton,
      'Reset password',
    );
    await tester.ensureVisible(resetPasswordButton);
    await tester.tap(resetPasswordButton);
    await tester.pump();

    expect(find.text('Please enter your email.'), findsOneWidget);
  });

  testWidgets('all auth art themes fit the small canvas', (tester) async {
    tester.view.physicalSize = const Size(480, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'app.language': 'en_US',
      'app.language.startup_confirmed': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final languageController = AppLanguageController(preferences);
    final visualThemeController = AppVisualThemeController(preferences);
    final sessionController = SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(preferences),
      languageController: languageController,
    );

    await tester.pumpWidget(
      InnocenceApp(
        sessionController: sessionController,
        languageController: languageController,
        visualThemeController: visualThemeController,
      ),
    );
    await tester.pumpAndSettle();

    for (final theme in [
      'wabi_sabi',
      'mid_century',
      'glass',
      'minimalism',
    ]) {
      final themeButton = find.byKey(ValueKey('visual-theme-$theme'));
      await tester.ensureVisible(themeButton);
      await tester.tap(themeButton);
      await tester.pump(const Duration(milliseconds: 260));
      expect(tester.takeException(), isNull);

      if (theme == 'glass') {
        expect(find.byType(GlassMotionBackdrop), findsOneWidget);
      }
    }

    expect(find.text('Password login'), findsOneWidget);
  });
}
