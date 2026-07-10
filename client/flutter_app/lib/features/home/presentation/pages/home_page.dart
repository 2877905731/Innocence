import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/team_workspace_snapshot.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/desktop_close_button.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/core/widgets/status_banner.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/friends/presentation/pages/friend_page.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/memos/presentation/pages/memo_page.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/notifications/presentation/pages/notification_page.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/week_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_panel.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/notification_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/privacy_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';
import 'package:innocence_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/stats/presentation/pages/stats_page.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';

const Color _homeInk = SurfacePalette.ink;
const Color _homeMuted = SurfacePalette.muted;

String _contextText(BuildContext context, String zh, String en) {
  return localizedText(context, zh, en);
}

String _profileDisplayName(BuildContext context, UserProfile profile) {
  final nickname = profile.nickname.trim();
  if (nickname.isNotEmpty) {
    return nickname;
  }
  final userNo = profile.userNo.trim();
  if (userNo.isNotEmpty) {
    return userNo;
  }
  return _contextText(context, '我', 'Me');
}

String _formatMinutesLocalized(BuildContext context, int minutes) {
  final normalized = minutes < 0 ? 0 : minutes;
  final hours = normalized ~/ 60;
  final remainingMinutes = normalized % 60;
  if (Localizations.localeOf(context)
      .languageCode
      .toLowerCase()
      .startsWith('zh')) {
    if (hours <= 0) {
      return '$remainingMinutes 分钟';
    }
    if (remainingMinutes == 0) {
      return '$hours 小时';
    }
    return '$hours 小时 $remainingMinutes 分钟';
  }
  if (hours <= 0) {
    return '$remainingMinutes min';
  }
  if (remainingMinutes == 0) {
    return '$hours h';
  }
  return '$hours h $remainingMinutes min';
}

String _formatMinutesCompactLocalized(BuildContext context, int minutes) {
  final normalized = minutes < 0 ? 0 : minutes;
  final hours = normalized ~/ 60;
  final remainingMinutes = normalized % 60;
  if (Localizations.localeOf(context)
      .languageCode
      .toLowerCase()
      .startsWith('zh')) {
    if (hours <= 0) {
      return '$remainingMinutes分';
    }
    if (remainingMinutes == 0) {
      return '$hours时';
    }
    return '$hours时$remainingMinutes分';
  }
  if (hours <= 0) {
    return '$remainingMinutes min';
  }
  if (remainingMinutes == 0) {
    return '$hours h';
  }
  return '$hours h $remainingMinutes min';
}

String _focusStageLabel(BuildContext context, String stageName, bool active) {
  switch (stageName.trim().toLowerCase()) {
    case 'study':
      return _contextText(context, '学习', 'Study');
    case 'break':
      return _contextText(context, '休息', 'Break');
    case 'finished':
      return _contextText(context, '已完成', 'Finished');
    default:
      return active
          ? _contextText(context, '学习', 'Study')
          : _contextText(context, '空闲', 'Idle');
  }
}

String _teamMemberDisplayName(BuildContext context, TeamMember member) {
  final nickname = member.nickname.trim();
  if (nickname.isNotEmpty) {
    return nickname;
  }
  final userNo = member.userNo.trim();
  if (userNo.isNotEmpty) {
    return userNo;
  }
  return member.owner
      ? _contextText(context, '队长', 'Captain')
      : _contextText(context, '队友', 'Teammate');
}

String _teamMemberTodayStudyLabel(BuildContext context, TeamMember member) {
  return _formatMinutesLocalized(context, member.todayStudyDurationMinutes);
}

String _teamMemberTotalStudyLabel(BuildContext context, TeamMember member) {
  return _formatMinutesLocalized(context, member.totalStudyDurationMinutes);
}

String _checkInHeadline(BuildContext context, CheckInStatus status) {
  if (status.checkedInToday) {
    return _contextText(context, '今日已签到', 'Checked in today');
  }
  if (status.todayPlanCompleted) {
    return _contextText(context, '可以签到', 'Ready for check-in');
  }
  if (status.todayPlanTotalCount <= 0) {
    return _contextText(context, '今天还没有计划', 'No plan yet');
  }
  return _contextText(context, '今日计划进行中', 'Plan still in progress');
}

String _checkInDescription(BuildContext context, CheckInStatus status) {
  if (status.checkedInToday) {
    return status.lastCheckInTime.isEmpty
        ? _contextText(context, '今天已经计入连续坚持。',
            'Today is already counted into your streak.')
        : _contextText(
            context,
            '已于 ${status.lastCheckInTime} 完成签到。',
            'Completed at ${status.lastCheckInTime}.',
          );
  }
  if (status.todayPlanCompleted) {
    return _contextText(context, '今天的计划已经完成，点击即可记录今天。',
        'Today plan is done. Tap once to record the day.');
  }
  if (status.todayPlanTotalCount <= 0) {
    return _contextText(context, '先创建今天的任务并完成它们，随后才能签到。',
        'Create today tasks first, then finish them before check-in.');
  }
  return _contextText(context, '完成今天全部任务后，连续坚持才会继续累计。',
      'Complete all today tasks before the streak can continue.');
}

String _checkInFailureSummary(BuildContext context, CheckInStatus status) {
  if (!status.hasFailureHint) {
    return '';
  }
  final attemptLabel = _contextText(
    context,
    '今日失败 ${status.todayFailedAttempts} 次',
    status.todayFailedAttempts == 1
        ? '1 failed attempt today'
        : '${status.todayFailedAttempts} failed attempts today',
  );
  return '$attemptLabel | ${status.latestFailureReason}';
}

String _checkInActionLabel(BuildContext context, CheckInStatus status) {
  if (status.checkedInToday) {
    return _contextText(context, '已完成', 'Completed');
  }
  if (status.todayPlanCompleted) {
    return _contextText(context, '立即签到', 'Check in now');
  }
  return _contextText(context, '尝试签到', 'Try check-in');
}

String _desktopEffectLabel(BuildContext context, AppearanceSetting appearance) {
  switch (appearance.desktopEffect) {
    case 'soft_glass':
      return _contextText(context, '柔光毛玻璃', 'Soft glass');
    case 'focus_glow':
      return _contextText(context, '专注光效', 'Focus glow');
    default:
      return _contextText(context, '沉浸毛玻璃', 'Immersive glass');
  }
}

String _notificationTypeLabel(BuildContext context, AppNotificationItem item) {
  switch (item.notificationType) {
    case 'friend_request':
      return _contextText(context, '好友申请', 'Friend request');
    case 'team_invitation':
      return _contextText(context, '团队邀请', 'Team invitation');
    case 'team_reminder':
      return _contextText(context, '队友提醒', 'Teammate reminder');
    case 'teammate_completion':
      return _contextText(context, '队友完成通知', 'Teammate finished');
    case 'plan_completion':
      return _contextText(context, '计划完成通知', 'Plan completed');
    case 'check_in_success':
      return _contextText(context, '签到成功', 'Check-in success');
    case 'check_in_failure':
      return _contextText(context, '签到待完成', 'Check-in pending');
    case 'system_announcement':
      return _contextText(context, '系统公告', 'System announcement');
    default:
      return _contextText(context, '通知', 'Notification');
  }
}

String _todayPlanDisplayName(BuildContext context, TodayPlan todayPlan) {
  final planName = todayPlan.planName.trim();
  if (planName.isEmpty || planName.toLowerCase() == 'today') {
    return _contextText(context, '今日计划', 'Today');
  }
  return planName;
}

String _todayPlanDurationLabel(BuildContext context, int minutes) {
  return _formatMinutesLocalized(context, minutes);
}

String _todayPlanItemScheduleLabel(BuildContext context, TodayPlanItem item) {
  if (!item.hasSchedule) {
    return _contextText(context, '弹性任务', 'Flexible task');
  }
  return '${TodayPlan.slotLabel(item.startSlot!)} - ${TodayPlan.slotLabel(item.endSlot!)}';
}

String _todayPlanItemDurationLabel(BuildContext context, TodayPlanItem item) {
  final durationMinutes = item.plannedMinutes <= 0 && item.hasSchedule
      ? (item.endSlot! - item.startSlot!) * 30
      : item.plannedMinutes;
  return _formatMinutesLocalized(context, durationMinutes);
}

String _teamMemberStageLabel(BuildContext context, TeamMember member) {
  return _focusStageLabel(context, member.activeStageName, member.activeStudy);
}

String _focusPlannedDurationLabel(BuildContext context, FocusSession session) {
  return _formatMinutesLocalized(context, session.plannedMinutes);
}

