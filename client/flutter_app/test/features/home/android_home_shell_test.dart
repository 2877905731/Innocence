import 'package:innocence_flutter/features/plans/presentation/pages/android_plans_view.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/minimal_white_hero.dart';
import 'package:innocence_flutter/core/widgets/focus_timer_dial.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/domain/theme_daily_slogan.dart';
import 'package:innocence_flutter/features/home/presentation/pages/android_home_shell.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

Widget androidHomeFixture({
  bool offline = false,
  AppVisualTheme visualTheme = AppVisualTheme.minimalism,
  TodayPlan? todayPlan,
  FocusSession? focusSession,
  AppLanguage language = AppLanguage.simplifiedChinese,
  Future<void> Function(int, bool)? onToggleTodayPlanItem,
  Future<void> Function()? onStartFocus,
  Future<void> Function()? onToggleFocusPause,
  Future<void> Function()? onFinishFocus,
  bool isBusy = false,
  double textScale = 1,
  String? fontFamily,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppVisualTokens.of(visualTheme).toThemeData(visualTheme).copyWith(
        textTheme: AppVisualTokens.of(visualTheme)
            .toThemeData(visualTheme)
            .textTheme
            .apply(fontFamily: fontFamily)),
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!),
    home: AndroidHomeShell(
      language: language,
      profile: UserProfile.local(
        localProfileId: 'synthetic-profile',
        nickname: '测试用户',
        timezone: 'Asia/Shanghai',
      ),
      todayPlan: todayPlan ?? TodayPlan.empty(),
      monthPlanOverview: MonthPlanOverview.empty(),
      annualPlanOverview: AnnualPlanOverview.empty(),
      planArchives: const [],
      planActions: AndroidPlanActions(
        loadMonth: (_) async {},
        loadYear: (_) async {},
        loadDate: (date) async => TodayPlan.empty(date),
        saveDate: (_) async => true,
        saveArchive: (_, __) async => true,
        deleteArchive: (_) async {},
        applyArchive: (_, __, {required strategy}) async {},
        saveAnnual: (_) async => true,
        deleteAnnual: (_) async {},
      ),
      focusSession: focusSession ?? FocusSession.empty(),
      checkInStatus: CheckInStatus.empty(),
      teamOverview: TeamOverview.empty(),
      friendOverview: FriendOverview.fromJson(const {'friendCount': 9}),
      notificationOverview:
          NotificationOverview.fromJson(const {'unreadCount': 5}),
      isOfflineMode: offline,
      isBusy: isBusy,
      bannerMessage: null,
      onClearBanner: () {},
      onRefresh: () async {},
      onLogout: () async {},
      onOpenPlanEditor: () async {},
      onToggleTodayPlanItem: onToggleTodayPlanItem ?? (_, __) async {},
      onStartFocus: onStartFocus ?? () async {},
      onToggleFocusPause: onToggleFocusPause ?? () async {},
      onFinishFocus: onFinishFocus ?? () async {},
      onSubmitCheckIn: () async {},
      onOpenFriends: () async {},
      onOpenTeam: () async {},
      onOpenNotifications: () async {},
      onOpenMemos: () async {},
      onOpenStats: () async {},
      onOpenSettings: () async {},
    ),
  );
}

