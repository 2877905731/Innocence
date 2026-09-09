import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';

void main() {
  testWidgets(
    'Chinese 48-slot timeline saves a selected block without extra editing',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      TodayPlan? savedPlan;
      const visualTheme = AppVisualTheme.glass;
      final tokens = AppVisualTokens.of(visualTheme);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: tokens.toThemeData(visualTheme),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      savedPlan = await showDialog<TodayPlan>(
                        context: context,
                        builder: (context) => TodayPlanEditorDialog(
                          initialPlan: TodayPlan.empty('2026-08-19'),
                        ),
                      );
                    },
                    child: const Text('打开编辑器'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开编辑器'));
      await tester.pumpAndSettle();

      expect(find.text('今日计划时间安排'), findsOneWidget);
      expect(find.text('Short plan scheduler'), findsNothing);
      expect(find.text('保存当天计划'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('today-plan-slot-');
        }),
        findsNWidgets(48),
      );

      await tester.tap(find.byKey(const ValueKey('today-plan-slot-4')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const ValueKey('today-plan-slot-5')));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byKey(const ValueKey('today-plan-save')));
      await tester.pumpAndSettle();

      expect(savedPlan, isNotNull);
      expect(savedPlan!.items, hasLength(1));
      expect(savedPlan!.items.single.title, '学习任务 1');
      expect(savedPlan!.items.single.startSlot, 4);
      expect(savedPlan!.items.single.endSlot, 6);
    },
  );

  testWidgets('saving keeps the editor open and allows another edit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final savedPlans = <TodayPlan>[];
    const visualTheme = AppVisualTheme.minimalism;
    final tokens = AppVisualTokens.of(visualTheme);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: tokens.toThemeData(visualTheme),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => TodayPlanEditorDialog(
                  initialPlan: TodayPlan.empty('2026-09-08'),
                  onSave: (plan) async => savedPlans.add(plan),
                ),
              ),
              child: const Text('编辑当天'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('编辑当天'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('today-plan-slot-4')));
    await tester.tap(find.byKey(const ValueKey('today-plan-slot-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();

    expect(savedPlans, hasLength(1));
    expect(find.text('今日计划时间安排'), findsOneWidget);
    expect(find.textContaining('已保存于'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('today-plan-slot-8')));
    await tester.tap(find.byKey(const ValueKey('today-plan-slot-9')));
    await tester.pump();
    expect(find.text('有未保存更改'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('today-plan-save')));
    await tester.pumpAndSettle();

    expect(savedPlans, hasLength(2));
    expect(savedPlans.last.items, hasLength(2));
    expect(find.text('今日计划时间安排'), findsOneWidget);
  });

  testWidgets('compact editor keeps all time slots and save action visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const visualTheme = AppVisualTheme.glass;
    final tokens = AppVisualTokens.of(visualTheme);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: tokens.toThemeData(visualTheme),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog<TodayPlan>(
                context: context,
                builder: (context) => TodayPlanEditorDialog(
                  initialPlan: TodayPlan.empty('2026-08-19'),
                ),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('today-plan-save')), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('today-plan-slot-');
      }),
      findsNWidgets(48),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'occupied blocks use distinct strips and resize stops at the next block',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const initialPlan = TodayPlan(
        planDate: '2026-08-20',
        planName: 'Today',
        completedCount: 0,
        totalCount: 2,
        totalPlannedMinutes: 120,
        completedPlannedMinutes: 0,
        items: [
          TodayPlanItem(
            id: 1,
            title: '任务 A',
            completed: false,
            plannedMinutes: 60,
            actualMinutes: 0,
            startSlot: 4,
            endSlot: 6,
            sortOrder: 0,
          ),
          TodayPlanItem(
            id: 2,
            title: '任务 B',
            completed: false,
            plannedMinutes: 60,
            actualMinutes: 0,
            startSlot: 8,
            endSlot: 10,
            sortOrder: 1,
          ),
        ],
      );
      TodayPlan? savedPlan;
      const visualTheme = AppVisualTheme.glass;
      final tokens = AppVisualTokens.of(visualTheme);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: tokens.toThemeData(visualTheme),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  savedPlan = await showDialog<TodayPlan>(
                    context: context,
                    builder: (context) => const TodayPlanEditorDialog(
                      initialPlan: initialPlan,
                    ),
                  );
                },
                child: const Text('编辑'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('today-plan-mini-strip-0-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('today-plan-mini-strip-1-0')),
        findsOneWidget,
      );
      final firstDecoration = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('today-plan-mini-strip-0-0')),
          )
          .decoration as BoxDecoration;
      final secondDecoration = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('today-plan-mini-strip-1-0')),
          )
          .decoration as BoxDecoration;
      expect(firstDecoration.color, isNot(secondDecoration.color));
      final firstBlockSecondStrip = tester
          .widget<DecoratedBox>(
            find.byKey(const ValueKey('today-plan-mini-strip-0-1')),
          )
          .decoration as BoxDecoration;
      expect(firstDecoration.color, isNot(firstBlockSecondStrip.color));

      await tester.tap(find.byKey(const ValueKey('today-plan-slot-4')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('today-plan-resize-start-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('today-plan-resize-end-0')),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const ValueKey('today-plan-slot-5')),
        const Offset(120, 0),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('today-plan-mini-strip-0-');
        }),
        findsNWidgets(4),
      );

      await tester.tap(find.byKey(const ValueKey('today-plan-slot-12')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('today-plan-slot-9')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('today-plan-resize-start-1')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('today-plan-save')));
      await tester.pumpAndSettle();

      expect(savedPlan, isNotNull);
      expect(savedPlan!.scheduledItems, hasLength(2));
      expect(savedPlan!.scheduledItems[0].startSlot, 4);
      expect(savedPlan!.scheduledItems[0].endSlot, 8);
      expect(savedPlan!.scheduledItems[1].startSlot, 8);
      expect(savedPlan!.scheduledItems[1].endSlot, 10);
    },
  );
}
