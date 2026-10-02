import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/domain/theme_daily_slogan.dart';
import 'package:innocence_flutter/features/home/presentation/pages/adaptive_desktop_home.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

Widget _app(AppVisualTheme theme, AppLanguage language) => MaterialApp(
      theme: AppVisualTokens.of(theme).toThemeData(theme),
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: AdaptiveDesktopHome(
          appLanguage: language,
          visualTheme: theme,
          profile: UserProfile.local(
              localProfileId: 'synthetic',
              nickname: 'Tester',
              timezone: 'Asia/Shanghai'),
          focusSession: FocusSession.fromJson(const {
            'active': true,
            'remainingSeconds': 1800,
            'taskName': 'Synthetic focus'
          }),
          checkInStatus: CheckInStatus.empty(),
          statsOverview: StatsOverview.empty(),
          teamOverview: TeamOverview.empty(),
          teamChatOverview: TeamChatOverview.empty(),
          friendOverview: FriendOverview.empty(),
          memoOverview: MemoOverview.empty(),
          notificationOverview: NotificationOverview.empty(),
          todayPlan: TodayPlan.empty(),
          monthPlanOverview: MonthPlanOverview.empty(),
          annualPlanOverview: AnnualPlanOverview.empty(),
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
          onToggleTodayPlanItem: (_, __) async {},
          onOpenPlanDate: (_) async {},
          onLoadMonthOverview: (_) async {},
          onPreviousMonth: () async {},
          onCurrentMonth: () async {},
          onNextMonth: () async {},
          onLoadAnnualOverview: (_) async {},
          onPreviousYear: () async {},
          onCurrentYear: () async {},
          onNextYear: () async {},
          onApplyDayTemplateToDate: (_, __, {required strategy}) async {},
          onApplyDayTemplateToDates: (_, __, {required strategy}) async {},
          onSavePlanAsDayTemplate: (_, __) async => true,
          onDeleteDayTemplate: (_) async {},
          onSaveAnnualSegment: (_) async {},
          onDeleteAnnualSegment: (_) async {},
        ),
      ),
    );

void main() {
  for (final size in [const Size(460, 700), const Size(1360, 900)]) {
    testWidgets('desktop daily slogan stays visible during focus at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final theme in AppVisualTheme.values) {
        for (final language in AppLanguage.values) {
          await tester.pumpWidget(_app(theme, language));
          await tester.pump(const Duration(milliseconds: 350));
          final slogan = ThemeDailySlogans.resolve(
              theme: theme, localDate: DateTime.now());
          expect(find.text(slogan.title(isChinese: language.isChinese)),
              findsOneWidget);
          expect(find.text(slogan.subtitle(isChinese: language.isChinese)),
              findsOneWidget);
          expect(
              find.text(language.isChinese
                  ? 'INNOCENCE · 每日标语'
                  : 'INNOCENCE · DAILY INSPIRATION'),
              findsOneWidget);
          expect(find.text('Synthetic focus'), findsWidgets);
          expect(tester.takeException(), isNull);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
