import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';
import 'package:innocence_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:innocence_flutter/core/widgets/soft_spectrum_backdrop.dart';

void main() {
  testWidgets('offline mode exposes only device-safe settings', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var savedWidgetSetting = WidgetSetting.empty();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        theme: AppVisualTokens.of(AppVisualTheme.minimalism)
            .toThemeData(AppVisualTheme.minimalism),
        home: SettingsPage(
          isOfflineMode: true,
          onChangeLanguage: (language, {confirmStartup = true}) async {},
          visualTheme: AppVisualTheme.minimalism,
          onChangeVisualTheme: (_) {},
          initialOverview: SettingOverview.empty(
            accountSetting: UserProfile.local(
              localProfileId: 'local-profile-test',
              nickname: 'Local user',
              timezone: 'Asia/Shanghai',
            ),
          ),
          onRefresh: () async => null,
          onLoadBlacklist: () async => const [],
          onAddBlacklist: (_) async => false,
          onRemoveBlacklist: (_) async => false,
          onLoadCurrentDeviceSession: () async => null,
          onUpdateProfile: ({
            required nickname,
            required avatarUrl,
            required bio,
          }) async =>
              null,
          onUploadAvatar: ({required bytes, required filename}) async => null,
          onUpdatePrivacy: ({
            required allowFriendViewProfile,
            required allowTeammateViewStudy,
          }) async =>
              null,
          onUpdateNotifications: ({
            required mobilePushEnabled,
            required desktopNoticeEnabled,
            required teamRemindEnabled,
            required systemAnnouncementEnabled,
          }) async =>
              null,
          onUpdateWidget: ({
            required autoStart,
            required alwaysOnTop,
            required showPlan,
            required showTimer,
            required showMemo,
          }) async {
            savedWidgetSetting = WidgetSetting(
              autoStart: autoStart,
              alwaysOnTop: alwaysOnTop,
              showPlan: showPlan,
              showTimer: showTimer,
              showMemo: showMemo,
            );
            return savedWidgetSetting;
          },
          onUpdateAppearance: ({required themeMode}) async => null,
          onClearCache: () async => false,
          onSendCancelCode: (_) async {},
          onCancelAccount: ({password = '', emailCode = ''}) async => false,
          onLogout: () async {},
          onLoadAdminReports: ({
            status = '',
            reportType = '',
            limit = 50,
          }) async =>
              const [],
          onLoadAdminReportDetail: (_) async => null,
          onReviewAdminReport: (
            _, {
            required decision,
            required deleteContent,
            required punishmentType,
            required durationDays,
            required reason,
          }) async =>
              null,
          onSearchAdminUsers: ({keyword = '', limit = 50}) async => const [],
          onLoadAdminUserDetail: (_) async => null,
          onLoadAdminUserReports: (_, {limit = 50}) async => const [],
          onLoadAdminUserPunishments: (
            _, {
            status = 'active',
            limit = 50,
          }) async =>
              const [],
          onLiftAdminUserPunishment: (
            _, {
            required punishmentId,
          }) async =>
              null,
          onLoadAdminTeams: ({keyword = '', status, limit = 50}) async =>
              const [],
          onLoadAdminTeamDetail: (_) async => null,
          onRemoveAdminTeamMember: (
            _, {
            required memberUserId,
          }) async =>
              null,
          onDissolveAdminTeam: (_) async => null,
          onLoadAdminAnnouncements: ({limit = 50}) async => const [],
          onCreateAdminAnnouncement: ({
            required title,
            required content,
          }) async =>
              null,
          onDeleteAdminAnnouncement: (_) async => null,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('System settings'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('offline-settings-notice')),
      findsOneWidget,
    );
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Account profile'), findsOneWidget);
    expect(find.text('Desktop experience'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('About & maintenance'), findsOneWidget);
    expect(find.text('Privacy & blacklist'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Device session'), findsNothing);
    expect(find.text('Admin tools'), findsNothing);
    expect(find.text('Cancel account'), findsNothing);
    expect(find.text('Refresh'), findsNothing);
    expect(find.byType(SoftSpectrumBackdrop), findsOneWidget);

    await tester.tap(find.text('Appearance'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('settings-visual-theme-minimalism')),
      findsOneWidget,
    );
    expect(find.text('Soft spectrum'), findsNWidgets(2));

    await tester.tap(find.text('Desktop experience'));
    await tester.pump();
    final memoSwitch = find.widgetWithText(
      SwitchListTile,
      'Show memo in Orb',
    );
    expect(memoSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(memoSwitch).onChanged, isNotNull);
    await tester.tap(memoSwitch);
    await tester.pump();

    expect(savedWidgetSetting.showMemo, isFalse);
  });
}
