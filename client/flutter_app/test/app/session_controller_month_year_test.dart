import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FailingStore extends OfflineStore {
  _FailingStore(String path)
      : super(
            databaseFactory: databaseFactoryFfi,
            databasePathProvider: () async => path);
  Exception? failure;
  @override
  Future<AnnualPlanOverview> saveAnnualSegment(
      String ownerScope, AnnualPlanSegment draft) async {
    if (failure != null) throw failure!;
    return super.saveAnnualSegment(ownerScope, draft);
  }

  @override
  Future<TodayPlan> saveDailyPlan(String ownerScope, TodayPlan plan,
      {bool addToOutbox = true}) async {
    if (failure != null) throw failure!;
    return super.saveDailyPlan(ownerScope, plan, addToOutbox: addToOutbox);
  }
}

AnnualPlanSegment _annual(int year) => AnnualPlanSegment(
        id: '',
        clientEntityId: '',
        year: year,
        title: 'Local annual task',
        startMonth: 2,
        endMonth: 12,
        colorKey: 'gold',
        sortOrder: 0,
        note: 'Synthetic fixture',
        progressPercent: 7,
        revision: 0,
        updateTime: '',
        subtasks: const [
          AnnualPlanSubtask(
              id: '',
              title: 'First',
              detail: '',
              completed: true,
              sortOrder: 0),
          AnnualPlanSubtask(
              id: '',
              title: 'Second',
              detail: '',
              completed: false,
              sortOrder: 1),
        ]);
TodayPlan _plan(String date, String title) =>
    TodayPlan.empty(date).copyWith(planName: title, items: [
      TodayPlanItem(
          id: 0,
          title: title,
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: 12,
          endSlot: 13,
          sortOrder: 0),
    ]);
SessionController _controller(SharedPreferences prefs, OfflineStore store) =>
    SessionController(
      authApi: AuthApi(),
      localStorage: AuthLocalStorage(prefs),
      languageController: AppLanguageController(prefs),
      offlineStore: store,
      restoreOfflineOnStartup: true,
      offlineOnlyBuild: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  test(
      'month archives and independent annual tasks survive reopening and preserve owner boundaries',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('innocence-month-year-');
    final path = '${directory.path}${Platform.pathSeparator}offline.db';
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var store = _FailingStore(path);
    var controller = _controller(prefs, store);
    addTearDown(() async {
      controller.dispose();
      await store.close();
      await directory.delete(recursive: true);
    });
    await controller.enterOfflineMode();
    final owner = controller.localOwnerScope!;
    await controller.loadMonthOverview('2028-02');
    expect(
        await controller.saveTodayPlan(_plan('2028-02-07', 'Existing')), true);
    expect(
        await controller.savePlanAsWeeklyTemplate(
            'Study archive', _plan('2028-02-01', 'Reusable')),
        true);
    final archive = controller.weeklyTemplates.single;
    await controller.applyDayTemplateToDates(
        archive.id, ['2028-02-07', '2028-02-08'],
        strategy: PlanApplyStrategy.skip);
    expect((await store.loadDailyPlan(owner, '2028-02-07')).items.single.title,
        'Existing');
    expect((await store.loadDailyPlan(owner, '2028-02-08')).items.single.title,
        'Reusable');
    await controller.applyDayTemplateToDates(archive.id, ['2028-02-07'],
        strategy: PlanApplyStrategy.overwrite);
    expect((await store.loadDailyPlan(owner, '2028-02-07')).items.single.title,
        'Reusable');
    expect(await controller.saveAnnualSegment(_annual(2028)), true);
    final segment = controller.annualPlanOverview.segments.single;
    expect(
        await controller.saveAnnualSegment(segment.adjustProgress(93)), true);
    expect(controller.annualPlanOverview.segments.single.progressPercent, 100);
    expect(
        await controller.saveAnnualSegment(
            controller.annualPlanOverview.segments.single.adjustProgress(-5)),
        true);
    const other = 'account:synthetic-other-user';
    expect((await store.loadMonthOverview(other, '2028-02')).totalTaskCount, 0);
    expect((await store.loadAnnualOverview(other, 2028)).segments, isEmpty);
    expect(await store.loadDayTemplates(other), isEmpty);
    controller.dispose();
    await store.close();
    store = _FailingStore(path);
    controller = _controller(prefs, store);
    await controller.initialize();
    await controller.loadMonthOverview('2028-02');
    await controller.loadAnnualOverview(2028);
    expect(controller.localOwnerScope, owner);
    expect(controller.monthPlanOverview.plannedDayCount, 2);
    expect(controller.weeklyTemplates.single.templateName, 'Study archive');
    final restored = controller.annualPlanOverview.segments.single;
    expect(restored.startMonth, 2);
    expect(restored.endMonth, 12);
    expect(restored.progressPercent, 95);
    expect(restored.colorKey, 'gold');
    expect(restored.subtasks.map((s) => s.completed), [true, false]);
    await controller.deleteAnnualSegment(restored);
    expect(controller.annualPlanOverview.segments, isEmpty);
    final outbox = await store.loadPendingSyncOperations(owner);
    expect(
        outbox.any((item) =>
            item.aggregateType == 'annual_segment' &&
            item.operationType == 'delete'),
        true);
  });

  test(
      'missing session, rejected writes and invalid month spans return failure without false success',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('innocence-save-result-');
    final path = '${directory.path}${Platform.pathSeparator}offline.db';
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = _FailingStore(path);
    final controller = _controller(prefs, store);
    addTearDown(() async {
      controller.dispose();
      await store.close();
      await directory.delete(recursive: true);
    });
    expect(await controller.saveAnnualSegment(_annual(2028)), false);
    expect(await controller.saveTodayPlan(_plan('2028-02-07', 'Not saved')),
        false);
    await controller.enterOfflineMode();
    expect(
        await controller
            .saveAnnualSegment(_annual(2028).copyWith(startMonth: 0)),
        false);
    expect(controller.annualPlanOverview.segments, isEmpty);
    for (final failure in [
      const ApiException('Authentication failed', statusCode: 401),
      const ApiException('Permission denied', statusCode: 403),
      const ApiException('Missing required field', statusCode: 400),
      const FileSystemException('Synthetic storage failure'),
    ]) {
      store.failure = failure;
      expect(await controller.saveAnnualSegment(_annual(2028)), false);
      expect(await controller.saveTodayPlan(_plan('2028-02-07', 'Not saved')),
          false);
      expect(controller.annualPlanOverview.segments, isEmpty);
      expect(controller.isBusy, false);
      expect(controller.bannerMessage, isNotNull);
    }
  });
}
