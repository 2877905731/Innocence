part of 'offline_store.dart';

extension OfflinePlanOrder on OfflineStore {
  Future<void> reorderPlans(String owner, PlanOrder order) async {
    final database = await _readyDatabase();
    final now = DateTime.now().toUtc().toIso8601String();
    final ids = order.items.map((item) => item.id).toList();
    void checkIds(Iterable<String> current) {
      final actual = current.toSet();
      if (ids.toSet().length != ids.length ||
          ids.length != actual.length ||
          !actual.containsAll(ids)) {
        throw const FormatException(
            '任务已变化，请重新打开排序。 / Tasks have changed. Reopen sorting.');
      }
    }

    void checkRevision(int? expected, int current) {
      if (expected != current) {
        throw const FormatException(
            '计划已变化，请重新打开排序。 / Plan has changed. Reopen sorting.');
      }
    }

    await database.transaction((tx) async {
      if (order.scope == 'today') {
        final date = order.planDate;
        if (date == null) throw const FormatException('Missing date.');
        final plan = await _assistantPlan(tx, owner, date);
        checkRevision(order.baseRevision, plan.dayRevision);
        checkIds(plan.items.map((item) => '${item.id}'));
        for (var i = 0; i < ids.length; i++) {
          await tx.update('local_daily_plan_item', {'sort_order': i},
              where: 'owner_scope=? AND plan_date=? AND item_id=?',
              whereArgs: [owner, date, ids[i]]);
        }
        await _assistantAdvance(tx, owner, date);
        await tx.update('local_daily_plan', {'dirty': 1, 'updated_at': now},
            where: 'owner_scope=? AND plan_date=?', whereArgs: [owner, date]);
        final saved = await _assistantPlan(tx, owner, date);
        await OfflineStore._enqueue(tx,
            ownerScope: owner,
            aggregateType: 'daily_plan',
            aggregateId: date,
            operationType: 'upsert',
            payload: saved.toSaveJson(),
            createdAt: now);
        return;
      }
      List<Map<String, Object?>> parents;
      if (order.scope == 'annual' && order.year != null) {
        parents = await tx.query('local_annual_segment',
            where: 'owner_scope=? AND year=?', whereArgs: [owner, order.year]);
        checkIds(parents.map((row) => '${row['segment_id']}'));
        final byId = {for (final row in parents) '${row['segment_id']}': row};
        for (final item in order.items) {
          checkRevision(item.revision, byId[item.id]!['revision'] as int);
        }
        for (var i = 0; i < ids.length; i++) {
          final row = byId[ids[i]]!;
          await tx.update(
              'local_annual_segment',
              {
                'sort_order': i,
                'revision': (row['revision'] as int) + 1,
                'dirty': 1,
                'updated_at': now
              },
              where: 'owner_scope=? AND segment_id=?',
              whereArgs: [owner, ids[i]]);
        }
      } else if (order.scope == 'subtasks' && order.segmentId != null) {
        parents = await tx.query('local_annual_segment',
            where: 'owner_scope=? AND segment_id=?',
            whereArgs: [owner, order.segmentId]);
        if (parents.length != 1) {
          throw const FormatException('Annual task not found.');
        }
        checkRevision(order.baseRevision, parents.single['revision'] as int);
        final children = await tx.query('local_annual_segment_subtask',
            where: 'owner_scope=? AND segment_id=?',
            whereArgs: [owner, order.segmentId]);
        checkIds(children.map((row) => '${row['subtask_id']}'));
        for (var i = 0; i < ids.length; i++) {
          await tx.update('local_annual_segment_subtask', {'sort_order': i},
              where: 'owner_scope=? AND segment_id=? AND subtask_id=?',
              whereArgs: [owner, order.segmentId, ids[i]]);
        }
        await tx.update(
            'local_annual_segment',
            {
              'revision': (parents.single['revision'] as int) + 1,
              'dirty': 1,
              'updated_at': now
            },
            where: 'owner_scope=? AND segment_id=?',
            whereArgs: [owner, order.segmentId]);
      } else {
        throw const FormatException('Invalid order scope.');
      }
      for (final parent in parents) {
        final id = parent['segment_id'] as String;
        final rows = await tx.query('local_annual_segment',
            where: 'owner_scope=? AND segment_id=?', whereArgs: [owner, id]);
        final row = rows.single;
        final children = await tx.query('local_annual_segment_subtask',
            where: 'owner_scope=? AND segment_id=?',
            whereArgs: [owner, id],
            orderBy: 'sort_order ASC, subtask_id ASC');
        final segment = AnnualPlanSegment.fromJson({
          'id': id,
          'clientEntityId': row['client_entity_id'],
          'year': row['year'],
          'title': row['title'],
          'startMonth': row['start_month'],
          'endMonth': row['end_month'],
          'colorKey': row['color_key'],
          'sortOrder': row['sort_order'],
          'note': row['note'],
          'progressPercent': row['progress_percent'],
          'revision': parent['revision'],
          'subtasks': [
            for (final child in children)
              {
                'id': child['subtask_id'],
                'title': child['title'],
                'detail': child['detail'],
                'completed': child['completed'],
                'sortOrder': child['sort_order'],
              }
          ],
        });
        await OfflineStore._enqueue(tx,
            ownerScope: owner,
            aggregateType: 'annual_segment',
            aggregateId: id,
            operationType: 'update',
            payload: segment.toSaveJson(),
            createdAt: now);
      }
    });
  }
}
