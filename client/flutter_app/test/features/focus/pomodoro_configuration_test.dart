import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  late OfflineStore store;
  late Database db;
  late String path;
  const owner = 'local:pomodoro-qa';
  setUp(() async {
    sqfliteFfiInit();
    folder = await Directory.systemTemp.createTemp('pomodoro-qa-');
    path = '${folder.path}/qa.db';
    store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => path);
    await store.initialize();
    db = await databaseFactoryFfi.openDatabase(path);
  });
  tearDown(() async {
    await store.close();
    await folder.delete(recursive: true);
  });
  Future<FocusSession> start() => store.startFocusSession(owner,
      endTime: DateTime.now().add(const Duration(hours: 1)));
  Future<FocusSession> configure(int id,
          {bool bind = true, int study = 25, int rest = 5}) =>
      store.configureFocusPomodoro(owner, id,
          bindPomodoro: bind,
          pomodoroStudyMinutes: study,
          pomodoroBreakMinutes: rest);

  test(
      'late binding starts a fresh stage and restores paused settings without changing focus time',
      () async {
    final focus = await start();
    await db.update('local_focus_session',
        {'paused': 1, 'elapsed_seconds': 1200, 'remaining_seconds': 2400},
        where: 'session_id = ?', whereArgs: [focus.sessionId]);
    final bound = await configure(focus.sessionId);
    expect(bound.paused, isTrue);
    expect(bound.elapsedSeconds, 1200);
    expect(bound.remainingSeconds, 2400);
    expect(bound.stageRemainingSeconds, 1500);
    expect(bound.pomodoroElapsedOffsetSeconds, 1200);
    expect(bound.plannedEndTime, focus.plannedEndTime);
    await store.close();
    await store.initialize();
    final restored = await store.loadActiveFocusSession(owner);
    expect(restored.stageRemainingSeconds, 1500);
    expect(restored.paused, isTrue);
    expect((await store.loadActiveFocusSession('local:other')).active, isFalse);
    final unchanged = await configure(focus.sessionId);
    expect(unchanged.pomodoroElapsedOffsetSeconds, 1200);
  });

  test(
      'change and unbind retain completed pomodoros and finish remains idempotent',
      () async {
    final focus = await start();
    await configure(focus.sessionId, study: 1, rest: 0);
    await db.update('local_focus_session',
        {'paused': 1, 'elapsed_seconds': 120, 'remaining_seconds': 3400});
    final changed = await configure(focus.sessionId, study: 10);
    expect(changed.completedPomodoroCount, 2);
    expect(changed.stageRemainingSeconds, 600);
    final unbound = await configure(focus.sessionId, bind: false);
    expect(unbound.completedPomodoroCount, 2);
    expect(unbound.bindPomodoro, isFalse);
    final finished = await store.finishFocusSession(owner, focus.sessionId);
    expect(finished.completedPomodoroCount, 2);
    expect(
        (await store.finishFocusSession(owner, focus.sessionId))
            .completedPomodoroCount,
        2);
    expect((await store.loadStatsOverview(owner)).totalPomodoroCompleted, 2);
  });

  test(
      'tenant mismatch invalid duration and failed outbox leave settings intact',
      () async {
    final focus = await start();
    await expectLater(
        store.configureFocusPomodoro('local:other', focus.sessionId,
            bindPomodoro: true,
            pomodoroStudyMinutes: 25,
            pomodoroBreakMinutes: 5),
        throwsStateError);
    await expectLater(
        configure(focus.sessionId, study: 0), throwsArgumentError);
    await db.execute(
        "CREATE TRIGGER reject_pomodoro_outbox BEFORE INSERT ON sync_outbox WHEN NEW.operation_type = 'pomodoro' BEGIN SELECT RAISE(ABORT, 'qa_failure'); END");
    await expectLater(
        configure(focus.sessionId), throwsA(isA<DatabaseException>()));
    expect((await store.loadActiveFocusSession(owner)).bindPomodoro, isFalse);
    expect((await db.query('sync_outbox')).length, 1);
  });

  test('v6 migration keeps existing focus and adds zero anchors', () async {
    final focus = await start();
    await db.execute(
        'ALTER TABLE local_focus_session DROP COLUMN pomodoro_elapsed_offset_seconds');
    await db.execute(
        'ALTER TABLE local_focus_session DROP COLUMN pomodoro_completed_base_count');
    await db.setVersion(6);
    await store.close();
    await store.initialize();
    final restored = await store.loadActiveFocusSession(owner);
    expect(restored.sessionId, focus.sessionId);
    expect(restored.taskName, focus.taskName);
    expect(restored.pomodoroElapsedOffsetSeconds, 0);
    expect(restored.pomodoroCompletedBaseCount, 0);
  });

  test('same timestamp imports keep focus create configure finish order',
      () async {
    final focus = await start();
    await configure(focus.sessionId);
    await store.finishFocusSession(owner, focus.sessionId);
    await db.update('sync_outbox', {'created_at': '2026-10-12T12:00:00.000Z'});
    final pending = await store.loadPendingSyncOperations(owner);
    expect(pending.map((item) => item.operationType),
        ['create', 'pomodoro', 'finish']);
    expect(pending.map((item) => item.clientVersion), [1, 2, 3]);
  });

  test(
      'anchored stage completes exactly at focus end and paused break stays frozen',
      () {
    final focus = FocusSession.fromJson({
      'active': true,
      'elapsedSeconds': 1200,
      'remainingSeconds': 60,
      'bindPomodoro': true,
      'pomodoroStudyMinutes': 1,
      'pomodoroBreakMinutes': 5,
      'pomodoroElapsedOffsetSeconds': 1200,
      'pomodoroCompletedBaseCount': 3
    });
    final done =
        focus.advanceTo(focus.referenceTime.add(const Duration(minutes: 1)));
    expect(done.completedPomodoroCount, 4);
    expect(done.active, isFalse);
    final paused = FocusSession.fromJson({
      'active': true,
      'paused': true,
      'elapsedSeconds': 1260,
      'remainingSeconds': 500,
      'bindPomodoro': true,
      'pomodoroStudyMinutes': 1,
      'pomodoroBreakMinutes': 5,
      'pomodoroElapsedOffsetSeconds': 1200,
      'pomodoroCompletedBaseCount': 3
    });
    expect(paused.stageName, 'break');
    expect(paused.stageRemainingSeconds, 300);
    expect(paused.tick(), same(paused));
  });
}
