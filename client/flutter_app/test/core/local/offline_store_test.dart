import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/core/local/offline_sync_models.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late OfflineStore store;

  setUp(() async {
    sqfliteFfiInit();
    tempDirectory = await Directory.systemTemp.createTemp('innocence-offline-');
    store = OfflineStore(
      databaseFactory: databaseFactoryFfi,
      databasePathProvider: () async =>
          '${tempDirectory.path}${Platform.pathSeparator}offline.db',
    );
  });

  tearDown(() async {
    await store.close();
    await tempDirectory.delete(recursive: true);
  });

  test('creates a stable local identity without a server user id', () async {
    final first = await store.getOrCreateLocalProfile();
    final second = await store.getOrCreateLocalProfile();

    expect(first.localProfileId, second.localProfileId);
    expect(first.ownerScope, startsWith('local:'));
    expect(first.toUserProfile().userId, isNull);
    expect(first.toUserProfile().isLocal, isTrue);
  });

  test('persists device-only desktop settings without queueing cloud work',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    const setting = WidgetSetting(
      autoStart: true,
      alwaysOnTop: true,
      showPlan: false,
      showTimer: true,
      showMemo: false,
    );

    final saved = await store.saveLocalWidgetSetting(
      profile.ownerScope,
      setting,
    );
    final restored = await store.loadLocalWidgetSetting(profile.ownerScope);

    expect(saved.autoStart, isTrue);
    expect(restored.alwaysOnTop, isTrue);
    expect(restored.showPlan, isFalse);
    expect(restored.showTimer, isTrue);
    expect(restored.showMemo, isFalse);
    expect(await store.pendingOutboxCount(profile.ownerScope), 0);
  });

  test('persists daily plans and queues one atomic outbox operation', () async {
    final profile = await store.getOrCreateLocalProfile();
    final plan = TodayPlan.empty('2026-09-08').copyWith(
      planName: 'Tuesday',
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'Read chapter 4',
          completed: false,
          plannedMinutes: 45,
          actualMinutes: 0,
          startSlot: 18,
          endSlot: 20,
          sortOrder: 0,
        ),
      ],
    );

    final saved = await store.saveDailyPlan(profile.ownerScope, plan);
    final loaded = await store.loadDailyPlan(
      profile.ownerScope,
      plan.planDate,
    );

    expect(saved.planName, 'Tuesday');
    expect(loaded.items, hasLength(1));
    expect(loaded.items.single.id, 1);
    expect(loaded.items.single.title, 'Read chapter 4');
    expect(await store.pendingOutboxCount(profile.ownerScope), 1);
  });

  test('supports local memo create, update, and delete', () async {
    final profile = await store.getOrCreateLocalProfile();
    const draft = MemoCardModel(
      memoId: 0,
      title: 'Ideas',
      content: 'First note',
      totalItemCount: 1,
      checkedItemCount: 0,
      updateTime: '',
      checkItems: [
        MemoCheckItemModel(
          id: 0,
          itemText: 'Try local mode',
          checked: false,
          sortNo: 0,
        ),
      ],
    );

    final created = await store.saveMemo(profile.ownerScope, draft);
    final memoId = created.items.single.memoId;
    final updated = await store.saveMemo(
      profile.ownerScope,
      draft.copyWith(content: 'Updated note'),
      memoId: memoId,
    );
    final deleted = await store.deleteMemo(profile.ownerScope, memoId);

    expect(updated.items.single.content, 'Updated note');
    expect(deleted.items, isEmpty);
    expect(await store.pendingOutboxCount(profile.ownerScope), 3);
  });

  test('persists an offline focus lifecycle', () async {
    final profile = await store.getOrCreateLocalProfile();
    final started = await store.startFocusSession(
      profile.ownerScope,
      endTime: DateTime.now().add(const Duration(minutes: 20)),
      taskName: 'Deep work',
    );
    final paused = await store.pauseFocusSession(
      profile.ownerScope,
      started.sessionId,
    );
    final restoredPaused =
        await store.loadActiveFocusSession(profile.ownerScope);
    final resumed = await store.resumeFocusSession(
      profile.ownerScope,
      started.sessionId,
    );
    final finished = await store.finishFocusSession(
      profile.ownerScope,
      started.sessionId,
    );

    expect(started.active, isTrue);
    expect(paused.paused, isTrue);
    expect(restoredPaused.paused, isTrue);
    expect(restoredPaused.taskName, 'Deep work');
    expect(resumed.active, isTrue);
    expect(resumed.paused, isFalse);
    expect(finished.active, isFalse);
    expect(await store.pendingOutboxCount(profile.ownerScope), 2);
  });

  test('migrates version 2 focus history without losing elapsed time',
      () async {
    final databasePath =
        '${tempDirectory.path}${Platform.pathSeparator}offline.db';
    final legacyDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) async {
          await database.execute('''CREATE TABLE local_focus_session (
            owner_scope TEXT NOT NULL,
            session_id INTEGER NOT NULL,
            active INTEGER NOT NULL DEFAULT 0,
            start_time TEXT NOT NULL,
            planned_end_time TEXT NOT NULL,
            actual_end_time TEXT NOT NULL DEFAULT '',
            planned_minutes INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (owner_scope, session_id)
          )''');
        },
      ),
    );
    await legacyDatabase.insert('local_focus_session', {
      'owner_scope': 'local:test',
      'session_id': 1,
      'active': 0,
      'start_time': '2026-09-10T00:00:00.000',
      'planned_end_time': '2026-09-10T00:30:00.000',
      'actual_end_time': '2026-09-10T00:10:00.000',
      'planned_minutes': 30,
      'updated_at': '2026-09-10T00:10:00.000',
    });
    await legacyDatabase.close();

    await store.initialize();
    await store.close();
    final migratedDatabase =
        await databaseFactoryFfi.openDatabase(databasePath);
    final columns = await migratedDatabase.rawQuery(
      'PRAGMA table_info(local_focus_session)',
    );
    final rows = await migratedDatabase.query('local_focus_session');
    await migratedDatabase.close();

    expect(columns.map((column) => column['name']), contains('paused'));
    expect(
        columns.map((column) => column['name']), contains('elapsed_seconds'));
    expect(rows.single['elapsed_seconds'], 600);
    expect(rows.single['remaining_seconds'], 0);
  });

  test('builds month summaries and applies saved day templates explicitly',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    final source = TodayPlan.empty('2026-09-08').copyWith(
      planName: 'Study rhythm',
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'Morning review',
          completed: true,
          plannedMinutes: 30,
          actualMinutes: 25,
          startSlot: 16,
          endSlot: 17,
          sortOrder: 0,
        ),
      ],
    );
    await store.saveDailyPlan(profile.ownerScope, source);
    final templates = await store.saveDayTemplate(
      profile.ownerScope,
      templateName: 'Morning',
      sourcePlan: source,
    );
    final applied = await store.applyDayTemplate(
      profile.ownerScope,
      templateId: templates.single.id,
      planDate: '2026-09-12',
      strategy: PlanApplyStrategy.overwrite,
    );
    final month = await store.loadMonthOverview(
      profile.ownerScope,
      '2026-09',
    );

    expect(applied.items.single.completed, isFalse);
    expect(month.plannedDayCount, 2);
    expect(month.dayFor('2026-09-08').completedCount, 1);
    expect(month.dayFor('2026-09-12').totalPlannedMinutes, 30);
  });

  test('updates and deletes a reusable task archive by name', () async {
    final profile = await store.getOrCreateLocalProfile();
    final firstPlan = TodayPlan.empty('2026-09-08').copyWith(
      planName: 'Morning',
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'Read',
          completed: false,
          plannedMinutes: 20,
          actualMinutes: 0,
          startSlot: null,
          endSlot: null,
          sortOrder: 0,
        ),
      ],
    );
    final created = await store.saveDayTemplate(
      profile.ownerScope,
      templateName: 'Reading archive',
      sourcePlan: firstPlan,
    );
    final updated = await store.saveDayTemplate(
      profile.ownerScope,
      templateName: 'Reading archive',
      sourcePlan: firstPlan.copyWith(
        items: [firstPlan.items.single.copyWith(title: 'Read two chapters')],
      ),
    );
    final deleted = await store.deleteDayTemplate(
      profile.ownerScope,
      created.single.id,
    );

    expect(updated, hasLength(1));
    expect(updated.single.id, created.single.id);
    expect(updated.single.items.single.title, 'Read two chapters');
    expect(deleted, isEmpty);
  });

  test('creates, updates, and deletes independent annual tasks with subtasks',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    const draft = AnnualPlanSegment(
      id: '',
      clientEntityId: '',
      year: 2026,
      title: 'Build the foundation',
      startMonth: 2,
      endMonth: 5,
      colorKey: 'accent',
      sortOrder: 0,
      note: 'One calm step at a time',
      progressPercent: 15,
      revision: 0,
      updateTime: '',
      subtasks: [
        AnnualPlanSubtask(
          id: '',
          title: 'First step',
          detail: 'Write the outline',
          completed: false,
          sortOrder: 0,
        ),
        AnnualPlanSubtask(
          id: '',
          title: 'Second step',
          detail: 'Review the outline',
          completed: false,
          sortOrder: 1,
        ),
      ],
    );

    final created = await store.saveAnnualSegment(profile.ownerScope, draft);
    final segment = created.segments.single;
    final updated = await store.saveAnnualSegment(
      profile.ownerScope,
      segment.copyWith(
        endMonth: 6,
        title: 'Foundation first',
        progressPercent: 36,
        subtasks: [
          segment.subtasks.first.copyWith(completed: true),
          segment.subtasks.last,
        ],
      ),
    );
    final deleted = await store.deleteAnnualSegment(
      profile.ownerScope,
      updated.segments.single,
    );

    expect(segment.id, isNotEmpty);
    expect(segment.subtasks, hasLength(2));
    expect(segment.subtasks.first.id, isNotEmpty);
    expect(segment.subtasks.first.detail, 'Write the outline');
    expect(segment.progressPercent, 15);
    expect(updated.segments.single.endMonth, 6);
    expect(updated.segments.single.revision, 2);
    expect(updated.segments.single.completedSubtaskCount, 1);
    expect(updated.segments.single.progressPercent, 36);
    expect(deleted.segments, isEmpty);
  });

  test('upgrades a version 4 annual task with zero progress', () async {
    final path = '${tempDirectory.path}${Platform.pathSeparator}offline.db';
    final legacy = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (database, version) async {
          await database.execute('''CREATE TABLE local_annual_segment (
            owner_scope TEXT NOT NULL,
            segment_id TEXT NOT NULL,
            progress_marker TEXT NOT NULL DEFAULT '',
            PRIMARY KEY (owner_scope, segment_id)
          )''');
          await database.insert('local_annual_segment', {
            'owner_scope': 'local:test',
            'segment_id': 'existing',
          });
        },
      ),
    );
    await legacy.close();

    await store.initialize();
    final migrated = await databaseFactoryFfi.openDatabase(path);
    final rows = await migrated.query('local_annual_segment');
    expect(rows.single['progress_percent'], 0);
    await migrated.close();
  });

  test('builds metadata-only manifest and dependency-ordered operations',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    final plan = TodayPlan.empty('2026-09-08').copyWith(
      planName: 'Import day',
      items: const [
        TodayPlanItem(
          id: 0,
          title: 'Prepare import',
          completed: true,
          plannedMinutes: 20,
          actualMinutes: 20,
          startSlot: null,
          endSlot: null,
          sortOrder: 0,
        ),
      ],
    );
    await store.saveDailyPlan(profile.ownerScope, plan);
    await store.saveDayTemplate(
      profile.ownerScope,
      templateName: 'Import template',
      sourcePlan: plan,
    );
    await store.recordCheckInIntent(profile.ownerScope, plan.planDate);

    final manifest = await store.buildImportManifest(
      profile.ownerScope,
      profile.localProfileId,
    );
    final operations =
        await store.loadPendingSyncOperations(profile.ownerScope);

    expect(manifest.pendingOperationCount, 3);
    expect(manifest.dailyPlanDates, ['2026-09-08']);
    expect(manifest.operationCounts['daily_plan'], 1);
    expect(operations.map((item) => item.aggregateType), [
      'day_template',
      'daily_plan',
      'checkin_intent',
    ]);
    expect(manifest.toJson().toString(), isNot(contains('Prepare import')));
  });

  test('marks only accepted imports synced and retains rejected operations',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    await store.saveDailyPlan(
      profile.ownerScope,
      TodayPlan.empty('2026-09-08').copyWith(planName: 'Accepted'),
    );
    await store.saveDailyPlan(
      profile.ownerScope,
      TodayPlan.empty('2026-09-09').copyWith(planName: 'Conflict'),
    );
    final operations =
        await store.loadPendingSyncOperations(profile.ownerScope);
    final accepted = operations.first;
    final rejected = operations.last;

    await store.applyImportResult(
      profile.ownerScope,
      localProfileId: profile.localProfileId,
      serverUserId: 42,
      result: OfflineImportResult(
        acceptedCount: 1,
        rejectedCount: 0,
        conflictCount: 1,
        items: [
          OfflineImportItemResult(
            operationId: accepted.operationId,
            aggregateType: accepted.aggregateType,
            aggregateId: accepted.aggregateId,
            status: 'accepted',
            message: 'Imported.',
            serverAggregateId: accepted.aggregateId,
          ),
          OfflineImportItemResult(
            operationId: rejected.operationId,
            aggregateType: rejected.aggregateType,
            aggregateId: rejected.aggregateId,
            status: 'conflict',
            message: 'Keep server.',
            serverAggregateId: '',
          ),
        ],
      ),
    );

    expect(await store.pendingOutboxCount(profile.ownerScope), 1);
    final remaining = await store.loadPendingSyncOperations(profile.ownerScope);
    expect(remaining.single.operationId, rejected.operationId);
    expect(
      (await store.loadDailyPlan(profile.ownerScope, '2026-09-08')).planName,
      'Accepted',
    );
  });

  test('derives offline statistics from local plans without cloud data',
      () async {
    final profile = await store.getOrCreateLocalProfile();
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await store.saveDailyPlan(
      profile.ownerScope,
      TodayPlan.empty(today).copyWith(
        planName: 'Local progress',
        items: const [
          TodayPlanItem(
            id: 1,
            title: 'Done',
            completed: true,
            plannedMinutes: 20,
            actualMinutes: 20,
            startSlot: null,
            endSlot: null,
            sortOrder: 0,
          ),
          TodayPlanItem(
            id: 2,
            title: 'Next',
            completed: false,
            plannedMinutes: 20,
            actualMinutes: 0,
            startSlot: null,
            endSlot: null,
            sortOrder: 1,
          ),
        ],
      ),
    );

    final stats = await store.loadStatsOverview(profile.ownerScope, days: 7);

    expect(stats.rangeDays, 7);
    expect(stats.trend, hasLength(7));
    expect(stats.activePlanDays, 1);
    expect(stats.planCompletionRate, 50);
    expect(stats.trend.last.planCompletionRate, 50);
    expect(stats.teammates, isEmpty);
  });
}
