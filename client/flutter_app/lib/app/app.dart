import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/local/offline_sync_models.dart';
import 'package:innocence_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:innocence_flutter/features/auth/presentation/widgets/auth_experience.dart';
import 'package:innocence_flutter/features/home/presentation/pages/home_page.dart';

import 'app_language.dart';
import 'app_visual_theme.dart';
import 'session_controller.dart';

class InnocenceApp extends StatefulWidget {
  const InnocenceApp({
    super.key,
    required this.sessionController,
    required this.languageController,
    required this.visualThemeController,
  });

  final SessionController sessionController;
  final AppLanguageController languageController;
  final AppVisualThemeController visualThemeController;

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
        widget.visualThemeController,
      ]),
      builder: (context, _) {
        final language = widget.languageController.currentLanguage;
        final visualTheme = widget.visualThemeController.currentTheme;
        final visualTokens = AppVisualTokens.of(visualTheme);
        return MaterialApp(
          title: 'Innocence',
          debugShowCheckedModeBanner: false,
          theme: visualTokens.toThemeData(visualTheme),
          themeMode: visualTokens.isDark ? ThemeMode.dark : ThemeMode.light,
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
          home: _buildHome(language, visualTheme),
        );
      },
    );
  }

  Widget _buildHome(AppLanguage language, AppVisualTheme visualTheme) {
    if (!widget.languageController.initialized) {
      return const _BootSplash();
    }

    if (!widget.languageController.startupConfirmed) {
      return _LanguageSelectionPage(
        controller: widget.languageController,
        visualTheme: visualTheme,
        onThemeChanged: widget.visualThemeController.updateTheme,
      );
    }

    switch (widget.sessionController.status) {
      case SessionStatus.initializing:
        return _LaunchScreen(
          language: language,
          visualTheme: visualTheme,
          onThemeChanged: widget.visualThemeController.updateTheme,
        );
      case SessionStatus.unauthenticated:
        return AuthPage(
          sessionController: widget.sessionController,
          appLanguage: language,
          visualTheme: visualTheme,
          onThemeChanged: widget.visualThemeController.updateTheme,
        );
      case SessionStatus.authenticated:
      case SessionStatus.offline:
        return _DesktopWindowModeScope(
          mode: 'canvas',
          child: Stack(
            children: [
              HomePage(
                appLanguage: language,
                onChangeLanguage: widget.languageController.updateLanguage,
                visualTheme: visualTheme,
                onChangeVisualTheme: widget.visualThemeController.updateTheme,
                profile: widget.sessionController.profile!,
                focusSession: widget.sessionController.focusSession,
                checkInStatus: widget.sessionController.checkInStatus,
                statsOverview: widget.sessionController.statsOverview,
                teamOverview: widget.sessionController.teamOverview,
                teamChatOverview: widget.sessionController.teamChatOverview,
                friendOverview: widget.sessionController.friendOverview,
                memoOverview: widget.sessionController.memoOverview,
                notificationOverview:
                    widget.sessionController.notificationOverview,
                settingOverview: widget.sessionController.settingOverview,
                todayPlan: widget.sessionController.todayPlan,
                isOfflineMode: widget.sessionController.isOffline,
                isBusy: widget.sessionController.isBusy,
                bannerMessage: widget.sessionController.bannerMessage,
                onClearBanner: widget.sessionController.clearBanner,
                onRequireOnline: widget.sessionController.requireOnlineFeature,
                onRefresh: widget.sessionController.refreshProfile,
                onLogout: widget.sessionController.logout,
                onStartFocusSession: widget.sessionController.startFocusSession,
                onFinishFocusSession:
                    widget.sessionController.finishFocusSession,
                onToggleFocusPause: widget.sessionController.toggleFocusPause,
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
                onLoadFriendOverview:
                    widget.sessionController.loadFriendOverview,
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
                onLoadBlacklist: widget.sessionController.loadBlacklist,
                onAddBlacklist: widget.sessionController.addBlacklist,
                onRemoveBlacklist: widget.sessionController.removeBlacklist,
                onLoadCurrentDeviceSession:
                    widget.sessionController.loadCurrentDeviceSession,
                onUpdateMySettingProfile:
                    widget.sessionController.updateMySettingProfile,
                onUploadMyAvatar: widget.sessionController.uploadMyAvatar,
                onUpdateMyPrivacySetting:
                    widget.sessionController.updateMyPrivacySetting,
                onUpdateNotificationSetting:
                    widget.sessionController.updateNotificationSetting,
                onUpdateWidgetSetting:
                    widget.sessionController.updateWidgetSetting,
                onUpdateAppearanceSetting:
                    widget.sessionController.updateAppearanceSetting,
                onClearSettingsCache:
                    widget.sessionController.clearSettingsCache,
                onSendCancelAccountCode:
                    widget.sessionController.sendCancelAccountCode,
                onCancelAccount: widget.sessionController.cancelAccount,
                onLoadAdminReports: widget.sessionController.loadAdminReports,
                onLoadAdminReportDetail:
                    widget.sessionController.loadAdminReportDetail,
                onReviewAdminReport: widget.sessionController.reviewAdminReport,
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
                onDissolveAdminTeam: widget.sessionController.dissolveAdminTeam,
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
                monthPlanOverview: widget.sessionController.monthPlanOverview,
                annualPlanOverview: widget.sessionController.annualPlanOverview,
                weeklyTemplates: widget.sessionController.weeklyTemplates,
                onPreviousWeek: widget.sessionController.loadPreviousWeek,
                onCurrentWeek: widget.sessionController.loadCurrentWeek,
                onNextWeek: widget.sessionController.loadNextWeek,
                onLoadMonthOverview: widget.sessionController.loadMonthOverview,
                onPreviousMonth: widget.sessionController.loadPreviousMonth,
                onCurrentMonth: widget.sessionController.loadCurrentMonth,
                onNextMonth: widget.sessionController.loadNextMonth,
                onLoadAnnualOverview:
                    widget.sessionController.loadAnnualOverview,
                onPreviousYear: widget.sessionController.loadPreviousYear,
                onCurrentYear: widget.sessionController.loadCurrentYear,
                onNextYear: widget.sessionController.loadNextYear,
                onApplyDayTemplateToDate:
                    widget.sessionController.applyDayTemplateToDate,
                onSaveAnnualSegment: widget.sessionController.saveAnnualSegment,
                onDeleteAnnualSegment:
                    widget.sessionController.deleteAnnualSegment,
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
              ),
              if (widget.sessionController.offlineImportPreview != null)
                _OfflineImportPrompt(
                  preview: widget.sessionController.offlineImportPreview!,
                  language: language,
                  busy: widget.sessionController.isBusy,
                  onCancel: widget.sessionController.dismissOfflineImport,
                  onImport: widget.sessionController.importOfflineData,
                ),
            ],
          ),
        );
    }
  }
}

