import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('explicit offline use restores the same local owner and plan on restart',
      () async {
    final directory = await Directory.systemTemp.createTemp('offline-restore-');
    final databasePath = '${directory.path}${Platform.pathSeparator}offline.db';
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AuthLocalStorage(preferences);
    final firstStore = _store(databasePath);
    final firstController = _controller(storage, preferences, firstStore);
    addTearDown(() async {
      firstController.dispose();
      await firstStore.close();
      await directory.delete(recursive: true);
    });

    await firstController.enterOfflineMode();
    expect(firstController.status, SessionStatus.offline);
    expect(storage.offlineModeActive, isTrue);
    final ownerScope = firstController.localOwnerScope;
    final plan = TodayPlan.empty().copyWith(
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'Local task',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: null,
          endSlot: null,
          sortOrder: 0,
        ),
      ],
    );
    await firstController.saveTodayPlan(plan);
    await firstStore.close();

    final restoredStore = _store(databasePath);
    final restoredController = _controller(storage, preferences, restoredStore);
    addTearDown(() async {
      restoredController.dispose();
      await restoredStore.close();
    });
    await restoredController.initialize();

    expect(restoredController.status, SessionStatus.offline);
    expect(restoredController.localOwnerScope, ownerScope);
    expect(restoredController.todayPlan.items.single.title, 'Local task');
    expect(restoredController.session, isNull);
    expect(restoredController.friendOverview.friends, isEmpty);
    expect(restoredController.notificationOverview.unreadCount, 0);
  });

  test('offline choice overrides retained online token until login or logout',
      () async {
    final directory = await Directory.systemTemp.createTemp('offline-token-');
    final databasePath = '${directory.path}${Platform.pathSeparator}offline.db';
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
    final store = _store(databasePath);
    final controller = _controller(storage, preferences, store);
    addTearDown(() async {
      controller.dispose();
      await store.close();
      await directory.delete(recursive: true);
    });

    await controller.enterOfflineMode();
    expect(storage.offlineModeActive, isTrue);
    expect(storage.readSession(), isNotNull);
    await store.close();

    final restoredStore = _store(databasePath);
    final restoredController = _controller(storage, preferences, restoredStore);
    addTearDown(() async {
      restoredController.dispose();
      await restoredStore.close();
    });
    await restoredController.initialize();
    expect(restoredController.status, SessionStatus.offline);
    expect(restoredController.session, isNull);

    await restoredController.logout();
    expect(storage.offlineModeActive, isFalse);
    expect(storage.readSession(), isNull);
    expect(restoredController.status, SessionStatus.unauthenticated);
    expect(await restoredStore.readLocalProfile(), isNotNull);
  });

  test('missing local profile does not silently create a replacement',
      () async {
    final directory = await Directory.systemTemp.createTemp('offline-missing-');
    final databasePath = '${directory.path}${Platform.pathSeparator}offline.db';
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AuthLocalStorage(preferences);
    await storage.setOfflineModeActive(true);
    final store = _store(databasePath);
    final controller = _controller(storage, preferences, store);
    addTearDown(() async {
      controller.dispose();
      await store.close();
      await directory.delete(recursive: true);
    });

    await controller.initialize();
    expect(controller.status, SessionStatus.unauthenticated);
    expect(storage.offlineModeActive, isFalse);
    expect(await store.readLocalProfile(), isNull);
    expect(controller.bannerMessage, contains('本机资料'));
  });

  test('saving an online session clears the offline startup choice', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AuthLocalStorage(preferences);
    await storage.setOfflineModeActive(true);

    await storage.saveSession(const AppSession(
      accessToken: 'synthetic-token',
      tokenType: 'Bearer',
      userId: 42,
      deviceType: 'android',
      deviceSlot: 'mobile',
      deviceId: 'synthetic-device',
    ));

    expect(storage.offlineModeActive, isFalse);
    expect(storage.readSession()?.userId, 42);
  });
}

OfflineStore _store(String databasePath) => OfflineStore(
      databaseFactory: databaseFactoryFfi,
      databasePathProvider: () async => databasePath,
    );

SessionController _controller(
  AuthLocalStorage storage,
  SharedPreferences preferences,
  OfflineStore store,
) =>
    SessionController(
      authApi: AuthApi(),
      localStorage: storage,
      languageController: AppLanguageController(preferences),
      offlineStore: store,
      restoreOfflineOnStartup: true,
    );
