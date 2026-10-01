import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline edition rejects every transport before opening a connection',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var requests = 0;
    server.listen((request) {
      requests++;
      request.response.close();
    });
    final http = HttpClient();
    addTearDown(() async {
      http.close(force: true);
      await server.close(force: true);
    });
    final client = ApiClient(
      httpClient: http,
      baseUrl: 'http://127.0.0.1:${server.port}/',
      offlineOnly: true,
    );
    final denied = throwsA(isA<ApiException>()
        .having((error) => error.statusCode, 'statusCode', 403));
    await expectLater(client.get('read'), denied);
    await expectLater(client.post('create'), denied);
    await expectLater(client.put('update'), denied);
    await expectLater(client.delete('remove'), denied);
    await expectLater(
        client.postMultipart('upload',
            fieldName: 'file',
            bytes: [1],
            filename: 'sample.png',
            contentType: 'image/png'),
        denied);
    expect(requests, 0);
  });

  test('offline build configuration omits the development server address', () {
    if (AppConfig.offlineOnlyBuild) {
      expect(AppConfig.apiBaseUrl, isEmpty);
    } else {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    }
  });

  test('offline edition startup cannot restore a retained online identity',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AuthLocalStorage(preferences);
    await storage.saveSession(const AppSession(
      accessToken: 'synthetic-token',
      tokenType: 'Bearer',
      userId: 42,
      deviceType: 'android',
      deviceSlot: 'mobile',
      deviceId: 'synthetic-device',
    ));
    final language = AppLanguageController(preferences);
    final controller = SessionController(
        authApi: AuthApi(),
        localStorage: storage,
        languageController: language,
        restoreOfflineOnStartup: true,
        offlineOnlyBuild: true);
    addTearDown(controller.dispose);
    addTearDown(language.dispose);
    await controller.initialize();
    expect(controller.status, SessionStatus.unauthenticated);
    expect(controller.profile, isNull);
    expect(storage.readSession()?.userId, 42);
    expect(storage.offlineModeActive, isFalse);
  });

  testWidgets(
      'offline edition entry has no sign-in form and requires explicit local choice',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final language = AppLanguageController(preferences);
    final controller = SessionController(
        authApi: AuthApi(),
        localStorage: AuthLocalStorage(preferences),
        languageController: language,
        offlineOnlyBuild: true);
    addTearDown(controller.dispose);
    addTearDown(language.dispose);
    await controller.initialize();
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      theme: AppVisualTokens.of(AppVisualTheme.minimalism)
          .toThemeData(AppVisualTheme.minimalism),
      home: AuthPage(
          sessionController: controller,
          appLanguage: AppLanguage.simplifiedChinese,
          visualTheme: AppVisualTheme.minimalism,
          onThemeChanged: (_) async {}),
    ));
    expect(find.text('本机离线版'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('offline-release-enter')));
    await tester.pumpAndSettle();
    expect(find.text('使用离线模式'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(controller.status, SessionStatus.unauthenticated);
  });
}