class _OfflineImportPrompt extends StatelessWidget {
  const _OfflineImportPrompt({
    required this.preview,
    required this.language,
    required this.busy,
    required this.onCancel,
    required this.onImport,
  });

  final OfflineImportPreview preview;
  final AppLanguage language;
  final bool busy;
  final VoidCallback onCancel;
  final Future<void> Function(OfflineConflictStrategy strategy) onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isChinese = language.isChinese;
    final accountName = preview.targetNickname.trim().isEmpty
        ? preview.targetUserNo
        : preview.targetNickname;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.48),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 18,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 32, color: colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        isChinese ? '导入本机离线数据？' : 'Import offline data?',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isChinese
                            ? '目标账号：$accountName（${preview.targetUserNo}）\n待导入：${preview.pendingOperationCount} 项'
                            : 'Target account: $accountName (${preview.targetUserNo})\nPending: ${preview.pendingOperationCount} operations',
                      ),
                      if (preview.conflictCount > 0) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isChinese
                                ? '发现 ${preview.conflictCount} 个日期已有云端计划：${preview.dailyPlanConflictDates.join('、')}'
                                : '${preview.conflictCount} dates already have online plans: ${preview.dailyPlanConflictDates.join(', ')}',
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        isChinese
                            ? '仅在你确认后上传。无论结果如何，本机原始数据都会保留；失败和冲突项仍可再次处理。'
                            : 'Nothing uploads until you confirm. Original local data is retained, and failed or conflicting items can be retried.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton(
                            onPressed: busy ? null : onCancel,
                            child: Text(isChinese ? '暂不导入' : 'Not now'),
                          ),
                          if (preview.conflictCount > 0)
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => onImport(
                                        OfflineConflictStrategy.keepServer,
                                      ),
                              child: Text(isChinese
                                  ? '保留云端并导入其余数据'
                                  : 'Keep online plans'),
                            ),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () => onImport(
                                      preview.conflictCount > 0
                                          ? OfflineConflictStrategy.overwrite
                                          : OfflineConflictStrategy.keepServer,
                                    ),
                            child: busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    preview.conflictCount > 0
                                        ? (isChinese
                                            ? '用本地计划覆盖并导入'
                                            : 'Overwrite and import')
                                        : (isChinese
                                            ? '确认导入到此账号'
                                            : 'Confirm import'),
                                  ),
                          ),
                        ],
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

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF111111),
          ),
        ),
      ),
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen({
    required this.language,
    required this.visualTheme,
    required this.onThemeChanged,
  });

  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return _DesktopWindowModeScope(
      mode: 'auth',
      child: AuthExperience(
        language: language,
        visualTheme: visualTheme,
        onThemeChanged: onThemeChanged,
        stageNumber: '02',
        title: language.launchMessage,
        description: language.isChinese
            ? '正在恢复你上次的学习状态。'
            : 'Restoring the study state you left last time.',
        child: const LinearProgressIndicator(minHeight: 3),
      ),
    );
  }
}

class _LanguageSelectionPage extends StatelessWidget {
  const _LanguageSelectionPage({
    required this.controller,
    required this.visualTheme,
    required this.onThemeChanged,
  });

  final AppLanguageController controller;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final language = controller.currentLanguage;
    return _DesktopWindowModeScope(
      mode: 'auth',
      child: AuthExperience(
        language: language,
        visualTheme: visualTheme,
        onThemeChanged: onThemeChanged,
        stageNumber: '01',
        title: language.startupTitle,
        description: language.isChinese
            ? '这个选择会保存在本机，以后也可以随时更改。'
            : 'This choice stays on this device and can be changed anytime.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...AppLanguage.values.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LanguageOptionCard(
                  label: item.label,
                  secondaryLabel: item == AppLanguage.simplifiedChinese
                      ? 'Simplified Chinese'
                      : '英语 / English',
                  selected: item == language,
                  onTap: () => controller.previewLanguage(item),
                ),
              );
            }),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: controller.confirmStartupLanguage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.continueLabel),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.label,
    required this.secondaryLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String secondaryLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.09)
              : colors.surface,
          border: Border.all(
            color: selected ? colors.primary : colors.outline,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.outline,
                  width: selected ? 5 : 1,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(secondaryLabel,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_rounded, color: colors.primary),
          ],
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
  State<_DesktopWindowModeScope> createState() =>
      _DesktopWindowModeScopeState();
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
