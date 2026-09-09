import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_language.dart';
import 'app/app_visual_theme.dart';
import 'app/session_controller.dart';
import 'core/local/offline_store.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final languageController = AppLanguageController(preferences);
  final visualThemeController = AppVisualThemeController(preferences);
  final sessionController = SessionController(
    authApi: AuthApi(),
    localStorage: AuthLocalStorage(preferences),
    languageController: languageController,
    offlineStore: OfflineStore(),
  );

  runApp(
    InnocenceApp(
      sessionController: sessionController,
      languageController: languageController,
      visualThemeController: visualThemeController,
    ),
  );
}
