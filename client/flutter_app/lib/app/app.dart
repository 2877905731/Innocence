import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/app_theme.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:innocence_flutter/features/home/presentation/pages/home_page.dart';

import 'app_language.dart';
import 'session_controller.dart';
import 'team_workspace_snapshot.dart';

class InnocenceApp extends StatefulWidget {
  const InnocenceApp({
    super.key,
    required this.sessionController,
    required this.languageController,
  });

  final SessionController sessionController;
  final AppLanguageController languageController;

  @override
  State<InnocenceApp> createState() => _InnocenceAppState();
}

class _InnocenceAppState extends State<InnocenceApp> {
  @override
  void initState() {
    super.initState();
    widget.languageController.initialize();
    widget.sessionController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.sessionController,
        widget.languageController,
      ]),
      builder: (context, _) {
        final language = widget.languageController.currentLanguage;
        return MaterialApp(
          title: 'Innocence',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: widget.sessionController.status == SessionStatus.authenticated
              ? widget.sessionController.themeMode
              : ThemeMode.light,
          locale: language.locale,
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _buildHome(language),
        );
      },
    );
  }

  Widget _buildHome(AppLanguage language) {
    if (!widget.languageController.initialized) {
      return const _BootSplash();
    }

    if (!widget.languageController.startupConfirmed) {
      return _LanguageSelectionPage(
        controller: widget.languageController,
      );
    }

    switch (widget.sessionController.status) {
      case SessionStatus.initializing:
        return _LaunchScreen(language: language);
      case SessionStatus.unauthenticated:
        return AuthPage(
          sessionController: widget.sessionController,
          appLanguage: language,
        );
      case SessionStatus.authenticated:
        return HomePage(
          appLanguage: language,
          onChangeLanguage: widget.languageController.updateLanguage,
          profile: widget.sessionController.profile!,
          focusSession: widget.sessionController.focusSession,
          checkInStatus: widget.sessionController.checkInStatus,
          statsOverview: widget.sessionController.statsOverview,
          teamOverview: widget.sessionController.teamOverview,
          teamChatOverview: widget.sessionController.teamChatOverview,
          friendOverview: widget.sessionController.friendOverview,
          memoOverview: widget.sessionController.memoOverview,
          notificationOverview: widget.sessionController.notificationOverview,
          settingOverview: widget.sessionController.settingOverview,
          todayPlan: widget.sessionController.todayPlan,
          isBusy: widget.sessionController.isBusy,
          bannerMessage: widget.sessionController.bannerMessage,
          onClearBanner: widget.sessionController.clearBanner,
          onRefresh: widget.sessionController.refreshProfile,
          onLogout: widget.sessionController.logout,
          onStartFocusSession: widget.sessionController.startFocusSession,
          onFinishFocusSession: widget.sessionController.finishFocusSession,
          onSubmitCheckIn: widget.sessionController.submitTodayCheckIn,
          onLoadStatsOverview: widget.sessionController.loadStatsOverview,
          onDeleteCheckInFailureRecord:
              widget.sessionController.deleteCheckInFailureRecord,
          onLoadNotifications: widget.sessionController.loadNotifications,
          onMarkNotificationRead:
              widget.sessionController.markNotificationRead,
          onMarkAllNotificationsRead:
              widget.sessionController.markAllNotificationsRead,
          onRespondNotificationFriendRequest:
              widget.sessionController.respondNotificationFriendRequest,
          onRespondNotificationTeamInvitation:
              widget.sessionController.respondNotificationTeamInvitation,
          onRemindTeammate: widget.sessionController.remindTeammate,
          onLoadFriendOverview: widget.sessionController.loadFriendOverview,
          onSearchFriends: widget.sessionController.searchFriends,
          onSendFriendRequest: widget.sessionController.sendFriendRequest,
          onRespondFriendRequest:
              widget.sessionController.respondToFriendRequest,
          onCreateFriendGroup: widget.sessionController.createFriendGroup,
          onMoveFriendToGroup: widget.sessionController.moveFriendToGroup,
          onDeleteFriend: widget.sessionController.deleteFriend,
          onLoadMemoOverview: widget.sessionController.loadMemoOverview,
          onLoadMemoDetail: widget.sessionController.loadMemoDetail,
          onCreateMemo: widget.sessionController.createMemo,
          onUpdateMemo: widget.sessionController.updateMemo,
          onDeleteMemo: widget.sessionController.deleteMemo,
          onLoadSettingsOverview:
              widget.sessionController.loadSettingsOverview,
          onUpdateMySettingProfile:
              widget.sessionController.updateMySettingProfile,
          onUpdateMyPrivacySetting:
              widget.sessionController.updateMyPrivacySetting,
          onUpdateNotificationSetting:
              widget.sessionController.updateNotificationSetting,
          onUpdateWidgetSetting:
              widget.sessionController.updateWidgetSetting,
          onUpdateAppearanceSetting:
              widget.sessionController.updateAppearanceSetting,
          onClearSettingsCache: widget.sessionController.clearSettingsCache,
          onSendCancelAccountCode:
              widget.sessionController.sendCancelAccountCode,
          onCancelAccount: widget.sessionController.cancelAccount,
          onLoadAdminReports: widget.sessionController.loadAdminReports,
          onLoadAdminReportDetail:
              widget.sessionController.loadAdminReportDetail,
          onReviewAdminReport:
              widget.sessionController.reviewAdminReport,
          onSearchAdminUsers: widget.sessionController.searchAdminUsers,
          onLoadAdminUserDetail:
              widget.sessionController.loadAdminUserDetail,
          onLoadAdminUserReports:
              widget.sessionController.loadAdminUserReports,
          onLoadAdminUserPunishments:
              widget.sessionController.loadAdminUserPunishments,
          onLiftAdminUserPunishment:
              widget.sessionController.liftAdminUserPunishment,
          onLoadAdminTeams: widget.sessionController.loadAdminTeams,
          onLoadAdminTeamDetail:
              widget.sessionController.loadAdminTeamDetail,
          onRemoveAdminTeamMember:
              widget.sessionController.removeAdminTeamMember,
          onDissolveAdminTeam:
              widget.sessionController.dissolveAdminTeam,
          onLoadAdminAnnouncements:
              widget.sessionController.loadAdminAnnouncements,
          onCreateAdminAnnouncement:
              widget.sessionController.createAdminAnnouncement,
          onDeleteAdminAnnouncement:
              widget.sessionController.deleteAdminAnnouncement,
          onCreateTeam: widget.sessionController.createTeam,
          onJoinTeam: widget.sessionController.joinTeam,
          onInviteTeamMember: widget.sessionController.inviteTeamMember,
          onRemoveTeamMember: widget.sessionController.removeTeamMember,
          onDissolveTeam: widget.sessionController.dissolveTeam,
          onLoadTeamChatMessages:
              widget.sessionController.loadTeamChatMessages,
          onSendTeamChatMessage:
              widget.sessionController.sendTeamChatMessage,
          onMarkTeamChatRead: widget.sessionController.markTeamChatRead,
          onReportTeamChatMessage:
              widget.sessionController.reportTeamChatMessage,
          onLoadTeamWorkspaceSnapshot:
              widget.sessionController.loadTeamWorkspaceSnapshot,
          onSaveTodayPlan: widget.sessionController.saveTodayPlan,
          onLoadPlanByDate: widget.sessionController.loadPlanByDate,
          weekPlanOverview: widget.sessionController.weekPlanOverview,
          weeklyTemplates: widget.sessionController.weeklyTemplates,
          onPreviousWeek: widget.sessionController.loadPreviousWeek,
          onCurrentWeek: widget.sessionController.loadCurrentWeek,
          onNextWeek: widget.sessionController.loadNextWeek,
          onSavePlanAsWeeklyTemplate:
              widget.sessionController.savePlanAsWeeklyTemplate,
          onApplyWeeklyTemplate:
              widget.sessionController.applyWeeklyTemplate,
          onApplyWeeklyTemplateToDate:
              widget.sessionController.applyWeeklyTemplateToDate,
          onDeleteWeeklyTemplate:
              widget.sessionController.deleteWeeklyTemplate,
          onCopyPlanToDate: widget.sessionController.copyPlanToDate,
          onCopyPlanToDates: widget.sessionController.copyPlanToDates,
          onClearPlanDate: widget.sessionController.clearPlanDate,
          onApplyWeeklyTemplateToDates:
              widget.sessionController.applyWeeklyTemplateToDates,
          onQuickArrangeWeek: widget.sessionController.quickArrangeWeek,
          onToggleTodayPlanItem:
              widget.sessionController.toggleTodayPlanItem,
        );
    }
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return _DesktopWindowModeScope(
      mode: 'auth',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuroraBackground(
          transparentOnWindows: true,
          child: Stack(
            children: [
              const Center(
                child: CircularProgressIndicator(),
              ),
              if (AppConfig.deviceType == 'windows')
                const Positioned(
                  top: 28,
                  right: 28,
                  child: DesktopCloseButton(compact: true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return _DesktopWindowModeScope(
      mode: 'auth',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuroraBackground(
          transparentOnWindows: true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Stack(
                  children: [
                    GlassPanel(
                      desktopTransparent: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Innocence',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  language.launchMessage,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (AppConfig.deviceType == 'windows')
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: DesktopCloseButton(compact: true),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageSelectionPage extends StatelessWidget {
  const _LanguageSelectionPage({
    required this.controller,
  });

  final AppLanguageController controller;

  @override
  Widget build(BuildContext context) {
    final language = controller.currentLanguage;
    final isDesktop = AppConfig.deviceType == 'windows';
    return _DesktopWindowModeScope(
      mode: 'auth',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuroraBackground(
          transparentOnWindows: true,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 680 : 520),
                  child: Stack(
                    children: [
                      GlassPanel(
                        desktopTransparent: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 30,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Innocence',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              language.startupTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(language.startupDescription),
                            const SizedBox(height: 24),
                            Row(
                              children: AppLanguage.values.map((item) {
                                final selected = item == language;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: item == AppLanguage.values.last ? 0 : 12,
                                    ),
                                    child: _LanguageOptionCard(
                                      label: item.label,
                                      selected: selected,
                                      onTap: () => controller.previewLanguage(item),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.confirmStartupLanguage,
                                child: Text(language.continueLabel),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (AppConfig.deviceType == 'windows')
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: DesktopCloseButton(compact: true),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: selected
                ? Colors.white.withValues(alpha: 0.11)
                : Colors.white.withValues(alpha: 0.045),
            border: Border.all(
              color: selected
                  ? AppColors.glow.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.14),
              width: selected ? 1.35 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.glow.withValues(alpha: 0.24),
                      blurRadius: 18,
                      spreadRadius: -8,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopWindowModeScope extends StatefulWidget {
  const _DesktopWindowModeScope({
    required this.mode,
    required this.child,
  });

  final String mode;
  final Widget child;

  @override
  State<_DesktopWindowModeScope> createState() => _DesktopWindowModeScopeState();
}

class _DesktopWindowModeScopeState extends State<_DesktopWindowModeScope> {
  @override
  void initState() {
    super.initState();
    _applyMode();
  }

  @override
  void didUpdateWidget(covariant _DesktopWindowModeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _applyMode();
    }
  }

  void _applyMode() {
    unawaited(DesktopWidgetBridge.setWindowMode(widget.mode));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
