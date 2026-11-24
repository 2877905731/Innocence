import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/plan_order_button.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';

TodayPlan _day() => TodayPlan.empty('2027-02-03').copyWith(items: [
      const TodayPlanItem(
          id: 41,
          title: 'Late',
          completed: true,
          plannedMinutes: 60,
          actualMinutes: 17,
          startSlot: 30,
          endSlot: 32,
          sortOrder: 0),
      const TodayPlanItem(
          id: 42,
          title: 'Flexible',
          completed: false,
          plannedMinutes: 20,
          actualMinutes: 3,
          startSlot: null,
          endSlot: null,
          sortOrder: 1),
      const TodayPlanItem(
          id: 43,
          title: 'Early',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: 10,
          endSlot: 11,
          sortOrder: 2),
    ]);
AnnualPlanSegment _annual(String title) => AnnualPlanSegment(
        id: '',
        clientEntityId: '',
        year: 2027,
        title: title,
        startMonth: 2,
        endMonth: 11,
        colorKey: 'gold',
        sortOrder: 0,
        note: 'fixture',
        progressPercent: 37,
        revision: 0,
        updateTime: '',
        subtasks: const [
          AnnualPlanSubtask(
              id: '',
              title: 'First child',
              detail: 'detail',
              completed: true,
              sortOrder: 0),
          AnnualPlanSubtask(
              id: '',
              title: 'Second child',
              detail: '',
              completed: false,
              sortOrder: 1),
        ]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);
  test(
      'SQLite sorting is atomic, owner scoped, restart safe and retains business values',
      () async {
    final dir = await Directory.systemTemp.createTemp('innocence-order-');
    final path = '${dir.path}/order.db';
    var store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => path);
    addTearDown(() async {
      await store.close();
      await dir.delete(recursive: true);
    });
    const owner = 'local:order-fixture';
    final day = await store.saveDailyPlan(owner, _day());
    var order = PlanOrder.today(day);
    final reversed = order.withItems(order.items.reversed.toList());
    await store.reorderPlans(owner, reversed);
    var saved = await store.loadDailyPlan(owner, day.planDate);
    expect(saved.items.map((i) => i.id), [43, 42, 41]);
    expect(saved.items.last.startSlot, 30);
    expect(saved.items.last.actualMinutes, 17);
    expect(saved.items.last.completed, true);
    expect(saved.dayRevision, day.dayRevision + 1);
    await expectLater(
        store.reorderPlans(owner, reversed), throwsFormatException);
    await expectLater(
        store.reorderPlans('local:foreign', reversed), throwsFormatException);
    order = PlanOrder.today(saved);
    await expectLater(
        store.reorderPlans(
            owner,
            order.withItems(
                [order.items.first, order.items.first, order.items.last])),
        throwsFormatException);
    await expectLater(
        store.reorderPlans(
            owner, order.withItems(order.items.take(2).toList())),
        throwsFormatException);
    expect(
        (await store.loadDailyPlan(owner, day.planDate)).items.map((i) => i.id),
        [43, 42, 41]);

    final db = await databaseFactoryFfi.openDatabase(path);
    final pending = (await db.query('sync_outbox')).length;
    await db.execute(
        "CREATE TRIGGER reject_order_fixture BEFORE UPDATE OF sort_order ON local_daily_plan_item WHEN NEW.item_id=42 BEGIN SELECT RAISE(ABORT, 'fixture write failure'); END");
    await expectLater(
        store.reorderPlans(
            owner, order.withItems(order.items.reversed.toList())),
        throwsA(isA<DatabaseException>()));
    await db.execute('DROP TRIGGER reject_order_fixture');
    final rolledBack = await store.loadDailyPlan(owner, day.planDate);
    expect(rolledBack.items.map((i) => i.id), [43, 42, 41]);
    expect(rolledBack.dayRevision, saved.dayRevision);
    expect((await db.query('sync_outbox')).length, pending);

    await store.saveAnnualSegment(owner, _annual('First'));
    var overview = await store.saveAnnualSegment(owner, _annual('Second'));
    final beforeIds = overview.segments.map((s) => s.id).toList();
    order = PlanOrder.annual(overview);
    await store.reorderPlans(
        owner, order.withItems(order.items.reversed.toList()));
    overview = await store.loadAnnualOverview(owner, 2027);
    expect(overview.segments.map((s) => s.id), beforeIds.reversed);
    await expectLater(store.reorderPlans(owner, order), throwsFormatException);
    final parent = overview.segments.first;
    final children = parent.subtasks.map((s) => s.id).toList();
    order = PlanOrder.subtasks(parent);
    await store.reorderPlans(
        owner, order.withItems(order.items.reversed.toList()));
    await expectLater(
        store.reorderPlans('local:foreign', order), throwsFormatException);
    final updated =
        (await store.loadAnnualOverview(owner, 2027)).segments.first;
    expect(updated.subtasks.map((s) => s.id), children.reversed);
    expect(updated.subtasks.last.completed, true);
    expect(updated.subtasks.last.detail, 'detail');
    expect(updated.progressPercent, 37);
    expect(updated.startMonth, 2);
    expect(updated.colorKey, 'gold');
    expect(updated.revision, parent.revision + 1);
    await store.close();
    store = OfflineStore(
        databaseFactory: databaseFactoryFfi,
        databasePathProvider: () async => path);
    saved = await store.loadDailyPlan(owner, day.planDate);
    expect(saved.items.map((i) => i.id), [43, 42, 41]);
    overview = await store.loadAnnualOverview(owner, 2027);
    expect(overview.segments.map((s) => s.id), beforeIds.reversed);
    expect(
        overview.segments.first.subtasks.map((s) => s.id), children.reversed);
  });

  testWidgets(
      'sorting supports drag and arrows, keeps failed drafts and retries at phone width',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    PlanOrder? submitted;
    var succeed = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => PlanOrderButton(
                    order: PlanOrder.today(_day()),
                    isChinese: false,
                    onSave: (order) async {
                      submitted = order;
                      return succeed;
                    })))));
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('order-down-41')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-plan-order')));
    await tester.pumpAndSettle();
    expect(submitted!.items.map((i) => i.id), ['42', '41', '43']);
    expect(find.textContaining('Order not saved.'), findsOneWidget);
    final list =
        tester.widget<ReorderableListView>(find.byType(ReorderableListView));
    // Matches the callback supported by the Flutter OH SDK.
    // ignore: deprecated_member_use
    list.onReorder!(2, 0);
    await tester.pumpAndSettle();
    succeed = true;
    await tester.tap(find.byKey(const ValueKey('save-plan-order')));
    await tester.pumpAndSettle();
    expect(submitted!.items.map((i) => i.id), ['43', '42', '41']);
    expect(find.byType(PlanOrderDialog), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets(
      'cancel never writes and editor saves preserve a mixed manual order',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    TodayPlan? saved;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => TodayPlanEditorDialog(
                            initialPlan: _day(),
                            onSaveResult: (plan) async {
                              saved = plan;
                              return true;
                            })),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('order-down-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    // A title edit after sorting must not restore chronological order.
    await tester.enterText(find.byType(TextField).first, 'Updated plan');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();
    expect(saved!.items.map((i) => i.id), [41, 42, 43]);
    expect(saved!.items.first.actualMinutes, 17);
    expect(saved!.items.first.completed, true);
    expect(saved!.items.first.startSlot, 30);
    expect(saved!.items.last.startSlot, 10);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
