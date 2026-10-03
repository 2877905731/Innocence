import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';
import 'package:innocence_flutter/features/plans/presentation/pages/android_plans_view.dart';

AnnualPlanSegment _segment({int progress = 95}) => AnnualPlanSegment(
      id: 'annual-a',
      clientEntityId: 'annual-client-a',
      year: 2028,
      title: '年度学习',
      startMonth: 2,
      endMonth: 12,
      colorKey: 'cyan',
      sortOrder: 0,
      note: '独立任务',
      progressPercent: progress,
      revision: 3,
      updateTime: '',
      subtasks: const [
        AnnualPlanSubtask(
            id: '', title: '子任务一', detail: '', completed: false, sortOrder: 0),
        AnnualPlanSubtask(
            id: '', title: '子任务二', detail: '', completed: false, sortOrder: 1),
      ],
    );
TodayPlan _plan(String date) =>
    TodayPlan.empty(date).copyWith(planName: '学习存档', items: const [
      TodayPlanItem(
          id: 0,
          title: '学习',
          completed: false,
          plannedMinutes: 30,
          actualMinutes: 0,
          startSlot: 12,
          endSlot: 13,
          sortOrder: 0),
    ]);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final vertical = find
        .descendant(
            of: find.byKey(const ValueKey('android-plans-content')),
            matching: find.byWidgetPredicate((widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down))
        .first;
    tester.state<ScrollableState>(vertical).position.jumpTo(0);
    await tester.pumpAndSettle();
  }
  for (var attempt = 0; finder.evaluate().isEmpty && attempt < 12; attempt++) {
    await tester.drag(find.byKey(const ValueKey('android-plans-content')),
        const Offset(0, -250));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Widget _host({
  AppVisualTheme theme = AppVisualTheme.minimalism,
  AppLanguage language = AppLanguage.simplifiedChinese,
  double scale = 1,
  double keyboard = 0,
  AnnualPlanSegment? initial,
  Future<bool> Function(AnnualPlanSegment)? onSave,
  Future<bool> Function(TodayPlan)? onSaveDate,
  void Function(String)? onLoadDate,
  void Function(List<String>, PlanApplyStrategy)? onApply,
  bool failLoad = false,
}) {
  var month = MonthPlanOverview(
      month: '2028-02', days: [MonthPlanDay.fromPlan(_plan('2028-02-07'))]);
  var annual = AnnualPlanOverview.empty(2028);
  if (initial != null) {
    annual = AnnualPlanOverview(
        year: 2028, months: annual.months, segments: [initial]);
  }
  final archive = WeeklyPlanTemplate(
      id: 11,
      templateName: '学习存档',
      sourcePlanName: '学习',
      itemCount: 1,
      totalPlannedMinutes: 30,
      items: _plan('2028-02-07').items);
  return MaterialApp(
    locale: language.isChinese
        ? const Locale('zh', 'CN')
        : const Locale('en', 'US'),
    supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    theme: AppVisualTokens.of(theme).toThemeData(theme),
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard)),
        child: child!),
    home: StatefulBuilder(
        builder: (context, update) => Scaffold(
                body: AndroidPlansView(
              language: language,
              month: month,
              annual: annual,
              archives: [archive],
              todayPlan: _plan('2028-02-07'),
              isBusy: false,
              isOffline: true,
              bannerMessage: null,
              onClearBanner: () {},
              dayContent: () => [const Text('Daily tasks')],
              actions: AndroidPlanActions(
                loadMonth: (value) async => update(() =>
                    month = MonthPlanOverview(month: value, days: month.days)),
                loadYear: (year) async => update(() => annual =
                    AnnualPlanOverview(
                        year: year,
                        months: annual.months,
                        segments: annual.segments)),
                loadDate: (date) async {
                  onLoadDate?.call(date);
                  if (failLoad) return null;
                  return _plan(date);
                },
                saveDate: (plan) async =>
                    onSaveDate == null ? true : onSaveDate(plan),
                saveArchive: (_, __) async => true,
                deleteArchive: (_) async {},
                applyArchive: (_, dates, {required strategy}) async =>
                    onApply?.call(dates, strategy),
                saveAnnual: (segment) async {
                  final saved = onSave == null ? true : await onSave(segment);
                  if (saved) {
                    update(() => annual = AnnualPlanOverview(
                        year: segment.year,
                        months: annual.months,
                        segments: [segment]));
                  }
                  return saved;
                },
                deleteAnnual: (_) async => update(
                    () => annual = AnnualPlanOverview.empty(annual.year)),
              ),
            ))),
  );
}