String _profileInitial(String displayName) {
  final normalized = displayName.trim();
  if (normalized.isEmpty) {
    return 'I';
  }
  return normalized.characters.first.toUpperCase();
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    this.badgeText,
    this.badgeColor = const Color(0xFFFF8C72),
    this.badgeTextColor = Colors.white,
    this.iconSize = 22,
    this.boxSize = 34,
  });

  final IconData icon;
  final String? badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final double iconSize;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    final label = badgeText?.trim() ?? '';

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 2),
              child: Icon(
                icon,
                color: SurfacePalette.ink,
                size: iconSize,
              ),
            ),
          ),
          if (label.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.appLanguage,
    required this.onChangeLanguage,
    required this.profile,
    required this.focusSession,
    required this.checkInStatus,
    required this.statsOverview,
    required this.teamOverview,
    required this.teamChatOverview,
    required this.friendOverview,
    required this.memoOverview,
    required this.notificationOverview,
    required this.settingOverview,
    required this.todayPlan,
    required this.onRefresh,
    required this.onLogout,
    required this.onStartFocusSession,
    required this.onFinishFocusSession,
    required this.onSubmitCheckIn,
    required this.onLoadStatsOverview,
    required this.onDeleteCheckInFailureRecord,
    required this.onLoadNotifications,
    required this.onMarkNotificationRead,
    required this.onMarkAllNotificationsRead,
    required this.onRespondNotificationFriendRequest,
    required this.onRespondNotificationTeamInvitation,
    required this.onRemindTeammate,
    required this.onLoadFriendOverview,
    required this.onSearchFriends,
    required this.onSendFriendRequest,
    required this.onRespondFriendRequest,
    required this.onCreateFriendGroup,
    required this.onMoveFriendToGroup,
    required this.onDeleteFriend,
    required this.onLoadMemoOverview,
    required this.onLoadMemoDetail,
    required this.onCreateMemo,
    required this.onUpdateMemo,
    required this.onDeleteMemo,
    required this.onLoadSettingsOverview,
    required this.onUpdateMySettingProfile,
    required this.onUpdateMyPrivacySetting,
    required this.onUpdateNotificationSetting,
    required this.onUpdateWidgetSetting,
    required this.onUpdateAppearanceSetting,
    required this.onClearSettingsCache,
    required this.onSendCancelAccountCode,
    required this.onCancelAccount,
    required this.onLoadAdminReports,
    required this.onLoadAdminReportDetail,
    required this.onReviewAdminReport,
    required this.onSearchAdminUsers,
    required this.onLoadAdminUserDetail,
    required this.onLoadAdminUserReports,
    required this.onLoadAdminUserPunishments,
    required this.onLiftAdminUserPunishment,
    required this.onLoadAdminTeams,
    required this.onLoadAdminTeamDetail,
    required this.onRemoveAdminTeamMember,
    required this.onDissolveAdminTeam,
    required this.onLoadAdminAnnouncements,
    required this.onCreateAdminAnnouncement,
    required this.onDeleteAdminAnnouncement,
    required this.onCreateTeam,
    required this.onJoinTeam,
    required this.onInviteTeamMember,
    required this.onRemoveTeamMember,
    required this.onDissolveTeam,
    required this.onLoadTeamChatMessages,
    required this.onSendTeamChatMessage,
    required this.onMarkTeamChatRead,
    required this.onReportTeamChatMessage,
    required this.onLoadTeamWorkspaceSnapshot,
    required this.onSaveTodayPlan,
    required this.onLoadPlanByDate,
    required this.weekPlanOverview,
    required this.weeklyTemplates,
    required this.onPreviousWeek,
    required this.onCurrentWeek,
    required this.onNextWeek,
    required this.onSavePlanAsWeeklyTemplate,
    required this.onApplyWeeklyTemplate,
    required this.onApplyWeeklyTemplateToDate,
    required this.onDeleteWeeklyTemplate,
    required this.onCopyPlanToDate,
    required this.onCopyPlanToDates,
    required this.onClearPlanDate,
    required this.onApplyWeeklyTemplateToDates,
    required this.onQuickArrangeWeek,
    required this.onToggleTodayPlanItem,
    required this.isBusy,
    required this.onClearBanner,
    this.bannerMessage,
  });

  final AppLanguage appLanguage;
  final Future<void> Function(
    AppLanguage language, {
    bool confirmStartup,
  }) onChangeLanguage;
  final UserProfile profile;
  final FocusSession focusSession;
  final CheckInStatus checkInStatus;
  final StatsOverview statsOverview;
  final TeamOverview teamOverview;
  final TeamChatOverview teamChatOverview;
  final FriendOverview friendOverview;
  final MemoOverview memoOverview;
  final NotificationOverview notificationOverview;
  final SettingOverview settingOverview;
  final TodayPlan todayPlan;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function({
    required DateTime endTime,
    String? taskName,
    bool bindPomodoro,
    int pomodoroStudyMinutes,
    int pomodoroBreakMinutes,
  }) onStartFocusSession;
  final Future<void> Function() onFinishFocusSession;
  final Future<void> Function() onSubmitCheckIn;
  final Future<StatsOverview?> Function({int days}) onLoadStatsOverview;
  final Future<bool> Function(String date) onDeleteCheckInFailureRecord;
  final Future<NotificationOverview?> Function({int limit}) onLoadNotifications;
  final Future<NotificationOverview?> Function(int notificationId)
      onMarkNotificationRead;
  final Future<NotificationOverview?> Function() onMarkAllNotificationsRead;
  final Future<NotificationOverview?> Function(
    int requestId, {
    required bool accept,
  }) onRespondNotificationFriendRequest;
  final Future<NotificationOverview?> Function(
    int invitationId, {
    required bool accept,
  }) onRespondNotificationTeamInvitation;
  final Future<bool> Function(int teammateUserId) onRemindTeammate;
  final Future<FriendOverview?> Function() onLoadFriendOverview;
  final Future<List<FriendSearchItemModel>> Function(String keyword)
      onSearchFriends;
  final Future<FriendOverview?> Function(
    int targetUserId, {
    String message,
  }) onSendFriendRequest;
  final Future<FriendOverview?> Function(
    int requestId, {
    required bool accept,
  }) onRespondFriendRequest;
  final Future<FriendOverview?> Function(String groupName) onCreateFriendGroup;
  final Future<FriendOverview?> Function(
    int friendUserId, {
    required int groupId,
  }) onMoveFriendToGroup;
  final Future<FriendOverview?> Function(int friendUserId) onDeleteFriend;
  final Future<MemoOverview?> Function() onLoadMemoOverview;
  final Future<MemoCardModel?> Function(int memoId) onLoadMemoDetail;
  final Future<MemoOverview?> Function(MemoCardModel draft) onCreateMemo;
  final Future<MemoOverview?> Function(int memoId, MemoCardModel draft)
      onUpdateMemo;
  final Future<MemoOverview?> Function(int memoId) onDeleteMemo;
  final Future<SettingOverview?> Function() onLoadSettingsOverview;
  final Future<UserProfile?> Function({
    required String nickname,
    required String avatarUrl,
    required String bio,
  }) onUpdateMySettingProfile;
  final Future<PrivacySetting?> Function({
    required bool allowFriendViewProfile,
    required bool allowTeammateViewStudy,
  }) onUpdateMyPrivacySetting;
  final Future<NotificationSetting?> Function({
    required bool mobilePushEnabled,
    required bool desktopNoticeEnabled,
    required bool teamRemindEnabled,
    required bool systemAnnouncementEnabled,
  }) onUpdateNotificationSetting;
  final Future<WidgetSetting?> Function({
    required bool autoStart,
    required bool alwaysOnTop,
    required bool showPlan,
    required bool showTimer,
    required bool showMemo,
  }) onUpdateWidgetSetting;
  final Future<AppearanceSetting?> Function({
    required String themeMode,
    required String desktopEffect,
  }) onUpdateAppearanceSetting;
  final Future<bool> Function() onClearSettingsCache;
  final Future<void> Function(String email) onSendCancelAccountCode;
  final Future<bool> Function({
    String password,
    String emailCode,
  }) onCancelAccount;
  final Future<List<AdminReportListItem>> Function({
    String status,
    String reportType,
    int limit,
  }) onLoadAdminReports;
  final Future<AdminReportDetail?> Function(int reportId)
      onLoadAdminReportDetail;
  final Future<AdminReportReviewResult?> Function(
    int reportId, {
    required String decision,
    required bool deleteContent,
    required String punishmentType,
    required int durationDays,
    required String reason,
  }) onReviewAdminReport;
  final Future<List<AdminUserSearchItem>> Function({
    String keyword,
    int limit,
  }) onSearchAdminUsers;
  final Future<AdminUserDetail?> Function(int userId) onLoadAdminUserDetail;
  final Future<List<AdminUserReportItem>> Function(
    int userId, {
    int limit,
  }) onLoadAdminUserReports;
  final Future<List<AdminUserPunishmentItem>> Function(
    int userId, {
    String status,
    int limit,
  }) onLoadAdminUserPunishments;
  final Future<AdminLiftPunishmentResult?> Function(
    int userId, {
    required int punishmentId,
  }) onLiftAdminUserPunishment;
  final Future<List<AdminTeamListItem>> Function({
    String keyword,
    int? status,
    int limit,
  }) onLoadAdminTeams;
  final Future<AdminTeamDetail?> Function(int teamId) onLoadAdminTeamDetail;
  final Future<AdminTeamActionResult?> Function(
    int teamId, {
    required int memberUserId,
  }) onRemoveAdminTeamMember;
  final Future<AdminTeamActionResult?> Function(int teamId) onDissolveAdminTeam;
  final Future<List<AdminAnnouncementItem>> Function({
    int limit,
  }) onLoadAdminAnnouncements;
  final Future<AdminAnnouncementActionResult?> Function({
    required String title,
    required String content,
  }) onCreateAdminAnnouncement;
  final Future<AdminAnnouncementActionResult?> Function(int announcementId)
      onDeleteAdminAnnouncement;
  final Future<void> Function(String teamName) onCreateTeam;
  final Future<void> Function(String inviteCode) onJoinTeam;
  final Future<void> Function(int targetUserId) onInviteTeamMember;
  final Future<bool> Function(int memberUserId) onRemoveTeamMember;
  final Future<bool> Function() onDissolveTeam;
  final Future<TeamChatOverview?> Function({int limit}) onLoadTeamChatMessages;
  final Future<TeamChatOverview?> Function(String content)
      onSendTeamChatMessage;
  final Future<TeamChatOverview?> Function() onMarkTeamChatRead;
  final Future<bool> Function(
    int messageId, {
    required String reason,
    String description,
  }) onReportTeamChatMessage;
  final Future<TeamWorkspaceSnapshot?> Function() onLoadTeamWorkspaceSnapshot;
  final Future<void> Function(TodayPlan plan) onSaveTodayPlan;
  final Future<TodayPlan?> Function(String planDate) onLoadPlanByDate;
  final WeekPlanOverview weekPlanOverview;
  final List<WeeklyPlanTemplate> weeklyTemplates;
  final Future<void> Function() onPreviousWeek;
  final Future<void> Function() onCurrentWeek;
  final Future<void> Function() onNextWeek;
  final Future<void> Function(String templateName, TodayPlan sourcePlan)
      onSavePlanAsWeeklyTemplate;
  final Future<void> Function(int templateId) onApplyWeeklyTemplate;
  final Future<void> Function(int templateId, String planDate)
      onApplyWeeklyTemplateToDate;
  final Future<void> Function(int templateId) onDeleteWeeklyTemplate;
  final Future<void> Function(String sourcePlanDate, String targetPlanDate)
      onCopyPlanToDate;
  final Future<void> Function(
      String sourcePlanDate, List<String> targetPlanDates) onCopyPlanToDates;
  final Future<void> Function(String planDate) onClearPlanDate;
  final Future<void> Function(int templateId, List<String> planDates)
      onApplyWeeklyTemplateToDates;
  final Future<void> Function(
    Map<String, int> templateAssignments,
    List<String> clearDates,
  ) onQuickArrangeWeek;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final bool isBusy;
  final String? bannerMessage;
  final VoidCallback onClearBanner;

  Future<void> _openEditor(BuildContext context) async {
    final result = await showDialog<TodayPlan>(
      context: context,
      builder: (context) {
        return TodayPlanEditorDialog(initialPlan: todayPlan);
      },
    );
    if (result == null) {
      return;
    }
    await onSaveTodayPlan(result);
  }

  Future<void> _openSaveTemplateDialog(BuildContext context) async {
    await _openSaveTemplateDialogForPlan(
      context,
      sourcePlan: todayPlan,
      title: _contextText(context, '保存周模板', 'Save weekly template'),
      hintText: _contextText(
        context,
        '例如：深度学习工作日',
        'For example: Deep study weekday',
      ),
    );
  }

  Future<void> _openSaveTemplateDialogForPlan(
    BuildContext context, {
    required TodayPlan sourcePlan,
    required String title,
    required String hintText,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _contextText(context, '模板名称', 'Template name'),
              hintText: hintText,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_contextText(context, '取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(_contextText(context, '保存', 'Save')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.isEmpty) {
      return;
    }
    await onSavePlanAsWeeklyTemplate(result, sourcePlan);
  }

  Future<void> _openFocusSessionDialog(BuildContext context) async {
    final result = await showDialog<_FocusSessionDraft>(
      context: context,
      builder: (context) => const _StartFocusSessionDialog(),
    );
    if (result == null) {
      return;
    }

    await onStartFocusSession(
      endTime: result.endTime,
      taskName: result.taskName,
      bindPomodoro: result.bindPomodoro,
      pomodoroStudyMinutes: result.pomodoroStudyMinutes,
      pomodoroBreakMinutes: result.pomodoroBreakMinutes,
    );
  }

  Future<void> _openEditorForDate(BuildContext context, String planDate) async {
    final plan = await onLoadPlanByDate(planDate);
    if (!context.mounted || plan == null) {
      return;
    }

    final result = await showDialog<TodayPlan>(
      context: context,
      builder: (context) {
        return TodayPlanEditorDialog(initialPlan: plan);
      },
    );
    if (result == null) {
      return;
    }
    await onSaveTodayPlan(result);
  }

  Future<void> _openStatsCenter(BuildContext context) async {
    final navigator = Navigator.of(context);
    final latestOverview =
        await onLoadStatsOverview(days: statsOverview.rangeDays);
    if (!context.mounted) {
      return;
    }
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StatsPage(
            profile: profile,
            initialOverview: latestOverview ?? statsOverview,
            onLoadStatsOverview: onLoadStatsOverview,
            onDeleteFailureRecord: onDeleteCheckInFailureRecord,
            onRemindTeammate: onRemindTeammate,
          );
        },
      ),
    );
  }

  Future<void> _openNotificationCenter(BuildContext context) async {
    final navigator = Navigator.of(context);
    final latestOverview = await onLoadNotifications(limit: 40);
    if (!context.mounted) {
      return;
    }
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          return NotificationPage(
            initialOverview: latestOverview ?? notificationOverview,
            onLoadNotifications: onLoadNotifications,
            onMarkNotificationRead: onMarkNotificationRead,
            onMarkAllNotificationsRead: onMarkAllNotificationsRead,
            onRespondFriendRequest: onRespondNotificationFriendRequest,
            onRespondTeamInvitation: onRespondNotificationTeamInvitation,
          );
        },
      ),
    );
  }

  Future<void> _openFriendCenter(BuildContext context) async {
    final navigator = Navigator.of(context);
    final latestOverview = await onLoadFriendOverview();
    if (!context.mounted) {
      return;
    }
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          return FriendPage(
            initialOverview: latestOverview ?? friendOverview,
            onRefresh: onLoadFriendOverview,
            onSearch: onSearchFriends,
            onSendFriendRequest: onSendFriendRequest,
            onRespondFriendRequest: onRespondFriendRequest,
            onCreateGroup: onCreateFriendGroup,
            onMoveFriendToGroup: onMoveFriendToGroup,
            onDeleteFriend: onDeleteFriend,
          );
        },
      ),
    );
  }

  Future<void> _openMemoCenter(BuildContext context) async {
    final navigator = Navigator.of(context);
    final latestOverview = await onLoadMemoOverview();
    if (!context.mounted) {
      return;
    }
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          return MemoPage(
            initialOverview: latestOverview ?? memoOverview,
            onRefresh: onLoadMemoOverview,
            onLoadDetail: onLoadMemoDetail,
            onCreateMemo: onCreateMemo,
            onUpdateMemo: onUpdateMemo,
            onDeleteMemo: onDeleteMemo,
          );
        },
      ),
    );
  }

  Future<void> _openSettingsCenter(BuildContext context) async {
    final navigator = Navigator.of(context);
    final latestOverview = await onLoadSettingsOverview();
    if (!context.mounted) {
      return;
    }
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          return SettingsPage(
            onChangeLanguage: onChangeLanguage,
            initialOverview: latestOverview ?? settingOverview,
            onRefresh: onLoadSettingsOverview,
            onUpdateProfile: onUpdateMySettingProfile,
            onUpdatePrivacy: onUpdateMyPrivacySetting,
            onUpdateNotifications: onUpdateNotificationSetting,
            onUpdateWidget: onUpdateWidgetSetting,
            onUpdateAppearance: onUpdateAppearanceSetting,
            onClearCache: onClearSettingsCache,
            onSendCancelCode: onSendCancelAccountCode,
            onCancelAccount: onCancelAccount,
            onLogout: onLogout,
            onLoadAdminReports: onLoadAdminReports,
            onLoadAdminReportDetail: onLoadAdminReportDetail,
            onReviewAdminReport: onReviewAdminReport,
            onSearchAdminUsers: onSearchAdminUsers,
            onLoadAdminUserDetail: onLoadAdminUserDetail,
            onLoadAdminUserReports: onLoadAdminUserReports,
            onLoadAdminUserPunishments: onLoadAdminUserPunishments,
            onLiftAdminUserPunishment: onLiftAdminUserPunishment,
            onLoadAdminTeams: onLoadAdminTeams,
            onLoadAdminTeamDetail: onLoadAdminTeamDetail,
            onRemoveAdminTeamMember: onRemoveAdminTeamMember,
            onDissolveAdminTeam: onDissolveAdminTeam,
            onLoadAdminAnnouncements: onLoadAdminAnnouncements,
            onCreateAdminAnnouncement: onCreateAdminAnnouncement,
            onDeleteAdminAnnouncement: onDeleteAdminAnnouncement,
          );
        },
      ),
    );
  }

  Future<void> _openTeamWorkspace(BuildContext context) async {
    final snapshot = await onLoadTeamWorkspaceSnapshot();
    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final nextTeamOverview = snapshot?.teamOverview ?? teamOverview;
          final nextFriendOverview = snapshot?.friendOverview ?? friendOverview;
          final nextTeamChatOverview =
              snapshot?.teamChatOverview ?? teamChatOverview;
          return _TeamWorkspacePage(
            profile: profile,
            teamOverview: nextTeamOverview,
            friendOverview: nextFriendOverview,
            teamChatOverview: nextTeamChatOverview,
            initialBannerMessage: snapshot?.bannerMessage ?? bannerMessage,
            isBusy: isBusy,
            onCreateTeam: onCreateTeam,
            onJoinTeam: onJoinTeam,
            onInviteMember: onInviteTeamMember,
            onRemoveMember: onRemoveTeamMember,
            onDissolveTeam: onDissolveTeam,
            onLoadTeamChatMessages: onLoadTeamChatMessages,
            onSendTeamChatMessage: onSendTeamChatMessage,
            onMarkTeamChatRead: onMarkTeamChatRead,
            onReportTeamChatMessage: onReportTeamChatMessage,
            onRefreshWorkspace: onLoadTeamWorkspaceSnapshot,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (AppConfig.deviceType == 'windows') {
      return _DesktopWidgetHomeV2(
        appLanguage: appLanguage,
        profile: profile,
        focusSession: focusSession,
        checkInStatus: checkInStatus,
        statsOverview: statsOverview,
        teamOverview: teamOverview,
        teamChatOverview: teamChatOverview,
        friendOverview: friendOverview,
        memoOverview: memoOverview,
        notificationOverview: notificationOverview,
        settingOverview: settingOverview,
        todayPlan: todayPlan,
        isBusy: isBusy,
        bannerMessage: bannerMessage,
        onClearBanner: onClearBanner,
        onRefresh: onRefresh,
        onOpenStats: () => _openStatsCenter(context),
        onOpenNotifications: () => _openNotificationCenter(context),
        onOpenFriends: () => _openFriendCenter(context),
        onOpenMemos: () => _openMemoCenter(context),
        onOpenSettings: () => _openSettingsCenter(context),
        onOpenTeamWorkspace: () => _openTeamWorkspace(context),
        onStartFocus: () => _openFocusSessionDialog(context),
        onFinishFocus: onFinishFocusSession,
        onSubmitCheckIn: onSubmitCheckIn,
        onEditTodayPlan: () => _openEditor(context),
        onToggleTodayPlanItem: onToggleTodayPlanItem,
        onRemindTeammate: onRemindTeammate,
      );
    }

    final homeTheme = SurfacePalette.homeTheme();
    final actionButtons = Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await _openMemoCenter(context);
                },
          icon: const Icon(Icons.sticky_note_2_rounded),
          label: Text(
            memoOverview.totalCount > 0
                ? '备忘录 ${memoOverview.totalCount}'
                : '备忘录',
          ),
        ),
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await _openFriendCenter(context);
                },
          icon: _BadgeIcon(
            icon: Icons.people_alt_rounded,
            badgeText: friendOverview.incomingRequests.isNotEmpty
                ? (friendOverview.incomingRequests.length > 99
                    ? '99+'
                    : '${friendOverview.incomingRequests.length}')
                : null,
            badgeColor: const Color(0xFF111111),
          ),
          label: Text(
            friendOverview.incomingRequests.isNotEmpty
                ? '好友 ${friendOverview.incomingRequests.length}'
                : '好友',
          ),
        ),
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await _openNotificationCenter(context);
                },
          icon: _UnreadBellIcon(
            unreadCount: notificationOverview.unreadCount,
          ),
          label: Text(
            notificationOverview.unreadCount > 0
                ? '通知 ${notificationOverview.unreadCount}'
                : '通知',
          ),
        ),
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await _openSettingsCenter(context);
                },
          icon: const Icon(Icons.tune_rounded),
          label: Text(_contextText(context, '设置', 'Settings')),
        ),
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await onRefresh();
                },
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(
            isBusy
                ? _contextText(context, '同步中', 'Syncing')
                : _contextText(context, '刷新', 'Refresh'),
          ),
        ),
        FilledButton.icon(
          onPressed: isBusy
              ? null
              : () async {
                  await onLogout();
                },
          icon: const Icon(Icons.logout_rounded),
          label: Text(_contextText(context, '退出登录', 'Sign out')),
        ),
      ],
    );

    return Theme(
      data: homeTheme,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AuroraBackground(
          lightStyle: true,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1020),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                  children: [
                    Text(
                      'INNOCENCE',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: _homeInk,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 180,
                        height: 2,
                        color: _homeInk,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _profileDisplayName(context, profile).isEmpty
                          ? _contextText(context, '学习总览', 'Study overview')
                          : _contextText(
                              context,
                              '${_profileDisplayName(context, profile)} 的学习总览',
                              '${_profileDisplayName(context, profile)} study overview',
                            ),
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: _homeInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _contextText(
                        context,
                        '手机与电脑进度保持同步，今日计划、专注状态、通知和团队提醒都会集中展示在这里。',
                        'Phone and desktop stay in sync, with today plans, focus status, notifications, and team reminders gathered here.',
                      ),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: _homeMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    actionButtons,
                    if (bannerMessage != null) ...[
                      const SizedBox(height: 18),
                      StatusBanner(
                        message: bannerMessage!,
                        onClose: onClearBanner,
                      ),
                    ],
                    const SizedBox(height: 22),
                    GlassPanel(
                      lightStyle: true,
                      child: _OverviewCard(profile: profile),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 230,
                          child: GlassPanel(
                            lightStyle: true,
                            child: _MetricTile(
                              title: _contextText(
                                context,
                                '累计学习时长',
                                'Total study time',
                              ),
                              value: _formatMinutesLocalized(
                                context,
                                profile.studyDurationTotal,
                              ),
                              hint: focusSession.active
                                  ? _contextText(
                                      context,
                                      '当前专注结束后会刷新总时长',
                                      'The total updates after the current focus session ends.',
                                    )
                                  : _contextText(
                                      context,
                                      '已完成的学习记录都会累计到这里',
                                      'Completed study records accumulate here.',
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: GlassPanel(
                            lightStyle: true,
                            child: _MetricTile(
                              title: _contextText(
                                context,
                                '累计签到天数',
                                'Total check-in days',
                              ),
                              value: _contextText(
                                context,
                                '${checkInStatus.totalDays} 天',
                                '${checkInStatus.totalDays} days',
                              ),
                              hint: _contextText(
                                context,
                                '当前连续 ${checkInStatus.consecutiveDays} 天',
                                'Current streak: ${checkInStatus.consecutiveDays} days',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: GlassPanel(
                            lightStyle: true,
                            child: _MetricTile(
                              title: _contextText(
                                context,
                                '今日计划完成',
                                'Today plan progress',
                              ),
                              value:
                                  '${todayPlan.completedCount}/${todayPlan.totalCount}',
                              hint: todayPlan.hasItems
                                  ? _contextText(
                                      context,
                                      '今日计划 ${_todayPlanDurationLabel(context, todayPlan.totalPlannedMinutes)}',
                                      'Today plan ${_todayPlanDurationLabel(context, todayPlan.totalPlannedMinutes)}',
                                    )
                                  : _contextText(
                                      context,
                                      '先创建今天的短计划',
                                      'Create today short plan first.',
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: GlassPanel(
                            lightStyle: true,
                            child: _MetricTile(
                              title: _contextText(
                                context,
                                '在线规则',
                                'Online rules',
                              ),
                              value: _contextText(
                                context,
                                '1 台手机 + 1 台电脑',
                                '1 phone + 1 computer',
                              ),
                              hint: _contextText(
                                context,
                                '新会话会顶掉同端旧会话',
                                'A new session replaces the old one on the same device type.',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _FocusSessionCard(
                        focusSession: focusSession,
                        isBusy: isBusy,
                        onStart: () => _openFocusSessionDialog(context),
                        onFinish: onFinishFocusSession,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _CheckInCard(
                        checkInStatus: checkInStatus,
                        isBusy: isBusy,
                        onSubmit: onSubmitCheckIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _TrendSummaryCard(
                        statsOverview: statsOverview,
                        isBusy: isBusy,
                        onRangeChanged: (days) =>
                            onLoadStatsOverview(days: days),
                        onOpenDetails: () => _openStatsCenter(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: TodayPlanPanel(
                        lightStyle: true,
                        plan: todayPlan,
                        weekPlanOverview: weekPlanOverview,
                        weeklyTemplates: weeklyTemplates,
                        isBusy: isBusy,
                        onEdit: () => _openEditor(context),
                        onOpenPlanDate: (planDate) =>
                            _openEditorForDate(context, planDate),
                        onPreviousWeek: onPreviousWeek,
                        onCurrentWeek: onCurrentWeek,
                        onNextWeek: onNextWeek,
                        onSaveTemplate: () => _openSaveTemplateDialog(context),
                        onSaveTemplateForDay: (planDate) async {
                          final plan = await onLoadPlanByDate(planDate);
                          if (!context.mounted || plan == null) {
                            return;
                          }
                          await _openSaveTemplateDialogForPlan(
                            context,
                            sourcePlan: plan,
                            title: _contextText(
                              context,
                              '保存 ${plan.planDate} 为模板',
                              'Save ${plan.planDate} as template',
                            ),
                            hintText: _contextText(
                              context,
                              '例如：周六复盘节奏',
                              'For example: Saturday review rhythm',
                            ),
                          );
                        },
                        onApplyTemplate: onApplyWeeklyTemplate,
                        onApplyTemplateToDate: onApplyWeeklyTemplateToDate,
                        onDeleteTemplate: onDeleteWeeklyTemplate,
                        onCopyDay: onCopyPlanToDate,
                        onCopyDayToDates: onCopyPlanToDates,
                        onClearDay: onClearPlanDate,
                        onApplyTemplateToDays: onApplyWeeklyTemplateToDates,
                        onQuickArrangeWeek: onQuickArrangeWeek,
                        onToggleItem: onToggleTodayPlanItem,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _NotificationSummaryCard(
                        notificationOverview: notificationOverview,
                        onOpenDetails: () => _openNotificationCenter(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _FriendSummaryCard(
                        friendOverview: friendOverview,
                        onOpenDetails: () => _openFriendCenter(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _MemoSummaryCard(
                        memoOverview: memoOverview,
                        onOpenDetails: () => _openMemoCenter(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _TeamPanel(
                        profile: profile,
                        teamOverview: teamOverview,
                        friendOverview: friendOverview,
                        teamChatOverview: teamChatOverview,
                        initialBannerMessage: bannerMessage,
                        isBusy: isBusy,
                        onCreateTeam: onCreateTeam,
                        onJoinTeam: onJoinTeam,
                        onInviteMember: onInviteTeamMember,
                        onRemoveMember: onRemoveTeamMember,
                        onDissolveTeam: onDissolveTeam,
                        onLoadTeamChatMessages: onLoadTeamChatMessages,
                        onSendTeamChatMessage: onSendTeamChatMessage,
                        onMarkTeamChatRead: onMarkTeamChatRead,
                        onReportTeamChatMessage: onReportTeamChatMessage,
                        onRefreshWorkspace: onLoadTeamWorkspaceSnapshot,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassPanel(
                      lightStyle: true,
                      child: _RoadmapCard(
                        settingsConnected: true,
                      ),
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

// ignore: unused_element
class _DesktopWidgetHome extends StatelessWidget {
  const _DesktopWidgetHome({
    required this.profile,
    required this.focusSession,
    required this.checkInStatus,
    required this.statsOverview,
    required this.teamOverview,
    required this.teamChatOverview,
    required this.friendOverview,
    required this.memoOverview,
    required this.notificationOverview,
    required this.settingOverview,
    required this.todayPlan,
    required this.isBusy,
    required this.onClearBanner,
    required this.onRefresh,
    required this.onOpenStats,
    required this.onOpenNotifications,
    required this.onOpenFriends,
    required this.onOpenMemos,
    required this.onOpenSettings,
    required this.onOpenTeamWorkspace,
    required this.onStartFocus,
    required this.onFinishFocus,
    required this.onSubmitCheckIn,
    required this.onEditTodayPlan,
    required this.onToggleTodayPlanItem,
    required this.onRemindTeammate,
    // ignore: unused_element_parameter
    this.bannerMessage,
  });

  final UserProfile profile;
  final FocusSession focusSession;
  final CheckInStatus checkInStatus;
  final StatsOverview statsOverview;
  final TeamOverview teamOverview;
  final TeamChatOverview teamChatOverview;
  final FriendOverview friendOverview;
  final MemoOverview memoOverview;
  final NotificationOverview notificationOverview;
  final SettingOverview settingOverview;
  final TodayPlan todayPlan;
  final bool isBusy;
  final String? bannerMessage;
  final VoidCallback onClearBanner;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onOpenStats;
  final Future<void> Function() onOpenNotifications;
  final Future<void> Function() onOpenFriends;
  final Future<void> Function() onOpenMemos;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenTeamWorkspace;
  final Future<void> Function() onStartFocus;
  final Future<void> Function() onFinishFocus;
  final Future<void> Function() onSubmitCheckIn;
  final Future<void> Function() onEditTodayPlan;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final Future<bool> Function(int teammateUserId) onRemindTeammate;

  List<MapEntry<int, TodayPlanItem>> _sortedPlanEntries() {
    final entries = todayPlan.items.asMap().entries.toList();
    entries.sort((left, right) {
      final leftItem = left.value;
      final rightItem = right.value;
      if (leftItem.hasSchedule && rightItem.hasSchedule) {
        final startCompare =
            (leftItem.startSlot ?? 999).compareTo(rightItem.startSlot ?? 999);
        if (startCompare != 0) {
          return startCompare;
        }
      }
      if (leftItem.hasSchedule != rightItem.hasSchedule) {
        return leftItem.hasSchedule ? -1 : 1;
      }
      return leftItem.sortOrder.compareTo(rightItem.sortOrder);
    });
    return entries;
  }

  List<TeamMember> _teammatePreview() {
    return teamOverview.members
        .where((member) => member.userId != profile.userId)
        .take(2)
        .toList();
  }

  Color _accentColor() {
    switch (settingOverview.appearanceSetting.desktopEffect) {
      case 'soft_glass':
        return AppColors.mint;
      case 'focus_glow':
        return const Color(0xFFFFD66B);
      default:
        return AppColors.glow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final widgetSetting = settingOverview.widgetSetting;
    final appearance = settingOverview.appearanceSetting;
    final accentColor = _accentColor();
    final latestNotification =
        notificationOverview.hasItems ? notificationOverview.items.first : null;
    final latestTeamChat = teamChatOverview.latestMessage;
    final previewPlanItems = _sortedPlanEntries().take(4).toList();
    final teammatePreview = _teammatePreview();
    final focusTotalSeconds =
        focusSession.elapsedSeconds + focusSession.remainingSeconds;
    final focusProgress = focusTotalSeconds <= 0
        ? 0.0
        : (focusSession.elapsedSeconds / focusTotalSeconds).clamp(0.0, 1.0);
    final planProgress = checkInStatus.todayPlanTotalCount <= 0
        ? 0.0
        : (checkInStatus.todayPlanCompletedCount /
                checkInStatus.todayPlanTotalCount)
            .clamp(0.0, 1.0);
    final statusBadge = checkInStatus.checkedInToday
        ? _contextText(context, '已签到', 'Checked')
        : checkInStatus.canCheckInToday
            ? _contextText(context, '可签到', 'Ready')
            : _contextText(context, '待完成', 'Pending');
    final headerMessage = latestNotification == null
        ? _contextText(
            context,
            '手机与 Windows 桌面端会在这里保持同步，下一步操作也会集中展示。',
            'Phone and Windows desktop stay in sync here, with your next actions kept in view.',
          )
        : '${_notificationTypeLabel(context, latestNotification)}: ${latestNotification.content}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        transparentOnWindows: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  GlassPanel(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor.withValues(alpha: 0.85),
                                    Colors.white.withValues(alpha: 0.22),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _profileInitial(
                                  _profileDisplayName(context, profile),
                                ),
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.night,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Innocence',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: SurfacePalette.muted,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profileDisplayName(context, profile),
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: SurfacePalette.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _contextText(
                                      context,
                                      'Windows 挂件 · ${_desktopEffectLabel(context, appearance)}',
                                      'Windows widget · ${_desktopEffectLabel(context, appearance)}',
                                    ),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: SurfacePalette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip:
                                      _contextText(context, '刷新', 'Refresh'),
                                  onPressed: isBusy
                                      ? null
                                      : () async {
                                          await onRefresh();
                                        },
                                  icon: isBusy
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.refresh_rounded),
                                ),
                                IconButton(
                                  tooltip:
                                      _contextText(context, '设置', 'Settings'),
                                  onPressed: () async {
                                    await onOpenSettings();
                                  },
                                  icon: const Icon(Icons.tune_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _DesktopMetricChip(
                              label: _contextText(context, '连续', 'Streak'),
                              value: _contextText(
                                context,
                                '${checkInStatus.consecutiveDays} 天',
                                '${checkInStatus.consecutiveDays} d',
                              ),
                              accentColor: accentColor,
                            ),
                            _DesktopMetricChip(
                              label: _contextText(context, '学习', 'Study'),
                              value: _formatMinutesLocalized(
                                context,
                                profile.studyDurationTotal,
                              ),
                              accentColor: AppColors.mint,
                            ),
                            _DesktopMetricChip(
                              label: _contextText(context, '未读', 'Unread'),
                              value: '${notificationOverview.unreadCount}',
                              accentColor: const Color(0xFFFFD66B),
                            ),
                            _DesktopMetricChip(
                              label: _contextText(context, '番茄', 'Pomodoro'),
                              value: '${statsOverview.totalPomodoroCompleted}',
                              accentColor: const Color(0xFFFF8C72),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          headerMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _DesktopActionTile(
                              icon: Icons.notifications_active_rounded,
                              label: _contextText(context, '通知', 'Notice'),
                              badge: notificationOverview.unreadCount > 0
                                  ? '${notificationOverview.unreadCount}'
                                  : null,
                              onTap: () async {
                                await onOpenNotifications();
                              },
                            ),
                            _DesktopActionTile(
                              icon: Icons.query_stats_rounded,
                              label: _contextText(context, '统计', 'Stats'),
                              onTap: () async {
                                await onOpenStats();
                              },
                            ),
                            _DesktopActionTile(
                              icon: Icons.sticky_note_2_rounded,
                              label: _contextText(context, '备忘录', 'Memo'),
                              badge: memoOverview.totalCount > 0
                                  ? '${memoOverview.totalCount}'
                                  : null,
                              onTap: () async {
                                await onOpenMemos();
                              },
                            ),
                            _DesktopActionTile(
                              icon: Icons.people_alt_rounded,
                              label: _contextText(context, '好友', 'Friends'),
                              badge: friendOverview.incomingRequests.isNotEmpty
                                  ? '${friendOverview.incomingRequests.length}'
                                  : null,
                              onTap: () async {
                                await onOpenFriends();
                              },
                            ),
                            _DesktopActionTile(
                              icon: Icons.groups_2_rounded,
                              label: _contextText(context, '团队', 'Team'),
                              badge: teamOverview.hasUnreadChat
                                  ? '${teamOverview.unreadChatCount}'
                                  : null,
                              onTap: () async {
                                await onOpenTeamWorkspace();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (bannerMessage != null) ...[
                    const SizedBox(height: 14),
                    StatusBanner(
                      message: bannerMessage!,
                      onClose: onClearBanner,
                    ),
                  ],
                  if (widgetSetting.showTimer) ...[
                    const SizedBox(height: 14),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DesktopSectionHeader(
                            title: _contextText(context, '当前专注', 'Focus now'),
                            subtitle: focusSession.active
                                ? focusSession.taskName.isEmpty
                                    ? _contextText(
                                        context,
                                        '当前专注正在设备间同步进行。',
                                        'A focus session is running across your devices.',
                                      )
                                    : focusSession.taskName
                                : _contextText(
                                    context,
                                    '设定结束时间后，随时开始学习。',
                                    'Set an end time and start learning when you are ready.',
                                  ),
                            trailing: _Tag(
                              label: focusSession.active
                                  ? _focusStageLabel(
                                      context,
                                      focusSession.stageName,
                                      focusSession.active,
                                    )
                                  : _contextText(context, '空闲', 'Idle'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            focusSession.active
                                ? focusSession.remainingLabel
                                : _contextText(
                                    context,
                                    '暂无进行中的专注',
                                    'No active session',
                                  ),
                            style: textTheme.displaySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              height: 0.95,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            focusSession.active
                                ? _contextText(
                                    context,
                                    '结束于 ${focusSession.endTimeLabel} · 已进行 ${focusSession.elapsedLabel}',
                                    'Ends at ${focusSession.endTimeLabel} · Elapsed ${focusSession.elapsedLabel}',
                                  )
                                : _contextText(
                                    context,
                                    '从桌面挂件直接开始，并把计时器固定在眼前。',
                                    'Start from the desktop widget and keep the timer pinned on screen.',
                                  ),
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: focusProgress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.06),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accentColor),
                            ),
                          ),
                          if (focusSession.active) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _Tag(
                                  label: _contextText(
                                    context,
                                    '计划 ${_focusPlannedDurationLabel(context, focusSession)}',
                                    'Planned ${focusSession.plannedDurationLabel}',
                                  ),
                                ),
                                if (focusSession.bindPomodoro)
                                  _Tag(
                                    label: _contextText(
                                      context,
                                      '循环 ${focusSession.currentCycleNo} · 当前阶段剩余 ${focusSession.stageRemainingLabel}',
                                      'Cycle ${focusSession.currentCycleNo} · ${focusSession.stageRemainingLabel}',
                                    ),
                                  ),
                                if (focusSession.bindPomodoro)
                                  _Tag(
                                    label: _contextText(
                                      context,
                                      '已完成 ${focusSession.completedPomodoroCount} 次',
                                      '${focusSession.completedPomodoroCount} done',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: isBusy
                                      ? null
                                      : focusSession.active
                                          ? () async {
                                              await onFinishFocus();
                                            }
                                          : () async {
                                              await onStartFocus();
                                            },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: AppColors.night,
                                  ),
                                  icon: Icon(
                                    focusSession.active
                                        ? Icons.stop_circle_rounded
                                        : Icons.play_circle_fill_rounded,
                                  ),
                                  label: Text(
                                    focusSession.active
                                        ? _contextText(
                                            context,
                                            '结束专注',
                                            'Finish focus',
                                          )
                                        : _contextText(
                                            context,
                                            '开始专注',
                                            'Start focus',
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await onOpenStats();
                                },
                                icon: const Icon(Icons.query_stats_rounded),
                                label:
                                    Text(_contextText(context, '统计', 'Stats')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DesktopSectionHeader(
                          title: _contextText(
                              context, '签到与坚持', 'Check-in & streak'),
                          subtitle: _checkInDescription(context, checkInStatus),
                          trailing: _Tag(label: statusBadge),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DesktopSummaryStat(
                                label: _contextText(
                                  context,
                                  '连续',
                                  'Consecutive',
                                ),
                                value: '${checkInStatus.consecutiveDays}',
                                hint: _contextText(context, '天', 'days'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DesktopSummaryStat(
                                label: _contextText(context, '累计', 'Total'),
                                value: '${checkInStatus.totalDays}',
                                hint: _contextText(context, '次签到', 'check-ins'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DesktopSummaryStat(
                                label: _contextText(context, '成功率', 'Success'),
                                value: '${statsOverview.checkInSuccessRate}%',
                                hint: _contextText(context, '比例', 'rate'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: planProgress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.mint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _contextText(
                            context,
                            '今日进度 ${checkInStatus.planProgressLabel} · 累计学习 ${_formatMinutesLocalized(context, checkInStatus.totalStudyDurationMinutes)}',
                            'Today progress ${checkInStatus.planProgressLabel} · ${_formatMinutesLocalized(context, checkInStatus.totalStudyDurationMinutes)} total study',
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (checkInStatus.hasFailureHint) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x22FF8C72),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x55FF8C72),
                              ),
                            ),
                            child: Text(
                              _checkInFailureSummary(context, checkInStatus),
                              style: textTheme.bodyMedium?.copyWith(
                                color: SurfacePalette.dangerInk,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    isBusy || !checkInStatus.canCheckInToday
                                        ? null
                                        : () async {
                                            await onSubmitCheckIn();
                                          },
                                icon: const Icon(Icons.task_alt_rounded),
                                label: Text(
                                  _checkInActionLabel(context, checkInStatus),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await onOpenStats();
                              },
                              icon: const Icon(Icons.insights_rounded),
                              label:
                                  Text(_contextText(context, '趋势', 'Trends')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widgetSetting.showPlan) ...[
                    const SizedBox(height: 14),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DesktopSectionHeader(
                            title: _todayPlanDisplayName(context, todayPlan),
                            subtitle: todayPlan.hasItems
                                ? _contextText(
                                    context,
                                    '${todayPlan.completedCount}/${todayPlan.totalCount} 完成 · 计划 ${_todayPlanDurationLabel(context, todayPlan.totalPlannedMinutes)}',
                                    '${todayPlan.completedCount}/${todayPlan.totalCount} finished · Planned ${todayPlan.plannedDurationLabel}',
                                  )
                                : _contextText(
                                    context,
                                    '还没有任务，先添加今天的短计划并在这里勾选完成。',
                                    'No tasks yet. Add a short plan and tick items from this widget.',
                                  ),
                            trailing: _Tag(
                              label: _contextText(
                                context,
                                '今日计划',
                                'Today plan',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: todayPlan.completionRatio.clamp(0.0, 1.0),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.06),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFD66B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _contextText(
                                    context,
                                    '已完成时长 ${_todayPlanDurationLabel(context, todayPlan.completedPlannedMinutes)}',
                                    'Completed ${_todayPlanDurationLabel(context, todayPlan.completedPlannedMinutes)}',
                                  ),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await onEditTodayPlan();
                                },
                                icon: const Icon(Icons.edit_calendar_rounded),
                                label:
                                    Text(_contextText(context, '编辑', 'Edit')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (previewPlanItems.isEmpty)
                            _DesktopHintCard(
                              icon: Icons.view_timeline_rounded,
                              text: _contextText(
                                context,
                                '短计划支持半小时排程、日模板保存和清单勾选完成。',
                                'Short plans support half-hour scheduling, saved daily templates, and completion ticks.',
                              ),
                            )
                          else
                            ...previewPlanItems.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DesktopPlanItemTile(
                                  item: entry.value,
                                  accentColor: const Color(0xFFFFD66B),
                                  onToggle: isBusy
                                      ? null
                                      : () async {
                                          await onToggleTodayPlanItem(
                                            entry.key,
                                            !entry.value.completed,
                                          );
                                        },
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                  if (widgetSetting.showMemo) ...[
                    const SizedBox(height: 14),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DesktopSectionHeader(
                            title:
                                _contextText(context, '备忘录预览', 'Memo preview'),
                            subtitle: memoOverview.hasItems
                                ? _contextText(
                                    context,
                                    '${memoOverview.totalCount} 条备忘录会在手机和电脑间同步。',
                                    '${memoOverview.totalCount} memo cards stay shared between phone and desktop.',
                                  )
                                : _contextText(
                                    context,
                                    '保存一条文字或清单备忘录，让它常驻在这里。',
                                    'Save a quick text or checklist memo and keep it floating here.',
                                  ),
                            trailing: _Tag(
                              label: _contextText(context, '备忘录', 'Memo'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!memoOverview.hasItems)
                            _DesktopHintCard(
                              icon: Icons.note_alt_rounded,
                              text: _contextText(
                                context,
                                '当前简版备忘录支持文字卡片和清单卡片，删除后不会进入回收站。',
                                'Memo center currently supports text cards and checklist cards, with direct delete and no recycle bin.',
                              ),
                            )
                          else
                            ...memoOverview.items.take(2).map((memo) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DesktopMemoTile(memo: memo),
                              );
                            }),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await onOpenMemos();
                              },
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(
                                _contextText(
                                    context, '打开备忘录中心', 'Open memo center'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DesktopSectionHeader(
                          title: teamOverview.inTeam
                              ? teamOverview.teamName
                              : _contextText(context, '可信团队', 'Trusted team'),
                          subtitle: teamOverview.inTeam
                              ? _contextText(
                                  context,
                                  '${teamOverview.memberCount}/${teamOverview.memberLimit} 人 · ${teamOverview.unreadChatCount} 条未读动态',
                                  '${teamOverview.memberCount}/${teamOverview.memberLimit} members · ${teamOverview.unreadChatCount} unread updates',
                                )
                              : _contextText(
                                  context,
                                  '一个用户只能加入一个团队。团队用于提醒、进度查看和小范围群聊。',
                                  'One user can join one team. Teams keep reminders, progress, and group chat in a small trusted circle.',
                                ),
                          trailing: _Tag(
                            label: teamOverview.inTeam
                                ? _contextText(context, '已加入', 'In team')
                                : _contextText(context, '未加入', 'Not joined'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (teamOverview.inTeam &&
                            (latestTeamChat != null ||
                                teamOverview.latestChatPreview.isNotEmpty))
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              latestTeamChat != null
                                  ? '${latestTeamChat.senderDisplayName}: ${latestTeamChat.content}'
                                  : teamOverview.latestChatPreview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        if (teamOverview.inTeam &&
                            (latestTeamChat != null ||
                                teamOverview.latestChatPreview.isNotEmpty))
                          const SizedBox(height: 12),
                        if (!teamOverview.inTeam)
                          _DesktopHintCard(
                            icon: Icons.groups_rounded,
                            text: _contextText(
                              context,
                              '创建团队或通过邀请码加入后，就可以在这里查看队友计划进度并发送提醒。',
                              'Create a team or join through an invite code, then watch teammate plan progress and send reminder nudges here.',
                            ),
                          )
                        else if (teammatePreview.isEmpty)
                          _DesktopHintCard(
                            icon: Icons.person_add_alt_1_rounded,
                            text: _contextText(
                              context,
                              '团队已经建立，可以继续邀请更多成员共享计划进度和学习时长。',
                              'Your team is ready. Invite more members to share plan progress and learning time.',
                            ),
                          )
                        else
                          ...teammatePreview.map((member) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _DesktopTeammateTile(
                                member: member,
                                onRemind: isBusy
                                    ? null
                                    : () async {
                                        await onRemindTeammate(member.userId);
                                      },
                              ),
                            );
                          }),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await onOpenTeamWorkspace();
                            },
                            icon: const Icon(Icons.forum_rounded),
                            label: Text(
                              teamOverview.inTeam
                                  ? _contextText(
                                      context,
                                      '打开团队中心',
                                      'Open team center',
                                    )
                                  : _contextText(
                                      context,
                                      '创建或加入',
                                      'Create or join',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopMetricChip extends StatelessWidget {
  const _DesktopMetricChip({
    required this.label,
    required this.value,
    required this.accentColor,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: SurfacePalette.subtle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: (compact ? textTheme.titleSmall : textTheme.titleMedium)
                ?.copyWith(
              color: SurfacePalette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopActionTile extends StatelessWidget {
  const _DesktopActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(compact ? 20 : 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        onTap: onTap,
        child: SizedBox(
          width: compact ? 72 : 84,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 10 : 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BadgeIcon(
                  icon: icon,
                  badgeText: badge,
                  iconSize: compact ? 20 : 22,
                  boxSize: compact ? 32 : 34,
                ),
                SizedBox(height: compact ? 8 : 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? textTheme.bodySmall : textTheme.bodyMedium)
                      ?.copyWith(
                    color: SurfacePalette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSectionHeader extends StatelessWidget {
  const _DesktopSectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _DesktopSummaryStat extends StatelessWidget {
  const _DesktopSummaryStat({
    required this.label,
    required this.value,
    required this.hint,
    this.compact = false,
  });

  final String label;
  final String value;
  final String hint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: SurfacePalette.subtle,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            value,
            style: (compact ? textTheme.titleLarge : textTheme.headlineSmall)
                ?.copyWith(
              color: SurfacePalette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: textTheme.bodySmall?.copyWith(
              color: SurfacePalette.subtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHintCard extends StatelessWidget {
  const _DesktopHintCard({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SurfacePalette.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.ink,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopPlanItemTile extends StatelessWidget {
  const _DesktopPlanItemTile({
    required this.item,
    required this.accentColor,
    this.onToggle,
  });

  final TodayPlanItem item;
  final Color accentColor;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: SurfacePalette.softSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: item.completed,
                activeColor: accentColor,
                onChanged: onToggle == null ? null : (_) => onToggle!(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty
                          ? _contextText(context, '未命名任务', 'Unnamed task')
                          : item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: SurfacePalette.ink,
                        fontWeight: FontWeight.w600,
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_todayPlanItemScheduleLabel(context, item)} · ${_todayPlanItemDurationLabel(context, item)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: SurfacePalette.subtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopMemoTile extends StatelessWidget {
  const _DesktopMemoTile({
    required this.memo,
  });

  final MemoCardModel memo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                memo.displayTitle,
                style: textTheme.titleMedium?.copyWith(
                  color: SurfacePalette.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _Tag(label: memo.progressLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            memo.summaryText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.ink,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTeammateTile extends StatelessWidget {
  const _DesktopTeammateTile({
    required this.member,
    this.onRemind,
  });

  final TeamMember member;
  final VoidCallback? onRemind;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _teamMemberDisplayName(context, member),
                      style: textTheme.titleMedium?.copyWith(
                        color: SurfacePalette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.activeStudy)
                      _Tag(label: _teamMemberStageLabel(context, member)),
                    if (member.owner)
                      _Tag(label: _contextText(context, '队长', 'Captain')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _contextText(
                    context,
                    '今日 ${member.todayPlanProgressLabel} · ${_teamMemberTodayStudyLabel(context, member)}',
                    'Today ${member.todayPlanProgressLabel} · ${_teamMemberTodayStudyLabel(context, member)}',
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _contextText(
                    context,
                    '累计 ${_teamMemberTotalStudyLabel(context, member)} · ${member.totalCheckInDays} 次签到',
                    'Total ${_teamMemberTotalStudyLabel(context, member)} · ${member.totalCheckInDays} check-ins',
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: SurfacePalette.subtle,
                  ),
                ),
                if (member.activeTaskName.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.activeTaskName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: SurfacePalette.subtle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRemind,
            icon: const Icon(Icons.notifications_active_rounded),
            label: Text(_contextText(context, '提醒', 'Remind')),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = profile.displayName.isEmpty
        ? _contextText(context, '欢迎回来', 'Welcome back')
        : _contextText(
            context,
            '欢迎回来，${profile.displayName}',
            'Welcome back, ${profile.displayName}',
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayName, style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          _contextText(
            context,
            '首页已经支持今日时间轴排程、清单勾选完成，以及真实账户资料展示。',
            'The home view now supports today timeline scheduling, checklist completion, and real profile data.',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(
              label: _contextText(
                context,
                '用户号 ${profile.userNo.isEmpty ? '待生成' : profile.userNo}',
                'User No ${profile.userNo.isEmpty ? 'pending' : profile.userNo}',
              ),
            ),
            _Tag(
              label: _contextText(
                context,
                '时区 ${profile.timezone.isEmpty ? 'Asia/Shanghai' : profile.timezone}',
                'Timezone ${profile.timezone.isEmpty ? 'Asia/Shanghai' : profile.timezone}',
              ),
            ),
            _Tag(
                label: _contextText(
                    context, '资料仅好友可见', 'Profile visible to friends')),
            _Tag(
                label: _contextText(
                    context, '学习数据仅队友可见', 'Study data visible to teammates')),
          ],
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SurfacePalette.softSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SurfacePalette.border),
            ),
            child: Text(profile.bio, style: textTheme.bodyMedium),
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.hint,
  });

  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            color: SurfacePalette.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(hint, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _FocusSessionCard extends StatelessWidget {
  const _FocusSessionCard({
    required this.focusSession,
    required this.isBusy,
    required this.onStart,
    required this.onFinish,
  });

  final FocusSession focusSession;
  final bool isBusy;
  final Future<void> Function() onStart;
  final Future<void> Function() onFinish;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        final primaryBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_contextText(context, '当前专注', 'Current focus'),
                style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              focusSession.active
                  ? focusSession.taskName
                  : _contextText(
                      context, '准备开始新的学习专注', 'Ready to start a study session'),
              style: textTheme.headlineSmall?.copyWith(
                color: SurfacePalette.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              focusSession.active
                  ? _contextText(
                      context,
                      '${_focusStageLabel(context, focusSession.stageName, focusSession.active)}中  |  结束于 ${focusSession.endTimeLabel}',
                      '${_focusStageLabel(context, focusSession.stageName, focusSession.active)} now  |  Ends at ${focusSession.endTimeLabel}',
                    )
                  : _contextText(
                      context,
                      '先设定结束时间，可选绑定番茄循环，然后直接从首页开始学习。',
                      'Set an end time, optionally bind a custom pomodoro loop, and start directly from the home page.',
                    ),
              style: textTheme.bodyLarge,
            ),
          ],
        );

        final statsBlock = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FocusStatChip(
              label: _contextText(context, '剩余', 'Remaining'),
              value:
                  focusSession.active ? focusSession.remainingLabel : '--:--',
            ),
            _FocusStatChip(
              label: _contextText(context, '已进行', 'Elapsed'),
              value: focusSession.active ? focusSession.elapsedLabel : '00:00',
            ),
            _FocusStatChip(
              label: _contextText(context, '计划', 'Plan'),
              value: focusSession.active
                  ? _focusPlannedDurationLabel(context, focusSession)
                  : _contextText(context, '自定义', 'Custom'),
            ),
            _FocusStatChip(
              label: _contextText(context, '番茄', 'Pomodoro'),
              value: focusSession.bindPomodoro
                  ? _contextText(
                      context,
                      '${focusSession.pomodoroStudyMinutes}/${focusSession.pomodoroBreakMinutes} 分钟',
                      '${focusSession.pomodoroStudyMinutes}/${focusSession.pomodoroBreakMinutes} min',
                    )
                  : _contextText(context, '关闭', 'Off'),
            ),
          ],
        );

        final actionBlock = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: isBusy || focusSession.active
                  ? null
                  : () async {
                      await onStart();
                    },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_contextText(context, '开始专注', 'Start focus')),
            ),
            OutlinedButton.icon(
              onPressed: isBusy || !focusSession.active
                  ? null
                  : () async {
                      await onFinish();
                    },
              icon: const Icon(Icons.stop_rounded),
              label: Text(_contextText(context, '立即结束', 'Finish now')),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              primaryBlock,
              const SizedBox(height: 16),
              statsBlock,
              if (focusSession.active && focusSession.bindPomodoro) ...[
                const SizedBox(height: 12),
                Text(
                  _contextText(
                    context,
                    '循环 ${focusSession.currentCycleNo}  |  当前阶段剩余 ${focusSession.stageRemainingLabel}  |  已完成 ${focusSession.completedPomodoroCount} 次番茄',
                    'Cycle ${focusSession.currentCycleNo}  |  Stage left ${focusSession.stageRemainingLabel}  |  Finished pomodoros ${focusSession.completedPomodoroCount}',
                  ),
                  style: textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              actionBlock,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  primaryBlock,
                  const SizedBox(height: 16),
                  statsBlock,
                  if (focusSession.active && focusSession.bindPomodoro) ...[
                    const SizedBox(height: 12),
                    Text(
                      _contextText(
                        context,
                        '循环 ${focusSession.currentCycleNo}  |  当前阶段剩余 ${focusSession.stageRemainingLabel}  |  已完成 ${focusSession.completedPomodoroCount} 次番茄',
                        'Cycle ${focusSession.currentCycleNo}  |  Stage left ${focusSession.stageRemainingLabel}  |  Finished pomodoros ${focusSession.completedPomodoroCount}',
                      ),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: actionBlock,
            ),
          ],
        );
      },
    );
  }
}

class _FocusStatChip extends StatelessWidget {
  const _FocusStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: SurfacePalette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.checkInStatus,
    required this.isBusy,
    required this.onSubmit,
  });

  final CheckInStatus checkInStatus;
  final bool isBusy;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        final primaryBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_contextText(context, '今日签到', 'Today check-in'),
                style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              _checkInHeadline(context, checkInStatus),
              style: textTheme.headlineSmall?.copyWith(
                color: SurfacePalette.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _checkInDescription(context, checkInStatus),
              style: textTheme.bodyLarge,
            ),
            if (checkInStatus.hasFailureHint) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SurfacePalette.dangerSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SurfacePalette.dangerBorder),
                ),
                child: Text(
                  _checkInFailureSummary(context, checkInStatus),
                  style: textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.dangerInk,
                  ),
                ),
              ),
            ],
          ],
        );

        final statsBlock = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FocusStatChip(
              label: _contextText(context, '连续', 'Streak'),
              value: _contextText(context, '${checkInStatus.consecutiveDays} 天',
                  '${checkInStatus.consecutiveDays} d'),
            ),
            _FocusStatChip(
              label: _contextText(context, '累计', 'Total'),
              value: _contextText(context, '${checkInStatus.totalDays} 天',
                  '${checkInStatus.totalDays} d'),
            ),
            _FocusStatChip(
              label: _contextText(context, '计划', 'Plan'),
              value: checkInStatus.planProgressLabel,
            ),
            _FocusStatChip(
              label: _contextText(context, '累计学习', 'Study total'),
              value: _formatMinutesLocalized(
                context,
                checkInStatus.totalStudyDurationMinutes,
              ),
            ),
          ],
        );

        final actionBlock = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: isBusy || checkInStatus.checkedInToday
                  ? null
                  : () async {
                      await onSubmit();
                    },
              icon: Icon(
                checkInStatus.checkedInToday
                    ? Icons.verified_rounded
                    : Icons.how_to_reg_rounded,
              ),
              label: Text(_checkInActionLabel(context, checkInStatus)),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              primaryBlock,
              const SizedBox(height: 16),
              statsBlock,
              const SizedBox(height: 16),
              actionBlock,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  primaryBlock,
                  const SizedBox(height: 16),
                  statsBlock,
                ],
              ),
            ),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: actionBlock,
            ),
          ],
        );
      },
    );
  }
}

enum _TrendMetric {
  study,
  checkIn,
  completion,
  failure,
}

class _TrendSummaryCard extends StatefulWidget {
  const _TrendSummaryCard({
    required this.statsOverview,
    required this.isBusy,
    required this.onRangeChanged,
    required this.onOpenDetails,
  });

  final StatsOverview statsOverview;
  final bool isBusy;
  final Future<StatsOverview?> Function(int days) onRangeChanged;
  final Future<void> Function() onOpenDetails;

  @override
  State<_TrendSummaryCard> createState() => _TrendSummaryCardState();
}

class _TrendSummaryCardState extends State<_TrendSummaryCard> {
  _TrendMetric _metric = _TrendMetric.study;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final points = widget.statsOverview.trend;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await widget.onOpenDetails();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_contextText(context, '趋势概览', 'Trend summary'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _contextText(
                      context,
                      '支持在近 7 天和近 30 天之间切换，并复用同一张趋势图作为统计中心入口。',
                      'Switch between the last 7 days and 30 days, and reuse the same chart source for the future statistics center.',
                    ),
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      await widget.onOpenDetails();
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(_contextText(
                        context, '打开统计中心', 'Open statistics center')),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(_contextText(context, '近 7 天', '7 days')),
                    selected: widget.statsOverview.rangeDays == 7,
                    onSelected: widget.isBusy
                        ? null
                        : (_) async {
                            await widget.onRangeChanged(7);
                          },
                  ),
                  ChoiceChip(
                    label: Text(_contextText(context, '近 30 天', '30 days')),
                    selected: widget.statsOverview.rangeDays == 30,
                    onSelected: widget.isBusy
                        ? null
                        : (_) async {
                            await widget.onRangeChanged(30);
                          },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricSelectorChip(
                label: _contextText(context, '学习', 'Study'),
                selected: _metric == _TrendMetric.study,
                onSelected: () {
                  setState(() {
                    _metric = _TrendMetric.study;
                  });
                },
              ),
              _MetricSelectorChip(
                label: _contextText(context, '签到', 'Check-in'),
                selected: _metric == _TrendMetric.checkIn,
                onSelected: () {
                  setState(() {
                    _metric = _TrendMetric.checkIn;
                  });
                },
              ),
              _MetricSelectorChip(
                label: _contextText(context, '完成率', 'Completion'),
                selected: _metric == _TrendMetric.completion,
                onSelected: () {
                  setState(() {
                    _metric = _TrendMetric.completion;
                  });
                },
              ),
              _MetricSelectorChip(
                label: _contextText(context, '失败', 'Failure'),
                selected: _metric == _TrendMetric.failure,
                onSelected: () {
                  setState(() {
                    _metric = _TrendMetric.failure;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TrendGraph(
            points: points,
            metric: _metric,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FocusStatChip(
                label: _contextText(context, '学习总时长', 'Study total'),
                value: _formatMinutesLocalized(
                  context,
                  widget.statsOverview.totalStudyDurationMinutes,
                ),
              ),
              _FocusStatChip(
                label: _contextText(context, '番茄次数', 'Pomodoros'),
                value: '${widget.statsOverview.totalPomodoroCompleted}',
              ),
              _FocusStatChip(
                label: _contextText(context, '计划完成率', 'Plan rate'),
                value: '${widget.statsOverview.planCompletionRate}%',
              ),
              _FocusStatChip(
                label: _contextText(context, '签到成功率', 'Check-in rate'),
                value: '${widget.statsOverview.checkInSuccessRate}%',
              ),
              _FocusStatChip(
                label: _contextText(context, '失败次数', 'Failures'),
                value: '${widget.statsOverview.totalFailedCheckInAttempts}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricSelectorChip extends StatelessWidget {
  const _MetricSelectorChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _TrendGraph extends StatelessWidget {
  const _TrendGraph({
    required this.points,
    required this.metric,
  });

  final List<StatsTrendPoint> points;
  final _TrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final bars = points.isEmpty
        ? <_TrendBarData>[]
        : points
            .map(
              (point) => _TrendBarData(
                label: point.label,
                value: _valueOf(point),
                tooltip: _tooltipOf(context, point),
              ),
            )
            .toList();

    final maxValue = bars.fold<int>(
      0,
      (current, bar) => bar.value > current ? bar.value : current,
    );
    final safeMaxValue = maxValue <= 0 ? 1 : maxValue;

    if (bars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SurfacePalette.softSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: SurfacePalette.border),
        ),
        child: Text(
          _contextText(
            context,
            '还没有趋势数据。开始使用计划、专注和签到后，这里会逐步生成图表。',
            'No trend data yet. Start using plans, focus sessions, and check-in to build your chart.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((bar) {
          final ratio = bar.value / safeMaxValue;
          final color = _colorOf(metric);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    bar.tooltip,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 28 + (150 * ratio),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color.withValues(alpha: 0.92),
                              color.withValues(alpha: 0.42),
                            ],
                          ),
                          border: Border.all(
                            color: SurfacePalette.border,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bar.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _valueOf(StatsTrendPoint point) {
    return switch (metric) {
      _TrendMetric.study => point.studyDurationMinutes,
      _TrendMetric.checkIn => point.checkInSuccessCount,
      _TrendMetric.completion => point.planCompletionRate,
      _TrendMetric.failure => point.failedCheckInAttempts,
    };
  }

  String _tooltipOf(BuildContext context, StatsTrendPoint point) {
    return switch (metric) {
      _TrendMetric.study => _contextText(
          context,
          '${point.studyDurationMinutes} 分钟',
          '${point.studyDurationMinutes} min',
        ),
      _TrendMetric.checkIn => _contextText(
          context,
          '${point.checkInSuccessCount} 次成功',
          '${point.checkInSuccessCount} success',
        ),
      _TrendMetric.completion => '${point.planCompletionRate}%',
      _TrendMetric.failure => _contextText(
          context,
          '${point.failedCheckInAttempts} 次失败',
          '${point.failedCheckInAttempts} fails',
        ),
    };
  }

  Color _colorOf(_TrendMetric metric) {
    return switch (metric) {
      _TrendMetric.study => AppColors.glow,
      _TrendMetric.checkIn => AppColors.mint,
      _TrendMetric.completion => const Color(0xFFFFD66B),
      _TrendMetric.failure => const Color(0xFFFFA17A),
    };
  }
}

class _TrendBarData {
  const _TrendBarData({
    required this.label,
    required this.value,
    required this.tooltip,
  });

  final String label;
  final int value;
  final String tooltip;
}

class _TeamPanel extends StatefulWidget {
  const _TeamPanel({
    required this.profile,
    required this.teamOverview,
    required this.friendOverview,
    required this.teamChatOverview,
    required this.initialBannerMessage,
    required this.isBusy,
    required this.onCreateTeam,
    required this.onJoinTeam,
    required this.onInviteMember,
    required this.onRemoveMember,
    required this.onDissolveTeam,
    required this.onLoadTeamChatMessages,
    required this.onSendTeamChatMessage,
    required this.onMarkTeamChatRead,
    required this.onReportTeamChatMessage,
    required this.onRefreshWorkspace,
  });

  final UserProfile profile;
  final TeamOverview teamOverview;
  final FriendOverview friendOverview;
  final TeamChatOverview teamChatOverview;
  final String? initialBannerMessage;
  final bool isBusy;
  final Future<void> Function(String teamName) onCreateTeam;
  final Future<void> Function(String inviteCode) onJoinTeam;
  final Future<void> Function(int targetUserId) onInviteMember;
  final Future<bool> Function(int memberUserId) onRemoveMember;
  final Future<bool> Function() onDissolveTeam;
  final Future<TeamChatOverview?> Function({int limit}) onLoadTeamChatMessages;
  final Future<TeamChatOverview?> Function(String content)
      onSendTeamChatMessage;
  final Future<TeamChatOverview?> Function() onMarkTeamChatRead;
  final Future<bool> Function(
    int messageId, {
    required String reason,
    String description,
  }) onReportTeamChatMessage;
  final Future<TeamWorkspaceSnapshot?> Function() onRefreshWorkspace;

  @override
  State<_TeamPanel> createState() => _TeamPanelState();
}

class _TeamPanelState extends State<_TeamPanel> {
  late TeamOverview _teamOverview;
  late FriendOverview _friendOverview;
  late TeamChatOverview _teamChatOverview;
  String? _bannerMessage;
  bool _bannerDismissed = false;

  String _text(BuildContext context, String zh, String en) {
    return _contextText(context, zh, en);
  }

  bool get _isBusy => widget.isBusy;

  @override
  void initState() {
    super.initState();
    _teamOverview = widget.teamOverview;
    _friendOverview = widget.friendOverview;
    _teamChatOverview = widget.teamChatOverview;
    _bannerMessage = widget.initialBannerMessage;
  }

  @override
  void didUpdateWidget(covariant _TeamPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamOverview != widget.teamOverview) {
      _teamOverview = widget.teamOverview;
    }
    if (oldWidget.friendOverview != widget.friendOverview) {
      _friendOverview = widget.friendOverview;
    }
    if (oldWidget.teamChatOverview != widget.teamChatOverview) {
      _teamChatOverview = widget.teamChatOverview;
    }
    if (oldWidget.initialBannerMessage != widget.initialBannerMessage &&
        !_bannerDismissed) {
      _bannerMessage = widget.initialBannerMessage;
    }
  }

  Future<void> _refreshWorkspaceState() async {
    final snapshot = await widget.onRefreshWorkspace();
    if (!mounted || snapshot == null) {
      return;
    }
    setState(() {
      _teamOverview = snapshot.teamOverview;
      _friendOverview = snapshot.friendOverview;
      _teamChatOverview = snapshot.teamChatOverview;
      _bannerMessage = snapshot.bannerMessage;
      _bannerDismissed = false;
    });
  }

  void _dismissBanner() {
    setState(() {
      _bannerDismissed = true;
    });
  }

  Future<void> _openCreateTeamDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '创建团队', 'Create team')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _text(context, '团队名称', 'Team name'),
              hintText:
                  _text(context, '例如：夜间自习室', 'For example: Night study room'),
            ),
            autofocus: true,
            maxLength: 64,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(_text(context, '创建', 'Create')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }
    await widget.onCreateTeam(result.trim());
    await _refreshWorkspaceState();
  }

  Future<void> _openJoinTeamDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '加入团队', 'Join team')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _text(context, '邀请码', 'Invite code'),
              hintText: _text(context, '请输入邀请码', 'Enter the invite code'),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(_text(context, '加入', 'Join')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }
    await widget.onJoinTeam(result.trim());
    await _refreshWorkspaceState();
  }

  Future<void> _openInviteMemberDialog(BuildContext context) async {
    final teamMemberIds =
        _teamOverview.members.map((member) => member.userId).toSet();
    final candidates = _friendOverview.friends
        .where((friend) => !teamMemberIds.contains(friend.userId))
        .toList()
      ..sort((left, right) => left.displayName.compareTo(right.displayName));

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(context, '当前没有可邀请进团队的好友。',
                'No available friends to invite right now.'),
          ),
        ),
      );
      return;
    }

    final targetUserId = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '邀请好友加入团队', 'Invite friend to team')),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: candidates.map((friend) {
                  return ListTile(
                    title: Text(friend.displayName),
                    subtitle: Text(
                      friend.userNo.isEmpty
                          ? friend.groupName
                          : '${friend.userNo}  |  ${friend.groupName}',
                    ),
                    trailing: friend.sameTeam
                        ? _Tag(label: _text(context, '同团队', 'Same team'))
                        : null,
                    onTap: () => Navigator.of(context).pop(friend.userId),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
          ],
        );
      },
    );

    if (targetUserId == null || targetUserId <= 0) {
      return;
    }
    await widget.onInviteMember(targetUserId);
    await _refreshWorkspaceState();
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    TeamMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '移除成员', 'Remove member')),
          content: Text(
            _text(
              context,
              '确定将 ${member.displayName} 移出团队吗？移除后他的团队关系会被清空。',
              'Remove ${member.displayName} from the team? Their team relation will be cleared.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text(context, '移除', 'Remove')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await widget.onRemoveMember(member.userId);
    await _refreshWorkspaceState();
  }

  Future<void> _confirmDissolveTeam(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '解散团队', 'Dissolve team')),
          content: Text(
            _text(
              context,
              '解散后会清空当前所有团队关系，此操作无法撤销。',
              'Dissolving will clear all current team relations. This action cannot be undone.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C72),
              ),
              child: Text(_text(context, '解散', 'Dissolve')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await widget.onDissolveTeam();
    await _refreshWorkspaceState();
  }

  Future<void> _openTeamChatDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _TeamChatDialog(
          teamOverview: _teamOverview,
          initialOverview: _teamChatOverview,
          onRefresh: widget.onLoadTeamChatMessages,
          onSendMessage: widget.onSendTeamChatMessage,
          onMarkRead: widget.onMarkTeamChatRead,
          onReportMessage: widget.onReportTeamChatMessage,
        );
      },
    );
    await _refreshWorkspaceState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    TeamMember? currentMember;
    for (final member in _teamOverview.members) {
      if (member.userId == widget.profile.userId) {
        currentMember = member;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_bannerMessage != null && !_bannerDismissed) ...[
          StatusBanner(
            message: _bannerMessage!,
            onClose: _dismissBanner,
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_text(context, '可信团队', 'Trusted team'),
                    style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  _teamOverview.inTeam
                      ? '${_teamOverview.teamName}  |  ${_teamOverview.subtitle}'
                      : _text(
                          context,
                          '创建一个熟人圈学习团队，或者通过邀请码加入现有团队。',
                          'Create a mature-circle study team or join one with an invite code.',
                        ),
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            if (!_teamOverview.inTeam)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed:
                        _isBusy ? null : () => _openCreateTeamDialog(context),
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(_text(context, '创建', 'Create')),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        _isBusy ? null : () => _openJoinTeamDialog(context),
                    icon: const Icon(Icons.key_rounded),
                    label: Text(_text(context, '加入', 'Join')),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (!_teamOverview.inTeam) ...[
          _InfoRow(
            icon: Icons.lock_person_rounded,
            text: _text(context, '每个账号只能加入 1 个团队，通过邀请码加入，最多 5 人。',
                'Only one team at a time, invite-code join, up to 5 members'),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.notifications_active_rounded,
            text: _text(context, '团队里可以查看彼此完成进度，也可以发送提醒。',
                'Teammates can be reminded and the team can see completion progress here'),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.blur_on_rounded,
            text: _text(context, '桌面端会保持统一的挂件视觉风格。',
                'Desktop UI keeps the translucent glass-and-glow style'),
          ),
        ] else ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(
                  label: _text(context, '邀请码 ${_teamOverview.inviteCode}',
                      'Invite ${_teamOverview.inviteCode}')),
              _Tag(
                  label: _text(
                      context,
                      '成员 ${_teamOverview.memberCount}/${_teamOverview.memberLimit}',
                      'Members ${_teamOverview.memberCount}/${_teamOverview.memberLimit}')),
              _Tag(
                label: _teamOverview.hasUnreadChat
                    ? _text(context, '群聊 ${_teamOverview.unreadChatCount} 条未读',
                        'Chat ${_teamOverview.unreadChatCount} unread')
                    : _text(context, '群聊已就绪', 'Chat ready'),
              ),
              if (_teamOverview.owner && !_teamOverview.isFull)
                _Tag(label: _text(context, '可邀请好友', 'Can invite friends')),
              if (_teamOverview.owner)
                _Tag(label: _text(context, '你是队长', 'You are captain')),
              if (currentMember != null)
                _Tag(
                  label: currentMember.allowStudyView
                      ? _text(context, '学习数据可见', 'Study view visible')
                      : _text(context, '学习数据隐藏', 'Study view hidden'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SurfacePalette.softSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SurfacePalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_text(context, '团队群聊', 'Team chat'),
                            style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          _teamOverview.latestChatPreview.isNotEmpty
                              ? _teamOverview.latestChatPreview
                              : _text(context, '当前团队仅支持文字群聊。',
                                  'Text-only group chat for your current team.'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: SurfacePalette.ink,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _isBusy
                          ? null
                          : () async {
                              await _openTeamChatDialog(context);
                            },
                      icon: _BadgeIcon(
                        icon: Icons.forum_rounded,
                        badgeText: _teamOverview.hasUnreadChat
                            ? (_teamOverview.unreadChatCount > 99
                                ? '99+'
                                : '${_teamOverview.unreadChatCount}')
                            : null,
                        badgeTextColor: AppColors.night,
                      ),
                      label: Text(_text(context, '打开群聊', 'Open chat')),
                    ),
                    if (_teamOverview.owner && !_teamOverview.isFull)
                      FilledButton.icon(
                        onPressed: _isBusy
                            ? null
                            : () => _openInviteMemberDialog(context),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(_text(context, '邀请好友', 'Invite friend')),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ..._teamOverview.members.map((member) {
            final canRemove = _teamOverview.owner && !member.owner;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TeamMemberTile(
                member: member,
                isBusy: _isBusy,
                canRemove: canRemove,
                onRemove: canRemove
                    ? () => _confirmRemoveMember(context, member)
                    : null,
              ),
            );
          }),
          if (_teamOverview.owner) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : () => _confirmDissolveTeam(context),
              icon: const Icon(Icons.delete_forever_rounded),
              label: Text(_text(context, '解散团队', 'Dissolve team')),
            ),
          ],
        ],
      ],
    );
  }
}

class _TeamChatDialog extends StatefulWidget {
  const _TeamChatDialog({
    required this.teamOverview,
    required this.initialOverview,
    required this.onRefresh,
    required this.onSendMessage,
    required this.onMarkRead,
    required this.onReportMessage,
  });

  final TeamOverview teamOverview;
  final TeamChatOverview initialOverview;
  final Future<TeamChatOverview?> Function({int limit}) onRefresh;
  final Future<TeamChatOverview?> Function(String content) onSendMessage;
  final Future<TeamChatOverview?> Function() onMarkRead;
  final Future<bool> Function(
    int messageId, {
    required String reason,
    String description,
  }) onReportMessage;

  @override
  State<_TeamChatDialog> createState() => _TeamChatDialogState();
}

class _TeamChatDialogState extends State<_TeamChatDialog> {
  late TeamChatOverview _overview;
  late final TextEditingController _messageController;
  bool _isLoading = false;

  String _text(String zh, String en) {
    return _contextText(context, zh, en);
  }

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
    _messageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _runAction(
      () => widget.onRefresh(limit: 50),
      fallbackMessage:
          _text('当前无法刷新团队群聊。', 'Unable to refresh team chat right now.'),
    );
  }

  Future<void> _markRead() async {
    if (_overview.unreadCount <= 0) {
      return;
    }
    await _runAction(
      widget.onMarkRead,
      fallbackMessage:
          _text('当前无法更新已读状态。', 'Unable to update read state right now.'),
      silentFailure: true,
    );
  }

  Future<void> _send() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return;
    }
    final sent = await _runAction(
      () => widget.onSendMessage(content),
      fallbackMessage:
          _text('当前无法发送团队消息。', 'Unable to send the team message right now.'),
    );
    if (sent) {
      _messageController.clear();
    }
  }

  Future<bool> _runAction(
    Future<TeamChatOverview?> Function() action, {
    required String fallbackMessage,
    bool silentFailure = false,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final overview = await action();
      if (!mounted) {
        return false;
      }
      if (overview == null) {
        if (!silentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(fallbackMessage)),
          );
        }
        return false;
      }
      setState(() {
        _overview = overview;
      });
      return true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reportMessage(TeamChatMessage item) async {
    if (item.ownMessage || item.deleted) {
      return;
    }
    final result = await showDialog<_ChatReportDraft>(
      context: context,
      builder: (context) => const _ChatReportDialog(),
    );
    if (result == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final success = await widget.onReportMessage(
        item.messageId,
        reason: result.reason,
        description: result.description,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? _text('举报已提交。', 'Report submitted.')
                : _text('当前无法提交举报。', 'Unable to submit the report right now.'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        lightStyle: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_text('团队群聊', 'Team chat'),
                          style: textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        _text(
                          '${widget.teamOverview.teamName}  |  仅保留最近 30 天',
                          '${widget.teamOverview.teamName}  |  Only the latest 30 days are kept',
                        ),
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Tag(
                        label: _overview.unreadCount > 0
                            ? _text('${_overview.unreadCount} 条未读',
                                '${_overview.unreadCount} unread')
                            : _text('全部已读', 'All read'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _refresh,
                        icon: _isLoading
                            ? const SizedBox.square(
                                dimension: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(_text('刷新', 'Refresh')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(_text('关闭', 'Close')),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _overview.messages.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: SurfacePalette.softSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: SurfacePalette.border,
                          ),
                        ),
                        child: Text(
                          _text(
                            '当前还没有团队消息，发送第一条文字消息来开始群聊吧。',
                            'No team messages yet. Send the first text message to start the group chat.',
                          ),
                          style: textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _overview.messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _overview.messages[index];
                          return _TeamChatBubble(
                            item: item,
                            onReport: item.ownMessage || item.deleted
                                ? null
                                : () async {
                                    await _reportMessage(item);
                                  },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 500,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _text('消息内容', 'Message'),
                        hintText: _text(
                          '当前仅支持文字消息。违规词会被拦截，部分词语可能会被替换遮罩。',
                          'Text only. Blocked words will be refused, some words may be masked.',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_text('发送', 'Send')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamChatBubble extends StatelessWidget {
  const _TeamChatBubble({
    required this.item,
    this.onReport,
  });

  final TeamChatMessage item;
  final Future<void> Function()? onReport;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final align =
        item.ownMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final background = item.ownMessage
        ? AppColors.mint.withValues(alpha: 0.18)
        : SurfacePalette.softSurface;
    final border = item.ownMessage
        ? AppColors.mint.withValues(alpha: 0.32)
        : SurfacePalette.border;

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    item.senderDisplayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SurfacePalette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(item.createTime,
                      style: Theme.of(context).textTheme.bodySmall),
                  if (item.masked) _Tag(label: text('已遮罩', 'Masked')),
                  if (item.deleted) _Tag(label: text('已移除', 'Removed')),
                ],
              ),
            ),
            if (onReport != null)
              PopupMenuButton<String>(
                tooltip: text('更多', 'More'),
                onSelected: (value) async {
                  if (value == 'report') {
                    await onReport!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text(text('举报', 'Report')),
                  ),
                ],
                icon: const Icon(Icons.more_horiz_rounded, size: 18),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Text(
            item.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SurfacePalette.ink,
                ),
          ),
        ),
      ],
    );
  }
}

class _ChatReportDraft {
  const _ChatReportDraft({
    required this.reason,
    required this.description,
  });

  final String reason;
  final String description;
}

class _ChatReportDialog extends StatefulWidget {
  const _ChatReportDialog();

  @override
  State<_ChatReportDialog> createState() => _ChatReportDialogState();
}

class _ChatReportDialogState extends State<_ChatReportDialog> {
  static const List<String> _reasons = <String>[
    '违规辱骂',
    '骚扰攻击',
    '垃圾内容',
    '联系方式传播',
    '其他',
  ];

  late String _selectedReason;
  late final TextEditingController _descriptionController;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons.first;
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        lightStyle: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text('举报消息', 'Report message'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _text(
                  '该消息当前不会立即消失，会先进入管理员审核队列。',
                  'This message will not disappear immediately. It will enter the moderation queue first.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: InputDecoration(
                  labelText: _text('举报原因', 'Reason'),
                ),
                items: _reasons
                    .map(
                      (reason) => DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLength: 255,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: _text('补充说明', 'Details'),
                  hintText: _text(
                    '可选，提供给管理员参考的说明。',
                    'Optional notes for the moderator.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(_text('取消', 'Cancel')),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _ChatReportDraft(
                          reason: _selectedReason,
                          description: _descriptionController.text.trim(),
                        ),
                      );
                    },
                    child: Text(_text('提交', 'Submit')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({
    required this.member,
    required this.isBusy,
    required this.canRemove,
    this.onRemove,
  });

  final TeamMember member;
  final bool isBusy;
  final bool canRemove;
  final Future<void> Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;
    final displayName = _teamMemberDisplayName(context, member);
    final initial =
        displayName.isEmpty ? '?' : displayName.characters.first.toUpperCase();
    final accent = member.activeStudy ? AppColors.mint : AppColors.glow;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.95),
                      AppColors.glow.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.night,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          displayName,
                          style: textTheme.titleMedium?.copyWith(
                            color: SurfacePalette.ink,
                          ),
                        ),
                        if (member.completedTodayPlan)
                          _Tag(label: text('计划完成', 'Plan done')),
                        if (member.userNo.trim().isNotEmpty)
                          Text(member.userNo, style: textTheme.bodyMedium),
                        if (member.owner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mint.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              text('队长', 'Captain'),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.mint,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member.completedTodayPlan
                          ? text('今天的计划已经全部完成。',
                              'Today\'s plan is fully completed.')
                          : member.activeStudy
                              ? '${_teamMemberStageLabel(context, member)}  |  ${member.activeTaskName.isEmpty ? text('当前任务已隐藏', 'Current task hidden') : member.activeTaskName}'
                              : member.todayTotalCount > 0
                                  ? text(
                                      '今日 ${member.todayPlanProgressLabel}  |  ${_teamMemberTodayStudyLabel(context, member)}',
                                      'Today ${member.todayPlanProgressLabel}  |  ${_teamMemberTodayStudyLabel(context, member)}',
                                    )
                                  : text('当前空闲', 'Idle now'),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (canRemove)
                TextButton.icon(
                  onPressed: isBusy || onRemove == null
                      ? null
                      : () async {
                          await onRemove!();
                        },
                  icon: const Icon(Icons.person_remove_alt_1_rounded),
                  label: Text(text('移除', 'Remove')),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MemberMetricChip(
                label: text('今日计划', 'Today plan'),
                value: member.todayPlanProgressLabel,
              ),
              _MemberMetricChip(
                label: text('今日学习', 'Today study'),
                value: _teamMemberTodayStudyLabel(context, member),
              ),
              _MemberMetricChip(
                label: text('累计学习', 'Total study'),
                value: _teamMemberTotalStudyLabel(context, member),
              ),
              _MemberMetricChip(
                label: text('签到天数', 'Check-in days'),
                value: '${member.totalCheckInDays}',
              ),
              _MemberMetricChip(
                label: text('学习数据', 'Study data'),
                value: member.allowStudyView
                    ? text('可见', 'Visible')
                    : text('隐藏', 'Hidden'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberMetricChip extends StatelessWidget {
  const _MemberMetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendSummaryCard extends StatelessWidget {
  const _FriendSummaryCard({
    required this.friendOverview,
    required this.onOpenDetails,
  });

  final FriendOverview friendOverview;
  final Future<void> Function() onOpenDetails;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;
    final groupNames = friendOverview.groups
        .take(4)
        .map((group) => '${group.groupName} (${group.friendCount})')
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await onOpenDetails();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text('好友概览', 'Friend summary'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    friendOverview.hasFriends
                        ? text(
                            '已连接 ${friendOverview.friendCount}/${friendOverview.maxFriendCount} 位熟人好友。',
                            '${friendOverview.friendCount}/${friendOverview.maxFriendCount} trusted friends connected.',
                          )
                        : text(
                            '你的熟人圈还是空的，可以通过用户号或昵称开始添加好友。',
                            'Your trusted circle is still empty. Search by user number or nickname to start.',
                          ),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await onOpenDetails();
                },
                icon: const Icon(Icons.people_alt_rounded),
                label: Text(text('打开好友中心', 'Open friends')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Tag(
                  label: text('好友 ${friendOverview.friendCount}',
                      'Friends ${friendOverview.friendCount}')),
              _Tag(
                  label: text('分组 ${friendOverview.groups.length}',
                      'Groups ${friendOverview.groups.length}')),
              _Tag(
                  label: text('收到 ${friendOverview.incomingRequests.length}',
                      'Incoming ${friendOverview.incomingRequests.length}')),
              _Tag(
                  label: text('发出 ${friendOverview.outgoingRequests.length}',
                      'Outgoing ${friendOverview.outgoingRequests.length}')),
            ],
          ),
          const SizedBox(height: 16),
          if (groupNames.isEmpty)
            _InfoRow(
              icon: Icons.person_search_rounded,
              text: text(
                '好友申请需要同意，资料仅好友可见，陌生人不能发私信。',
                'Friend requests require approval, profiles are friend-only, and strangers cannot private-message.',
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: groupNames.map((label) => _Tag(label: label)).toList(),
            ),
        ],
      ),
    );
  }
}

class _MemoSummaryCard extends StatelessWidget {
  const _MemoSummaryCard({
    required this.memoOverview,
    required this.onOpenDetails,
  });

  final MemoOverview memoOverview;
  final Future<void> Function() onOpenDetails;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await onOpenDetails();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text('备忘录概览', 'Memo summary'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    memoOverview.hasItems
                        ? text(
                            '已有 ${memoOverview.totalCount} 条备忘录在手机和电脑间同步。',
                            '${memoOverview.totalCount} memo cards are ready across phone and desktop.',
                          )
                        : text(
                            '还没有备忘录，可以先保存一条文字卡片或清单，把想法留在眼前。',
                            'No memos yet. Save a quick text card or a checklist to keep ideas in view.',
                          ),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await onOpenDetails();
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(text('打开备忘录', 'Open memos')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!memoOverview.hasItems)
            _InfoRow(
              icon: Icons.edit_note_rounded,
              text: text(
                '当前简版备忘录支持文字卡片和清单卡片，支持双端同步，删除后不会进入回收站。',
                'Memo center supports text cards and checklist cards, syncs across devices, and deletes directly without a recycle bin.',
              ),
            )
          else
            ...memoOverview.items.take(3).map((memo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SurfacePalette.softSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SurfacePalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            memo.displayTitle,
                            style: textTheme.titleMedium?.copyWith(
                              color: SurfacePalette.ink,
                            ),
                          ),
                          _Tag(label: memo.progressLabel),
                          if (memo.updateTime.isNotEmpty)
                            _Tag(label: memo.updateTime),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memo.summaryText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: SurfacePalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({
    required this.settingsConnected,
  });

  final bool settingsConnected;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text('当前进度', 'Current progress'), style: textTheme.titleMedium),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.mark_email_read_rounded,
          text: text(
            '账号登录、邮箱验证码和注册流程已经打通。',
            'Account login, email code, and register flow are connected',
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.task_alt_rounded,
          text: text(
            '今日短计划的创建、保存、读取和完成勾选已经联通。',
            'Today short-plan create, save, load, and completion are connected',
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.notifications_active_rounded,
          text: text(
            '通知中心简版已经打通：提醒、完成通知和签到结果都会进入这里。',
            'Notification center is connected: reminders, completion updates, and check-in results arrive here.',
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow(
          icon: Icons.dashboard_customize_rounded,
          text: settingsConnected
              ? text(
                  '系统设置已经打通：主题、挂件、隐私和账号操作都已接入。',
                  'System settings are connected: theme, widget, privacy, and account actions are all available.',
                )
              : text(
                  '下一步建议优先完善系统设置联通。',
                  'Next recommended step: finish connecting system settings.',
                ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: SurfacePalette.ink, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SurfacePalette.ink,
                ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}

class _UnreadBellIcon extends StatelessWidget {
  const _UnreadBellIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return _BadgeIcon(
      icon: Icons.notifications_rounded,
      badgeText:
          unreadCount > 0 ? (unreadCount > 99 ? '99+' : '$unreadCount') : null,
      badgeTextColor: AppColors.night,
    );
  }
}

class _NotificationSummaryCard extends StatelessWidget {
  const _NotificationSummaryCard({
    required this.notificationOverview,
    required this.onOpenDetails,
  });

  final NotificationOverview notificationOverview;
  final Future<void> Function() onOpenDetails;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await onOpenDetails();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text('通知概览', 'Notification summary'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    notificationOverview.hasUnread
                        ? text(
                            '你有 ${notificationOverview.unreadCount} 条未读动态等待处理。',
                            '${notificationOverview.unreadCount} unread updates are waiting for you.',
                          )
                        : text(
                            '最近的团队提醒和签到结果会集中显示在这里。',
                            'Recent team and check-in updates gather here.',
                          ),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await onOpenDetails();
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(text('打开通知中心', 'Open notifications')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!notificationOverview.hasItems)
            _InfoRow(
              icon: Icons.notifications_none_rounded,
              text: text(
                '暂时还没有通知。等到提醒、完成通知或签到结果产生后，这里就会显示。',
                'No notifications yet. Once reminders, completion, or check-in results happen, they will show here.',
              ),
            )
          else
            ...notificationOverview.previewItems.map((item) {
              final unread = !item.read;
              final accent =
                  unread ? SurfacePalette.ink : SurfacePalette.subtle;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: unread ? Colors.white : SurfacePalette.softSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SurfacePalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                            ),
                          ),
                          Text(
                            _notificationTypeLabel(context, item),
                            style: textTheme.bodyMedium?.copyWith(
                              color: SurfacePalette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(item.createTime, style: textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.content,
                        style: textTheme.bodyMedium?.copyWith(
                          color: SurfacePalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StartFocusSessionDialog extends StatefulWidget {
  const _StartFocusSessionDialog();

  @override
  State<_StartFocusSessionDialog> createState() =>
      _StartFocusSessionDialogState();
}

class _StartFocusSessionDialogState extends State<_StartFocusSessionDialog> {
  late final TextEditingController _taskNameController;
  late final TextEditingController _studyMinutesController;
  late final TextEditingController _breakMinutesController;
  int _durationMinutes = 60;
  bool _bindPomodoro = false;
  String? _validationMessage;

  String _text(String zh, String en) {
    return _contextText(context, zh, en);
  }

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _studyMinutesController = TextEditingController(text: '40');
    _breakMinutesController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _studyMinutesController.dispose();
    _breakMinutesController.dispose();
    super.dispose();
  }

  void _submit() {
    final studyMinutes = int.tryParse(_studyMinutesController.text.trim()) ?? 0;
    final breakMinutes = int.tryParse(_breakMinutesController.text.trim()) ?? 0;

    if (_durationMinutes <= 0) {
      setState(() {
        _validationMessage =
            _text('请选择有效的结束时长。', 'Please choose a valid end duration.');
      });
      return;
    }
    if (_bindPomodoro && studyMinutes <= 0) {
      setState(() {
        _validationMessage = _text(
            '番茄学习时长必须大于 0。', 'Pomodoro study minutes must be greater than 0.');
      });
      return;
    }
    if (_bindPomodoro && breakMinutes < 0) {
      setState(() {
        _validationMessage = _text(
            '番茄休息时长不能小于 0。', 'Pomodoro break minutes cannot be negative.');
      });
      return;
    }

    final draft = _FocusSessionDraft(
      taskName: _taskNameController.text.trim(),
      endTime: DateTime.now().add(Duration(minutes: _durationMinutes)),
      bindPomodoro: _bindPomodoro,
      pomodoroStudyMinutes: _bindPomodoro ? studyMinutes : 0,
      pomodoroBreakMinutes: _bindPomodoro ? breakMinutes : 0,
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plannedEndTime =
        DateTime.now().add(Duration(minutes: _durationMinutes));
    final endHour = plannedEndTime.hour.toString().padLeft(2, '0');
    final endMinute = plannedEndTime.minute.toString().padLeft(2, '0');

    return AlertDialog(
      title: Text(_text('开始专注', 'Start focus session')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: _text('任务名称', 'Task name'),
                  hintText: _text('例如：英语阅读', 'For example: English reading'),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _text('你想学习多久？', 'How long do you want to study?'),
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [30, 45, 60, 90, 120].map((minutes) {
                  final selected = _durationMinutes == minutes;
                  return ChoiceChip(
                    label: Text(_text('$minutes 分钟', '$minutes min')),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _durationMinutes = minutes;
                        _validationMessage = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                _text(
                  '结束于 $endHour:$endMinute  |  计划 ${FocusSession.formatMinutes(_durationMinutes)}',
                  'Ends at $endHour:$endMinute  |  Planned ${FocusSession.formatMinutes(_durationMinutes)}',
                ),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _bindPomodoro,
                title: Text(_text('绑定番茄循环', 'Bind pomodoro loop')),
                subtitle: Text(
                  _text(
                    '按自定义的学习/休息循环持续运行，直到本次专注结束。',
                    'Repeat a custom study/break cycle until the focus session ends.',
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _bindPomodoro = value;
                    _validationMessage = null;
                  });
                },
              ),
              if (_bindPomodoro) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _studyMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _text('学习时长', 'Study minutes'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _breakMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _text('休息时长', 'Break minutes'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_validationMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _validationMessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade200,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_text('取消', 'Cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_text('开始', 'Start')),
        ),
      ],
    );
  }
}

class _TeamWorkspacePage extends StatelessWidget {
  const _TeamWorkspacePage({
    required this.profile,
    required this.teamOverview,
    required this.friendOverview,
    required this.teamChatOverview,
    required this.initialBannerMessage,
    required this.isBusy,
    required this.onCreateTeam,
    required this.onJoinTeam,
    required this.onInviteMember,
    required this.onRemoveMember,
    required this.onDissolveTeam,
    required this.onLoadTeamChatMessages,
    required this.onSendTeamChatMessage,
    required this.onMarkTeamChatRead,
    required this.onReportTeamChatMessage,
    required this.onRefreshWorkspace,
  });

  final UserProfile profile;
  final TeamOverview teamOverview;
  final FriendOverview friendOverview;
  final TeamChatOverview teamChatOverview;
  final String? initialBannerMessage;
  final bool isBusy;
  final Future<void> Function(String teamName) onCreateTeam;
  final Future<void> Function(String inviteCode) onJoinTeam;
  final Future<void> Function(int targetUserId) onInviteMember;
  final Future<bool> Function(int memberUserId) onRemoveMember;
  final Future<bool> Function() onDissolveTeam;
  final Future<TeamChatOverview?> Function({int limit}) onLoadTeamChatMessages;
  final Future<TeamChatOverview?> Function(String content)
      onSendTeamChatMessage;
  final Future<TeamChatOverview?> Function() onMarkTeamChatRead;
  final Future<bool> Function(
    int messageId, {
    required String reason,
    String description,
  }) onReportTeamChatMessage;
  final Future<TeamWorkspaceSnapshot?> Function() onRefreshWorkspace;

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _contextText(context, '返回', 'Back'),
      title: _contextText(context, '团队中心', 'Team center'),
      description: _contextText(
        context,
        '在这里创建或加入团队、查看队友进度、发送提醒，以及进入团队群聊。',
        'Create or join a team, view teammate progress, send reminders, and open team chat here.',
      ),
      children: [
        GlassPanel(
          lightStyle: true,
          child: _TeamPanel(
            profile: profile,
            teamOverview: teamOverview,
            friendOverview: friendOverview,
            teamChatOverview: teamChatOverview,
            initialBannerMessage: initialBannerMessage,
            isBusy: isBusy,
            onCreateTeam: onCreateTeam,
            onJoinTeam: onJoinTeam,
            onInviteMember: onInviteMember,
            onRemoveMember: onRemoveMember,
            onDissolveTeam: onDissolveTeam,
            onLoadTeamChatMessages: onLoadTeamChatMessages,
            onSendTeamChatMessage: onSendTeamChatMessage,
            onMarkTeamChatRead: onMarkTeamChatRead,
            onReportTeamChatMessage: onReportTeamChatMessage,
            onRefreshWorkspace: onRefreshWorkspace,
          ),
        ),
      ],
    );
  }
}

class _FocusSessionDraft {
  const _FocusSessionDraft({
    required this.taskName,
    required this.endTime,
    required this.bindPomodoro,
    required this.pomodoroStudyMinutes,
    required this.pomodoroBreakMinutes,
  });

  final String taskName;
  final DateTime endTime;
  final bool bindPomodoro;
  final int pomodoroStudyMinutes;
  final int pomodoroBreakMinutes;
}

enum _DesktopWidgetSectionKey {
  timer,
  checkIn,
  plan,
  memo,
  team,
}

class _DesktopWidgetHomeV2 extends StatefulWidget {
  const _DesktopWidgetHomeV2({
    required this.appLanguage,
    required this.profile,
    required this.focusSession,
    required this.checkInStatus,
    required this.statsOverview,
    required this.teamOverview,
    required this.teamChatOverview,
    required this.friendOverview,
    required this.memoOverview,
    required this.notificationOverview,
    required this.settingOverview,
    required this.todayPlan,
    required this.isBusy,
    required this.onClearBanner,
    required this.onRefresh,
    required this.onOpenStats,
    required this.onOpenNotifications,
    required this.onOpenFriends,
    required this.onOpenMemos,
    required this.onOpenSettings,
    required this.onOpenTeamWorkspace,
    required this.onStartFocus,
    required this.onFinishFocus,
    required this.onSubmitCheckIn,
    required this.onEditTodayPlan,
    required this.onToggleTodayPlanItem,
    required this.onRemindTeammate,
    this.bannerMessage,
  });

  final AppLanguage appLanguage;
  final UserProfile profile;
  final FocusSession focusSession;
  final CheckInStatus checkInStatus;
  final StatsOverview statsOverview;
  final TeamOverview teamOverview;
  final TeamChatOverview teamChatOverview;
  final FriendOverview friendOverview;
  final MemoOverview memoOverview;
  final NotificationOverview notificationOverview;
  final SettingOverview settingOverview;
  final TodayPlan todayPlan;
  final bool isBusy;
  final String? bannerMessage;
  final VoidCallback onClearBanner;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onOpenStats;
  final Future<void> Function() onOpenNotifications;
  final Future<void> Function() onOpenFriends;
  final Future<void> Function() onOpenMemos;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenTeamWorkspace;
  final Future<void> Function() onStartFocus;
  final Future<void> Function() onFinishFocus;
  final Future<void> Function() onSubmitCheckIn;
  final Future<void> Function() onEditTodayPlan;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final Future<bool> Function(int teammateUserId) onRemindTeammate;

  @override
  State<_DesktopWidgetHomeV2> createState() => _DesktopWidgetHomeV2State();
}

class _DesktopWidgetHomeV2State extends State<_DesktopWidgetHomeV2> {
  final GlobalKey _contentKey = GlobalKey();

  bool _collapsedMode = false;
  bool _miniMode = false;
  late bool _timerExpanded;
  late bool _checkInExpanded;
  late bool _planExpanded;
  late bool _memoExpanded;
  late bool _teamExpanded;

  bool _heightSyncQueued = false;
  double? _lastSyncedHeight;

  static const _widgetMessageMaxWidth = 360.0;

  @override
  void initState() {
    super.initState();
    DesktopWidgetBridge.setWindowModeListener(_handleWindowModeChanged);
    unawaited(DesktopWidgetBridge.setWindowMode('widget'));
    _timerExpanded = widget.focusSession.active;
    _checkInExpanded = true;
    _planExpanded = widget.todayPlan.hasItems;
    _memoExpanded = widget.memoOverview.hasItems;
    _teamExpanded = widget.teamOverview.inTeam;
    _scheduleWindowHeightSync();
  }

  @override
  void dispose() {
    DesktopWidgetBridge.setWindowModeListener(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DesktopWidgetHomeV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.focusSession.active && widget.focusSession.active) {
      _timerExpanded = true;
    }
    if (!oldWidget.todayPlan.hasItems && widget.todayPlan.hasItems) {
      _planExpanded = true;
    }
    if (!oldWidget.memoOverview.hasItems && widget.memoOverview.hasItems) {
      _memoExpanded = true;
    }
    if (!oldWidget.teamOverview.inTeam && widget.teamOverview.inTeam) {
      _teamExpanded = true;
    }
    _scheduleWindowHeightSync();
  }

  List<MapEntry<int, TodayPlanItem>> _sortedPlanEntries() {
    final entries = widget.todayPlan.items.asMap().entries.toList();
    entries.sort((left, right) {
      final leftItem = left.value;
      final rightItem = right.value;
      if (leftItem.hasSchedule && rightItem.hasSchedule) {
        final startCompare =
            (leftItem.startSlot ?? 999).compareTo(rightItem.startSlot ?? 999);
        if (startCompare != 0) {
          return startCompare;
        }
      }
      if (leftItem.hasSchedule != rightItem.hasSchedule) {
        return leftItem.hasSchedule ? -1 : 1;
      }
      return leftItem.sortOrder.compareTo(rightItem.sortOrder);
    });
    return entries;
  }

  List<TeamMember> _teammatePreview() {
    return widget.teamOverview.members
        .where((member) => member.userId != widget.profile.userId)
        .take(2)
        .toList();
  }

  Color _accentColor() {
    switch (widget.settingOverview.appearanceSetting.desktopEffect) {
      case 'soft_glass':
        return AppColors.mint;
      case 'focus_glow':
        return const Color(0xFFFFD66B);
      default:
        return AppColors.glow;
    }
  }

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) {
    return _isChinese ? zh : en;
  }

  Color get _primaryTextColor => SurfacePalette.ink;
  Color get _secondaryTextColor => SurfacePalette.muted;

  void _setSectionExpanded(_DesktopWidgetSectionKey section, bool expanded) {
    setState(() {
      switch (section) {
        case _DesktopWidgetSectionKey.timer:
          _timerExpanded = expanded;
          break;
        case _DesktopWidgetSectionKey.checkIn:
          _checkInExpanded = expanded;
          break;
        case _DesktopWidgetSectionKey.plan:
          _planExpanded = expanded;
          break;
        case _DesktopWidgetSectionKey.memo:
          _memoExpanded = expanded;
          break;
        case _DesktopWidgetSectionKey.team:
          _teamExpanded = expanded;
          break;
      }
    });
    _scheduleWindowHeightSync();
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        _scheduleWindowHeightSync();
      }),
    );
  }

  void _toggleCollapsedMode() {
    setState(() {
      _collapsedMode = !_collapsedMode;
      if (_collapsedMode) {
        _timerExpanded = false;
        _checkInExpanded = false;
        _planExpanded = false;
        _memoExpanded = false;
        _teamExpanded = false;
      } else {
        _checkInExpanded = true;
        _timerExpanded = widget.focusSession.active;
        _planExpanded = widget.todayPlan.hasItems;
        _memoExpanded = widget.memoOverview.hasItems;
        _teamExpanded = widget.teamOverview.inTeam;
      }
    });
    _scheduleWindowHeightSync();
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        _scheduleWindowHeightSync();
      }),
    );
  }

  Future<void> _resetDesktopAnchor() async {
    await DesktopWidgetBridge.resetWindowPosition();
  }

  Future<void> _hideDesktopWidget() async {
    await DesktopWidgetBridge.showMiniWindow();
  }

  Future<void> _restoreDesktopWidget() async {
    await DesktopWidgetBridge.showWidgetWindow();
  }

  void _handleWindowModeChanged(String mode) {
    if (!mounted) {
      return;
    }

    final nextMiniMode = mode == 'mini';
    if (_miniMode != nextMiniMode) {
      setState(() {
        _miniMode = nextMiniMode;
      });
    }
    if (!nextMiniMode) {
      _scheduleWindowHeightSync();
    }
  }

  void _scheduleWindowHeightSync() {
    if (AppConfig.deviceType != 'windows' || _heightSyncQueued || _miniMode) {
      return;
    }

    _heightSyncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heightSyncQueued = false;
      if (!mounted) {
        return;
      }

      final renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      final measuredHeight = renderBox?.size.height;
      if (measuredHeight == null || measuredHeight <= 0) {
        return;
      }

      final targetHeight = (measuredHeight + 32).clamp(380.0, 940.0).toDouble();
      if (_lastSyncedHeight != null &&
          (targetHeight - _lastSyncedHeight!).abs() < 1) {
        return;
      }

      _lastSyncedHeight = targetHeight;
      unawaited(DesktopWidgetBridge.updateWindowHeight(targetHeight));
    });
  }

  // ignore: unused_element
  Widget _buildHeaderCard(
    BuildContext context,
    TextTheme textTheme,
    Color accentColor,
    String headerMessage,
  ) {
    final appearance = widget.settingOverview.appearanceSetting;
    final displayName = _profileDisplayName(context, widget.profile);
    final profileInitial = _profileInitial(displayName);
    final desktopSubtitle = _collapsedMode
        ? _text(
            '双击展开 | ${_desktopEffectLabel(context, appearance)}',
            'Double-tap to expand | ${_desktopEffectLabel(context, appearance)}',
          )
        : _text(
            '拖动移动 | 双击切换紧凑 | ${_desktopEffectLabel(context, appearance)}',
            'Drag to move | Double-tap to compact | ${_desktopEffectLabel(context, appearance)}',
          );

    return GlassPanel(
      desktopTransparent: true,
      padding: EdgeInsets.fromLTRB(
        14,
        _collapsedMode ? 14 : 16,
        14,
        _collapsedMode ? 12 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: _toggleCollapsedMode,
                  onPanStart: (_) {
                    unawaited(DesktopWidgetBridge.startWindowDrag());
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: _collapsedMode ? 46 : 52,
                        height: _collapsedMode ? 46 : 52,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(_collapsedMode ? 20 : 24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withValues(alpha: 0.82),
                              Colors.white.withValues(alpha: 0.22),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profileInitial,
                          style: (_collapsedMode
                                  ? textTheme.titleLarge
                                  : textTheme.headlineSmall)
                              ?.copyWith(
                            color: AppColors.night,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(width: _collapsedMode ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Innocence',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _DesktopDragHandle(compact: _collapsedMode),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style: (_collapsedMode
                                      ? textTheme.titleLarge
                                      : textTheme.headlineSmall)
                                  ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: _collapsedMode ? 4 : 6),
                            Text(
                              desktopSubtitle,
                              style: (_collapsedMode
                                      ? textTheme.bodySmall
                                      : textTheme.bodyMedium)
                                  ?.copyWith(
                                color: _secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Wrap(
                direction: Axis.vertical,
                spacing: 4,
                children: [
                  IconButton(
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tooltip: _text('恢复默认位置', 'Reset position'),
                    onPressed: () async {
                      await _resetDesktopAnchor();
                    },
                    icon: const Icon(Icons.push_pin_rounded),
                  ),
                  IconButton(
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tooltip: _collapsedMode
                        ? _text('展开挂件', 'Expand widget')
                        : _text('切换紧凑模式', 'Compact mode'),
                    onPressed: _toggleCollapsedMode,
                    icon: Icon(
                      _collapsedMode
                          ? Icons.unfold_more_rounded
                          : Icons.unfold_less_rounded,
                    ),
                  ),
                  IconButton(
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tooltip: _text('刷新数据', 'Refresh'),
                    onPressed: widget.isBusy
                        ? null
                        : () async {
                            await widget.onRefresh();
                          },
                    icon: widget.isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tooltip: _text('打开设置', 'Settings'),
                    onPressed: () async {
                      await widget.onOpenSettings();
                    },
                    icon: const Icon(Icons.tune_rounded),
                  ),
                  DesktopCloseButton(
                    compact: true,
                    tooltip: _text('关闭挂件', 'Close widget'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: _collapsedMode ? 10 : 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DesktopMetricChip(
                label: _text('连续', 'Streak'),
                value: _text(
                  '${widget.checkInStatus.consecutiveDays} 天',
                  '${widget.checkInStatus.consecutiveDays} d',
                ),
                accentColor: accentColor,
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('学习', 'Study'),
                value: _formatMinutesCompactLocalized(
                  context,
                  widget.profile.studyDurationTotal,
                ),
                accentColor: AppColors.mint,
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('未读', 'Unread'),
                value: '${widget.notificationOverview.unreadCount}',
                accentColor: const Color(0xFFFFD66B),
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('番茄', 'Pomodoro'),
                value: '${widget.statsOverview.totalPomodoroCompleted}',
                accentColor: const Color(0xFFFF8C72),
                compact: true,
              ),
            ],
          ),
          SizedBox(height: _collapsedMode ? 10 : 12),
          Text(
            headerMessage,
            maxLines: _collapsedMode ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: (_collapsedMode ? textTheme.bodySmall : textTheme.bodyMedium)
                ?.copyWith(
              color: _primaryTextColor,
              height: 1.42,
            ),
          ),
          SizedBox(height: _collapsedMode ? 10 : 12),
          SizedBox(
            height: _collapsedMode ? 74 : 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _DesktopActionTile(
                  icon: Icons.notifications_active_rounded,
                  label: _text('通知', 'Notice'),
                  badge: widget.notificationOverview.unreadCount > 0
                      ? '${widget.notificationOverview.unreadCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenNotifications();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.query_stats_rounded,
                  label: _text('统计', 'Stats'),
                  onTap: () async {
                    await widget.onOpenStats();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.sticky_note_2_rounded,
                  label: _text('备忘录', 'Memo'),
                  badge: widget.memoOverview.totalCount > 0
                      ? '${widget.memoOverview.totalCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenMemos();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.people_alt_rounded,
                  label: _text('好友', 'Friends'),
                  badge: widget.friendOverview.incomingRequests.isNotEmpty
                      ? '${widget.friendOverview.incomingRequests.length}'
                      : null,
                  onTap: () async {
                    await widget.onOpenFriends();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.groups_2_rounded,
                  label: _text('团队', 'Team'),
                  badge: widget.teamOverview.hasUnreadChat
                      ? '${widget.teamOverview.unreadChatCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenTeamWorkspace();
                  },
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetHeaderCard(
    BuildContext context,
    TextTheme textTheme,
    Color accentColor,
    String headerMessage,
  ) {
    final displayName = widget.profile.displayName.trim().isEmpty
        ? 'Innocence'
        : widget.profile.displayName.trim();

    Widget buildHeaderButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback? onPressed,
      Widget? child,
    }) {
      final enabled = onPressed != null;

      return Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: SurfacePalette.border,
                ),
                boxShadow: SurfacePalette.shadows,
              ),
              child: Center(
                child: child ??
                    Icon(
                      icon,
                      size: 18,
                      color:
                          enabled ? SurfacePalette.ink : SurfacePalette.subtle,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return GlassPanel(
      lightStyle: true,
      padding: EdgeInsets.fromLTRB(
        14,
        _collapsedMode ? 14 : 16,
        14,
        _collapsedMode ? 12 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: _collapsedMode ? 92 : 132,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.move,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: _toggleCollapsedMode,
                            onPanStart: (_) {
                              unawaited(DesktopWidgetBridge.startWindowDrag());
                            },
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'INNOCENCE',
                                    style: (_collapsedMode
                                            ? textTheme.titleLarge
                                            : textTheme.headlineSmall)
                                        ?.copyWith(
                                      color: SurfacePalette.ink,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: _collapsedMode ? 1.8 : 2.6,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _DesktopDragHandle(
                                    compact: _collapsedMode,
                                  ),
                                ],
                              ),
                              SizedBox(height: _collapsedMode ? 7 : 8),
                              Container(
                                width: _collapsedMode ? 110 : 150,
                                height: 2,
                                color: SurfacePalette.ink,
                              ),
                              SizedBox(height: _collapsedMode ? 8 : 10),
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: (_collapsedMode
                                        ? textTheme.titleMedium
                                        : textTheme.titleLarge)
                                    ?.copyWith(
                                  color: SurfacePalette.ink,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                ),
                              ),
                              SizedBox(height: _collapsedMode ? 3 : 5),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: _widgetMessageMaxWidth,
                                ),
                                child: Text(
                                  headerMessage,
                                  maxLines: _collapsedMode ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: (_collapsedMode
                                          ? textTheme.bodySmall
                                          : textTheme.bodyMedium)
                                      ?.copyWith(
                                    color: SurfacePalette.ink.withValues(
                                      alpha: _collapsedMode ? 0.72 : 0.78,
                                    ),
                                    height: _collapsedMode ? 1.3 : 1.36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 84,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    buildHeaderButton(
                      icon: Icons.push_pin_rounded,
                      tooltip: _text('恢复默认位置', 'Reset position'),
                      onPressed: () {
                        unawaited(_resetDesktopAnchor());
                      },
                    ),
                    buildHeaderButton(
                      icon: Icons.remove_rounded,
                      tooltip: _text('收起到后台', 'Hide to background'),
                      onPressed: () {
                        unawaited(_hideDesktopWidget());
                      },
                    ),
                    buildHeaderButton(
                      icon: _collapsedMode
                          ? Icons.open_in_full_rounded
                          : Icons.close_fullscreen_rounded,
                      tooltip: _collapsedMode
                          ? _text('展开挂件', 'Expand widget')
                          : _text('切换紧凑模式', 'Compact mode'),
                      onPressed: _toggleCollapsedMode,
                    ),
                    buildHeaderButton(
                      icon: Icons.refresh_rounded,
                      tooltip: _text('刷新数据', 'Refresh'),
                      onPressed: widget.isBusy
                          ? null
                          : () {
                              unawaited(widget.onRefresh());
                            },
                      child: widget.isBusy
                          ? SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                    buildHeaderButton(
                      icon: Icons.tune_rounded,
                      tooltip: _text('打开设置', 'Settings'),
                      onPressed: () {
                        unawaited(widget.onOpenSettings());
                      },
                    ),
                    DesktopCloseButton(
                      compact: true,
                      tooltip: _text('关闭挂件', 'Close widget'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _collapsedMode ? 10 : 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DesktopMetricChip(
                label: _text('连续', 'Streak'),
                value: _text(
                  '${widget.checkInStatus.consecutiveDays} 天',
                  '${widget.checkInStatus.consecutiveDays} d',
                ),
                accentColor: accentColor,
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('学习', 'Study'),
                value: _formatMinutesCompactLocalized(
                  context,
                  widget.profile.studyDurationTotal,
                ),
                accentColor: AppColors.mint,
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('未读', 'Unread'),
                value: '${widget.notificationOverview.unreadCount}',
                accentColor: const Color(0xFFFFD66B),
                compact: true,
              ),
              _DesktopMetricChip(
                label: _text('番茄', 'Pomodoro'),
                value: '${widget.statsOverview.totalPomodoroCompleted}',
                accentColor: const Color(0xFFFF8C72),
                compact: true,
              ),
            ],
          ),
          SizedBox(height: _collapsedMode ? 10 : 14),
          SizedBox(
            height: _collapsedMode ? 74 : 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _DesktopActionTile(
                  icon: Icons.notifications_active_rounded,
                  label: _text('通知', 'Notices'),
                  badge: widget.notificationOverview.unreadCount > 0
                      ? '${widget.notificationOverview.unreadCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenNotifications();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.query_stats_rounded,
                  label: _text('统计', 'Stats'),
                  onTap: () async {
                    await widget.onOpenStats();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.sticky_note_2_rounded,
                  label: _text('备忘录', 'Memos'),
                  badge: widget.memoOverview.totalCount > 0
                      ? '${widget.memoOverview.totalCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenMemos();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.people_alt_rounded,
                  label: _text('好友', 'Friends'),
                  badge: widget.friendOverview.incomingRequests.isNotEmpty
                      ? '${widget.friendOverview.incomingRequests.length}'
                      : null,
                  onTap: () async {
                    await widget.onOpenFriends();
                  },
                  compact: true,
                ),
                const SizedBox(width: 10),
                _DesktopActionTile(
                  icon: Icons.groups_2_rounded,
                  label: _text('团队', 'Team'),
                  badge: widget.teamOverview.hasUnreadChat
                      ? '${widget.teamOverview.unreadChatCount}'
                      : null,
                  onTap: () async {
                    await widget.onOpenTeamWorkspace();
                  },
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(TextTheme textTheme, Color accentColor) {
    final session = widget.focusSession;
    final focusTotalSeconds = session.elapsedSeconds + session.remainingSeconds;
    final focusProgress = focusTotalSeconds <= 0
        ? 0.0
        : (session.elapsedSeconds / focusTotalSeconds).clamp(0.0, 1.0);
    final collapsedSummary = session.active
        ? '${_focusStageLabel(context, session.stageName, session.active)} | ${session.remainingLabel}'
        : _text('在挂件中设定结束时间后即可开始学习。',
            'Set an end time from the widget and start learning when you are ready.');

    return _DesktopCollapsibleSection(
      icon: Icons.timelapse_rounded,
      title: _text('当前专注', 'Focus now'),
      subtitle: session.active
          ? session.taskName.isEmpty
              ? _text('当前专注正在设备间同步进行。',
                  'A focus session is running across your devices.')
              : session.taskName
          : _text('设定结束时间后，随时开始学习。',
              'Set an end time and start learning when you are ready.'),
      tagLabel: session.active
          ? _focusStageLabel(context, session.stageName, session.active)
          : _text('空闲', 'Idle'),
      collapsedSummary: collapsedSummary,
      accentColor: accentColor,
      expanded: _timerExpanded,
      headerAction: IconButton(
        tooltip: session.active
            ? _text('结束专注', 'Finish focus')
            : _text('开始专注', 'Start focus'),
        onPressed: widget.isBusy
            ? null
            : () async {
                if (session.active) {
                  await widget.onFinishFocus();
                } else {
                  await widget.onStartFocus();
                }
              },
        icon: Icon(
          session.active
              ? Icons.stop_circle_rounded
              : Icons.play_circle_fill_rounded,
          color: accentColor,
        ),
      ),
      onToggle: () {
        _setSectionExpanded(_DesktopWidgetSectionKey.timer, !_timerExpanded);
      },
      onAnimationEnd: _scheduleWindowHeightSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.active
                ? session.remainingLabel
                : _text('暂无进行中的专注', 'No active session'),
            style: textTheme.displaySmall?.copyWith(
              color: SurfacePalette.ink,
              fontWeight: FontWeight.w700,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.active
                ? _text(
                    '结束于 ${session.endTimeLabel} | 已进行 ${session.elapsedLabel}',
                    'Ends at ${session.endTimeLabel} | Elapsed ${session.elapsedLabel}',
                  )
                : _text(
                    '可以直接从桌面挂件启动，并把计时器固定在眼前。',
                    'Start from the desktop widget and keep the timer pinned on screen.',
                  ),
            style: textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.muted,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: focusProgress,
              backgroundColor: SurfacePalette.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          if (session.active) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                    label: _text(
                  '计划 ${_focusPlannedDurationLabel(context, session)}',
                  'Planned ${session.plannedDurationLabel}',
                )),
                if (session.bindPomodoro)
                  _Tag(
                    label: _text(
                      '循环 ${session.currentCycleNo} | ${session.stageRemainingLabel}',
                      'Cycle ${session.currentCycleNo} | ${session.stageRemainingLabel}',
                    ),
                  ),
                if (session.bindPomodoro)
                  _Tag(
                      label: _text('已完成 ${session.completedPomodoroCount} 次',
                          '${session.completedPomodoroCount} done')),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isBusy
                      ? null
                      : session.active
                          ? () async {
                              await widget.onFinishFocus();
                            }
                          : () async {
                              await widget.onStartFocus();
                            },
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: AppColors.night,
                  ),
                  icon: Icon(
                    session.active
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                  label: Text(
                    session.active
                        ? _text('结束专注', 'Finish focus')
                        : _text('开始专注', 'Start focus'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  await widget.onOpenStats();
                },
                icon: const Icon(Icons.query_stats_rounded),
                label: Text(_text('统计', 'Stats')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInSection(TextTheme textTheme) {
    final status = widget.checkInStatus;
    final statusBadge = status.checkedInToday
        ? _text('已签到', 'Checked')
        : status.canCheckInToday
            ? _text('可签到', 'Ready')
            : _text('待完成', 'Pending');
    final planProgress = status.todayPlanTotalCount <= 0
        ? 0.0
        : (status.todayPlanCompletedCount / status.todayPlanTotalCount)
            .clamp(0.0, 1.0);

    return _DesktopCollapsibleSection(
      icon: Icons.task_alt_rounded,
      title: _text('签到与坚持', 'Check-in & streak'),
      subtitle: _checkInDescription(context, status),
      tagLabel: statusBadge,
      collapsedSummary: _collapsedMode
          ? _text(
              '${status.consecutiveDays} 天连续 | ${_formatMinutesLocalized(context, status.totalStudyDurationMinutes)}',
              '${status.consecutiveDays}d streak | ${_formatMinutesLocalized(context, status.totalStudyDurationMinutes)}',
            )
          : _text(
              '连续 ${status.consecutiveDays} 天 | ${status.planProgressLabel}',
              '${status.consecutiveDays} day streak | ${status.planProgressLabel}',
            ),
      accentColor: AppColors.mint,
      expanded: _checkInExpanded,
      headerAction: IconButton(
        tooltip: _checkInActionLabel(context, status),
        onPressed: widget.isBusy || !status.canCheckInToday
            ? null
            : () async {
                await widget.onSubmitCheckIn();
              },
        icon: const Icon(
          Icons.task_alt_rounded,
          color: AppColors.mint,
        ),
      ),
      onToggle: () {
        _setSectionExpanded(
          _DesktopWidgetSectionKey.checkIn,
          !_checkInExpanded,
        );
      },
      onAnimationEnd: _scheduleWindowHeightSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DesktopSummaryStat(
                  label: _text('连续', 'Consecutive'),
                  value: '${status.consecutiveDays}',
                  hint: _text('天', 'days'),
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DesktopSummaryStat(
                  label: _text('累计', 'Total'),
                  value: '${status.totalDays}',
                  hint: _text('次签到', 'check-ins'),
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DesktopSummaryStat(
                  label: _text('成功率', 'Success'),
                  value: '${widget.statsOverview.checkInSuccessRate}%',
                  hint: _text('比例', 'rate'),
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: planProgress,
              backgroundColor: SurfacePalette.borderSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              '今日进度 ${status.planProgressLabel} | 累计学习 ${_formatMinutesLocalized(context, status.totalStudyDurationMinutes)}',
              'Today progress ${status.planProgressLabel} | ${_formatMinutesLocalized(context, status.totalStudyDurationMinutes)} total study',
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.muted,
            ),
          ),
          if (status.hasFailureHint) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x22FF8C72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x55FF8C72)),
              ),
              child: Text(
                _checkInFailureSummary(context, status),
                style: textTheme.bodyMedium?.copyWith(
                  color: SurfacePalette.dangerInk,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isBusy || !status.canCheckInToday
                      ? null
                      : () async {
                          await widget.onSubmitCheckIn();
                        },
                  icon: const Icon(Icons.task_alt_rounded),
                  label: Text(_checkInActionLabel(context, status)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  await widget.onOpenStats();
                },
                icon: const Icon(Icons.insights_rounded),
                label: Text(_text('趋势', 'Trends')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(TextTheme textTheme) {
    final todayPlan = widget.todayPlan;
    final previewPlanItems = _sortedPlanEntries().take(4).toList();

    return _DesktopCollapsibleSection(
      icon: Icons.view_timeline_rounded,
      title: _todayPlanDisplayName(context, todayPlan),
      subtitle: todayPlan.hasItems
          ? _text(
              '已完成 ${todayPlan.completedCount}/${todayPlan.totalCount} | 计划 ${_todayPlanDurationLabel(context, todayPlan.totalPlannedMinutes)}',
              '${todayPlan.completedCount}/${todayPlan.totalCount} finished | Planned ${todayPlan.plannedDurationLabel}',
            )
          : _text('还没有任务，先添加今天的短计划。',
              'No tasks yet. Add a short plan and tick items from this widget.'),
      tagLabel: _text('今日计划', 'Today plan'),
      collapsedSummary: todayPlan.hasItems
          ? _collapsedMode
              ? _text(
                  '${todayPlan.completedCount}/${todayPlan.totalCount} 完成 | ${_todayPlanDurationLabel(context, todayPlan.totalPlannedMinutes)}',
                  '${todayPlan.completedCount}/${todayPlan.totalCount} done | ${todayPlan.plannedDurationLabel}',
                )
              : _text(
                  '${todayPlan.completedCount}/${todayPlan.totalCount} 完成 | 已学 ${_todayPlanDurationLabel(context, todayPlan.completedPlannedMinutes)}',
                  '${todayPlan.completedCount}/${todayPlan.totalCount} finished | ${todayPlan.completedDurationLabel}',
                )
          : _text('先搭建今天的时间块，并在这里勾选完成。',
              'No tasks yet. Build today plan blocks and tick them from here.'),
      accentColor: const Color(0xFFFFD66B),
      expanded: _planExpanded,
      headerAction: IconButton(
        tooltip: _text('编辑计划', 'Edit plan'),
        onPressed: () async {
          await widget.onEditTodayPlan();
        },
        icon: const Icon(
          Icons.edit_calendar_rounded,
          color: Color(0xFFFFD66B),
        ),
      ),
      onToggle: () {
        _setSectionExpanded(_DesktopWidgetSectionKey.plan, !_planExpanded);
      },
      onAnimationEnd: _scheduleWindowHeightSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: todayPlan.completionRatio.clamp(0.0, 1.0),
              backgroundColor: SurfacePalette.borderSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD66B),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(
                    '已完成时长 ${_todayPlanDurationLabel(context, todayPlan.completedPlannedMinutes)}',
                    'Completed ${todayPlan.completedDurationLabel}',
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.muted,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await widget.onEditTodayPlan();
                },
                icon: const Icon(Icons.edit_calendar_rounded),
                label: Text(_text('编辑', 'Edit')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (previewPlanItems.isEmpty)
            const _DesktopHintCard(
              icon: Icons.view_timeline_rounded,
              text: '短计划支持半小时排程、日模板保存和清单勾选完成。',
            )
          else
            ...previewPlanItems.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DesktopPlanItemTileCompact(
                  item: entry.value,
                  accentColor: const Color(0xFFFFD66B),
                  onToggle: widget.isBusy
                      ? null
                      : () async {
                          await widget.onToggleTodayPlanItem(
                            entry.key,
                            !entry.value.completed,
                          );
                        },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMemoSection(Color accentColor) {
    final memoOverview = widget.memoOverview;

    return _DesktopCollapsibleSection(
      icon: Icons.note_alt_rounded,
      title: _text('备忘录预览', 'Memo preview'),
      subtitle: memoOverview.hasItems
          ? _text(
              '${memoOverview.totalCount} 条备忘录会在手机和电脑间同步。',
              '${memoOverview.totalCount} memo cards stay shared between phone and desktop.',
            )
          : _text('保存文字或清单备忘录，并让它常驻在这里。',
              'Save a quick text or checklist memo and keep it floating here.'),
      tagLabel: _text('备忘录', 'Memo'),
      collapsedSummary: memoOverview.hasItems
          ? _collapsedMode
              ? _text('${memoOverview.totalCount} 条已同步',
                  '${memoOverview.totalCount} memo cards synced')
              : _text('${memoOverview.totalCount} 条同步备忘录已就绪。',
                  '${memoOverview.totalCount} synced memo cards ready on both devices.')
          : _text('把常用文字或清单放在这里，方便随手查看。',
              'Keep a floating text or checklist memo here for quick access.'),
      accentColor: accentColor,
      expanded: _memoExpanded,
      headerAction: IconButton(
        tooltip: _text('打开备忘录', 'Open memo center'),
        onPressed: () async {
          await widget.onOpenMemos();
        },
        icon: Icon(
          Icons.open_in_new_rounded,
          color: accentColor,
        ),
      ),
      onToggle: () {
        _setSectionExpanded(_DesktopWidgetSectionKey.memo, !_memoExpanded);
      },
      onAnimationEnd: _scheduleWindowHeightSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!memoOverview.hasItems)
            const _DesktopHintCard(
              icon: Icons.note_alt_rounded,
              text: '当前简版备忘录支持文字卡片和清单卡片，删除后不会进入回收站。',
            )
          else
            ...memoOverview.items.take(2).map((memo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DesktopMemoTileCompact(memo: memo),
              );
            }),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                await widget.onOpenMemos();
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(_text('打开备忘录中心', 'Open memo center')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(TextTheme textTheme, Color accentColor) {
    final teamOverview = widget.teamOverview;
    final latestTeamChat = widget.teamChatOverview.latestMessage;
    final teammatePreview = _teammatePreview();

    return _DesktopCollapsibleSection(
      icon: Icons.groups_rounded,
      title: teamOverview.inTeam
          ? teamOverview.teamName
          : _text('可信团队', 'Trusted team'),
      subtitle: teamOverview.inTeam
          ? _text(
              '${teamOverview.memberCount}/${teamOverview.memberLimit} 人 | ${teamOverview.unreadChatCount} 条未读动态',
              '${teamOverview.memberCount}/${teamOverview.memberLimit} members | ${teamOverview.unreadChatCount} unread updates',
            )
          : _text('一个用户只能加入一个团队。团队用于提醒、进度查看和小范围群聊。',
              'One user can join one team. Teams keep reminders, progress, and group chat in a small trusted circle.'),
      tagLabel: teamOverview.inTeam
          ? _text('已加入', 'In team')
          : _text('未加入', 'Not joined'),
      collapsedSummary: teamOverview.inTeam
          ? _collapsedMode
              ? _text(
                  '${teamOverview.memberCount}/${teamOverview.memberLimit} 人 | ${teamOverview.unreadChatCount} 未读',
                  '${teamOverview.memberCount}/${teamOverview.memberLimit} members | ${teamOverview.unreadChatCount} unread',
                )
              : _text(
                  '${teamOverview.memberCount}/${teamOverview.memberLimit} 人 | ${teamOverview.unreadChatCount} 未读',
                  '${teamOverview.memberCount}/${teamOverview.memberLimit} members | ${teamOverview.unreadChatCount} unread',
                )
          : _text('创建或加入一个团队后，就能查看队友进度并发送提醒。',
              'Create or join one trusted team to track progress and send reminders.'),
      accentColor: accentColor,
      expanded: _teamExpanded,
      headerAction: IconButton(
        tooltip: teamOverview.inTeam
            ? _text('打开团队中心', 'Open team center')
            : _text('创建或加入团队', 'Create or join'),
        onPressed: () async {
          await widget.onOpenTeamWorkspace();
        },
        icon: Icon(
          teamOverview.inTeam
              ? Icons.forum_rounded
              : Icons.person_add_alt_1_rounded,
          color: accentColor,
        ),
      ),
      onToggle: () {
        _setSectionExpanded(_DesktopWidgetSectionKey.team, !_teamExpanded);
      },
      onAnimationEnd: _scheduleWindowHeightSync,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (teamOverview.inTeam &&
              (latestTeamChat != null ||
                  teamOverview.latestChatPreview.isNotEmpty))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SurfacePalette.softSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SurfacePalette.border),
              ),
              child: Text(
                latestTeamChat != null
                    ? '${latestTeamChat.senderDisplayName}: ${latestTeamChat.content}'
                    : teamOverview.latestChatPreview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: SurfacePalette.ink,
                ),
              ),
            ),
          if (teamOverview.inTeam &&
              (latestTeamChat != null ||
                  teamOverview.latestChatPreview.isNotEmpty))
            const SizedBox(height: 12),
          if (!teamOverview.inTeam)
            const _DesktopHintCard(
              icon: Icons.groups_rounded,
              text: '创建团队或通过邀请码加入后，就可以在这里查看队友计划进度并发送提醒。',
            )
          else if (teammatePreview.isEmpty)
            const _DesktopHintCard(
              icon: Icons.person_add_alt_1_rounded,
              text: '团队已经建立，可以继续邀请更多成员共享计划进度和学习时长。',
            )
          else
            ...teammatePreview.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DesktopTeammateTileCompact(
                  member: member,
                  onRemind: widget.isBusy
                      ? null
                      : () async {
                          await widget.onRemindTeammate(member.userId);
                        },
                ),
              );
            }),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                await widget.onOpenTeamWorkspace();
              },
              icon: const Icon(Icons.forum_rounded),
              label: Text(
                teamOverview.inTeam
                    ? _text('打开团队中心', 'Open team center')
                    : _text('创建或加入', 'Create or join'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final widgetSetting = widget.settingOverview.widgetSetting;
    final accentColor = _accentColor();
    final latestNotification = widget.notificationOverview.hasItems
        ? widget.notificationOverview.items.first
        : null;
    final headerMessage = latestNotification == null
        ? _text(
            '手机与 Windows 桌面端会在这里保持同步，下一步操作也会集中展示。',
            'Phone and Windows desktop stay in sync here, with your next actions kept in view.',
          )
        : '${_notificationTypeLabel(context, latestNotification)}: ${latestNotification.content}';

    if (_miniMode) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: AuroraBackground(
          lightStyle: true,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    unawaited(_restoreDesktopWidget());
                  },
                  onPanStart: (_) {
                    unawaited(DesktopWidgetBridge.startWindowDrag());
                  },
                  child: GlassPanel(
                    lightStyle: true,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      key: _contentKey,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'INNOCENCE',
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: SurfacePalette.ink,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _DesktopDragHandle(compact: true),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 72,
                          height: 2,
                          color: SurfacePalette.ink,
                        ),
                        const SizedBox(height: 12),
                        Icon(
                          Icons.widgets_rounded,
                          size: 28,
                          color: accentColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _text('点击展开', 'Tap to open'),
                          style: textTheme.titleSmall?.copyWith(
                            color: SurfacePalette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _text('拖动调整位置', 'Drag to move'),
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: SurfacePalette.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _DesktopMetricChip(
                              label: _text('未读', 'Unread'),
                              value:
                                  '${widget.notificationOverview.unreadCount}',
                              accentColor: const Color(0xFFFFD66B),
                              compact: true,
                            ),
                            _DesktopMetricChip(
                              label: _text('连续', 'Streak'),
                              value: _text(
                                '${widget.checkInStatus.consecutiveDays} 天',
                                '${widget.checkInStatus.consecutiveDays}d',
                              ),
                              accentColor: accentColor,
                              compact: true,
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: AuroraBackground(
        lightStyle: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  key: _contentKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWidgetHeaderCard(
                      context,
                      textTheme,
                      accentColor,
                      headerMessage,
                    ),
                    if (widget.bannerMessage != null) ...[
                      const SizedBox(height: 12),
                      StatusBanner(
                        message: widget.bannerMessage!,
                        onClose: widget.onClearBanner,
                      ),
                    ],
                    if (widgetSetting.showTimer) ...[
                      const SizedBox(height: 12),
                      _buildTimerSection(textTheme, accentColor),
                    ],
                    const SizedBox(height: 12),
                    _buildCheckInSection(textTheme),
                    if (widgetSetting.showPlan) ...[
                      const SizedBox(height: 12),
                      _buildPlanSection(textTheme),
                    ],
                    if (widgetSetting.showMemo) ...[
                      const SizedBox(height: 12),
                      _buildMemoSection(accentColor),
                    ],
                    const SizedBox(height: 12),
                    _buildTeamSection(textTheme, accentColor),
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

class _DesktopCollapsibleSection extends StatelessWidget {
  const _DesktopCollapsibleSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tagLabel,
    required this.collapsedSummary,
    required this.accentColor,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.headerAction,
    this.onAnimationEnd,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tagLabel;
  final String collapsedSummary;
  final Color accentColor;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final Widget? headerAction;
  final VoidCallback? onAnimationEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassPanel(
      lightStyle: true,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: SurfacePalette.softSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: SurfacePalette.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: SurfacePalette.ink, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: textTheme.titleLarge?.copyWith(
                                  color: SurfacePalette.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _Tag(label: tagLabel),
                            if (headerAction != null) ...[
                              const SizedBox(width: 8),
                              headerAction!,
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          expanded ? subtitle : collapsedSummary,
                          maxLines: expanded ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: expanded
                                ? SurfacePalette.muted
                                : SurfacePalette.ink,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: SurfacePalette.subtle,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            onEnd: onAnimationEnd,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DesktopDragHandle extends StatelessWidget {
  const _DesktopDragHandle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = SurfacePalette.subtle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 3),
          child: Container(
            width: compact ? 4 : 5,
            height: compact ? 18 : 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _DesktopPlanItemTileCompact extends StatelessWidget {
  const _DesktopPlanItemTileCompact({
    required this.item,
    required this.accentColor,
    this.onToggle,
  });

  final TodayPlanItem item;
  final Color accentColor;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: SurfacePalette.softSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: item.completed,
                  activeColor: accentColor,
                  visualDensity: const VisualDensity(
                    horizontal: -3,
                    vertical: -3,
                  ),
                  onChanged: onToggle == null ? null : (_) => onToggle!(),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty
                          ? _contextText(context, '未命名任务', 'Unnamed task')
                          : item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: SurfacePalette.ink,
                        fontWeight: FontWeight.w600,
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_todayPlanItemScheduleLabel(context, item)} | ${_todayPlanItemDurationLabel(context, item)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: SurfacePalette.subtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopMemoTileCompact extends StatelessWidget {
  const _DesktopMemoTileCompact({required this.memo});

  final MemoCardModel memo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                memo.displayTitle,
                style: textTheme.titleSmall?.copyWith(
                  color: SurfacePalette.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _Tag(label: memo.progressLabel),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            memo.summaryText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTeammateTileCompact extends StatelessWidget {
  const _DesktopTeammateTileCompact({
    required this.member,
    this.onRemind,
  });

  final TeamMember member;
  final VoidCallback? onRemind;

  @override
  Widget build(BuildContext context) {
    String text(String zh, String en) => _contextText(context, zh, en);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _teamMemberDisplayName(context, member),
                      style: textTheme.titleSmall?.copyWith(
                        color: SurfacePalette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.completedTodayPlan)
                      _Tag(label: text('计划完成', 'Plan done')),
                    if (member.activeStudy)
                      _Tag(label: _teamMemberStageLabel(context, member)),
                    if (member.owner) _Tag(label: text('队长', 'Captain')),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text(
                    '今日 ${member.todayPlanProgressLabel} | ${_teamMemberTodayStudyLabel(context, member)}',
                    'Today ${member.todayPlanProgressLabel} | ${_teamMemberTodayStudyLabel(context, member)}',
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: SurfacePalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text(
                    '累计 ${_teamMemberTotalStudyLabel(context, member)} | ${member.totalCheckInDays} 次签到',
                    'Total ${_teamMemberTotalStudyLabel(context, member)} | ${member.totalCheckInDays} check-ins',
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    color: SurfacePalette.subtle,
                  ),
                ),
                if (member.activeTaskName.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    member.activeTaskName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: SurfacePalette.subtle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onRemind,
            icon: const Icon(Icons.notifications_active_rounded),
            label: Text(text('提醒', 'Nudge')),
          ),
        ],
      ),
    );
  }
}
