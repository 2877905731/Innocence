import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:innocence_flutter/app/app.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';

void main() {
  testWidgets('app renders title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final sessionController = SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(preferences),
    );

    await tester.pumpWidget(
      InnocenceApp(sessionController: sessionController),
    );
    await tester.pump();

    expect(find.text('Innocence'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
