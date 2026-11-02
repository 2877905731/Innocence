import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/focus/application/pomodoro_controller.dart';
import 'package:innocence_flutter/features/focus/domain/models/pomodoro_timer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bound focus credits only study and caps recovery at its total deadline',
      () {
    final start = DateTime(2026, 11, 3, 9).millisecondsSinceEpoch;
    final t = PomodoroTimer(
        id: 'bound',
        active: true,
        studyMinutes: 2,
        breakMinutes: 1,
        referenceMs: start,
        boundSessionId: 7,
        boundUntilMs: start + 90000,
        coveredFromMs: start,
        coveredUntilMs: start + 90000);
    final recovered =
        PomodoroTimer.fromJson(t.toJson()).advance(start + 3600000);
    expect(recovered.active, isFalse);
    expect(recovered.records.single.studyMs, 90000);
    expect(recovered.records.single.creditedMs, 90000);
    expect(recovered.completed, 0);
    expect(recovered.advance(start + 999999999).records.single.studyMs, 90000);
  });
  test('bound waiting and incomplete break never manufacture study or a round',
      () {
    final start = DateTime(2026, 11, 3, 9).millisecondsSinceEpoch;
    final t = PomodoroTimer(
        id: 'bound',
        active: true,
        studyMinutes: 1,
        breakMinutes: 1,
        referenceMs: start,
        boundSessionId: 7,
        boundUntilMs: start + 180000);
    final study = t.advance(start + 90000);
    expect(study.awaitingNext, isTrue);
    expect(study.records.single.studyMs, 60000);
    final rest = study.beginNextStage(start + 150000).advance(start + 900000);
    expect(rest.active, isFalse);
    expect(rest.records.single.studyMs, 60000);
    expect(rest.completed, 0);
    expect(study.advance(start + 900000).active, isFalse);
  });
  test('offline bound focus envelope is excluded from stats and import credit',
      () async {
    sqfliteFfiInit();
    final folder = await Directory.systemTemp.createTemp('bound-focus-qa-');
    final store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => '${folder.path}/qa.db');
    try {
      final focus = await store.startFocusSession('local:bound',
          endTime: DateTime.now().add(const Duration(hours: 1)),
          bindPomodoro: true,
          manualPomodoro: true,
          pomodoroStudyMinutes: 1,
          pomodoroBreakMinutes: 1);
      expect(focus.manualPomodoro, isTrue);
      final db = await databaseFactoryFfi.openDatabase('${folder.path}/qa.db');
      await db.update('local_focus_session',
          {'elapsed_seconds': 240, 'remaining_seconds': 3360, 'paused': 1},
          where: 'session_id=?', whereArgs: [focus.sessionId]);
      expect(
          (await store.loadStatsOverview('local:bound'))
              .totalStudyDurationMinutes,
          0);
      final restored = await store.loadActiveFocusSession('local:bound');
      expect(restored.manualPomodoro, isTrue);
      expect(restored.completedPomodoroCount, 0);
      await store.finishFocusSession('local:bound', focus.sessionId);
      expect(
          (await store.loadStatsOverview('local:bound'))
              .totalStudyDurationMinutes,
          0);
    } finally {
      await store.close();
      await folder.delete(recursive: true);
    }
  });
  test(
      'new focus coverage is applied to the pending interval before study is saved',
      () async {
    sqfliteFfiInit();
    final folder = await Directory.systemTemp.createTemp('pomodoro-overlap-');
    final store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => '${folder.path}/qa.db');
    final start = DateTime.now().millisecondsSinceEpoch;
    var now = start;
    var window = [0, 0];
    final c = PomodoroController(
        store: store,
        owner: () => 'local:qa',
        chinese: () => true,
        platform: 'test',
        now: () => now,
        focusWindow: () => window);
    try {
      await c.updateIdentity();
      await c.start(1, 0, false);
      now += 30000;
      window = [start + 15000, start + 45000];
      await c.updateFocusCoverage();
      now += 60000;
      await c.checkpoint();
      final rows = await store.pendingPomodoroStudies('local:qa');
      expect(rows.single.studyMs, 60000);
      expect(rows.single.creditedMs, 30000);
      expect(rows.single.completedRounds, 1);
    } finally {
      c.dispose();
      await store.close();
      await folder.delete(recursive: true);
    }
  });
  test('study, waiting, break and next round each require the correct boundary',
      () {
    final start = DateTime(2026, 11, 2, 9).millisecondsSinceEpoch;
    final t = PomodoroTimer(
        id: 'qa',
        active: true,
        studyMinutes: 1,
        breakMinutes: 1,
        referenceMs: start);
    final study = t.advance(start + 90000);
    expect(study.awaitingNext, isTrue);
    expect(study.records.single.studyMs, 60000);
    expect(study.completed, 0);
    final waiting = study.advance(start + 999999999);
    expect(waiting.referenceMs, start + 60000);
    expect(waiting.records.single.studyMs, 60000);
    final rest = waiting.beginNextStage(start + 300000);
    expect(rest.resting, isTrue);
    expect(rest.remainingSeconds, 60);
    final complete = rest.advance(start + 390000);
    expect(complete.completed, 1);
    expect(complete.records.single.studyMs, 60000);
    expect(complete.records.single.completedRounds, 1);
    final next = complete.beginNextStage(start + 600000);
    expect(next.stage, 'study');
    expect(next.cycle, 2);
    expect(next.remainingSeconds, 60);
    expect(next.records, isEmpty);
  });

  test(
      'midnight slices and saved focus coverage survive restart without duplicate study',
      () {
    final start = DateTime(2026, 11, 2, 23, 59, 30).millisecondsSinceEpoch;
    final t = PomodoroTimer(
        id: 'qa',
        active: true,
        studyMinutes: 2,
        breakMinutes: 0,
        referenceMs: start,
        coveredFromMs: start,
        coveredUntilMs: start + 60000);
    final halfway = PomodoroTimer.fromJson(t.advance(start + 45000).toJson());
    final end = halfway.advance(start + 86400000);
    expect(end.completed, 1);
    expect(end.awaitingNext, isTrue);
    expect(
        end.records.map((r) => r.date).toList(), ['2026-11-02', '2026-11-03']);
    expect(end.records.fold<int>(0, (v, r) => v + r.studyMs), 120000);
    expect(end.records.fold<int>(0, (v, r) => v + r.creditedMs), 60000);
    expect(end.records.last.completedRounds, 1);
  });

  test(
      'legacy timer converts only its current stage and does not invent historical credit',
      () {
    final migrated = PomodoroTimer.fromJson({
      'id': 'legacy',
      'active': true,
      'paused': true,
      'studyMinutes': 1,
      'breakMinutes': 1,
      'elapsedMs': 210000,
      'referenceMs': 1800000000000,
      'notices': true
    });
    expect(migrated.stage, 'break');
    expect(migrated.cycle, 2);
    expect(migrated.completed, 1);
    expect(migrated.remainingSeconds, 30);
    expect(migrated.records, isEmpty);
    expect(migrated.advance(1800000100000).records, isEmpty);
  });

  test(
      'learning stats are durable and idempotent, while waiting and breaks add no study',
      () async {
    sqfliteFfiInit();
    final folder = await Directory.systemTemp.createTemp('manual-pomodoro-');
    final store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => '${folder.path}/qa.db');
    final today = DateTime.now();
    // Keep this same-day persistence case independent of the wall-clock hour;
    // the explicit midnight cases above verify date splitting separately.
    var now =
        DateTime(today.year, today.month, today.day, 12).millisecondsSinceEpoch;
    final c = PomodoroController(
        store: store,
        owner: () => 'local:qa',
        chinese: () => true,
        platform: 'test',
        now: () => now);
    try {
      await c.updateIdentity();
      await c.start(1, 1, false);
      now += 90000;
      await c.checkpoint();
      expect(
          (await store.loadStatsOverview('local:qa')).totalStudyDurationMinutes,
          1);
      expect((await store.loadStatsOverview('local:qa')).totalPomodoroCompleted,
          0);
      now += 3600000;
      await c.checkpoint();
      expect((await store.pendingPomodoroStudies('local:qa')).length, 1);
      await c.startNextStage();
      now += 60000;
      await c.checkpoint();
      final stats = await store.loadStatsOverview('local:qa');
      expect(stats.totalStudyDurationMinutes, 1);
      expect(stats.totalPomodoroCompleted, 1);
      expect(
          (await store.loadStatsOverview('local:other'))
              .totalStudyDurationMinutes,
          0);
      await c.startNextStage();
      now += 30000;
      await c.finish();
      final rows = await store.pendingPomodoroStudies('local:qa');
      expect(rows.fold<int>(0, (v, r) => v + r.studyMs), 90000);
      expect(rows.fold<int>(0, (v, r) => v + r.completedRounds), 1);
      expect(await store.pendingOutboxCount('local:qa'), greaterThan(0));
      final row = rows.first;
      await store.acknowledgePomodoroStudy('local:other', row);
      expect((await store.pendingPomodoroStudies('local:qa')).length, 2);
    } finally {
      c.dispose();
      await store.close();
      await folder.delete(recursive: true);
    }
  });
}
