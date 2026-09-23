import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/presentation/pages/adaptive_desktop_home.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

void main() {
  testWidgets('today completion and monthly annual task controls stay in sync',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 980);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final today = TodayPlan.empty('2026-09-23').copyWith(items: const [
      TodayPlanItem(
        id: 1,
        title: 'First',
        completed: true,
        plannedMinutes: 30,
        actualMinutes: 0,
        startSlot: null,
        endSlot: null,
        sortOrder: 0,
      ),
      TodayPlanItem(
        id: 2,
        title: 'Second',
        completed: true,
        plannedMinutes: 30,
        actualMinutes: 0,
        startSlot: null,
        endSlot: null,
        sortOrder: 1,
      ),
    ]);
    var segment = AnnualPlanSegment(
      id: 'annual-1',
      clientEntityId: 'annual-1',
      year: now.year,
      title: 'Build the year',
      startMonth: now.month,
      endMonth: now.month,
      colorKey: 'accent',
      sortOrder: 0,
      note: '',
      progressPercent: 0,
      revision: 1,
      updateTime: '',
      subtasks: const [],
    );
    final reference = segment.copyWith(
      id: 'annual-reference',
      clientEntityId: 'annual-reference',
      title: 'Long color span',
      startMonth: 4,
      endMonth: 11,
      colorKey: 'warm',
      progressPercent: 25,
    );
    final filler = List.generate(
      7,
      (index) => segment.copyWith(
        id: 'annual-extra-$index',
        clientEntityId: 'annual-extra-$index',
        title: 'Extra annual task $index',
        startMonth: 1,
        endMonth: 12,
        sortOrder: index + 2,
      ),
    );
    AnnualPlanOverview overview() => AnnualPlanOverview(
          year: now.year,
          months:
              List.generate(12, (index) => AnnualMonthSummary.empty(index + 1)),
          segments: [reference, segment, ...filler],
        );
    AnnualPlanSegment? lastSaved;

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('zh', 'CN'),
      home: StatefulBuilder(
        builder: (context, rebuild) => AdaptiveDesktopHome(
          appLanguage: AppLanguage.simplifiedChinese,
          visualTheme: AppVisualTheme.glass,
          profile: UserProfile.local(
            localProfileId: 'test',
            nickname: 'Tester',
            timezone: 'Asia/Shanghai',
          ),
          focusSession: FocusSession.empty(),
          checkInStatus: CheckInStatus.empty(),
          statsOverview: StatsOverview.empty(),
          teamOverview: TeamOverview.empty(),
          teamChatOverview: TeamChatOverview.empty(),
          friendOverview: FriendOverview.empty(),
          memoOverview: MemoOverview.empty(),
          notificationOverview: NotificationOverview.empty(),
          todayPlan: today,
          monthPlanOverview: MonthPlanOverview.empty(),
          annualPlanOverview: overview(),
          weeklyTemplates: const [],
          isOfflineMode: true,
          isBusy: false,
          onClearBanner: () {},
          onRefresh: () async {},
          onOpenStats: () async {},
          onOpenNotifications: () async {},
          onOpenFriends: () async {},
          onOpenMemos: () async {},
          onOpenSettings: () async {},
          onOpenTeamWorkspace: () async {},
          onStartFocus: () async {},
          onFinishFocus: () async {},
          onToggleFocus: () async {},
          onSubmitCheckIn: () async {},
          onEditTodayPlan: () async {},
          onToggleTodayPlanItem: (index, completed) async {},
          onOpenPlanDate: (date) async {},
          onLoadMonthOverview: (month) async {},
          onPreviousMonth: () async {},
          onCurrentMonth: () async {},
          onNextMonth: () async {},
          onLoadAnnualOverview: (year) async {},
          onPreviousYear: () async {},
          onCurrentYear: () async {},
          onNextYear: () async {},
          onApplyDayTemplateToDate: (
            templateId,
            date, {
            required strategy,
          }) async {},
          onApplyDayTemplateToDates: (
            templateId,
            dates, {
            required strategy,
          }) async {},
          onSavePlanAsDayTemplate: (name, plan) async => true,
          onDeleteDayTemplate: (id) async {},
          onSaveAnnualSegment: (updated) async {
            lastSaved = updated;
            rebuild(() => segment = updated);
          },
          onDeleteAnnualSegment: (deleted) async {},
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('今日计划完成率'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    final homeTab = find.byKey(const ValueKey('home-plan-tab-annual-month'));
    await tester.ensureVisible(homeTab);
    await tester.tap(homeTab);
    await tester.pump();
    expect(find.text('Build the year'), findsOneWidget);
    final homeCharge = find.byKey(
      const ValueKey('annual-charge-annual-1-annual-1'),
    );
    expect(homeCharge, findsOneWidget);
    expect(
        tester
            .getRect(find.descendant(
              of: homeCharge,
              matching: find.byKey(ValueKey(
                  'annual-month-charge-fill-${now.month}-${now.month}')),
            ))
            .width,
        0);

    await tester.tap(find.text('打开面板'));
    await tester.pump();
    expect(find.byKey(const ValueKey('day-plan-tab-annual-month')),
        findsOneWidget);
    final annualCard = find.byKey(
      const ValueKey('annual-task-annual-1-annual-1'),
    );
    Finder inAnnualCard(String key) => find.descendant(
          of: annualCard,
          matching: find.byKey(ValueKey(key)),
        );
    final chargeFrame = inAnnualCard(
      'annual-month-active-${now.month}-${now.month}',
    );
    final chargeFill = inAnnualCard(
      'annual-month-charge-fill-${now.month}-${now.month}',
    );
    expect(
        find.descendant(
          of: annualCard,
          matching: find.byType(LinearProgressIndicator),
        ),
        findsNothing);
    final plusTen =
        find.byKey(const ValueKey('annual-progress-plus10-annual-1'));
    await tester.ensureVisible(plusTen);
    expect(tester.getRect(chargeFill).width, 0);
    final minusTen =
        find.byKey(const ValueKey('annual-progress-minus10-annual-1'));
    final minusFive =
        find.byKey(const ValueKey('annual-progress-minus5-annual-1'));
    final minusOne =
        find.byKey(const ValueKey('annual-progress-minus1-annual-1'));
    expect(tester.widget<OutlinedButton>(minusTen).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(minusFive).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(minusOne).onPressed, isNull);
    await tester.tap(plusTen);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getRect(chargeFill).width, greaterThan(0));
    expect(tester.getRect(chargeFill).width,
        lessThan(tester.getRect(chargeFrame).width * 0.1));
    await tester.pump(const Duration(milliseconds: 550));
    expect(lastSaved?.progressPercent, 10);
    expect(tester.getRect(chargeFill).width,
        closeTo(tester.getRect(chargeFrame).width * 0.1, 0.1));

    Future<void> tapAndFinish(Finder button) async {
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    for (final step in [5, 1]) {
      final button = find.byKey(ValueKey('annual-progress-plus$step-annual-1'));
      await tapAndFinish(button);
    }
    expect(lastSaved?.progressPercent, 16);
    for (final step in [1, 5, 10]) {
      final button =
          find.byKey(ValueKey('annual-progress-minus$step-annual-1'));
      await tapAndFinish(button);
    }
    expect(lastSaved?.progressPercent, 0);
    expect(tester.getRect(chargeFill).width, 0);
    expect(tester.widget<OutlinedButton>(minusTen).onPressed, isNull);

    final complete =
        find.byKey(const ValueKey('annual-task-complete-annual-1'));
    await tapAndFinish(complete);
    expect(lastSaved?.progressPercent, 100);
    expect(find.text('已完成'), findsWidgets);
    expect(tester.getRect(chargeFill).width,
        closeTo(tester.getRect(chargeFrame).width, 0.1));
    expect(tester.widget<OutlinedButton>(plusTen).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(minusTen).onPressed, isNotNull);
    await tapAndFinish(minusTen);
    expect(lastSaved?.progressPercent, 90);
    expect(tester.getRect(chargeFill).width,
        closeTo(tester.getRect(chargeFrame).width * 0.9, 0.1));

    final fullYear = find.text('查看全年');
    await tester.ensureVisible(fullYear);
    await tester.tap(fullYear);
    await tester.pump();
    final firstMonth =
        tester.getRect(find.byKey(const ValueKey('annual-month-1')));
    final lastMonth =
        tester.getRect(find.byKey(const ValueKey('annual-month-12')));
    final span = tester.getRect(find.byKey(
      ValueKey('annual-month-span-${now.month}-${now.month}'),
    ));
    expect((firstMonth.left - span.left).abs(), lessThan(1));
    expect((lastMonth.right - span.right).abs(), lessThan(1));

    final fourthMonth =
        tester.getRect(find.byKey(const ValueKey('annual-month-4')));
    final eleventhMonth =
        tester.getRect(find.byKey(const ValueKey('annual-month-11')));
    final referenceCard = find.byKey(
      const ValueKey('annual-task-annual-reference-annual-reference'),
    );
    final active = tester.getRect(
      find.descendant(
        of: referenceCard,
        matching: find.byKey(const ValueKey('annual-month-active-4-11')),
      ),
    );
    final fourthTrack = tester.getRect(
      find.descendant(
        of: referenceCard,
        matching: find.byKey(const ValueKey('annual-month-track-4')),
      ),
    );
    final eleventhTrack = tester.getRect(
      find.descendant(
        of: referenceCard,
        matching: find.byKey(const ValueKey('annual-month-track-11')),
      ),
    );
    expect((fourthMonth.left - active.left).abs(), lessThan(0.01));
    expect((eleventhMonth.right - active.right).abs(), lessThan(0.01));
    expect((fourthTrack.left - active.left).abs(), lessThan(0.01));
    expect((eleventhTrack.right - active.right).abs(), lessThan(0.01));
    expect(active.height, fourthTrack.height);

    final annualScroll = find.byKey(
      const PageStorageKey<String>('desktop.plans.annual'),
    );
    final scrollable = find.descendant(
      of: annualScroll,
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.maxScrollExtent, greaterThan(1000));
    position.jumpTo(position.maxScrollExtent * 0.6);
    await tester.pump();
    final pinnedTop =
        tester.getRect(find.byKey(const ValueKey('annual-month-1'))).top;
    position.jumpTo(position.maxScrollExtent * 0.9);
    await tester.pump();
    final stillPinnedTop =
        tester.getRect(find.byKey(const ValueKey('annual-month-1'))).top;
    expect((pinnedTop - stillPinnedTop).abs(), lessThan(0.1));
  });
}
