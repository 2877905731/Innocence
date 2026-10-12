import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/session_controller.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/assistant/domain/assistant_models.dart';
import 'package:innocence_flutter/features/assistant/domain/local_planner.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// These pinned FFI adapters keep real SQLite transactions while denying JSON SQL.
// ignore: implementation_imports
import 'package:sqflite_common_ffi/src/database_factory_ffi_io.dart';
// ignore: implementation_imports
import 'package:sqflite_common_ffi/src/sqflite_import.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late OfflineStore store;
  late Database db;
  const owner = 'local:focus-compatibility';

  setUp(() async {
    sqfliteFfiInit();
    directory = await Directory.systemTemp.createTemp('offline-focus-');
    final path = '${directory.path}/focus.db';
    final factory = buildDatabaseFactory(
      invokeMethod: (method, [arguments]) async {
        final sql = arguments is Map ? arguments['sql'] : null;
        if (sql is String &&
            RegExp(r'\bjson\w*\s*\(', caseSensitive: false).hasMatch(sql)) {
          throw SqfliteDatabaseException('no such function: json_set', null);
        }
        return ffiMethodCallHandleNoIsolate(FfiMethodCall(method, arguments));
      },
    );
    store = OfflineStore(
        databaseFactory: factory, databasePathProvider: () async => path);
    await store.initialize();
    db = await factory.openDatabase(path);
    await expectLater(
        db.rawQuery("SELECT json('{}')"), throwsA(isA<DatabaseException>()));
  });
  tearDown(() async {
    await store.close();
    await directory.delete(recursive: true);
  });

  Future<AssistantExecution> apply() async {
    final plan = await store.loadDailyPlan(owner, TodayPlan.empty().planDate);
    final proposal = LocalPlanner().generate(plan, 'Review 60 min', 20, 30);
    await store.saveAssistantProposal(owner, proposal);
    final candidate = proposal.candidates[1];
    final validation = await store.validateAssistant(
        owner, proposal.id, proposal.revision, candidate.id);
    return store.applyAssistant(owner, proposal.id, proposal.revision,
        candidate.id, validation.id, assistantId());
  }

  test(
      'offline controller starts, pauses, restores and finishes without JSON SQL',
      () async {
    SharedPreferences.setMockInitialValues({'app.language': 'zh_CN'});
    final preferences = await SharedPreferences.getInstance();
    SessionController controller() => SessionController(
          authApi: AuthApi(),
          localStorage: AuthLocalStorage(preferences),
          languageController: AppLanguageController(preferences),
          offlineStore: store,
          restoreOfflineOnStartup: true,
          offlineOnlyBuild: true,
        );
    final first = controller();
    var firstDisposed = false;
    addTearDown(() {
      if (!firstDisposed) first.dispose();
    });
    await first.enterOfflineMode();
    final localOwner = first.localOwnerScope!;
    await first.startFocusSession(
        endTime: DateTime.now().add(const Duration(minutes: 10)));
    expect(first.focusSession.active, isTrue);
    expect(first.bannerMessage, '离线专注已开始，记录保存在本机。');
    final id = first.focusSession.sessionId;
    await first.toggleFocusPause();
    expect(first.focusSession.paused, isTrue);
    final pausedSeconds = first.focusSession.remainingSeconds;
    first.dispose();
    firstDisposed = true;
    await store.close();
    final second = controller();
    addTearDown(second.dispose);
    await second.initialize();
    expect(second.localOwnerScope, localOwner);
    expect(second.focusSession.sessionId, id);
    expect(second.focusSession.paused, isTrue);
    expect(second.focusSession.remainingSeconds, pausedSeconds);
    await second.toggleFocusPause();
    expect(second.focusSession.paused, isFalse);
    await second.finishFocusSession();
    expect(second.focusSession.active, isFalse);
    expect(await store.pendingOutboxCount(localOwner), 2);
  });

  test(
      'focus invalidates only this owner execution and preserves other document values',
      () async {
    final execution = await apply();
    final row = (await db.query('local_assistant_document',
            where: 'owner_scope=? AND kind=? AND document_id=?',
            whereArgs: [owner, 'execution', execution.id]))
        .single;
    final before = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
    before['extra'] = {'kept': 'fixture'};
    await db.update('local_assistant_document', {'payload': jsonEncode(before)},
        where: 'owner_scope=? AND kind=? AND document_id=?',
        whereArgs: [owner, 'execution', execution.id]);
    await db.insert('local_assistant_document',
        {...row, 'owner_scope': 'local:other', 'payload': jsonEncode(before)});
    await db.insert('local_assistant_document',
        {...row, 'document_id': 'expired', 'payload': '{"status":"expired"}'});
    await store.saveAssistantRecovery(owner, {
      'execution': {'undoEligibility': true}
    });
    final started = await store.startFocusSession(owner,
        endTime: DateTime.now().add(const Duration(minutes: 10)));
    expect(started.active, isTrue);
    final afterRow = (await db.query('local_assistant_document',
            where: 'owner_scope=? AND kind=? AND document_id=?',
            whereArgs: [owner, 'execution', execution.id]))
        .single;
    final expected = jsonDecode(jsonEncode(before)) as Map<String, dynamic>;
    expected['execution']['undoEligibility'] = false;
    expect(jsonDecode(afterRow['payload'] as String), expected);
    expect(afterRow['created_at'], row['created_at']);
    expect(
        (await store.assistantExecution('local:other', execution.id))!
            .undoEligibility,
        isTrue);
    expect(
        (await store.loadAssistantRecovery(owner))!['execution']
            ['undoEligibility'],
        isTrue);
    await store.finishFocusSession(owner, started.sessionId);
    await expectLater(
        store.undoAssistant(
            owner, execution.id, execution.afterRevision, assistantId()),
        throwsFormatException);
    expect(
        (await store.assistantExecution(owner, execution.id))!.undoEligibility,
        isFalse);
  });

  test('focus write failure rolls back undo eligibility, revision and outbox',
      () async {
    final execution = await apply();
    final count = await store.pendingOutboxCount(owner);
    await db.execute(
        "CREATE TRIGGER fail_focus BEFORE INSERT ON local_focus_session BEGIN SELECT RAISE(ABORT,'fixture-focus-failure'); END");
    await expectLater(
        store.startFocusSession(owner,
            endTime: DateTime.now().add(const Duration(minutes: 10))),
        throwsA(isA<DatabaseException>()));
    expect(
        (await store.assistantExecution(owner, execution.id))!.undoEligibility,
        isTrue);
    expect((await store.loadDailyPlan(owner, execution.planDate)).dayRevision,
        execution.afterRevision);
    expect(await store.pendingOutboxCount(owner), count);
    expect((await store.loadActiveFocusSession(owner)).active, isFalse);
  });
}
