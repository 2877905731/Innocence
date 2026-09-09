import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile_sqlite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../features/focus/domain/models/focus_session.dart';
import '../../features/memos/domain/models/memo_overview.dart';
import '../../features/plans/domain/models/annual_plan_overview.dart';
import '../../features/plans/domain/models/month_plan_overview.dart';
import '../../features/plans/domain/models/today_plan.dart';
import '../../features/plans/domain/models/weekly_plan_template.dart';
import '../../features/settings/domain/models/widget_setting.dart';
import '../../features/stats/domain/models/stats_overview.dart';
import 'local_profile.dart';
import 'offline_sync_models.dart';

typedef OfflineDatabasePathProvider = Future<String> Function();

class OfflineStore {
  OfflineStore({
    DatabaseFactory? databaseFactory,
    OfflineDatabasePathProvider? databasePathProvider,
  })  : _databaseFactory = databaseFactory,
        _databasePathProvider = databasePathProvider;

  final DatabaseFactory? _databaseFactory;
  final OfflineDatabasePathProvider? _databasePathProvider;
  Database? _database;

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }
    final factory = _databaseFactory ?? _defaultDatabaseFactory();
    final path = _databasePathProvider == null
        ? await _defaultDatabasePath()
        : await _databasePathProvider();
    _database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) => _createSchema(database),
        onUpgrade: (database, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createLocalWidgetSettingTable(database);
          }
        },
      ),
    );
  }

  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  Future<LocalProfile> getOrCreateLocalProfile() async {
    final database = await _readyDatabase();
    final rows = await database.query('local_profile', limit: 1);
    if (rows.isNotEmpty) {
      return _profileFromRow(rows.first);
    }

    final now = DateTime.now().toUtc();
    final profile = LocalProfile(
      localProfileId: _uuidV4(),
      nickname: '本地用户',
      timezone: DateTime.now().timeZoneName,
      createdAt: now,
      updatedAt: now,
    );
    await database.insert('local_profile', {
      'local_profile_id': profile.localProfileId,
      'nickname': profile.nickname,
      'timezone': profile.timezone,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    return profile;
  }

  Future<LocalProfile?> readLocalProfile() async {
    final database = await _readyDatabase();
    final rows = await database.query('local_profile', limit: 1);
    return rows.isEmpty ? null : _profileFromRow(rows.first);
  }

  Future<WidgetSetting> loadLocalWidgetSetting(String ownerScope) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_widget_setting',
      where: 'owner_scope = ?',
      whereArgs: [ownerScope],
      limit: 1,
    );
    if (rows.isEmpty) {
      return WidgetSetting.empty();
    }
    final row = rows.first;
    return WidgetSetting(
      autoStart: row['auto_start'] == 1,
      alwaysOnTop: row['always_on_top'] == 1,
      showPlan: row['show_plan'] == 1,
      showTimer: row['show_timer'] == 1,
      showMemo: row['show_memo'] == 1,
    );
  }

  Future<WidgetSetting> saveLocalWidgetSetting(
    String ownerScope,
    WidgetSetting setting,
  ) async {
    final database = await _readyDatabase();
    await database.insert(
      'local_widget_setting',
      {
        'owner_scope': ownerScope,
        'auto_start': setting.autoStart ? 1 : 0,
        'always_on_top': setting.alwaysOnTop ? 1 : 0,
        'show_plan': setting.showPlan ? 1 : 0,
        'show_timer': setting.showTimer ? 1 : 0,
        'show_memo': setting.showMemo ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return loadLocalWidgetSetting(ownerScope);
  }

  Future<OfflineImportManifest> buildImportManifest(
    String ownerScope,
    String localProfileId,
  ) async {
    final database = await _readyDatabase();
    final countRows = await database.rawQuery(
      '''SELECT aggregate_type, COUNT(*) AS operation_count
      FROM sync_outbox
      WHERE owner_scope = ? AND status = 'pending'
      GROUP BY aggregate_type''',
      [ownerScope],
    );
    final operationCounts = <String, int>{};
    var total = 0;
    for (final row in countRows) {
      final count = row['operation_count'] as int? ?? 0;
      operationCounts['${row['aggregate_type']}'] = count;
      total += count;
    }
    final dateRows = await database.rawQuery(
      '''SELECT DISTINCT aggregate_id
      FROM sync_outbox
      WHERE owner_scope = ?
        AND status = 'pending'
        AND aggregate_type = 'daily_plan'
      ORDER BY aggregate_id''',
      [ownerScope],
    );
    return OfflineImportManifest(
      localProfileId: localProfileId,
      pendingOperationCount: total,
      dailyPlanDates: dateRows.map((row) => '${row['aggregate_id']}').toList(),
      operationCounts: operationCounts,
    );
  }

  Future<List<OfflineSyncOperation>> loadPendingSyncOperations(
    String ownerScope,
  ) async {
    final database = await _readyDatabase();
    final rows = await database.rawQuery(
      '''SELECT * FROM sync_outbox
      WHERE owner_scope = ? AND status = 'pending'
      ORDER BY CASE aggregate_type
        WHEN 'day_template' THEN 1
        WHEN 'daily_plan' THEN 2
        WHEN 'annual_segment' THEN 3
        WHEN 'focus_session' THEN 4
        WHEN 'memo' THEN 5
        WHEN 'checkin_intent' THEN 6
        ELSE 99 END,
        created_at,
        operation_id''',
      [ownerScope],
    );
    return rows.map((row) {
      final decoded = jsonDecode('${row['payload_json']}');
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid offline outbox payload.');
      }
      return OfflineSyncOperation(
        operationId: '${row['operation_id']}',
        aggregateType: '${row['aggregate_type']}',
        aggregateId: '${row['aggregate_id']}',
        operationType: '${row['operation_type']}',
        payload: decoded,
        clientVersion: row['client_version'] as int? ?? 1,
        createdAt: '${row['created_at']}',
        idempotencyKey: '${row['idempotency_key']}',
      );
    }).toList();
  }

  Future<void> applyImportResult(
    String ownerScope, {
    required String localProfileId,
    required int serverUserId,
    required OfflineImportResult result,
  }) async {
    final database = await _readyDatabase();
    final syncedAt = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      for (final item in result.items) {
        if (item.accepted) {
          await transaction.update(
            'sync_outbox',
            {'status': 'synced', 'last_error': ''},
            where: 'owner_scope = ? AND operation_id = ?',
            whereArgs: [ownerScope, item.operationId],
          );
          if (item.serverAggregateId.isNotEmpty) {
            await transaction.insert(
              'sync_binding',
              {
                'local_profile_id': localProfileId,
                'server_user_id': serverUserId,
                'aggregate_type': item.aggregateType,
                'local_aggregate_id': item.aggregateId,
                'server_aggregate_id': item.serverAggregateId,
                'synced_at': syncedAt,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          await _clearDirtyWhenFullySynced(
            transaction,
            ownerScope,
            item.aggregateType,
            item.aggregateId,
          );
        } else {
          await transaction.rawUpdate(
            '''UPDATE sync_outbox
            SET retry_count = retry_count + 1, last_error = ?
            WHERE owner_scope = ? AND operation_id = ?''',
            [item.message, ownerScope, item.operationId],
          );
        }
      }
    });
  }

  Future<TodayPlan> loadDailyPlan(
    String ownerScope,
    String planDate,
  ) async {
    final database = await _readyDatabase();
    final planRows = await database.query(
      'local_daily_plan',
      where: 'owner_scope = ? AND plan_date = ?',
      whereArgs: [ownerScope, planDate],
      limit: 1,
    );
    if (planRows.isEmpty) {
      return TodayPlan.empty(planDate);
    }
    final itemRows = await database.query(
      'local_daily_plan_item',
      where: 'owner_scope = ? AND plan_date = ?',
      whereArgs: [ownerScope, planDate],
      orderBy: 'sort_order ASC, item_id ASC',
    );
    return TodayPlan.fromJson({
      'planDate': planDate,
      'planName': planRows.first['plan_name'],
      'items': itemRows
          .map(
            (row) => {
              'id': row['item_id'],
              'title': row['title'],
              'completed': row['completed'],
              'plannedMinutes': row['planned_minutes'],
              'actualMinutes': row['actual_minutes'],
              'startSlot': row['start_slot'],
              'endSlot': row['end_slot'],
              'sortOrder': row['sort_order'],
            },
          )
          .toList(),
    });
  }

  Future<TodayPlan> saveDailyPlan(
    String ownerScope,
    TodayPlan plan, {
    bool addToOutbox = true,
  }) async {
    final database = await _readyDatabase();
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.insert(
        'local_daily_plan',
        {
          'owner_scope': ownerScope,
          'plan_date': plan.planDate,
          'plan_name': plan.planName,
          'updated_at': now,
          'dirty': addToOutbox ? 1 : 0,
          'template_applied': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.delete(
        'local_daily_plan_item',
        where: 'owner_scope = ? AND plan_date = ?',
        whereArgs: [ownerScope, plan.planDate],
      );
      for (var index = 0; index < plan.items.length; index += 1) {
        final item = plan.items[index];
        await transaction.insert('local_daily_plan_item', {
          'owner_scope': ownerScope,
          'plan_date': plan.planDate,
          'item_id': item.id > 0 ? item.id : index + 1,
          'title': item.title,
          'completed': item.completed ? 1 : 0,
          'planned_minutes': item.plannedMinutes,
          'actual_minutes': item.actualMinutes,
          'start_slot': item.startSlot,
          'end_slot': item.endSlot,
          'sort_order': index,
        });
      }
      if (addToOutbox) {
        await _enqueue(
          transaction,
          ownerScope: ownerScope,
          aggregateType: 'daily_plan',
          aggregateId: plan.planDate,
          operationType: 'upsert',
          payload: plan.toSaveJson(),
          createdAt: now,
        );
      }
    });
    return loadDailyPlan(ownerScope, plan.planDate);
  }

  Future<MemoOverview> loadMemoOverview(String ownerScope) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_memo',
      where: 'owner_scope = ?',
      whereArgs: [ownerScope],
      orderBy: 'updated_at DESC, memo_id DESC',
    );
    final memos = <MemoCardModel>[];
    for (final row in rows) {
      memos.add(await _loadMemoFromRow(database, ownerScope, row));
    }
    return MemoOverview(totalCount: memos.length, items: memos);
  }

  Future<StatsOverview> loadStatsOverview(
    String ownerScope, {
    int days = 7,
  }) async {
    final database = await _readyDatabase();
    final rangeDays = days == 30 ? 30 : 7;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: rangeDays - 1));
    final endExclusive = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));
    final planRows = await database.rawQuery(
      '''SELECT p.plan_date,
        COUNT(i.item_id) AS total_count,
        COALESCE(SUM(CASE WHEN i.completed = 1 THEN 1 ELSE 0 END), 0)
          AS completed_count
      FROM local_daily_plan p
      LEFT JOIN local_daily_plan_item i
        ON p.owner_scope = i.owner_scope AND p.plan_date = i.plan_date
      WHERE p.owner_scope = ? AND p.plan_date >= ? AND p.plan_date < ?
      GROUP BY p.plan_date
      ORDER BY p.plan_date''',
      [ownerScope, _formatDate(start), _formatDate(endExclusive)],
    );
    final planByDate = <String, Map<String, Object?>>{
      for (final row in planRows) '${row['plan_date']}': row,
    };
    final focusRows = await database.query(
      'local_focus_session',
      where: 'owner_scope = ?',
      whereArgs: [ownerScope],
      orderBy: 'start_time',
    );
    final studyMinutesByDate = <String, int>{};
    final pomodoroByDate = <String, int>{};
    var totalStudyDurationMinutes = 0;
    var totalPomodoroCompleted = 0;
    for (final row in focusRows) {
      final startTime = DateTime.tryParse('${row['start_time']}');
      if (startTime == null) {
        continue;
      }
      final durationMinutes = _localFocusDurationMinutes(row, today);
      final pomodoroCount = _localPomodoroCount(row, durationMinutes);
      totalStudyDurationMinutes += durationMinutes;
      totalPomodoroCompleted += pomodoroCount;
      final date = _formatDate(startTime);
      studyMinutesByDate.update(
        date,
        (value) => value + durationMinutes,
        ifAbsent: () => durationMinutes,
      );
      pomodoroByDate.update(
        date,
        (value) => value + pomodoroCount,
        ifAbsent: () => pomodoroCount,
      );
    }

    final trend = <StatsTrendPoint>[];
    var completedTaskCount = 0;
    var totalTaskCount = 0;
    for (var offset = 0; offset < rangeDays; offset += 1) {
      final date = start.add(Duration(days: offset));
      final dateText = _formatDate(date);
      final plan = planByDate[dateText];
      final dayCompleted = plan?['completed_count'] as int? ?? 0;
      final dayTotal = plan?['total_count'] as int? ?? 0;
      completedTaskCount += dayCompleted;
      totalTaskCount += dayTotal;
      trend.add(
        StatsTrendPoint(
          date: dateText,
          label: '${date.month}/${date.day}',
          hasPlan: dayTotal > 0,
          studyDurationMinutes: studyMinutesByDate[dateText] ?? 0,
          pomodoroCompletedCount: pomodoroByDate[dateText] ?? 0,
          checkInSuccessCount: 0,
          failedCheckInAttempts: 0,
          planCompletedCount: dayCompleted,
          planTotalCount: dayTotal,
          planCompletionRate:
              dayTotal <= 0 ? 0 : ((dayCompleted * 100) / dayTotal).round(),
          checkInSuccessRate: 0,
        ),
      );
    }
    return StatsOverview(
      rangeDays: rangeDays,
      activePlanDays:
          planRows.where((row) => (row['total_count'] as int? ?? 0) > 0).length,
      totalStudyDurationMinutes: totalStudyDurationMinutes,
      totalPomodoroCompleted: totalPomodoroCompleted,
      totalCheckInDays: 0,
      totalFailedCheckInAttempts: 0,
      planCompletionRate: totalTaskCount <= 0
          ? 0
          : ((completedTaskCount * 100) / totalTaskCount).round(),
      checkInSuccessRate: 0,
      trend: trend,
      failures: const [],
      teammates: const [],
    );
  }

  Future<MonthPlanOverview> loadMonthOverview(
    String ownerScope,
    String month,
  ) async {
    final database = await _readyDatabase();
    final start = DateTime.tryParse('$month-01');
    if (start == null) {
      throw ArgumentError.value(month, 'month', 'Expected YYYY-MM.');
    }
    final next = DateTime(start.year, start.month + 1);
    final rows = await database.rawQuery(
      '''SELECT p.plan_date, p.plan_name, p.template_applied,
        COUNT(i.item_id) AS total_count,
        COALESCE(SUM(CASE WHEN i.completed = 1 THEN 1 ELSE 0 END), 0)
          AS completed_count,
        COALESCE(SUM(i.planned_minutes), 0) AS total_planned_minutes
      FROM local_daily_plan p
      LEFT JOIN local_daily_plan_item i
        ON p.owner_scope = i.owner_scope AND p.plan_date = i.plan_date
      WHERE p.owner_scope = ? AND p.plan_date >= ? AND p.plan_date < ?
      GROUP BY p.plan_date, p.plan_name, p.template_applied
      ORDER BY p.plan_date''',
      [ownerScope, _formatDate(start), _formatDate(next)],
    );
    return MonthPlanOverview.fromJson({
      'month': month,
      'days': rows
          .map(
            (row) => {
              'planDate': row['plan_date'],
              'hasPlan': (row['total_count'] as int? ?? 0) > 0,
              'planName': row['plan_name'],
              'completedCount': row['completed_count'],
              'totalCount': row['total_count'],
              'totalPlannedMinutes': row['total_planned_minutes'],
              'templateApplied': row['template_applied'],
            },
          )
          .toList(),
    });
  }

  Future<List<WeeklyPlanTemplate>> loadDayTemplates(String ownerScope) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_day_template',
      where: 'owner_scope = ?',
      whereArgs: [ownerScope],
      orderBy: 'updated_at DESC',
    );
    final templates = <WeeklyPlanTemplate>[];
    for (final row in rows) {
      final templateId = int.tryParse('${row['template_id']}') ?? 0;
      final itemRows = await database.query(
        'local_day_template_item',
        where: 'owner_scope = ? AND template_id = ?',
        whereArgs: [ownerScope, '$templateId'],
        orderBy: 'sort_order ASC, item_id ASC',
      );
      templates.add(
        WeeklyPlanTemplate.fromJson({
          'id': templateId,
          'templateName': row['template_name'],
          'sourcePlanName': row['source_plan_name'],
          'items': itemRows
              .map(
                (item) => {
                  'id': item['item_id'],
                  'title': item['title'],
                  'completed': false,
                  'plannedMinutes': item['planned_minutes'],
                  'actualMinutes': 0,
                  'startSlot': item['start_slot'],
                  'endSlot': item['end_slot'],
                  'sortOrder': item['sort_order'],
                },
              )
              .toList(),
        }),
      );
    }
    return templates;
  }

  Future<List<WeeklyPlanTemplate>> saveDayTemplate(
    String ownerScope, {
    required String templateName,
    required TodayPlan sourcePlan,
  }) async {
    final database = await _readyDatabase();
    final idRows = await database.rawQuery(
      'SELECT COALESCE(MAX(CAST(template_id AS INTEGER)), 0) + 1 AS next_id '
      'FROM local_day_template WHERE owner_scope = ?',
      [ownerScope],
    );
    final templateId = idRows.first['next_id'] as int;
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.insert('local_day_template', {
        'owner_scope': ownerScope,
        'template_id': '$templateId',
        'template_name': templateName,
        'source_plan_name': sourcePlan.planName,
        'created_at': now,
        'updated_at': now,
        'dirty': 1,
      });
      for (var index = 0; index < sourcePlan.items.length; index += 1) {
        final item = sourcePlan.items[index];
        await transaction.insert('local_day_template_item', {
          'owner_scope': ownerScope,
          'template_id': '$templateId',
          'item_id': index + 1,
          'title': item.title,
          'planned_minutes': item.plannedMinutes,
          'start_slot': item.startSlot,
          'end_slot': item.endSlot,
          'sort_order': index,
        });
      }
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'day_template',
        aggregateId: '$templateId',
        operationType: 'create',
        payload: {
          'templateName': templateName,
          'sourcePlanName': sourcePlan.planName,
          'items': sourcePlan.items.map((item) => item.toSaveJson()).toList(),
        },
        createdAt: now,
      );
    });
    return loadDayTemplates(ownerScope);
  }

  Future<TodayPlan> applyDayTemplate(
    String ownerScope, {
    required int templateId,
    required String planDate,
    required PlanApplyStrategy strategy,
  }) async {
    final existing = await loadDailyPlan(ownerScope, planDate);
    if (existing.hasItems && strategy == PlanApplyStrategy.skip) {
      return existing;
    }
    final templates = await loadDayTemplates(ownerScope);
    final template = templates.firstWhere(
      (item) => item.id == templateId,
      orElse: () => throw StateError('Day template not found.'),
    );
    final plan = TodayPlan.empty(planDate).copyWith(
      planName: template.sourcePlanName,
      items: template.items
          .asMap()
          .entries
          .map(
            (entry) => entry.value.copyWith(
              completed: false,
              actualMinutes: 0,
              sortOrder: entry.key,
            ),
          )
          .toList(),
    );
    final saved = await saveDailyPlan(ownerScope, plan);
    await (await _readyDatabase()).update(
      'local_daily_plan',
      {'template_applied': 1},
      where: 'owner_scope = ? AND plan_date = ?',
      whereArgs: [ownerScope, planDate],
    );
    return saved;
  }

  Future<AnnualPlanOverview> loadAnnualOverview(
    String ownerScope,
    int year,
  ) async {
    final database = await _readyDatabase();
    final planRows = await database.rawQuery(
      '''SELECT CAST(SUBSTR(p.plan_date, 6, 2) AS INTEGER) AS month,
        COUNT(DISTINCT p.plan_date) AS planned_day_count,
        COUNT(i.item_id) AS total_task_count,
        COALESCE(SUM(CASE WHEN i.completed = 1 THEN 1 ELSE 0 END), 0)
          AS completed_task_count,
        COALESCE(SUM(i.planned_minutes), 0) AS total_planned_minutes
      FROM local_daily_plan p
      LEFT JOIN local_daily_plan_item i
        ON p.owner_scope = i.owner_scope AND p.plan_date = i.plan_date
      WHERE p.owner_scope = ? AND p.plan_date >= ? AND p.plan_date < ?
      GROUP BY SUBSTR(p.plan_date, 6, 2)
      ORDER BY month''',
      [ownerScope, '$year-01-01', '${year + 1}-01-01'],
    );
    final segmentRows = await database.query(
      'local_annual_segment',
      where: 'owner_scope = ? AND year = ?',
      whereArgs: [ownerScope, year],
      orderBy: 'sort_order ASC, updated_at ASC',
    );
    return AnnualPlanOverview.fromJson({
      'year': year,
      'months': planRows
          .map(
            (row) => {
              'month': row['month'],
              'plannedDayCount': row['planned_day_count'],
              'completedTaskCount': row['completed_task_count'],
              'totalTaskCount': row['total_task_count'],
              'totalPlannedMinutes': row['total_planned_minutes'],
            },
          )
          .toList(),
      'segments': segmentRows
          .map(
            (row) => {
              'id': row['segment_id'],
              'clientEntityId': row['client_entity_id'],
              'year': row['year'],
              'title': row['title'],
              'startMonth': row['start_month'],
              'endMonth': row['end_month'],
              'colorKey': row['color_key'],
              'sortOrder': row['sort_order'],
              'note': row['note'],
              'revision': row['revision'],
              'updateTime': row['updated_at'],
            },
          )
          .toList(),
    });
  }

  Future<AnnualPlanOverview> saveAnnualSegment(
    String ownerScope,
    AnnualPlanSegment draft,
  ) async {
    if (draft.startMonth < 1 ||
        draft.endMonth > 12 ||
        draft.startMonth > draft.endMonth) {
      throw ArgumentError('Annual segment months must be within 1...12.');
    }
    final database = await _readyDatabase();
    final segmentId = draft.id.trim().isEmpty ? _uuidV4() : draft.id;
    final clientEntityId =
        draft.clientEntityId.trim().isEmpty ? segmentId : draft.clientEntityId;
    final existing = await database.query(
      'local_annual_segment',
      columns: ['segment_id'],
      where: 'owner_scope = ? AND segment_id = ?',
      whereArgs: [ownerScope, segmentId],
      limit: 1,
    );
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.insert(
        'local_annual_segment',
        {
          'owner_scope': ownerScope,
          'segment_id': segmentId,
          'client_entity_id': clientEntityId,
          'year': draft.year,
          'start_month': draft.startMonth,
          'end_month': draft.endMonth,
          'title': draft.title,
          'color_key': draft.colorKey,
          'sort_order': draft.sortOrder,
          'note': draft.note,
          'revision': draft.revision + 1,
          'updated_at': now,
          'dirty': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'annual_segment',
        aggregateId: segmentId,
        operationType: existing.isEmpty ? 'create' : 'update',
        payload: draft
            .copyWith(id: segmentId, clientEntityId: clientEntityId)
            .toSaveJson(),
        createdAt: now,
      );
    });
    return loadAnnualOverview(ownerScope, draft.year);
  }

  Future<AnnualPlanOverview> deleteAnnualSegment(
    String ownerScope,
    AnnualPlanSegment segment,
  ) async {
    final database = await _readyDatabase();
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.delete(
        'local_annual_segment',
        where: 'owner_scope = ? AND segment_id = ?',
        whereArgs: [ownerScope, segment.id],
      );
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'annual_segment',
        aggregateId: segment.id,
        operationType: 'delete',
        payload: {
          'clientEntityId': segment.clientEntityId,
          'year': segment.year,
          'revision': segment.revision,
        },
        createdAt: now,
      );
    });
    return loadAnnualOverview(ownerScope, segment.year);
  }

  Future<MemoCardModel?> loadMemo(String ownerScope, int memoId) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_memo',
      where: 'owner_scope = ? AND memo_id = ?',
      whereArgs: [ownerScope, memoId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _loadMemoFromRow(database, ownerScope, rows.first);
  }

  Future<MemoOverview> saveMemo(
    String ownerScope,
    MemoCardModel draft, {
    int? memoId,
  }) async {
    final database = await _readyDatabase();
    final resolvedMemoId = memoId ?? await _nextMemoId(database, ownerScope);
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.insert(
        'local_memo',
        {
          'owner_scope': ownerScope,
          'memo_id': resolvedMemoId,
          'title': draft.title,
          'content': draft.content,
          'updated_at': now,
          'dirty': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.delete(
        'local_memo_item',
        where: 'owner_scope = ? AND memo_id = ?',
        whereArgs: [ownerScope, resolvedMemoId],
      );
      for (var index = 0; index < draft.checkItems.length; index += 1) {
        final item = draft.checkItems[index];
        await transaction.insert('local_memo_item', {
          'owner_scope': ownerScope,
          'memo_id': resolvedMemoId,
          'item_id': item.id > 0 ? item.id : index + 1,
          'item_text': item.itemText,
          'checked': item.checked ? 1 : 0,
          'sort_no': index,
        });
      }
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'memo',
        aggregateId: '$resolvedMemoId',
        operationType: memoId == null ? 'create' : 'update',
        payload: draft.toSaveJson(),
        createdAt: now,
      );
    });
    return loadMemoOverview(ownerScope);
  }

  Future<MemoOverview> deleteMemo(String ownerScope, int memoId) async {
    final database = await _readyDatabase();
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.delete(
        'local_memo_item',
        where: 'owner_scope = ? AND memo_id = ?',
        whereArgs: [ownerScope, memoId],
      );
      await transaction.delete(
        'local_memo',
        where: 'owner_scope = ? AND memo_id = ?',
        whereArgs: [ownerScope, memoId],
      );
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'memo',
        aggregateId: '$memoId',
        operationType: 'delete',
        payload: {'memoId': memoId},
        createdAt: now,
      );
    });
    return loadMemoOverview(ownerScope);
  }

  Future<FocusSession> loadActiveFocusSession(String ownerScope) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_focus_session',
      where: 'owner_scope = ? AND active = 1',
      whereArgs: [ownerScope],
      orderBy: 'session_id DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return FocusSession.empty();
    }
    final row = rows.first;
    final plannedEnd = DateTime.tryParse('${row['planned_end_time']}');
    final start = DateTime.tryParse('${row['start_time']}');
    final now = DateTime.now();
    final plannedSeconds = (row['planned_minutes'] as int) * 60;
    final elapsed = start == null ? 0 : now.difference(start).inSeconds;
    final remaining = plannedEnd == null
        ? plannedSeconds
        : plannedEnd.difference(now).inSeconds.clamp(0, plannedSeconds);
    if (remaining <= 0) {
      await finishFocusSession(ownerScope, row['session_id'] as int);
      return FocusSession.empty();
    }
    return FocusSession.fromJson({
      'sessionId': row['session_id'],
      'active': true,
      'taskName': row['task_name'],
      'stageName': row['stage_name'],
      'startTime': row['start_time'],
      'plannedEndTime': row['planned_end_time'],
      'actualEndTime': row['actual_end_time'],
      'plannedMinutes': row['planned_minutes'],
      'elapsedSeconds': elapsed.clamp(0, plannedSeconds),
      'remainingSeconds': remaining,
      'bindPomodoro': row['bind_pomodoro'] == 1,
      'pomodoroStudyMinutes': row['pomodoro_study_minutes'],
      'pomodoroBreakMinutes': row['pomodoro_break_minutes'],
      'currentCycleNo': row['current_cycle_no'],
      'completedPomodoroCount': row['completed_pomodoro_count'],
      'stageRemainingSeconds': remaining,
    });
  }

  Future<FocusSession> startFocusSession(
    String ownerScope, {
    required DateTime endTime,
    String? taskName,
    bool bindPomodoro = false,
    int pomodoroStudyMinutes = 0,
    int pomodoroBreakMinutes = 0,
  }) async {
    final database = await _readyDatabase();
    final now = DateTime.now();
    final plannedMinutes = max(1, endTime.difference(now).inMinutes);
    final remainingSeconds = max(1, endTime.difference(now).inSeconds);
    final sessionId = await _nextFocusSessionId(database, ownerScope);
    final nowText = now.toIso8601String();
    await database.transaction((transaction) async {
      await transaction.update(
        'local_focus_session',
        {'active': 0, 'actual_end_time': nowText},
        where: 'owner_scope = ? AND active = 1',
        whereArgs: [ownerScope],
      );
      await transaction.insert('local_focus_session', {
        'owner_scope': ownerScope,
        'session_id': sessionId,
        'active': 1,
        'task_name': taskName?.trim() ?? '',
        'stage_name': 'study',
        'start_time': nowText,
        'planned_end_time': endTime.toIso8601String(),
        'actual_end_time': '',
        'planned_minutes': plannedMinutes,
        'bind_pomodoro': bindPomodoro ? 1 : 0,
        'pomodoro_study_minutes': pomodoroStudyMinutes,
        'pomodoro_break_minutes': pomodoroBreakMinutes,
        'current_cycle_no': 1,
        'completed_pomodoro_count': 0,
        'updated_at': nowText,
        'dirty': 1,
      });
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'focus_session',
        aggregateId: '$sessionId',
        operationType: 'create',
        payload: {
          'endTime': endTime.toIso8601String(),
          'taskName': taskName?.trim() ?? '',
          'bindPomodoro': bindPomodoro,
          'pomodoroStudyMinutes': pomodoroStudyMinutes,
          'pomodoroBreakMinutes': pomodoroBreakMinutes,
        },
        createdAt: now.toUtc().toIso8601String(),
      );
    });
    return FocusSession.fromJson({
      'sessionId': sessionId,
      'active': true,
      'taskName': taskName?.trim() ?? '',
      'stageName': 'study',
      'startTime': nowText,
      'plannedEndTime': endTime.toIso8601String(),
      'actualEndTime': '',
      'plannedMinutes': plannedMinutes,
      'elapsedSeconds': 0,
      'remainingSeconds': remainingSeconds,
      'bindPomodoro': bindPomodoro,
      'pomodoroStudyMinutes': pomodoroStudyMinutes,
      'pomodoroBreakMinutes': pomodoroBreakMinutes,
      'currentCycleNo': 1,
      'completedPomodoroCount': 0,
      'stageRemainingSeconds': bindPomodoro && pomodoroStudyMinutes > 0
          ? min(remainingSeconds, pomodoroStudyMinutes * 60)
          : remainingSeconds,
    });
  }

  Future<FocusSession> finishFocusSession(
    String ownerScope,
    int sessionId,
  ) async {
    final database = await _readyDatabase();
    final now = DateTime.now();
    final nowText = now.toIso8601String();
    final rows = await database.query(
      'local_focus_session',
      where: 'owner_scope = ? AND session_id = ?',
      whereArgs: [ownerScope, sessionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return FocusSession.empty();
    }
    final row = rows.first;
    final start = DateTime.tryParse('${row['start_time']}');
    final elapsedSeconds = start == null
        ? 0
        : now.difference(start).inSeconds.clamp(
              0,
              (row['planned_minutes'] as int) * 60,
            );
    await database.transaction((transaction) async {
      await transaction.update(
        'local_focus_session',
        {
          'active': 0,
          'stage_name': 'finished',
          'actual_end_time': nowText,
          'updated_at': nowText,
          'dirty': 1,
        },
        where: 'owner_scope = ? AND session_id = ?',
        whereArgs: [ownerScope, sessionId],
      );
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'focus_session',
        aggregateId: '$sessionId',
        operationType: 'finish',
        payload: {'actualEndTime': nowText},
        createdAt: now.toUtc().toIso8601String(),
      );
    });
    return FocusSession.fromJson({
      'sessionId': sessionId,
      'active': false,
      'taskName': row['task_name'],
      'stageName': 'finished',
      'startTime': row['start_time'],
      'plannedEndTime': row['planned_end_time'],
      'actualEndTime': nowText,
      'plannedMinutes': row['planned_minutes'],
      'elapsedSeconds': elapsedSeconds,
      'remainingSeconds': 0,
      'bindPomodoro': row['bind_pomodoro'] == 1,
      'pomodoroStudyMinutes': row['pomodoro_study_minutes'],
      'pomodoroBreakMinutes': row['pomodoro_break_minutes'],
      'currentCycleNo': row['current_cycle_no'],
      'completedPomodoroCount': row['completed_pomodoro_count'],
      'stageRemainingSeconds': 0,
    });
  }

  Future<bool> hasCheckInIntent(String ownerScope, String planDate) async {
    final database = await _readyDatabase();
    final rows = await database.query(
      'local_checkin_intent',
      columns: ['intent_id'],
      where: 'owner_scope = ? AND plan_date = ?',
      whereArgs: [ownerScope, planDate],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> recordCheckInIntent(
    String ownerScope,
    String planDate,
  ) async {
    final database = await _readyDatabase();
    if (await hasCheckInIntent(ownerScope, planDate)) {
      return false;
    }
    final intentId = _uuidV4();
    final now = DateTime.now().toUtc().toIso8601String();
    await database.transaction((transaction) async {
      await transaction.insert('local_checkin_intent', {
        'owner_scope': ownerScope,
        'intent_id': intentId,
        'plan_date': planDate,
        'created_at': now,
        'status': 'pending',
      });
      await _enqueue(
        transaction,
        ownerScope: ownerScope,
        aggregateType: 'checkin_intent',
        aggregateId: planDate,
        operationType: 'create',
        payload: {'planDate': planDate},
        createdAt: now,
      );
    });
    return true;
  }

  Future<int> pendingOutboxCount(String ownerScope) async {
    final database = await _readyDatabase();
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM sync_outbox '
      'WHERE owner_scope = ? AND status = ?',
      [ownerScope, 'pending'],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<Database> _readyDatabase() async {
    await initialize();
    return _database!;
  }

  DatabaseFactory _defaultDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return mobile_sqlite.databaseFactory;
    }
    throw UnsupportedError(
        'Offline SQLite is not configured for this platform.');
  }

  Future<String> _defaultDatabasePath() async {
    if (Platform.isWindows || Platform.isLinux) {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      return '${directory.path}${Platform.pathSeparator}innocence_local.db';
    }
    final directory = await mobile_sqlite.getDatabasesPath();
    return '$directory${Platform.pathSeparator}innocence_local.db';
  }

  static Future<void> _createSchema(Database database) async {
    final statements = <String>[
      '''CREATE TABLE local_profile (
        local_profile_id TEXT PRIMARY KEY,
        nickname TEXT NOT NULL,
        timezone TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''',
      '''CREATE TABLE local_daily_plan (
        owner_scope TEXT NOT NULL,
        plan_date TEXT NOT NULL,
        plan_name TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        template_applied INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (owner_scope, plan_date)
      )''',
      '''CREATE TABLE local_daily_plan_item (
        owner_scope TEXT NOT NULL,
        plan_date TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        planned_minutes INTEGER NOT NULL DEFAULT 0,
        actual_minutes INTEGER NOT NULL DEFAULT 0,
        start_slot INTEGER,
        end_slot INTEGER,
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (owner_scope, plan_date, item_id),
        FOREIGN KEY (owner_scope, plan_date)
          REFERENCES local_daily_plan(owner_scope, plan_date) ON DELETE CASCADE
      )''',
      '''CREATE TABLE local_day_template (
        owner_scope TEXT NOT NULL,
        template_id TEXT NOT NULL,
        template_name TEXT NOT NULL,
        source_plan_name TEXT NOT NULL DEFAULT 'Today',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (owner_scope, template_id)
      )''',
      '''CREATE TABLE local_day_template_item (
        owner_scope TEXT NOT NULL,
        template_id TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        planned_minutes INTEGER NOT NULL DEFAULT 0,
        start_slot INTEGER,
        end_slot INTEGER,
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (owner_scope, template_id, item_id),
        FOREIGN KEY (owner_scope, template_id)
          REFERENCES local_day_template(owner_scope, template_id) ON DELETE CASCADE
      )''',
      '''CREATE TABLE local_annual_segment (
        owner_scope TEXT NOT NULL,
        segment_id TEXT NOT NULL,
        client_entity_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        start_month INTEGER NOT NULL,
        end_month INTEGER NOT NULL,
        title TEXT NOT NULL,
        color_key TEXT NOT NULL DEFAULT 'accent',
        sort_order INTEGER NOT NULL DEFAULT 0,
        note TEXT NOT NULL DEFAULT '',
        revision INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (owner_scope, segment_id)
      )''',
      '''CREATE TABLE local_focus_session (
        owner_scope TEXT NOT NULL,
        session_id INTEGER NOT NULL,
        active INTEGER NOT NULL DEFAULT 0,
        task_name TEXT NOT NULL DEFAULT '',
        stage_name TEXT NOT NULL DEFAULT 'idle',
        start_time TEXT NOT NULL,
        planned_end_time TEXT NOT NULL,
        actual_end_time TEXT NOT NULL DEFAULT '',
        planned_minutes INTEGER NOT NULL DEFAULT 0,
        bind_pomodoro INTEGER NOT NULL DEFAULT 0,
        pomodoro_study_minutes INTEGER NOT NULL DEFAULT 0,
        pomodoro_break_minutes INTEGER NOT NULL DEFAULT 0,
        current_cycle_no INTEGER NOT NULL DEFAULT 0,
        completed_pomodoro_count INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (owner_scope, session_id)
      )''',
      '''CREATE TABLE local_focus_event (
        owner_scope TEXT NOT NULL,
        event_id TEXT NOT NULL,
        session_id INTEGER NOT NULL,
        event_type TEXT NOT NULL,
        occurred_at TEXT NOT NULL,
        payload_json TEXT NOT NULL DEFAULT '{}',
        PRIMARY KEY (owner_scope, event_id)
      )''',
      '''CREATE TABLE local_memo (
        owner_scope TEXT NOT NULL,
        memo_id INTEGER NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        content TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (owner_scope, memo_id)
      )''',
      '''CREATE TABLE local_memo_item (
        owner_scope TEXT NOT NULL,
        memo_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_text TEXT NOT NULL,
        checked INTEGER NOT NULL DEFAULT 0,
        sort_no INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (owner_scope, memo_id, item_id),
        FOREIGN KEY (owner_scope, memo_id)
          REFERENCES local_memo(owner_scope, memo_id) ON DELETE CASCADE
      )''',
      '''CREATE TABLE local_checkin_intent (
        owner_scope TEXT NOT NULL,
        intent_id TEXT NOT NULL,
        plan_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        PRIMARY KEY (owner_scope, intent_id)
      )''',
      '''CREATE UNIQUE INDEX idx_local_checkin_owner_date
        ON local_checkin_intent(owner_scope, plan_date)''',
      '''CREATE TABLE sync_outbox (
        operation_id TEXT PRIMARY KEY,
        owner_scope TEXT NOT NULL,
        aggregate_type TEXT NOT NULL,
        aggregate_id TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        client_version INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT NOT NULL DEFAULT '',
        idempotency_key TEXT NOT NULL UNIQUE
      )''',
      '''CREATE INDEX idx_sync_outbox_owner_status
        ON sync_outbox(owner_scope, status, created_at)''',
      '''CREATE TABLE sync_binding (
        local_profile_id TEXT NOT NULL,
        server_user_id INTEGER NOT NULL,
        aggregate_type TEXT NOT NULL,
        local_aggregate_id TEXT NOT NULL,
        server_aggregate_id TEXT NOT NULL,
        synced_at TEXT NOT NULL,
        PRIMARY KEY (local_profile_id, aggregate_type, local_aggregate_id)
      )''',
    ];
    for (final statement in statements) {
      await database.execute(statement);
    }
    await _createLocalWidgetSettingTable(database);
  }

  static Future<void> _createLocalWidgetSettingTable(
    DatabaseExecutor database,
  ) {
    return database.execute(
      '''CREATE TABLE IF NOT EXISTS local_widget_setting (
        owner_scope TEXT PRIMARY KEY,
        auto_start INTEGER NOT NULL DEFAULT 0,
        always_on_top INTEGER NOT NULL DEFAULT 0,
        show_plan INTEGER NOT NULL DEFAULT 1,
        show_timer INTEGER NOT NULL DEFAULT 1,
        show_memo INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )''',
    );
  }

  static LocalProfile _profileFromRow(Map<String, Object?> row) {
    return LocalProfile(
      localProfileId: '${row['local_profile_id']}',
      nickname: '${row['nickname']}',
      timezone: '${row['timezone']}',
      createdAt: DateTime.parse('${row['created_at']}'),
      updatedAt: DateTime.parse('${row['updated_at']}'),
    );
  }

  static Future<MemoCardModel> _loadMemoFromRow(
    DatabaseExecutor database,
    String ownerScope,
    Map<String, Object?> row,
  ) async {
    final memoId = row['memo_id'] as int;
    final itemRows = await database.query(
      'local_memo_item',
      where: 'owner_scope = ? AND memo_id = ?',
      whereArgs: [ownerScope, memoId],
      orderBy: 'sort_no ASC, item_id ASC',
    );
    return MemoCardModel.fromJson({
      'memoId': memoId,
      'title': row['title'],
      'content': row['content'],
      'updateTime': row['updated_at'],
      'totalItemCount': itemRows.length,
      'checkedItemCount': itemRows.where((item) => item['checked'] == 1).length,
      'checkItems': itemRows
          .map(
            (item) => {
              'id': item['item_id'],
              'itemText': item['item_text'],
              'checked': item['checked'],
              'sortNo': item['sort_no'],
            },
          )
          .toList(),
    });
  }

  static Future<int> _nextMemoId(
    DatabaseExecutor database,
    String ownerScope,
  ) async {
    final rows = await database.rawQuery(
      'SELECT COALESCE(MAX(memo_id), 0) + 1 AS next_id '
      'FROM local_memo WHERE owner_scope = ?',
      [ownerScope],
    );
    return rows.first['next_id'] as int;
  }

  static Future<int> _nextFocusSessionId(
    DatabaseExecutor database,
    String ownerScope,
  ) async {
    final rows = await database.rawQuery(
      'SELECT COALESCE(MAX(session_id), 0) + 1 AS next_id '
      'FROM local_focus_session WHERE owner_scope = ?',
      [ownerScope],
    );
    return rows.first['next_id'] as int;
  }

  static Future<void> _enqueue(
    DatabaseExecutor database, {
    required String ownerScope,
    required String aggregateType,
    required String aggregateId,
    required String operationType,
    required Map<String, dynamic> payload,
    required String createdAt,
  }) async {
    final operationId = _uuidV4();
    await database.insert('sync_outbox', {
      'operation_id': operationId,
      'owner_scope': ownerScope,
      'aggregate_type': aggregateType,
      'aggregate_id': aggregateId,
      'operation_type': operationType,
      'payload_json': jsonEncode(payload),
      'client_version': 1,
      'created_at': createdAt,
      'status': 'pending',
      'retry_count': 0,
      'last_error': '',
      'idempotency_key': operationId,
    });
  }

  static Future<void> _clearDirtyWhenFullySynced(
    DatabaseExecutor database,
    String ownerScope,
    String aggregateType,
    String aggregateId,
  ) async {
    final pendingRows = await database.rawQuery(
      '''SELECT COUNT(*) AS count FROM sync_outbox
      WHERE owner_scope = ?
        AND aggregate_type = ?
        AND aggregate_id = ?
        AND status = 'pending' ''',
      [ownerScope, aggregateType, aggregateId],
    );
    if ((pendingRows.first['count'] as int? ?? 0) > 0) {
      return;
    }
    switch (aggregateType) {
      case 'daily_plan':
        await database.update(
          'local_daily_plan',
          {'dirty': 0},
          where: 'owner_scope = ? AND plan_date = ?',
          whereArgs: [ownerScope, aggregateId],
        );
      case 'day_template':
        await database.update(
          'local_day_template',
          {'dirty': 0},
          where: 'owner_scope = ? AND template_id = ?',
          whereArgs: [ownerScope, aggregateId],
        );
      case 'annual_segment':
        await database.update(
          'local_annual_segment',
          {'dirty': 0},
          where: 'owner_scope = ? AND segment_id = ?',
          whereArgs: [ownerScope, aggregateId],
        );
      case 'focus_session':
        await database.update(
          'local_focus_session',
          {'dirty': 0},
          where: 'owner_scope = ? AND session_id = ?',
          whereArgs: [ownerScope, aggregateId],
        );
      case 'memo':
        await database.update(
          'local_memo',
          {'dirty': 0},
          where: 'owner_scope = ? AND memo_id = ?',
          whereArgs: [ownerScope, aggregateId],
        );
      case 'checkin_intent':
        await database.update(
          'local_checkin_intent',
          {'status': 'synced'},
          where: 'owner_scope = ? AND plan_date = ?',
          whereArgs: [ownerScope, aggregateId],
        );
    }
  }

  static int _localFocusDurationMinutes(
    Map<String, Object?> row,
    DateTime now,
  ) {
    final start = DateTime.tryParse('${row['start_time']}');
    final plannedEnd = DateTime.tryParse('${row['planned_end_time']}');
    final actualText = '${row['actual_end_time'] ?? ''}';
    final actualEnd = actualText.isEmpty ? null : DateTime.tryParse(actualText);
    if (start == null) {
      return 0;
    }
    var end = actualEnd ?? now;
    if (plannedEnd != null && end.isAfter(plannedEnd)) {
      end = plannedEnd;
    }
    if (!end.isAfter(start)) {
      return 0;
    }
    return end.difference(start).inMinutes;
  }

  static int _localPomodoroCount(
    Map<String, Object?> row,
    int durationMinutes,
  ) {
    final stored = row['completed_pomodoro_count'] as int? ?? 0;
    if (stored > 0 || row['bind_pomodoro'] != 1) {
      return stored;
    }
    final study = row['pomodoro_study_minutes'] as int? ?? 0;
    final rest = row['pomodoro_break_minutes'] as int? ?? 0;
    final cycle = study + rest;
    return cycle <= 0 ? 0 : durationMinutes ~/ cycle;
  }

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
