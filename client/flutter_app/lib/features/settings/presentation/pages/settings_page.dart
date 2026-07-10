import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_announcement_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_report_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_team_management_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_user_management_page.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/notification_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/privacy_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.onChangeLanguage,
    required this.initialOverview,
    required this.onRefresh,
    required this.onUpdateProfile,
    required this.onUpdatePrivacy,
    required this.onUpdateNotifications,
    required this.onUpdateWidget,
    required this.onUpdateAppearance,
    required this.onClearCache,
    required this.onSendCancelCode,
    required this.onCancelAccount,
    required this.onLogout,
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
  });

  final Future<void> Function(
    AppLanguage language, {
    bool confirmStartup,
  }) onChangeLanguage;
  final SettingOverview initialOverview;
  final Future<SettingOverview?> Function() onRefresh;
  final Future<UserProfile?> Function({
    required String nickname,
    required String avatarUrl,
    required String bio,
  }) onUpdateProfile;
  final Future<PrivacySetting?> Function({
    required bool allowFriendViewProfile,
    required bool allowTeammateViewStudy,
  }) onUpdatePrivacy;
  final Future<NotificationSetting?> Function({
    required bool mobilePushEnabled,
    required bool desktopNoticeEnabled,
    required bool teamRemindEnabled,
    required bool systemAnnouncementEnabled,
  }) onUpdateNotifications;
  final Future<WidgetSetting?> Function({
    required bool autoStart,
    required bool alwaysOnTop,
    required bool showPlan,
    required bool showTimer,
    required bool showMemo,
  }) onUpdateWidget;
  final Future<AppearanceSetting?> Function({
    required String themeMode,
    required String desktopEffect,
  }) onUpdateAppearance;
  final Future<bool> Function() onClearCache;
  final Future<void> Function(String email) onSendCancelCode;
  final Future<bool> Function({
    String password,
    String emailCode,
  }) onCancelAccount;
  final Future<void> Function() onLogout;
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

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingOverview _overview;
  bool _isLoading = false;

  String _text(String zh, String en) {
    return localizedText(context, zh, en);
  }

  String _accountDisplayName(UserProfile profile) {
    if (profile.nickname.trim().isNotEmpty) {
      return profile.nickname.trim();
    }
    if (profile.userNo.trim().isNotEmpty) {
      return profile.userNo.trim();
    }
    return _text('我', 'Me');
  }

  String _appearanceThemeLabel(AppearanceSetting appearance) {
    return appearance.isLightMode ? _text('浅色', 'Light') : _text('深色', 'Dark');
  }

  String _appearanceEffectLabel(AppearanceSetting appearance) {
    switch (appearance.desktopEffect) {
      case 'soft_glass':
        return _text('柔和玻璃', 'Soft glass');
      case 'focus_glow':
        return _text('专注光效', 'Focus glow');
      default:
        return _text('沉浸毛玻璃', 'Immersive glass');
    }
  }

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
  }

  Future<void> _refresh() async {
    await _runOverviewAction(
      widget.onRefresh,
      fallbackMessage:
          _text('当前无法刷新设置，请稍后再试。', 'Unable to refresh settings right now.'),
    );
  }

  Future<void> _editProfile() async {
    final current = _overview.accountSetting;
    final nicknameController = TextEditingController(text: current.nickname);
    final avatarController = TextEditingController(text: current.avatarUrl);
    final bioController = TextEditingController(text: current.bio);
    final draft = await showDialog<_ProfileDraft>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('编辑资料', 'Edit profile')),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nicknameController,
                    maxLength: 64,
                    decoration: InputDecoration(
                      labelText: _text('昵称', 'Nickname'),
                      hintText: _text('队友看到你的名字', 'How teammates will see you'),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avatarController,
                    maxLength: 255,
                    decoration: InputDecoration(
                      labelText: _text('头像地址', 'Avatar URL'),
                      hintText: _text('可选的头像图片地址', 'Optional image address'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioController,
                    maxLength: 255,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _text('简介', 'Bio'),
                      hintText:
                          _text('一句简短的学习介绍', 'A short study introduction'),
                    ),
                  ),
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
              onPressed: () {
                Navigator.of(context).pop(
                  _ProfileDraft(
                    nickname: nicknameController.text.trim(),
                    avatarUrl: avatarController.text.trim(),
                    bio: bioController.text.trim(),
                  ),
                );
              },
              child: Text(_text('保存', 'Save')),
            ),
          ],
        );
      },
    );
    nicknameController.dispose();
    avatarController.dispose();
    bioController.dispose();

    if (draft == null || draft.nickname.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final updatedProfile = await widget.onUpdateProfile(
        nickname: draft.nickname,
        avatarUrl: draft.avatarUrl,
        bio: draft.bio,
      );
      if (!mounted) {
        return;
      }
      if (updatedProfile == null) {
        _showMessage(_text('资料保存失败。', 'Unable to save the profile.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(accountSetting: updatedProfile);
      });
      _showMessage(_text('资料已保存。', 'Profile saved.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setFriendProfileVisible(bool value) async {
    final current = _overview.privacySetting;
    await _updatePrivacy(
      current.copyWith(allowFriendViewProfile: value),
    );
  }

  Future<void> _setTeammateStudyVisible(bool value) async {
    final current = _overview.privacySetting;
    await _updatePrivacy(
      current.copyWith(allowTeammateViewStudy: value),
    );
  }

  Future<void> _updatePrivacy(PrivacySetting next) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await widget.onUpdatePrivacy(
        allowFriendViewProfile: next.allowFriendViewProfile,
        allowTeammateViewStudy: next.allowTeammateViewStudy,
      );
      if (!mounted) {
        return;
      }
      if (updated == null) {
        _showMessage(_text('隐私设置保存失败。', 'Unable to save privacy settings.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(privacySetting: updated);
      });
      _showMessage(_text('隐私设置已更新。', 'Privacy settings updated.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateNotifications(NotificationSetting next) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await widget.onUpdateNotifications(
        mobilePushEnabled: next.mobilePushEnabled,
        desktopNoticeEnabled: next.desktopNoticeEnabled,
        teamRemindEnabled: next.teamRemindEnabled,
        systemAnnouncementEnabled: next.systemAnnouncementEnabled,
      );
      if (!mounted) {
        return;
      }
      if (updated == null) {
        _showMessage(
            _text('通知设置保存失败。', 'Unable to save notification settings.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(notificationSetting: updated);
      });
      _showMessage(_text('通知设置已更新。', 'Notification settings updated.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateWidgetSetting(WidgetSetting next) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await widget.onUpdateWidget(
        autoStart: next.autoStart,
        alwaysOnTop: next.alwaysOnTop,
        showPlan: next.showPlan,
        showTimer: next.showTimer,
        showMemo: next.showMemo,
      );
      if (!mounted) {
        return;
      }
      if (updated == null) {
        _showMessage(_text('挂件设置保存失败。', 'Unable to save widget settings.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(widgetSetting: updated);
      });
      _showMessage(_text('桌面挂件设置已更新。', 'Desktop widget settings updated.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAppearance(AppearanceSetting next) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updated = await widget.onUpdateAppearance(
        themeMode: next.themeMode,
        desktopEffect: next.desktopEffect,
      );
      if (!mounted) {
        return;
      }
      if (updated == null) {
        _showMessage(_text('外观设置保存失败。', 'Unable to save appearance settings.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(appearanceSetting: updated);
      });
      _showMessage(_text('外观设置已更新。', 'Appearance settings updated.'));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onChangeLanguage(
        language,
        confirmStartup: true,
      );
      if (!mounted) {
        return;
      }
      setState(() {});
      _showMessage(
        language == AppLanguage.simplifiedChinese
            ? _text('语言已切换为简体中文。', 'Language switched to Simplified Chinese.')
            : _text('语言已切换为英文。', 'Language switched to English.'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cleared = await widget.onClearCache();
      if (!mounted) {
        return;
      }
      _showMessage(
        cleared
            ? _text('缓存已清理。', 'Cache cleared.')
            : _text('未清理任何缓存。', 'Cache was not cleared.'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onLogout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).maybePop();
  }

  Future<void> _closeApp() async {
    await SystemNavigator.pop();
  }

  Future<void> _openAdminReportPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AdminReportPage(
            onLoadReports: widget.onLoadAdminReports,
            onLoadDetail: widget.onLoadAdminReportDetail,
            onReview: widget.onReviewAdminReport,
          );
        },
      ),
    );
  }

  Future<void> _openAdminUserPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AdminUserManagementPage(
            onSearchUsers: widget.onSearchAdminUsers,
            onLoadUserDetail: widget.onLoadAdminUserDetail,
            onLoadUserReports: widget.onLoadAdminUserReports,
            onLoadUserPunishments: widget.onLoadAdminUserPunishments,
            onLiftPunishment: widget.onLiftAdminUserPunishment,
          );
        },
      ),
    );
  }

  Future<void> _openAdminTeamPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AdminTeamManagementPage(
            onLoadTeams: widget.onLoadAdminTeams,
            onLoadTeamDetail: widget.onLoadAdminTeamDetail,
            onRemoveMember: widget.onRemoveAdminTeamMember,
            onDissolveTeam: widget.onDissolveAdminTeam,
          );
        },
      ),
    );
  }

  Future<void> _openAdminAnnouncementPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return AdminAnnouncementPage(
            onLoadAnnouncements: widget.onLoadAdminAnnouncements,
            onCreateAnnouncement: widget.onCreateAdminAnnouncement,
            onDeleteAnnouncement: widget.onDeleteAdminAnnouncement,
          );
        },
      ),
    );
  }

  Future<void> _cancelAccount() async {
    final profile = _overview.accountSetting;
    final draft = await showDialog<_CancelAccountDraft>(
      context: context,
      builder: (context) => _CancelAccountDialog(
        userLabel: _accountDisplayName(profile),
        onSendCode: widget.onSendCancelCode,
      ),
    );
    if (draft == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final cancelled = await widget.onCancelAccount(
        password: draft.password,
        emailCode: draft.emailCode,
      );
      if (!mounted) {
        return;
      }
      if (!cancelled) {
        _showMessage(
            _text('账号注销未完成。', 'Account cancellation did not complete.'));
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runOverviewAction(
    Future<SettingOverview?> Function() action, {
    required String fallbackMessage,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final overview = await action();
      if (!mounted) {
        return;
      }
      if (overview == null) {
        _showMessage(fallbackMessage);
        return;
      }
      setState(() {
        _overview = overview;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = SurfacePalette.homeTheme().textTheme;
    final account = _overview.accountSetting;
    final privacy = _overview.privacySetting;
    final notifications = _overview.notificationSetting;
    final widgetSetting = _overview.widgetSetting;
    final appearance = _overview.appearanceSetting;

    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('系统设置', 'System settings'),
      description: _text(
        '在这里统一管理账号、隐私、通知、挂件行为和桌面显示风格。',
        'Control account, privacy, notifications, widget behavior, and the desktop look from one place.',
      ),
      headerActions: [
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _refresh,
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(_text('刷新', 'Refresh')),
        ),
      ],
      children: [
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('语言', 'Language'),
            subtitle: _text(
              '这里可以切换进入软件后的显示语言。',
              'Switch the display language used after entering the app.',
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppLanguage.values.map((language) {
                final selected = Localizations.localeOf(context).languageCode ==
                    language.locale.languageCode;
                return ChoiceChip(
                  selected: selected,
                  label: Text(language.label),
                  onSelected: _isLoading
                      ? null
                      : (_) async {
                          if (selected) {
                            return;
                          }
                          await _changeLanguage(language);
                        },
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('账号', 'Account'),
            subtitle: _text(
              '这里是手机和电脑共用的熟人圈账号资料。',
              'This is the trusted-circle account profile shared on phone and desktop.',
            ),
            trailing: OutlinedButton.icon(
              onPressed: _isLoading ? null : _editProfile,
              icon: const Icon(Icons.edit_rounded),
              label: Text(_text('编辑资料', 'Edit profile')),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(
                  label: _text('昵称', 'Nickname'),
                  value: _accountDisplayName(account),
                ),
                _InfoLine(
                  label: _text('用户号', 'User No'),
                  value: account.userNo.isEmpty
                      ? _text('待生成', 'Pending')
                      : account.userNo,
                ),
                _InfoLine(
                  label: _text('时区', 'Timezone'),
                  value: account.timezone.isEmpty
                      ? 'Asia/Shanghai'
                      : account.timezone,
                ),
                _InfoLine(
                  label: _text('头像地址', 'Avatar URL'),
                  value: account.avatarUrl.isEmpty
                      ? _text('未设置', 'Not set')
                      : account.avatarUrl,
                ),
                if (account.bio.isNotEmpty)
                  _InfoLine(
                    label: _text('简介', 'Bio'),
                    value: account.bio,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('隐私', 'Privacy'),
            subtitle: _text(
              '只有好友能看资料，只有队友能看学习数据。',
              'Only friends can view profile details, and only teammates can view study data.',
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: privacy.allowFriendViewProfile,
                  onChanged: _isLoading
                      ? null
                      : (value) => _setFriendProfileVisible(value),
                  title: Text(_text('好友可见资料', 'Friends can view profile')),
                  subtitle: Text(
                    _text(
                      '详细资料仅对你的好友开放。',
                      'Keep your detailed profile visible only inside your friend list.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: privacy.allowTeammateViewStudy,
                  onChanged: _isLoading
                      ? null
                      : (value) => _setTeammateStudyVisible(value),
                  title: Text(
                    _text('队友可见学习数据', 'Teammates can view study data'),
                  ),
                  subtitle: Text(
                    _text(
                      '允许队友查看学习时长和计划完成进度。',
                      'Let teammates see duration and completion progress inside the team.',
                    ),
                  ),
                ),
                _StaticHintRow(
                  title: _text('陌生人私信规则', 'Stranger message policy'),
                  value: _text('已拦截', 'Blocked'),
                  note: _text(
                    '当前产品方向下，陌生人不能给你发送私信。',
                    'Strangers cannot send private messages in this product direction.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('通知', 'Notifications'),
            subtitle: _text(
              '学习核心事件支持手机推送和桌面系统通知。',
              'Mobile push plus desktop system notices for core study events.',
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: notifications.mobilePushEnabled,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateNotifications(
                            notifications.copyWith(mobilePushEnabled: value),
                          ),
                  title: Text(_text('手机推送', 'Mobile push')),
                  subtitle: Text(
                    _text(
                      '向安卓应用发送推送提醒。',
                      'Send push updates to the Android app.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: notifications.desktopNoticeEnabled,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateNotifications(
                            notifications.copyWith(desktopNoticeEnabled: value),
                          ),
                  title: Text(_text('桌面通知', 'Desktop notice')),
                  subtitle: Text(
                    _text(
                      '使用 Windows 系统通知展示挂件事件。',
                      'Use Windows system notifications for widget events.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: notifications.teamRemindEnabled,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateNotifications(
                            notifications.copyWith(teamRemindEnabled: value),
                          ),
                  title: Text(_text('队友提醒', 'Teammate reminders')),
                  subtitle: Text(
                    _text(
                      '接收队友发来的提醒消息。',
                      'Receive reminders sent by your teammates.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: notifications.systemAnnouncementEnabled,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateNotifications(
                            notifications.copyWith(
                              systemAnnouncementEnabled: value,
                            ),
                          ),
                  title: Text(_text('系统公告', 'System announcements')),
                  subtitle: Text(
                    _text(
                      '保留项目级的重要通知。',
                      'Keep project-level updates visible.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('桌面挂件', 'Desktop widget'),
            subtitle: _text(
              '这里可以控制桌面挂件的基础行为。',
              'Simple behavior controls for the desktop companion window.',
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: widgetSetting.autoStart,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateWidgetSetting(
                            widgetSetting.copyWith(autoStart: value),
                          ),
                  title: Text(_text('开机启动', 'Auto start')),
                  subtitle: Text(
                    _text(
                      '随 Windows 一起启动桌面挂件。',
                      'Launch the desktop widget with Windows.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: widgetSetting.alwaysOnTop,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateWidgetSetting(
                            widgetSetting.copyWith(alwaysOnTop: value),
                          ),
                  title: Text(_text('始终置顶', 'Always on top')),
                  subtitle: Text(
                    _text(
                      '让挂件始终浮在其他窗口上方。',
                      'Keep the desktop widget floating above other windows.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: widgetSetting.showPlan,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateWidgetSetting(
                            widgetSetting.copyWith(showPlan: value),
                          ),
                  title: Text(_text('显示计划', 'Show plan')),
                  subtitle: Text(
                    _text(
                      '在挂件中显示今日计划摘要。',
                      'Display today plan summary inside the widget.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: widgetSetting.showTimer,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateWidgetSetting(
                            widgetSetting.copyWith(showTimer: value),
                          ),
                  title: Text(_text('显示计时器', 'Show timer')),
                  subtitle: Text(
                    _text(
                      '显示当前学习计时器和番茄状态。',
                      'Display active study timer and pomodoro state.',
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: widgetSetting.showMemo,
                  onChanged: _isLoading
                      ? null
                      : (value) => _updateWidgetSetting(
                            widgetSetting.copyWith(showMemo: value),
                          ),
                  title: Text(_text('显示备忘录', 'Show memo')),
                  subtitle: Text(
                    _text(
                      '在挂件中显示备忘录摘要卡片。',
                      'Display memo summary cards in the widget.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('外观', 'Appearance'),
            subtitle: _text(
              '这里可以切换明暗模式，并预留桌面视觉风格选项。',
              'Switch between light and dark, and prepare the desktop style.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('主题模式', 'Theme mode'),
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: 'dark',
                      label: Text(_text('深色', 'Dark')),
                      icon: const Icon(Icons.dark_mode_rounded),
                    ),
                    ButtonSegment<String>(
                      value: 'light',
                      label: Text(_text('浅色', 'Light')),
                      icon: const Icon(Icons.light_mode_rounded),
                    ),
                  ],
                  selected: {appearance.themeMode},
                  onSelectionChanged: _isLoading
                      ? null
                      : (selection) async {
                          final nextValue = selection.first;
                          await _updateAppearance(
                            appearance.copyWith(themeMode: nextValue),
                          );
                        },
                ),
                const SizedBox(height: 12),
                _InfoLine(
                  label: _text('当前主题', 'Current theme'),
                  value: _appearanceThemeLabel(appearance),
                ),
                const SizedBox(height: 18),
                Text(
                  _text('桌面效果', 'Desktop effect'),
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _EffectOption(
                      value: 'immersive_glass',
                      label: _text('沉浸毛玻璃', 'Immersive glass'),
                      hint: _text(
                        '更偏沉浸式的桌面层次感',
                        'Apple-style translucent layer',
                      ),
                    ),
                    _EffectOption(
                      value: 'soft_glass',
                      label: _text('柔和玻璃', 'Soft glass'),
                      hint: _text(
                        '更轻、更柔和的透明感',
                        'Lighter, calmer translucency',
                      ),
                    ),
                    _EffectOption(
                      value: 'focus_glow',
                      label: _text('专注光效', 'Focus glow'),
                      hint: _text(
                        '更强调专注氛围的光感',
                        'Glow-forward study atmosphere',
                      ),
                    ),
                  ].map((option) {
                    final selected = appearance.desktopEffect == option.value;
                    return ChoiceChip(
                      selected: selected,
                      onSelected: _isLoading
                          ? null
                          : (_) async {
                              await _updateAppearance(
                                appearance.copyWith(
                                  desktopEffect: option.value,
                                ),
                              );
                            },
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.label),
                          const SizedBox(height: 2),
                          Text(
                            option.hint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _InfoLine(
                  label: _text('当前桌面效果', 'Current desktop effect'),
                  value: _appearanceEffectLabel(appearance),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('后台管理', 'Admin tools'),
            subtitle: _text(
              '这里放简版举报、用户、团队和公告管理入口。',
              'Moderation tools for reports, users, teams, and system announcements.',
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _openAdminAnnouncementPage,
                  icon: const Icon(Icons.campaign_rounded),
                  label: Text(_text('公告管理', 'Open announcements')),
                ),
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _openAdminTeamPage,
                  icon: const Icon(Icons.groups_rounded),
                  label: Text(_text('团队管理', 'Open team management')),
                ),
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _openAdminUserPage,
                  icon: const Icon(Icons.manage_accounts_rounded),
                  label: Text(_text('用户管理', 'Open user management')),
                ),
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _openAdminReportPage,
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  label: Text(_text('举报审核', 'Open report moderation')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('快捷操作', 'Quick actions'),
            subtitle: _text(
              '当前设备的一些轻量维护操作。',
              'Lightweight maintenance actions for the current device.',
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _clearCache,
                  icon: const Icon(Icons.cleaning_services_rounded),
                  label: Text(_text('清理缓存', 'Clear cache')),
                ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(_text('退出登录', 'Sign out')),
                ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _closeApp,
                  icon: const Icon(Icons.power_settings_new_rounded),
                  label: Text(_text('退出程序', 'Close app')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _SettingSection(
            title: _text('危险操作', 'Danger zone'),
            subtitle: _text(
              '当前版本中，注销账号会立即生效，请谨慎操作。',
              'Account cancellation takes effect immediately. Please use it carefully.',
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _cancelAccount,
                  icon: const Icon(Icons.person_off_rounded),
                  label: Text(_text('注销账号', 'Cancel account')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
                Text(title, style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(subtitle, style: textTheme.bodyLarge),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SurfacePalette.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StaticHintRow extends StatelessWidget {
  const _StaticHintRow({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title：$value',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SurfacePalette.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(note, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EffectOption {
  const _EffectOption({
    required this.value,
    required this.label,
    required this.hint,
  });

  final String value;
  final String label;
  final String hint;
}

class _ProfileDraft {
  const _ProfileDraft({
    required this.nickname,
    required this.avatarUrl,
    required this.bio,
  });

  final String nickname;
  final String avatarUrl;
  final String bio;
}

class _CancelAccountDraft {
  const _CancelAccountDraft({
    required this.password,
    required this.emailCode,
  });

  final String password;
  final String emailCode;
}

class _CancelAccountDialog extends StatefulWidget {
  const _CancelAccountDialog({
    required this.userLabel,
    required this.onSendCode,
  });

  final String userLabel;
  final Future<void> Function(String email) onSendCode;

  @override
  State<_CancelAccountDialog> createState() => _CancelAccountDialogState();
}

class _CancelAccountDialogState extends State<_CancelAccountDialog> {
  late final TextEditingController _passwordController;
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  bool _isSending = false;
  String? _message;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) {
    return _isChinese ? zh : en;
  }

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = _text('请先输入注册邮箱。', 'Enter the registered email first.');
      });
      return;
    }
    setState(() {
      _isSending = true;
      _message = null;
    });
    try {
      await widget.onSendCode(email);
      if (!mounted) {
        return;
      }
      setState(() {
        _message = _text('验证码已发送到注册邮箱。',
            'Verification code sent to the registered mailbox.');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _confirm() {
    final password = _passwordController.text.trim();
    final code = _codeController.text.trim();
    if (password.isEmpty && code.isEmpty) {
      setState(() {
        _message = _text(
            '请输入密码或邮箱验证码后继续。', 'Enter password or email code to continue.');
      });
      return;
    }
    Navigator.of(context).pop(
      _CancelAccountDraft(
        password: password,
        emailCode: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_text('注销账号', 'Cancel account')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text(
                  '这将注销当前账号 ${widget.userLabel}。请使用密码或邮箱验证码确认。',
                  'This will remove the current account for ${widget.userLabel}. Use password or email verification code to confirm.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _text('密码', 'Password'),
                  hintText:
                      _text('如果使用邮箱验证码，这里可不填', 'Optional if using email code'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _text('注册邮箱', 'Registered email'),
                  hintText: _text(
                      '发送验证码时需要填写', 'Needed when sending a verification code'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: _text('邮箱验证码', 'Email code'),
                  hintText: _text('如果使用密码，这里可不填', 'Optional if using password'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSending ? null : _sendCode,
                icon: _isSending
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.mark_email_read_rounded),
                label: Text(_text('发送验证码', 'Send code')),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SurfacePalette.ink,
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
          onPressed: _confirm,
          child: Text(_text('确认', 'Confirm')),
        ),
      ],
    );
  }
}
