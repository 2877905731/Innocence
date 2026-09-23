import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline plan completion rate refreshes after each task change',
      () async {
    sqfliteFfiInit();
    final tempDirectory =
        await Directory.systemTemp.createTemp('innocence-rate-');
    final store = OfflineStore(
      databaseFactory: databaseFactoryFfi,
      databasePathProvider: () async =>
          '${tempDirectory.path}${Platform.pathSeparator}offline.db',
    );
    SharedPreferences.setMockInitialValues({
      'app.language': 'zh_CN',
      'app.language.startup_confirmed': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(preferences),
      languageController: AppLanguageController(preferences),
      offlineStore: store,
    );
    addTearDown(() async {
      await store.close();
      controller.dispose();
      await tempDirectory.delete(recursive: true);
    });

    await controller.enterOfflineMode();
    expect(controller.status, SessionStatus.offline);
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final plan = TodayPlan.empty(date).copyWith(
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'First',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: null,
          endSlot: null,
          sortOrder: 0,
        ),
        TodayPlanItem(
          id: 0,
          title: 'Second',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: null,
          endSlot: null,
          sortOrder: 1,
        ),
      ],
    );

    await controller.saveTodayPlan(plan);
    expect(controller.statsOverview.planCompletionRate, 0);
    await controller.toggleTodayPlanItem(0, true);
    expect(controller.statsOverview.planCompletionRate, 50);
    await controller.toggleTodayPlanItem(1, true);
    expect(controller.todayPlan.completedCount, 2);
    expect(controller.statsOverview.planCompletionRate, 100);
  });
}
