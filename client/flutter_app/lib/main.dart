import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_language.dart';
import 'app/session_controller.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final languageController = AppLanguageController(preferences);
  final sessionController = SessionController(
    authApi: AuthApi(),
    localStorage: AuthLocalStorage(preferences),
    languageController: languageController,
  );

  runApp(
    InnocenceApp(
      sessionController: sessionController,
      languageController: languageController,
    ),
  );
}
