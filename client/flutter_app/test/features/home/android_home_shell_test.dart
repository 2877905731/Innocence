import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/citrus_focus_disc.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/presentation/pages/android_home_shell.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

Widget _app({
  bool offline = false,
  AppVisualTheme visualTheme = AppVisualTheme.minimalism,
  TodayPlan? todayPlan,
  Future<void> Function(int, bool)? onToggleTodayPlanItem,
}) {
  return MaterialApp(
    theme: AppVisualTokens.of(visualTheme).toThemeData(visualTheme),
    home: AndroidHomeShell(
      language: AppLanguage.simplifiedChinese,
      profile: UserProfile.local(
        localProfileId: 'synthetic-profile',
        nickname: '测试用户',
        timezone: 'Asia/Shanghai',
      ),
      todayPlan: todayPlan ?? TodayPlan.empty(),
      focusSession: FocusSession.empty(),
      checkInStatus: CheckInStatus.empty(),
      teamOverview: TeamOverview.empty(),
      friendOverview: FriendOverview.fromJson(const {'friendCount': 9}),
      notificationOverview:
          NotificationOverview.fromJson(const {'unreadCount': 5}),
      isOfflineMode: offline,
      isBusy: false,
      bannerMessage: null,
      onClearBanner: () {},
      onRefresh: () async {},
      onLogout: () async {},
      onOpenPlanEditor: () async {},
      onToggleTodayPlanItem: onToggleTodayPlanItem ?? (_, __) async {},
      onStartFocus: () async {},
      onToggleFocusPause: () async {},
      onFinishFocus: () async {},
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
  testWidgets('Android home renders both reference styles with live data',
      (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(CitrusFocusDisc), findsOneWidget);
    expect(find.text('已完成 0/0 项'), findsOneWidget);

    await tester.pumpWidget(_app(visualTheme: AppVisualTheme.glass));
    await tester.pump(const Duration(milliseconds: 350));
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
    await tester.pumpWidget(_app());

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
      const Color(0xFF242522).withValues(alpha: .72),
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
    await tester.pumpWidget(_app(offline: true));
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
    await tester.pumpWidget(_app(
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
