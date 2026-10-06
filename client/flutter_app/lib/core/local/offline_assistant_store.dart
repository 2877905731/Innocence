part of 'offline_store.dart';

Future<void> _createAssistantTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS local_day_revision (
    owner_scope TEXT NOT NULL, plan_date TEXT NOT NULL, revision INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(owner_scope,plan_date))''');
  await db.execute('''CREATE TABLE IF NOT EXISTS local_assistant_document (
    owner_scope TEXT NOT NULL, kind TEXT NOT NULL, document_id TEXT NOT NULL,
    payload TEXT NOT NULL, created_at TEXT NOT NULL,
    PRIMARY KEY(owner_scope,kind,document_id))''');
}

Future<void> _assistantAdvance(
    DatabaseExecutor db, String owner, String date) async {
  await db.rawInsert(
      'INSERT OR IGNORE INTO local_day_revision(owner_scope,plan_date,revision) VALUES(?,?,0)',
      [owner, date]);
  await db.rawUpdate(
      'UPDATE local_day_revision SET revision=revision+1 WHERE owner_scope=? AND plan_date=?',
      [owner, date]);
}

Future<TodayPlan> _assistantPlan(
    DatabaseExecutor db, String owner, String date) async {
  final revision = await db.query('local_day_revision',
      where: 'owner_scope=? AND plan_date=?', whereArgs: [owner, date]);
  final rev = revision.isEmpty ? 0 : revision.first['revision'] as int;
  final headers = await db.query('local_daily_plan',
      where: 'owner_scope=? AND plan_date=?', whereArgs: [owner, date]);
  if (headers.isEmpty) return TodayPlan.empty(date).copyWith(dayRevision: rev);
  final rows = await db.query('local_daily_plan_item',
      where: 'owner_scope=? AND plan_date=?',
      whereArgs: [owner, date],
      orderBy: 'sort_order,item_id');
  return TodayPlan.fromJson({
    'planDate': date,
    'planName': headers.first['plan_name'],
    'dayRevision': rev,
    'items': rows
        .map((r) => {
              'id': r['item_id'],
              'title': r['title'],
              'completed': r['completed'],
              'plannedMinutes': r['planned_minutes'],
              'actualMinutes': r['actual_minutes'],
              'startSlot': r['start_slot'],
              'endSlot': r['end_slot'],
              'sortOrder': r['sort_order']
            })
        .toList()
  });
}

Future<Map<String, dynamic>?> _assistantRecord(
    DatabaseExecutor db, String owner, String kind, String id) async {
  final rows = await db.query('local_assistant_document',
      where: 'owner_scope=? AND kind=? AND document_id=?',
      whereArgs: [owner, kind, id]);
  if (rows.isEmpty) return null;
  if (kind == 'execution' &&
      DateTime.parse(rows.first['created_at'] as String).isBefore(
          DateTime.now().toUtc().subtract(const Duration(days: 30)))) {
    throw const FormatException('操作记录已超过30天 / Operation expired.');
  }
  return Map<String, dynamic>.from(
      jsonDecode(rows.first['payload'] as String) as Map);
}

Future<void> _assistantPut(DatabaseExecutor db, String owner, String kind,
    String id, Map<String, dynamic> data,
    {bool update = false}) async {
  if (update) {
    await db.update('local_assistant_document', {'payload': jsonEncode(data)},
        where: 'owner_scope=? AND kind=? AND document_id=?',
        whereArgs: [owner, kind, id]);
  } else {
    await db.insert('local_assistant_document', {
      'owner_scope': owner,
      'kind': kind,
      'document_id': id,
      'payload': jsonEncode(data),
      'created_at': DateTime.now().toUtc().toIso8601String()
    });
  }
}

Never _assistantMissing() => throw const FormatException(
    '当前身份下记录不存在 / Record unavailable for this identity.');
void _assistantFresh(AssistantProposal p) {
  assistantDate(p.planDate);
  if (!p.expiresAt.isAfter(DateTime.now().toUtc()) || p.status != 'ready') {
    throw const FormatException(
        '方案未就绪或已过期，请重新生成 / Proposal unavailable or expired.');
  }
}

extension OfflineAssistantStore on OfflineStore {
  Future<Map<String, dynamic>?> _loadAssistantRecovery(String owner) async =>
      _assistantRecord(await _readyDatabase(), owner, 'recovery', 'state');
  Future<void> _saveAssistantRecovery(
      String owner, Map<String, dynamic> data) async {
    final db = await _readyDatabase();
    await db.insert(
        'local_assistant_document',
        {
          'owner_scope': owner,
          'kind': 'recovery',
          'document_id': 'state',
          'payload': jsonEncode(data),
          'created_at': DateTime.now().toUtc().toIso8601String()
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _saveAssistantProposal(
      String owner, AssistantProposal proposal) async {
    final db = await _readyDatabase();
    final now = DateTime.now().toUtc();
    await db.delete('local_assistant_document',
        where: 'kind<>? AND created_at<?',
        whereArgs: [
          'execution',
          now.subtract(const Duration(days: 7)).toIso8601String()
        ]);
    await db.update(
        'local_assistant_document', {'payload': '{"status":"expired"}'},
        where: 'kind=? AND created_at<?',
        whereArgs: [
          'execution',
          now.subtract(const Duration(days: 30)).toIso8601String()
        ]);
    await _assistantPut(db, owner, 'proposal', proposal.id, proposal.toJson());
  }

  Future<AssistantValidation> _validateAssistant(
      String owner, String id, int revision, String candidateId,
      {List<AssistantTask>? edited}) async {
    final db = await _readyDatabase();
    return db.transaction((tx) async {
      final raw = await _assistantRecord(tx, owner, 'proposal', id) ??
          _assistantMissing();
      var p = AssistantProposal.fromJson(raw);
      _assistantFresh(p);
      if (p.revision != revision) {
        throw const FormatException('方案版本已变化 / Proposal changed.');
      }
      final candidate =
          p.candidates.where((c) => c.id == candidateId).firstOrNull;
      if (candidate == null) _assistantMissing();
      final items = List<AssistantTask>.unmodifiable(edited ?? candidate.items);
      final plan = await _assistantPlan(tx, owner, p.planDate);
      final conflicts = assistantConflicts(items, plan);
      if (plan.dayRevision != p.sourceRevision) {
        conflicts.add('日计划已变化，请重新生成 / Day plan changed; regenerate.');
      }
      if (edited != null) {
        p = AssistantProposal(
            id: p.id,
            revision: p.revision + 1,
            status: p.status,
            planDate: p.planDate,
            timeZone: p.timeZone,
            sourceRevision: p.sourceRevision,
            expiresAt: p.expiresAt,
            questions: p.questions,
            assumptions: p.assumptions,
            candidates: p.candidates
                .map((c) => c.id == candidateId
                    ? AssistantCandidate(
                        c.id, c.intensity, items, c.explanation)
                    : c)
                .toList());
        await _assistantPut(tx, owner, 'proposal', id, p.toJson(),
            update: true);
      }
      final validation = {
        'validationId': assistantId(),
        'proposalId': id,
        'proposalRevision': p.revision,
        'candidateId': candidateId,
        'expiresAt': p.expiresAt.toIso8601String(),
        'canExecute': conflicts.isEmpty,
        'conflicts': conflicts,
        'items': items.map((t) => t.toJson()).toList()
      };
      await _assistantPut(tx, owner, 'validation',
          validation['validationId'] as String, validation);
      return AssistantValidation.fromJson(validation);
    });
  }

  Future<AssistantExecution?> _assistantExecution(
      String owner, String id) async {
    final raw =
        await _assistantRecord(await _readyDatabase(), owner, 'execution', id);
    return raw == null
        ? null
        : AssistantExecution.fromJson(
            Map<String, dynamic>.from(raw['execution'] as Map));
  }

  Future<AssistantExecution> _applyAssistant(
      String owner,
      String proposalId,
      int revision,
      String candidateId,
      String validationId,
      String operationId) async {
    final db = await _readyDatabase();
    final fingerprint =
        jsonEncode([proposalId, revision, candidateId, validationId]);
    return _localOperation(
        db,
        owner,
        operationId,
        fingerprint,
        () async => db.transaction((tx) async {
              final prior =
                  await _assistantRecord(tx, owner, 'execution', operationId);
              if (prior?['execution']?['status'] == 'committed') {
                return AssistantExecution.fromJson(
                    Map<String, dynamic>.from(prior!['execution'] as Map));
              }
              final raw =
                  await _assistantRecord(tx, owner, 'proposal', proposalId) ??
                      _assistantMissing();
              final p = AssistantProposal.fromJson(raw);
              _assistantFresh(p);
              final v = await _assistantRecord(
                      tx, owner, 'validation', validationId) ??
                  _assistantMissing();
              final candidate =
                  p.candidates.where((c) => c.id == candidateId).firstOrNull;
              if (p.revision != revision ||
                  v['proposalId'] != proposalId ||
                  v['proposalRevision'] != revision ||
                  v['candidateId'] != candidateId ||
                  v['canExecute'] != true ||
                  candidate == null ||
                  jsonEncode(v['items']) !=
                      jsonEncode(
                          candidate.items.map((t) => t.toJson()).toList())) {
                throw const FormatException(
                    '校验已失效 / Validation is no longer valid.');
              }
              final plan = await _assistantPlan(tx, owner, p.planDate);
              final active = await tx.query('local_focus_session',
                  where: 'owner_scope=? AND active=1',
                  whereArgs: [owner],
                  limit: 1);
              if (plan.dayRevision != p.sourceRevision ||
                  active.isNotEmpty ||
                  assistantConflicts(candidate.items, plan).isNotEmpty) {
                throw const FormatException(
                    '日计划或专注状态已变化，请重新生成 / Plan or focus changed.');
              }
              final headers = await tx.query('local_daily_plan',
                  where: 'owner_scope=? AND plan_date=?',
                  whereArgs: [owner, p.planDate]);
              final created = headers.isEmpty;
              final now = DateTime.now().toUtc().toIso8601String();
              final changes = <Map<String, dynamic>>[];
              if (candidate.items.isNotEmpty) {
                if (created) {
                  await tx.insert('local_daily_plan', {
                    'owner_scope': owner,
                    'plan_date': p.planDate,
                    'plan_name': 'Today',
                    'updated_at': now,
                    'dirty': 1,
                    'template_applied': 0
                  });
                }
                var itemId = plan.items.fold(0, (m, i) => max(m, i.id));
                var sort = plan.items.fold(-1, (m, i) => max(m, i.sortOrder));
                for (final task in candidate.items) {
                  itemId++;
                  sort++;
                  await tx.insert('local_daily_plan_item', {
                    'owner_scope': owner,
                    'plan_date': p.planDate,
                    'item_id': itemId,
                    'title': task.title,
                    'completed': 0,
                    'planned_minutes': (task.endSlot - task.startSlot) * 30,
                    'actual_minutes': 0,
                    'start_slot': task.startSlot,
                    'end_slot': task.endSlot,
                    'sort_order': sort
                  });
                  changes.add({
                    'itemId': itemId,
                    'title': task.title,
                    'startSlot': task.startSlot,
                    'endSlot': task.endSlot
                  });
                }
                await _assistantAdvance(tx, owner, p.planDate);
                await tx.update(
                    'local_daily_plan', {'dirty': 1, 'updated_at': now},
                    where: 'owner_scope=? AND plan_date=?',
                    whereArgs: [owner, p.planDate]);
                final saved = await _assistantPlan(tx, owner, p.planDate);
                await OfflineStore._enqueue(tx,
                    ownerScope: owner,
                    aggregateType: 'daily_plan',
                    aggregateId: p.planDate,
                    operationType: 'upsert',
                    payload: saved.toSaveJson(),
                    createdAt: now);
              }
              final result = AssistantExecution(
                  operationId,
                  'committed',
                  p.planDate,
                  plan.dayRevision + (changes.isEmpty ? 0 : 1),
                  changes.isNotEmpty,
                  changes,
                  null);
              await _assistantPut(
                  tx,
                  owner,
                  'execution',
                  operationId,
                  {
                    'fingerprint': fingerprint,
                    'execution': result.toJson(),
                    'createdPlan': created && changes.isNotEmpty
                  },
                  update: true);
              return result;
            }));
  }

  Future<AssistantExecution> _undoAssistant(String owner, String originalId,
      int afterRevision, String operationId) async {
    final db = await _readyDatabase();
    final fingerprint = jsonEncode(['undo', originalId, afterRevision]);
    return _localOperation(
        db,
        owner,
        operationId,
        fingerprint,
        () async => db.transaction((tx) async {
              final prior =
                  await _assistantRecord(tx, owner, 'execution', operationId);
              if (prior?['execution']?['status'] == 'committed') {
                return AssistantExecution.fromJson(
                    Map<String, dynamic>.from(prior!['execution'] as Map));
              }
              final original =
                  await _assistantRecord(tx, owner, 'execution', originalId) ??
                      _assistantMissing();
              final e = AssistantExecution.fromJson(
                  Map<String, dynamic>.from(original['execution'] as Map));
              final plan = await _assistantPlan(tx, owner, e.planDate);
              final active = await tx.query('local_focus_session',
                  where: 'owner_scope=? AND active=1',
                  whereArgs: [owner],
                  limit: 1);
              if (e.status != 'committed' ||
                  !e.undoEligibility ||
                  e.undoOf != null ||
                  plan.dayRevision != afterRevision ||
                  e.afterRevision != afterRevision ||
                  active.isNotEmpty) {
                throw const FormatException(
                    '任务已有变化或专注，不能撤销 / Changes or focus prevent undo.');
              }
              for (final change in e.changes) {
                final item = plan.items
                    .where((i) => i.id == change['itemId'])
                    .firstOrNull;
                if (item == null || item.completed || item.actualMinutes > 0) {
                  throw const FormatException('任务状态已变化 / Task state changed.');
                }
              }
              for (final change in e.changes) {
                await tx.delete('local_daily_plan_item',
                    where: 'owner_scope=? AND plan_date=? AND item_id=?',
                    whereArgs: [owner, e.planDate, change['itemId']]);
              }
              await _assistantAdvance(tx, owner, e.planDate);
              var saved = await _assistantPlan(tx, owner, e.planDate);
              if (original['createdPlan'] == true && saved.items.isEmpty) {
                await tx.delete('local_daily_plan',
                    where: 'owner_scope=? AND plan_date=?',
                    whereArgs: [owner, e.planDate]);
                saved = saved.copyWith(planName: '');
              } else {
                await tx.update(
                    'local_daily_plan',
                    {
                      'dirty': 1,
                      'updated_at': DateTime.now().toUtc().toIso8601String()
                    },
                    where: 'owner_scope=? AND plan_date=?',
                    whereArgs: [owner, e.planDate]);
              }
              await OfflineStore._enqueue(tx,
                  ownerScope: owner,
                  aggregateType: 'daily_plan',
                  aggregateId: e.planDate,
                  operationType: 'upsert',
                  payload: saved.toSaveJson(),
                  createdAt: DateTime.now().toUtc().toIso8601String());
              final result = AssistantExecution(operationId, 'committed',
                  e.planDate, saved.dayRevision, false, e.changes, originalId);
              await _assistantPut(tx, owner, 'execution', operationId,
                  {'fingerprint': fingerprint, 'execution': result.toJson()},
                  update: true);
              return result;
            }));
  }
}

Future<AssistantExecution> _localOperation(Database db, String owner, String id,
    String fingerprint, Future<AssistantExecution> Function() action) async {
  if (!RegExp(
          r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[89aAbB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$')
      .hasMatch(id)) {
    throw const FormatException('操作标识无效 / Invalid operation ID.');
  }
  final previous = await db.transaction((tx) async {
    final prior = await _assistantRecord(tx, owner, 'execution', id);
    if (prior != null) {
      if (prior['fingerprint'] != fingerprint) {
        throw const FormatException('操作标识与内容冲突 / Idempotency conflict.');
      }
      final result = AssistantExecution.fromJson(
          Map<String, dynamic>.from(prior['execution'] as Map));
      return result.status == 'prepared' ? null : result;
    }
    await _assistantPut(tx, owner, 'execution', id, {
      'fingerprint': fingerprint,
      'execution':
          AssistantExecution(id, 'prepared', '', 0, false, const [], null)
              .toJson()
    });
    return null;
  });
  if (previous != null) return previous;
  try {
    return await action();
  } catch (_) {
    await db.transaction((tx) async {
      final prior = await _assistantRecord(tx, owner, 'execution', id);
      if (prior?['execution']?['status'] == 'prepared') {
        await _assistantPut(
            tx,
            owner,
            'execution',
            id,
            {
              'fingerprint': fingerprint,
              'execution': AssistantExecution(
                      id, 'rejected', '', 0, false, const [], null)
                  .toJson()
            },
            update: true);
      }
    });
    rethrow;
  }
}