void main() {
  testWidgets('Android daily slogan follows theme and language during focus',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppVisualTheme.minimalism, AppVisualTheme.glass]) {
      for (final language in AppLanguage.values) {
        final slogan =
            ThemeDailySlogans.resolve(theme: theme, localDate: DateTime.now());
        await tester.pumpWidget(androidHomeFixture(
          visualTheme: theme,
          language: language,
          focusSession: FocusSession.fromJson(const {
            'active': true,
            'remainingSeconds': 1800,
            'taskName': 'Synthetic focus',
          }),
        ));
        await tester.pump(const Duration(milliseconds: 350));
        final card = find.byKey(const ValueKey('android-daily-slogan'));
        final scroll = find.byType(Scrollable).first;
        tester.state<ScrollableState>(scroll).position.jumpTo(0);
        await tester.pump();
        await tester.scrollUntilVisible(card, 180, scrollable: scroll);
        await tester.pump();
        expect(
            find.descendant(
                of: card,
                matching:
                    find.text(slogan.title(isChinese: language.isChinese))),
            findsOneWidget);
        expect(
            find.descendant(
                of: card,
                matching:
                    find.text(slogan.subtitle(isChinese: language.isChinese))),
            findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(find.text('每日标语'), findsNothing);
        expect(find.text('Daily inspiration'), findsNothing);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Android home renders both reference styles with live data',
      (tester) async {
    await tester.pumpWidget(androidHomeFixture());
    expect(find.byType(MinimalWhiteHero), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(FocusTimerDial), 180,
        scrollable: find.byType(Scrollable).first);
    expect(find.byType(FocusTimerDial), findsOneWidget);
    expect(find.text('已完成 0/0 项'), findsOneWidget);

    await tester
        .pumpWidget(androidHomeFixture(visualTheme: AppVisualTheme.glass));
    await tester.pump(const Duration(milliseconds: 350));
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pump();
    expect(
      Theme.of(tester.element(find.byType(AndroidHomeShell)))
          .extension<AppVisualThemeMarker>()
          ?.visualTheme,
      AppVisualTheme.glass,
    );
    expect(find.byType(GlassMotionBackdrop), findsOneWidget);
    expect(find.text('已完成 0/0 项'), findsOneWidget);
  });

  testWidgets('ellipsis button opens the drawer and switches destinations',
      (tester) async {
    await tester.pumpWidget(androidHomeFixture());

    expect(find.byType(NavigationBar), findsNothing);
    expect(
        find.byKey(const ValueKey('android-more-navigation')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('android-more-navigation')));
    await tester.pumpAndSettle();

    final drawer = find.byType(NavigationDrawer);
    expect(drawer, findsOneWidget);
    expect(
      tester
          .widget<Text>(find.descendant(of: drawer, matching: find.text('首页')))
          .style
          ?.color,
      Colors.white,
    );
    expect(
      tester
          .widget<Text>(find.descendant(of: drawer, matching: find.text('计划')))
          .style
          ?.color,
      const Color(0xFF1A1A1A).withValues(alpha: .72),
    );
    for (final label in ['计划', '专注', '陪伴', '收件箱']) {
      expect(find.descendant(of: drawer, matching: find.text(label)),
          findsOneWidget);
    }

    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
    expect(scaffold.isDrawerOpen, isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isFalse);
    await tester.tap(find.byKey(const ValueKey('android-more-navigation')));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: drawer, matching: find.text('计划')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('android-plans-content')), findsOneWidget);
    expect(find.text('还没有今日任务'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('android-home-content')), findsOneWidget);
  });

  testWidgets('offline drawer sections do not expose social summaries',
      (tester) async {
    await tester.pumpWidget(androidHomeFixture(offline: true));
    await tester.tap(find.byKey(const ValueKey('android-more-navigation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('陪伴'));
    await tester.pumpAndSettle();

    expect(find.text('需要登录'), findsOneWidget);
    expect(find.text('当前 9 位好友'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('android-more-navigation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('收件箱'));
    await tester.pumpAndSettle();

    expect(find.text('需要登录'), findsOneWidget);
    expect(find.text('未读 5 条'), findsNothing);
  });

  testWidgets('plan task action keeps the existing model callback',
      (tester) async {
    final toggles = <String>[];
    final plan = TodayPlan.fromJson(const {
      'planDate': '2026-09-27',
      'items': [
        {
          'id': 1,
          'title': 'Synthetic study task',
          'completed': false,
          'startSlot': 12,
          'endSlot': 14,
        },
      ],
    });
    await tester.pumpWidget(androidHomeFixture(
      todayPlan: plan,
      onToggleTodayPlanItem: (index, completed) async {
        toggles.add('$index:$completed');
      },
    ));

    await tester.tap(find.byKey(const ValueKey('android-more-navigation')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('计划'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Synthetic study task'));
    await tester.pump();

    expect(toggles, ['0:true']);
  });
}
