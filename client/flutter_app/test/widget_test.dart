import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:innocence_flutter/app/app.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';

void main() {
  testWidgets('app renders the unauthenticated shell', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app.language': 'en_US',
      'app.language.startup_confirmed': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final languageController = AppLanguageController(preferences);
    final sessionController = SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(preferences),
      languageController: languageController,
    );

    await tester.pumpWidget(
      InnocenceApp(
        sessionController: sessionController,
        languageController: languageController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Password login'), findsOneWidget);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsNWidgets(2));
    expect(find.text('Send reset code'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset password'));
    await tester.pump();

    expect(find.text('Please enter your email.'), findsOneWidget);
  });
}
