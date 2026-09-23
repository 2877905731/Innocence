import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_announcement_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_report_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_team_management_page.dart';
import 'package:innocence_flutter/features/admin/presentation/pages/admin_user_management_page.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/account/domain/models/blacklist_item.dart';
import 'package:innocence_flutter/features/account/domain/models/current_device_session.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/notification_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/privacy_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';
import 'package:innocence_flutter/features/settings/presentation/settings_presentation.dart';

enum _SettingsSectionId {
  language,
  account,
  privacy,
  session,
  notifications,
  desktop,
  appearance,
  admin,
  quickActions,
  danger,
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.isOfflineMode,
    required this.onChangeLanguage,
    required this.visualTheme,
    required this.onChangeVisualTheme,
    required this.initialOverview,
    required this.onRefresh,
    required this.onLoadBlacklist,
    required this.onAddBlacklist,
    required this.onRemoveBlacklist,
    required this.onLoadCurrentDeviceSession,
    required this.onUpdateProfile,
    required this.onUploadAvatar,
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

  final bool isOfflineMode;
  final Future<void> Function(
    AppLanguage language, {
    bool confirmStartup,
  }) onChangeLanguage;
  final AppVisualTheme visualTheme;
  final ValueChanged<AppVisualTheme> onChangeVisualTheme;
  final SettingOverview initialOverview;
  final Future<SettingOverview?> Function() onRefresh;
  final Future<List<BlacklistItem>> Function() onLoadBlacklist;
  final Future<bool> Function(int targetUserId) onAddBlacklist;
  final Future<bool> Function(int blockedUserId) onRemoveBlacklist;
  final Future<CurrentDeviceSession?> Function() onLoadCurrentDeviceSession;
  final Future<UserProfile?> Function({
    required String nickname,
    required String avatarUrl,
    required String bio,
  }) onUpdateProfile;
  final Future<UserProfile?> Function({
    required List<int> bytes,
    required String filename,
  }) onUploadAvatar;
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
  late AppVisualTheme _visualTheme;
  List<BlacklistItem> _blacklist = const [];
  CurrentDeviceSession? _currentDeviceSession;
  bool _isLoading = false;
  bool _isPrivacyContextLoading = true;
  _SettingsSectionId _selectedSection = _SettingsSectionId.account;
  bool _smallDetailOpen = false;

