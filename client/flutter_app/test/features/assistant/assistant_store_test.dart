import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/assistant/domain/assistant_models.dart';
import 'package:innocence_flutter/features/assistant/domain/local_planner.dart';
import 'package:flutter/foundation.dart';
import 'package:innocence_flutter/features/assistant/application/assistant_controller.dart';
import 'package:innocence_flutter/features/assistant/data/assistant_api.dart';

void main() {
  late Directory dir;
  late OfflineStore store;
  late String path;
  const owner = 'local:assistant-fixture';
  final date = TodayPlan.empty().planDate;
  setUp(() async {
    sqfliteFfiInit();
    dir = await Directory.systemTemp.createTemp('innocence-assistant-');
    path = '${dir.path}/fixture.db';
    store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => path);
    await store.initialize();
  });
  tearDown(() async {
    await store.close();
    expect(dir.absolute.path, startsWith(Directory.systemTemp.absolute.path));
    await dir.delete(recursive: true);
  });
  Future<AssistantProposal> proposal(
      {String text = 'English 60 min; Maths 60 min',
      int start = 20,
      int end = 32}) async {
    final p = LocalPlanner()
        .generate(await store.loadDailyPlan(owner, date), text, start, end);
    await store.saveAssistantProposal(owner, p);
    return p;
  }

  Future<({AssistantProposal p, AssistantCandidate c, AssistantValidation v})>
      ready() async {
    final p = await proposal();
    final c = p.candidates[1];
    final v = await store.validateAssistant(owner, p.id, p.revision, c.id);
    return (p: p, c: c, v: v);
  }

  test('45 minutes requests clarification and 24:00 is an explicit endpoint',
      () async {
    final p = await proposal(text: 'English 45 min');
    expect(p.status, 'needs_input');
    expect(p.questions, isNotEmpty);
    expect(assistantSlot('24:00', end: true), 48);
    expect(() => assistantSlot('24:30', end: true), throwsFormatException);
    expect(() => assistantSlot('10:15'), throwsFormatException);
    final midnight = await proposal(text: 'Review 60 min', start: 46, end: 48);
    expect(midnight.candidates[1].items.single.endSlot, 48);
  });
  test(
      'three strategies respect occupied slots and disclose capacity shortfall',
      () async {
    await store.saveDailyPlan(
        owner,
        TodayPlan.empty(date).copyWith(items: [
          const TodayPlanItem(
              id: 7,
              title: 'Original',
              completed: true,
              plannedMinutes: 60,
              actualMinutes: 55,
              startSlot: 20,
              endSlot: 22,
              sortOrder: 0)
        ]));
    final p = await proposal(end: 27);
    expect(p.candidates.length, 3);
    for (final c in p.candidates) {
      expect(
          assistantConflicts(c.items, await store.loadDailyPlan(owner, date)),
          isEmpty);
    }
    expect(p.candidates.first.explanation, contains('Unscheduled'));
    expect(p.candidates.last.items.length, 2);
  });
  test('stable append, repeated apply and undo preserve original state',
      () async {
    await store.saveDailyPlan(
        owner,
        TodayPlan.empty(date).copyWith(items: [
          const TodayPlanItem(
              id: 7,
              title: 'Original',
              completed: true,
              plannedMinutes: 60,
              actualMinutes: 55,
              startSlot: 16,
              endSlot: 18,
              sortOrder: 0)
        ]));
    final r = await ready();
    final id = assistantId();
    final e = await store.applyAssistant(
        owner, r.p.id, r.p.revision, r.c.id, r.v.id, id);
    final again = await store.applyAssistant(
        owner, r.p.id, r.p.revision, r.c.id, r.v.id, id);
    expect(again.afterRevision, e.afterRevision);
    final plan = await store.loadDailyPlan(owner, date);
    expect(plan.items.length, 3);
    expect(plan.items.first.id, 7);
    expect(plan.items.first.completed, true);
    expect(plan.items.first.actualMinutes, 55);
    expect(await store.pendingOutboxCount(owner), 2);
    final undoId = assistantId();
    final u = await store.undoAssistant(owner, e.id, e.afterRevision, undoId);
    expect(
        (await store.undoAssistant(owner, e.id, e.afterRevision, undoId))
            .afterRevision,
        u.afterRevision);
    final restored = await store.loadDailyPlan(owner, date);
    expect(restored.items.single.id, 7);
    expect(restored.dayRevision, e.afterRevision + 1);
    await expectLater(
        store.applyAssistant(
            owner, r.p.id, r.p.revision, r.c.id, 'different-validation', id),
        throwsFormatException);
  });
  test('tenant mismatch rejects proposal and execution access', () async {
    final r = await ready();
    await expectLater(store.validateAssistant('local:other', r.p.id, 1, r.c.id),
        throwsFormatException);
    final e = await store.applyAssistant(
        owner, r.p.id, 1, r.c.id, r.v.id, assistantId());
    expect(await store.assistantExecution('local:other', e.id), isNull);
  });
  test('manual save rejects stale apply and leaves a rejected query result',
      () async {
    final r = await ready();
    await store.saveDailyPlan(
        owner, TodayPlan.empty(date).copyWith(planName: 'Manual'));
    final id = assistantId();
    await expectLater(
        store.applyAssistant(owner, r.p.id, 1, r.c.id, r.v.id, id),
        throwsFormatException);
    expect((await store.assistantExecution(owner, id))!.status, 'rejected');
    expect((await store.loadDailyPlan(owner, date)).items, isEmpty);
  });
  test('completion and focus followed by finish reject undo', () async {
    final r = await ready();
    final e = await store.applyAssistant(
        owner, r.p.id, 1, r.c.id, r.v.id, assistantId());
    final active = await store.startFocusSession(owner,
        endTime: DateTime.now().add(const Duration(minutes: 10)),
        taskName: 'English');
    await store.finishFocusSession(owner, active.sessionId);
    await expectLater(
        store.undoAssistant(owner, e.id, e.afterRevision, assistantId()),
        throwsFormatException);
    expect((await store.loadDailyPlan(owner, date)).items.length, 2);
  });
  test(
      'failure after task writes rolls back task, revision and outbox atomically',
      () async {
    final r = await ready();
    final db = await databaseFactoryFfi.openDatabase(path);
    await db.execute(
        "CREATE TRIGGER fixture_abort BEFORE UPDATE ON local_assistant_document WHEN json_extract(NEW.payload,'\$.execution.status')='committed' BEGIN SELECT RAISE(ABORT,'fixture-failure'); END");
    final id = assistantId();
    await expectLater(
        store.applyAssistant(owner, r.p.id, 1, r.c.id, r.v.id, id),
        throwsA(isA<DatabaseException>()));
    final plan = await store.loadDailyPlan(owner, date);
    expect(plan.items, isEmpty);
    expect(plan.dayRevision, 0);
    expect(await store.pendingOutboxCount(owner), 0);
    expect((await store.assistantExecution(owner, id))!.status, 'rejected');
  });
  test('empty edit creates no plan and validation is bound to one proposal',
      () async {
    final r = await ready();
    final empty =
        await store.validateAssistant(owner, r.p.id, 1, r.c.id, edited: []);
    final e = await store.applyAssistant(
        owner, r.p.id, empty.revision, r.c.id, empty.id, assistantId());
    expect(e.changes, isEmpty);
    expect(e.afterRevision, 0);
    final second = await proposal();
    await expectLater(
        store.applyAssistant(owner, second.id, 1, second.candidates[1].id,
            r.v.id, assistantId()),
        throwsFormatException);
    final db = await databaseFactoryFfi.openDatabase(path);
    expect(
        (await db.rawQuery('SELECT COUNT(*) AS count FROM local_daily_plan'))
            .first['count'],
        0);
  });
  test('new validation invalidates old edited candidate revision', () async {
    final r = await ready();
    await store.validateAssistant(owner, r.p.id, 1, r.c.id,
        edited: r.c.items.sublist(0, 1));
    await expectLater(
        store.applyAssistant(owner, r.p.id, 1, r.c.id, r.v.id, assistantId()),
        throwsFormatException);
  });
  test('cold start keeps committed operation and day revision', () async {
    final r = await ready();
    final e = await store.applyAssistant(
        owner, r.p.id, 1, r.c.id, r.v.id, assistantId());
    await store.close();
    await store.initialize();
    expect((await store.assistantExecution(owner, e.id))!.status, 'committed');
    expect(
        (await store.loadDailyPlan(owner, date)).dayRevision, e.afterRevision);
  });
  test(
      'manual insertion after assistant append allocates a noncolliding stable ID',
      () async {
    final r = await ready();
    await store.applyAssistant(owner, r.p.id, 1, r.c.id, r.v.id, assistantId());
    final plan = await store.loadDailyPlan(owner, date);
    final originalIds = plan.items.map((i) => i.id).toList();
    final inserted = plan.copyWith(items: [
      plan.items.first,
      const TodayPlanItem(
          id: 0,
          title: 'New manual task',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: 40,
          endSlot: 41,
          sortOrder: 1),
      plan.items.last
    ]);
    final saved = await store.saveDailyPlan(owner, inserted);
    expect(saved.items.first.id, originalIds.first);
    expect(saved.items.last.id, originalIds.last);
    expect(saved.items[1].id, greaterThan(originalIds.last));
    expect(saved.items.map((i) => i.id).toSet().length, 3);
  });
  test('exact direct command validates and saves without a second apply',
      () async {
    final identity = ValueNotifier(owner);
    final c = AssistantController(
        identity: identity,
        owner: () => identity.value,
        offline: () => true,
        session: () => null,
        loadPlan: (day) => store.loadDailyPlan(owner, day),
        refresh: (_) async {},
        store: store,
        api: AssistantApi());
    c.instruction = '直接新增 $date 23:00-24:00 英语，保留已有任务';
    await c.generate();
    expect(c.execution!.status, 'committed');
    expect(c.pendingOperationId, isNull);
    final plan = await store.loadDailyPlan(owner, date);
    expect(plan.items.single.title, '英语');
    expect(plan.items.single.startSlot, 46);
    expect(plan.items.single.endSlot, 48);
    expect(await store.pendingOutboxCount(owner), 1);
    await c.undo();
    expect((await store.loadDailyPlan(owner, date)).items, isEmpty);
    expect((await store.loadDailyPlan(owner, date)).dayRevision, 2);
    c.dispose();
    identity.dispose();
  });
  test('a completed task prevents undo without removing newer edits', () async {
    final r = await ready();
    final e = await store.applyAssistant(
        owner, r.p.id, 1, r.c.id, r.v.id, assistantId());
    final plan = await store.loadDailyPlan(owner, date);
    await store.saveDailyPlan(owner, plan.toggleAt(0, true));
    await expectLater(
        store.undoAssistant(owner, e.id, e.afterRevision, assistantId()),
        throwsFormatException);
    expect(
        (await store.loadDailyPlan(owner, date)).items.first.completed, true);
  });
}