void main() {
  testWidgets('leap-month selection, date load, and explicit batch strategies',
      (tester) async {
    tester.view.physicalSize = const Size(411, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? dateLoaded;
    List<String>? applied;
    PlanApplyStrategy? strategy;
    await tester.pumpWidget(_host(
        onLoadDate: (date) => dateLoaded = date,
        onApply: (dates, choice) {
          applied = dates;
          strategy = choice;
        }));
    await _tap(tester, find.text('月计划'));
    final lastColumn = tester
        .getRect(find.byKey(const ValueKey('android-calendar-2028-02-06')));
    expect(lastColumn.right, lessThanOrEqualTo(379));
    expect(lastColumn.width, greaterThanOrEqualTo(48));
    expect(lastColumn.height, greaterThanOrEqualTo(48));
    expect(find.byKey(const ValueKey('android-calendar-2028-02-29')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('android-calendar-2028-02-30')),
        findsNothing);
    await _tap(
        tester, find.byKey(const ValueKey('android-calendar-2028-02-07')));
    await _tap(
        tester, find.byKey(const ValueKey('android-edit-selected-date')));
    expect(dateLoaded, '2028-02-07');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await _tap(tester, find.text('多选日期'));
    await _tap(
        tester, find.byKey(const ValueKey('android-calendar-2028-02-07')));
    await _tap(
        tester, find.byKey(const ValueKey('android-calendar-2028-02-08')));
    await _tap(tester, find.byKey(const ValueKey('android-apply-archive-11')));
    expect(find.textContaining('其中 1 天已有计划'), findsOneWidget);
    await _tap(tester, find.text('取消'));
    expect(applied, isNull);
    await _tap(tester, find.byKey(const ValueKey('android-apply-archive-11')));
    await _tap(tester, find.text('跳过已有计划'));
    expect(applied, ['2028-02-07', '2028-02-08']);
    expect(strategy, PlanApplyStrategy.skip);
    await _tap(tester, find.byKey(const ValueKey('android-apply-archive-11')));
    await _tap(tester, find.text('覆盖并套用'));
    expect(strategy, PlanApplyStrategy.overwrite);
    await _tap(tester, find.byKey(const ValueKey('android-next-month')));
    expect(find.byKey(const ValueKey('android-calendar-2028-03-31')),
        findsOneWidget);
    expect(find.text('已选 0 天'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'annual progress clamps, reopens, and subtask identities stay independent',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AnnualPlanSegment? saved;
    await tester.pumpWidget(_host(
        initial: _segment(),
        onSave: (segment) async {
          saved = segment;
          return true;
        }));
    await _tap(tester, find.text('年度'));
    await _tap(tester,
        find.byKey(const ValueKey('android-progress-plus-annual-a-10')));
    expect(saved!.progressPercent, 100);
    expect(
        tester
            .widget<OutlinedButton>(
                find.byKey(const ValueKey('android-progress-plus-annual-a-1')))
            .onPressed,
        isNull);
    await _tap(tester,
        find.byKey(const ValueKey('android-progress-minus-annual-a-10')));
    expect(saved!.progressPercent, 90);
    await _tap(
        tester, find.byKey(const ValueKey('android-subtask-annual-a-0')));
    expect(saved!.subtasks.first.completed, true);
    expect(saved!.subtasks.last.completed, false);
    expect(saved!.progressPercent, 90);
    await _tap(tester, find.byKey(const ValueKey('android-complete-annual-a')));
    expect(saved!.progressPercent, 100);
    await _tap(tester, find.byKey(const ValueKey('android-filter-month-1')));
    expect(find.text('当前范围还没有年度任务'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('android-all-months')));
    expect(find.text('年度学习'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'sticky month ruler and charge tracks scroll together without shrinking',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(initial: _segment()));
    await _tap(tester, find.text('年度'));
    final ruler = find.byKey(const ValueKey('android-filter-month-2'));
    expect(tester.getSize(ruler).width, 48);
    await tester
        .ensureVisible(find.byKey(const ValueKey('android-charge-annual-a')));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(ruler).dx,
        closeTo(
            tester
                .getTopLeft(find.byKey(const ValueKey('annual-month-track-2')))
                .dx,
            .1));
    final top = tester.getTopLeft(ruler).dy;
    await tester.drag(ruler, const Offset(-220, 0));
    await tester.pumpAndSettle();
    final november = find.byKey(const ValueKey('android-filter-month-11'));
    expect(
        tester.getTopLeft(november).dx,
        closeTo(
            tester
                .getTopLeft(find.byKey(const ValueKey('annual-month-track-11')))
                .dx,
            .1));
    await tester.drag(find.byKey(const ValueKey('android-plans-content')),
        const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(ruler).dy, top);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'annual validation, nested subtasks and failed save preserve the draft',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var attempts = 0;
    AnnualPlanSegment? saved;
    await tester.pumpWidget(_host(onSave: (segment) async {
      saved = segment;
      return ++attempts > 1;
    }));
    await _tap(tester, find.text('年度'));
    await _tap(tester, find.byKey(const ValueKey('android-create-annual')));
    await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
    expect(attempts, 0);
    expect(find.byKey(const ValueKey('android-annual-error')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('android-annual-title')), '保留草稿');
    await _tap(tester, find.byKey(const ValueKey('android-annual-start-1')));
    await _tap(tester, find.text('2 月').last);
    await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
    expect(attempts, 0);
    await _tap(tester, find.byKey(const ValueKey('android-annual-end-1')));
    await _tap(tester, find.text('12 月').last);
    await tester.enterText(
        find.byKey(const ValueKey('android-annual-progress')), '101');
    await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
    expect(attempts, 0);
    await tester.enterText(
        find.byKey(const ValueKey('android-annual-progress')), '7');
    await _tap(tester, find.byKey(const ValueKey('android-annual-color-gold')));
    await _tap(tester, find.byKey(const ValueKey('android-add-subtask')));
    await _tap(tester, find.byKey(const ValueKey('android-save-subtask')));
    expect(find.text('请输入子任务名称'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('android-subtask-title')), '单独子任务');
    await _tap(tester, find.byKey(const ValueKey('android-save-subtask')));
    await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
    expect(attempts, 1);
    expect(find.text('保存失败，草稿已保留，请重试。'), findsOneWidget);
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('android-annual-title')))
            .controller!
            .text,
        '保留草稿');
    await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
    expect(attempts, 2);
    expect(saved!.colorKey, 'gold');
    expect(saved!.startMonth, 2);
    expect(saved!.endMonth, 12);
    expect(saved!.progressPercent, 7);
    expect(saved!.subtasks.single.title, '单独子任务');
    expect(find.byKey(const ValueKey('android-save-annual')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed date loading does not open an empty replacement plan',
      (tester) async {
    await tester.pumpWidget(_host(failLoad: true));
    await _tap(tester, find.text('月计划'));
    await _tap(
        tester, find.byKey(const ValueKey('android-edit-selected-date')));
    expect(find.text('日期计划加载失败，请重试。'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('date editor does not show a saved state after a rejected write',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(_host(onSaveDate: (_) async {
      attempts++;
      return false;
    }));
    await _tap(tester, find.text('月计划'));
    await _tap(
        tester, find.byKey(const ValueKey('android-edit-selected-date')));
    await tester.enterText(find.byType(TextField).first, 'Changed plan');
    await _tap(tester, find.byKey(const ValueKey('today-plan-save')));
    expect(attempts, 1);
    expect(find.byKey(const ValueKey('today-plan-save')), findsOneWidget);
    expect(find.textContaining('已保存'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'both themes, languages, large text and keyboard retain reachable actions',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
      for (final language in AppLanguage.values) {
        await tester.pumpWidget(_host(
            theme: theme,
            language: language,
            scale: 1.5,
            keyboard: 280,
            initial: _segment()));
        final zh = language.isChinese;
        await _tap(tester, find.text(zh ? '月计划' : 'Month'));
        await _tap(
            tester, find.byKey(const ValueKey('android-calendar-2028-02-07')));
        final dateTarget = tester
            .getSize(find.byKey(const ValueKey('android-calendar-2028-02-07')));
        expect(dateTarget.width, greaterThanOrEqualTo(48));
        expect(dateTarget.height, greaterThanOrEqualTo(48));
        await _tap(
            tester, find.byKey(const ValueKey('android-create-archive')));
        expect(tester.takeException(), isNull);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await _tap(tester, find.text(zh ? '年度' : 'Year'));
        await _tap(tester, find.byKey(const ValueKey('android-create-annual')));
        final button =
            tester.getRect(find.byKey(const ValueKey('android-save-annual')));
        expect(button.bottom, lessThanOrEqualTo(440));
        expect(button.height, greaterThanOrEqualTo(48));
        await tester.enterText(
            find.byKey(const ValueKey('android-annual-title')), 'Layout check');
        await _tap(tester, find.byKey(const ValueKey('android-save-annual')));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });
}