  List<_SettingsSectionId> get _availableSections => widget.isOfflineMode
      ? const [
          _SettingsSectionId.language,
          _SettingsSectionId.account,
          _SettingsSectionId.desktop,
          _SettingsSectionId.appearance,
          _SettingsSectionId.quickActions,
        ]
      : _SettingsSectionId.values;

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

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
    _visualTheme = widget.visualTheme;
    if (widget.isOfflineMode) {
      _isPrivacyContextLoading = false;
    } else {
      _loadPrivacyContext();
    }
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualTheme != widget.visualTheme &&
        _visualTheme != widget.visualTheme) {
      _visualTheme = widget.visualTheme;
    }
  }

  void _changeVisualTheme(AppVisualTheme visualTheme) {
    if (_visualTheme == visualTheme) {
      return;
    }
    setState(() => _visualTheme = visualTheme);
    widget.onChangeVisualTheme(visualTheme);
  }

  Future<void> _loadPrivacyContext() async {
    if (widget.isOfflineMode) {
      return;
    }
    try {
      final blacklist = await widget.onLoadBlacklist();
      if (mounted) {
        setState(() => _blacklist = blacklist);
      }
    } catch (_) {
      // The settings overview remains usable when a secondary privacy read fails.
    }
    try {
      final currentSession = await widget.onLoadCurrentDeviceSession();
      if (mounted) {
        setState(() => _currentDeviceSession = currentSession);
      }
    } catch (_) {
      // The session status is supplementary and must not block profile editing.
    }
    if (mounted) {
      setState(() {
        _isPrivacyContextLoading = false;
      });
    }
  }

  String _deviceLabel(CurrentDeviceSession session) {
    switch (session.deviceType.trim().toLowerCase()) {
      case 'windows':
        return _text('Windows 桌面端', 'Windows desktop');
      case 'android':
        return _text('Android 手机端', 'Android phone');
      default:
        return session.deviceType.isEmpty
            ? _text('未知设备', 'Unknown device')
            : session.deviceType;
    }
  }

  String _sessionStateLabel(CurrentDeviceSession session) {
    if (session.replaced) {
      return _text('已被同类型新设备替换', 'Replaced by a newer device');
    }
    if (session.online) {
      return _text('当前在线', 'Currently online');
    }
    return _text('已离线', 'Offline');
  }

  Future<void> _refresh() async {
    await _runOverviewAction(
      widget.onRefresh,
      fallbackMessage:
          _text('当前无法刷新设置，请稍后再试。', 'Unable to refresh settings right now.'),
    );
    await _loadPrivacyContext();
  }

  Future<void> _addBlacklist() async {
    final controller = TextEditingController();
    final rawUserId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('加入黑名单', 'Add to blacklist')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: _text('用户 ID', 'User ID'),
              helperText: _text(
                '拉黑会解除现有好友关系并阻止后续互动。',
                'Blocking removes the friend relationship and stops interaction.',
              ),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(_text('确认拉黑', 'Block user')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (rawUserId == null || !mounted) {
      return;
    }
    final targetUserId = int.tryParse(rawUserId) ?? 0;
    if (targetUserId <= 0) {
      _showMessage(_text('请输入有效的用户 ID。', 'Enter a valid user ID.'));
      return;
    }
    if (targetUserId == _overview.accountSetting.userId) {
      _showMessage(_text('不能拉黑自己。', 'You cannot block yourself.'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final added = await widget.onAddBlacklist(targetUserId);
      if (!mounted) {
        return;
      }
      if (!added) {
        _showMessage(_text('加入黑名单失败。', 'Unable to add the entry.'));
        return;
      }
      await _loadPrivacyContext();
      if (mounted) {
        _showMessage(_text('已加入黑名单。', 'Added to the blacklist.'));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeBlacklist(BlacklistItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('解除拉黑？', 'Remove from blacklist?')),
        content: Text(
          _text(
            '解除后，对方仍需满足好友和隐私规则才能查看资料或发起互动。',
            'Removing the entry does not bypass friend or privacy rules.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text('解除拉黑', 'Remove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final removed = await widget.onRemoveBlacklist(item.blockedUserId);
    if (!mounted) {
      return;
    }
    if (removed) {
      setState(() {
        _blacklist = _blacklist
            .where((entry) => entry.blockedUserId != item.blockedUserId)
            .toList(growable: false);
      });
      _showMessage(_text('已解除拉黑。', 'Removed from the blacklist.'));
    } else {
      _showMessage(_text('解除拉黑失败。', 'Unable to remove the entry.'));
    }
  }

  Future<void> _editProfile() async {
    final current = _overview.accountSetting;
    final nicknameController = TextEditingController(text: current.nickname);
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
        avatarUrl: current.avatarUrl,
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

  String _sectionLabel(_SettingsSectionId section) {
    return switch (section) {
      _SettingsSectionId.language => _text('语言', 'Language'),
      _SettingsSectionId.account => _text('账户资料', 'Account profile'),
      _SettingsSectionId.privacy => _text('隐私与黑名单', 'Privacy & blacklist'),
      _SettingsSectionId.session => _text('设备会话', 'Device session'),
      _SettingsSectionId.notifications => _text('通知', 'Notifications'),
      _SettingsSectionId.desktop => _text('桌面体验', 'Desktop experience'),
      _SettingsSectionId.appearance => _text('外观', 'Appearance'),
      _SettingsSectionId.admin => _text('后台管理', 'Admin tools'),
      _SettingsSectionId.quickActions => _text('关于与维护', 'About & maintenance'),
      _SettingsSectionId.danger => _text('注销账号', 'Cancel account'),
    };
  }

  IconData _sectionIcon(_SettingsSectionId section) {
    return switch (section) {
      _SettingsSectionId.language => Icons.translate_rounded,
      _SettingsSectionId.account => Icons.person_outline_rounded,
      _SettingsSectionId.privacy => Icons.shield_outlined,
      _SettingsSectionId.session => Icons.devices_rounded,
      _SettingsSectionId.notifications => Icons.notifications_none_rounded,
      _SettingsSectionId.desktop => Icons.desktop_windows_outlined,
      _SettingsSectionId.appearance => Icons.palette_outlined,
      _SettingsSectionId.admin => Icons.admin_panel_settings_outlined,
      _SettingsSectionId.quickActions => Icons.info_outline_rounded,
      _SettingsSectionId.danger => Icons.person_off_outlined,
    };
  }

  void _selectSection(
    _SettingsSectionId section, {
    required bool openSmallDetail,
  }) {
    setState(() {
      _selectedSection = section;
      _smallDetailOpen = openSmallDetail;
    });
  }

  Widget _buildSectionNavigation(DesktopPresentationTier tier) {
    final items = _availableSections;
    final visualTheme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme ??
            _visualTheme;
    final tokens = AppVisualTokens.of(visualTheme);
    final glass = visualTheme == AppVisualTheme.glass;
    final softSpectrum = visualTheme == AppVisualTheme.minimalism;
    final radius = switch (visualTheme) {
      AppVisualTheme.minimalism => 20.0,
      AppVisualTheme.wabiSabi => 0.0,
      AppVisualTheme.midCentury => 16.0,
      AppVisualTheme.glass => 20.0,
    };
    if (tier == DesktopPresentationTier.medium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: glass ? const Color(0x36101D3B) : tokens.softPanel,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: glass ? const Color(0x3FFFFFFF) : tokens.line,
          ),
          boxShadow: glass
              ? const [
                  BoxShadow(
                    color: Color(0x305F8CFF),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ]
              : softSpectrum
                  ? const [
                      BoxShadow(
                        color: Color(0x14252635),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ]
                  : null,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (section) => ChoiceChip(
                  selected: section == _selectedSection,
                  avatar: Icon(_sectionIcon(section), size: 18),
                  label: Text(_sectionLabel(section)),
                  onSelected: (_) => _selectSection(
                    section,
                    openSmallDetail: false,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: glass ? const Color(0x36101D3B) : tokens.softPanel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: glass ? const Color(0x3FFFFFFF) : tokens.line,
        ),
        boxShadow: glass
            ? const [
                BoxShadow(
                  color: Color(0x305F8CFF),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ]
            : softSpectrum
                ? const [
                    BoxShadow(
                      color: Color(0x14252635),
                      blurRadius: 26,
                      offset: Offset(0, 11),
                    ),
                  ]
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (section) => Material(
                type: MaterialType.transparency,
                child: ListTile(
                  selected: tier == DesktopPresentationTier.large &&
                      section == _selectedSection,
                  leading: Icon(_sectionIcon(section)),
                  title: Text(_sectionLabel(section)),
                  trailing: tier == DesktopPresentationTier.small
                      ? const Icon(Icons.chevron_right_rounded)
                      : null,
                  onTap: () => _selectSection(
                    section,
                    openSmallDetail: tier == DesktopPresentationTier.small,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  List<Widget> _composeAdaptiveSections(
    DesktopPresentationTier tier,
    List<_SettingsSurface> panes,
  ) {
    final selectedPane = panes.firstWhere(
      (pane) => pane.section == _selectedSection,
      orElse: () => panes.first,
    );
    final navigation = _buildSectionNavigation(tier);

    switch (SettingsPresentationPolicy.resolve(tier)) {
      case SettingsPageComposition.splitPane:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 244, child: navigation),
              const SizedBox(width: 18),
              Expanded(child: selectedPane),
            ],
          ),
        ];
      case SettingsPageComposition.groupedForm:
        return [
          navigation,
          const SizedBox(height: 16),
          selectedPane,
        ];
      case SettingsPageComposition.listDetail:
        if (!_smallDetailOpen) {
          return [navigation];
        }
        return [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _smallDetailOpen = false),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(_text('设置列表', 'Settings list')),
            ),
          ),
          const SizedBox(height: 8),
          selectedPane,
        ];
    }
  }

  Future<void> _uploadAvatar() async {
    const imageTypes = XTypeGroup(
      label: 'JPEG/PNG images',
      extensions: ['jpg', 'jpeg', 'png'],
      mimeTypes: ['image/jpeg', 'image/png'],
    );

    XFile? file;
    try {
      file = await openFile(acceptedTypeGroups: [imageTypes]);
    } catch (_) {
      if (mounted) {
        _showMessage(_text(
          '无法打开文件选择器。',
          'Unable to open the file selector.',
        ));
      }
      return;
    }
    if (file == null || !mounted) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fileLength = await file.length();
      if (!mounted) {
        return;
      }
      if (fileLength <= 0 || fileLength > 5 * 1024 * 1024) {
        _showMessage(_text(
          '头像必须是大小不超过 5 MiB 的 JPEG 或 PNG 图片。',
          'Choose a JPEG or PNG image no larger than 5 MiB.',
        ));
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      final updatedProfile = await widget.onUploadAvatar(
        bytes: bytes,
        filename: file.name,
      );
      if (!mounted) {
        return;
      }
      if (updatedProfile == null) {
        _showMessage(_text('头像上传失败。', 'Unable to upload the avatar.'));
        return;
      }
      setState(() {
        _overview = _overview.copyWith(accountSetting: updatedProfile);
      });
      _showMessage(_text('头像已更新。', 'Avatar updated.'));
    } catch (_) {
      if (mounted) {
        _showMessage(_text('头像读取失败。', 'Unable to read the avatar file.'));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final account = _overview.accountSetting;
    final privacy = _overview.privacySetting;
    final notifications = _overview.notificationSetting;
    final widgetSetting = _overview.widgetSetting;

    return DesktopPresentationLayout(
      surface: DesktopWindowSurface.canvas,
      builder: (context, spec) {
        final sectionChildren = <Widget>[
          _SettingsSurface(
            section: _SettingsSectionId.language,
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
                  final selected =
                      Localizations.localeOf(context).languageCode ==
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
          _SettingsSurface(
            section: _SettingsSectionId.account,
            child: _SettingSection(
              title: _text('账号', 'Account'),
              subtitle: widget.isOfflineMode
                  ? _text(
                      '这是当前设备的离线资料；登录后才能编辑云端账号和上传头像。',
                      'This is the local offline profile. Sign in to edit the cloud account or upload an avatar.',
                    )
                  : _text(
                      '这里是手机和电脑共用的熟人圈账号资料。',
                      'This is the trusted-circle account profile shared on phone and desktop.',
                    ),
              trailing: widget.isOfflineMode
                  ? null
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _uploadAvatar,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: Text(_text('更换头像', 'Change avatar')),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _editProfile,
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(_text('编辑资料', 'Edit profile')),
                        ),
                      ],
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
                    label: _text('头像', 'Avatar'),
                    value: account.avatarUrl.isEmpty
                        ? _text('未设置', 'Not set')
                        : _text('已设置', 'Configured'),
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
          _SettingsSurface(
            section: _SettingsSectionId.privacy,
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _text('黑名单', 'Blacklist'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _addBlacklist,
                        icon: const Icon(Icons.person_add_disabled_rounded),
                        label: Text(_text('添加', 'Add')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _text(
                      '被拉黑的账号不会出现在好友互动入口中。',
                      'Blocked accounts stay out of friend interaction entry points.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_isPrivacyContextLoading)
                    const LinearProgressIndicator()
                  else if (_blacklist.isEmpty)
                    Text(
                      _text('黑名单为空。', 'Your blacklist is empty.'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Column(
                      children: _blacklist
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.block_rounded),
                              title: Text(
                                '${_text('用户', 'User')} #${item.blockedUserId}',
                              ),
                              subtitle: item.createTime.isEmpty
                                  ? null
                                  : Text(item.createTime),
                              trailing: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _removeBlacklist(item),
                                child: Text(_text('解除', 'Remove')),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSurface(
            section: _SettingsSectionId.session,
            child: _SettingSection(
              title: _text('当前设备会话', 'Current device session'),
              subtitle: _text(
                '账号同时保留 1 台手机和 1 台 Windows 电脑会话。',
                'One phone session and one Windows session are kept per account.',
              ),
              child: _currentDeviceSession == null
                  ? Text(
                      _isPrivacyContextLoading
                          ? _text('正在核对会话状态…', 'Checking session status…')
                          : _text(
                              '当前会话状态暂不可用。', 'Session status is unavailable.'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLine(
                          label: _text('设备', 'Device'),
                          value: _deviceLabel(_currentDeviceSession!),
                        ),
                        _InfoLine(
                          label: _text('状态', 'Status'),
                          value: _sessionStateLabel(_currentDeviceSession!),
                        ),
                        _InfoLine(
                          label: _text('设备标识', 'Device ID'),
                          value: _currentDeviceSession!.deviceId.isEmpty
                              ? _text('未提供', 'Unavailable')
                              : _currentDeviceSession!.deviceId,
                        ),
                        if (_currentDeviceSession!.loginTime.isNotEmpty)
                          _InfoLine(
                            label: _text('登录时间', 'Login time'),
                            value: _currentDeviceSession!.loginTime,
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSurface(
            section: _SettingsSectionId.notifications,
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
                              notifications.copyWith(
                                  desktopNoticeEnabled: value),
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
          _SettingsSurface(
            section: _SettingsSectionId.desktop,
            child: _SettingSection(
              title: _text('桌面体验', 'Desktop experience'),
              subtitle: _text(
                '这里控制 Canvas 与 Focus Orb 的窗口行为。',
                'Control Canvas and Focus Orb window behavior here.',
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
                    title: Text(_text('开机启动 Canvas', 'Auto start Canvas')),
                    subtitle: Text(
                      _text(
                        '随 Windows 一起启动桌面画布。',
                        'Launch the desktop Canvas with Windows.',
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
                    title:
                        Text(_text('Focus Orb 始终置顶', 'Keep Focus Orb on top')),
                    subtitle: Text(
                      _text(
                        '让主动收纳后的 Focus Orb 保持在其他窗口上方。',
                        'Keep the Focus Orb above other windows when stowed.',
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
                    title: Text(_text('Orb 显示下一计划', 'Show next plan in Orb')),
                    subtitle: Text(
                      _text(
                        '在 Focus Orb 中显示下一项计划摘要。',
                        'Display the next plan summary in Focus Orb.',
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
                    title: Text(_text('Orb 显示计时器', 'Show timer in Orb')),
                    subtitle: Text(
                      _text(
                        '显示 Focus Orb 的当前学习计时器和番茄状态。',
                        'Display the active timer and pomodoro state in Focus Orb.',
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
                    title: Text(_text('Orb 显示备忘录', 'Show memo in Orb')),
                    subtitle: Text(
                      _text(
                        '在 Canvas 摘要中显示备忘录卡片；Orb 不显示正文。',
                        'Show memo cards in Canvas summaries; Orb never shows body text.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSurface(
            section: _SettingsSectionId.appearance,
            child: _SettingSection(
              title: _text('外观', 'Appearance'),
              subtitle: _text(
                '切换完整视觉主题。选择保存在本机，下次启动和登录时会自动恢复。',
                'Switch the complete visual theme. It is restored on the next launch and sign-in.',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text('视觉主题', 'Visual theme'),
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppVisualTheme.values.map((theme) {
                      final selected = _visualTheme == theme;
                      final tokens = AppVisualTokens.of(theme);
                      return ChoiceChip(
                        key: ValueKey(
                            'settings-visual-theme-${theme.storageValue}'),
                        selected: selected,
                        onSelected: _isLoading
                            ? null
                            : (_) => _changeVisualTheme(theme),
                        avatar: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: tokens.canvas,
                            shape: BoxShape.circle,
                            border: Border.all(color: tokens.accent, width: 3),
                          ),
                        ),
                        label: Text(
                          theme.label(
                            isChinese:
                                Localizations.localeOf(context).languageCode ==
                                    'zh',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  _InfoLine(
                    label: _text('当前主题', 'Current theme'),
                    value: _visualTheme.label(
                      isChinese:
                          Localizations.localeOf(context).languageCode == 'zh',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSurface(
            section: _SettingsSectionId.admin,
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
          _SettingsSurface(
            section: _SettingsSectionId.quickActions,
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
                  if (!widget.isOfflineMode)
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _clearCache,
                      icon: const Icon(Icons.cleaning_services_rounded),
                      label: Text(_text('清理缓存', 'Clear cache')),
                    ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      widget.isOfflineMode
                          ? _text('退出离线模式', 'Leave offline mode')
                          : _text('退出登录', 'Sign out'),
                    ),
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
          _SettingsSurface(
            section: _SettingsSectionId.danger,
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
        ];
        final panes = sectionChildren
            .whereType<_SettingsSurface>()
            .where((pane) => _availableSections.contains(pane.section))
            .toList(growable: false);
        final pageChildren = <Widget>[
          if (widget.isOfflineMode) ...[
            _OfflineSettingsNotice(
              message: _text(
                '离线模式仅开放语言、当前设备资料、桌面体验、外观和本机操作；隐私、通知、设备会话、后台管理及账号注销需要登录联网。',
                'Offline mode keeps language, local profile, desktop experience, appearance, and device actions available. Privacy, notifications, sessions, admin tools, and account cancellation require sign-in and a network connection.',
              ),
            ),
            const SizedBox(height: 16),
          ],
          ..._composeAdaptiveSections(spec.tier!, panes),
        ];
        return SecondaryPageScaffold(
          visualTheme: _visualTheme,
          backLabel: _text('返回', 'Back'),
          title: _text('系统设置', 'System settings'),
          description: widget.isOfflineMode
              ? _text(
                  '管理当前设备可独立生效的设置。',
                  'Manage settings that can take effect on this device.',
                )
              : _text(
                  '统一管理账户、隐私、通知、Canvas、Focus Orb 与外观。',
                  'Manage account, privacy, notifications, Canvas, Focus Orb, and appearance.',
                ),
          headerActions: widget.isOfflineMode
              ? const []
              : [
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
          children: pageChildren,
        );
      },
    );
  }
}

class _OfflineSettingsNotice extends StatelessWidget {
  const _OfflineSettingsNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('offline-settings-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.62),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_bolt_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _SettingsSurface extends StatefulWidget {
  const _SettingsSurface({
    required this.section,
    required this.child,
  }) : padding = const EdgeInsets.all(18);

  final _SettingsSectionId section;
  final Widget child;
  final EdgeInsets padding;

  @override
  State<_SettingsSurface> createState() => _SettingsSurfaceState();
}

class _SettingsSurfaceState extends State<_SettingsSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final visualTheme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme ??
            AppVisualTheme.minimalism;
    final tokens = AppVisualTokens.of(visualTheme);
    final radius = switch (visualTheme) {
      AppVisualTheme.minimalism => 20.0,
      AppVisualTheme.wabiSabi => 0.0,
      AppVisualTheme.midCentury => 18.0,
      AppVisualTheme.glass => 22.0,
    };
    final glass = visualTheme == AppVisualTheme.glass;
    final softSpectrum = visualTheme == AppVisualTheme.minimalism;
    final materializedChild = Material(
      type: MaterialType.transparency,
      child: widget.child,
    );
    return KeyedSubtree(
      key: ValueKey('settings.${widget.section.name}'),
      child: MouseRegion(
        onEnter: glass || softSpectrum
            ? (_) => setState(() => _hovered = true)
            : null,
        onExit: glass || softSpectrum
            ? (_) => setState(() => _hovered = false)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _hovered ? (glass ? -4 : -2) : 0,
            0,
          ),
          padding: glass ? EdgeInsets.zero : widget.padding,
          decoration: BoxDecoration(
            color: glass
                ? (_hovered ? const Color(0x52172A55) : const Color(0x3D101D3B))
                : tokens.panel,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: glass
                  ? (_hovered
                      ? const Color(0x70FFFFFF)
                      : const Color(0x3FFFFFFF))
                  : tokens.line,
            ),
            boxShadow: glass
                ? [
                    BoxShadow(
                      color: _hovered
                          ? const Color(0x665F8CFF)
                          : tokens.artOne.withValues(alpha: 0.18),
                      blurRadius: _hovered ? 44 : 28,
                      offset: Offset(0, _hovered ? 18 : 12),
                    ),
                  ]
                : softSpectrum
                    ? [
                        BoxShadow(
                          color: const Color(0xFF252635).withValues(
                            alpha: _hovered ? 0.12 : 0.07,
                          ),
                          blurRadius: _hovered ? 32 : 22,
                          offset: Offset(0, _hovered ? 14 : 9),
                        ),
                      ]
                    : null,
          ),
          child: glass
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _hovered ? 24 : 18,
                      sigmaY: _hovered ? 24 : 18,
                    ),
                    child: Padding(
                      padding: widget.padding,
                      child: materializedChild,
                    ),
                  ),
                )
              : materializedChild,
        ),
      ),
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
                  color: Theme.of(context).colorScheme.onSurface,
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
    final scheme = Theme.of(context).colorScheme;
    final visualTheme =
        Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme;
    final glass = visualTheme == AppVisualTheme.glass;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: glass ? const Color(0x18FFFFFF) : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: glass ? const Color(0x38FFFFFF) : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title：$value',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(note, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProfileDraft {
  const _ProfileDraft({
    required this.nickname,
    required this.bio,
  });

  final String nickname;
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
                        color: Theme.of(context).colorScheme.onSurface,
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
