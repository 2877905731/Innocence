import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/team_workspace_snapshot.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/local/local_profile.dart';
import 'package:innocence_flutter/core/local/offline_store.dart';
import 'package:innocence_flutter/core/local/offline_sync_models.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/account/domain/models/blacklist_item.dart';
import 'package:innocence_flutter/features/account/domain/models/current_device_session.dart';
import 'package:innocence_flutter/features/admin/data/admin_report_api.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/auth/domain/models/auth_result.dart';
import 'package:innocence_flutter/features/checkin/data/check_in_api.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/data/focus_session_api.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/data/friend_api.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/memos/data/memo_api.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/notifications/data/notification_api.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/data/study_plan_api.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/week_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';
import 'package:innocence_flutter/features/settings/data/settings_api.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/notification_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/privacy_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';
import 'package:innocence_flutter/features/stats/data/stats_api.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/sync/data/offline_sync_api.dart';
import 'package:innocence_flutter/features/team/data/team_api.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

enum SessionStatus {
  initializing,
  unauthenticated,
  authenticated,
  offline,
}

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthApi authApi,
    required AuthLocalStorage localStorage,
    required AppLanguageController languageController,
    OfflineStore? offlineStore,
    StudyPlanApi? studyPlanApi,
    FocusSessionApi? focusSessionApi,
    CheckInApi? checkInApi,
    StatsApi? statsApi,
    TeamApi? teamApi,
    FriendApi? friendApi,
    MemoApi? memoApi,
    NotificationApi? notificationApi,
    SettingsApi? settingsApi,
    AdminReportApi? adminReportApi,
    OfflineSyncApi? offlineSyncApi,
  })  : _authApi = authApi,
        _localStorage = localStorage,
        _languageController = languageController,
        _offlineStore = offlineStore ?? OfflineStore(),
        _studyPlanApi = studyPlanApi ?? StudyPlanApi(),
        _focusSessionApi = focusSessionApi ?? FocusSessionApi(),
        _checkInApi = checkInApi ?? CheckInApi(),
        _statsApi = statsApi ?? StatsApi(),
        _teamApi = teamApi ?? TeamApi(),
        _friendApi = friendApi ?? FriendApi(),
        _memoApi = memoApi ?? MemoApi(),
        _notificationApi = notificationApi ?? NotificationApi(),
        _settingsApi = settingsApi ?? SettingsApi(),
        _adminReportApi = adminReportApi ?? AdminReportApi(),
        _offlineSyncApi = offlineSyncApi ?? OfflineSyncApi();

  final AuthApi _authApi;
  final AuthLocalStorage _localStorage;
  final AppLanguageController _languageController;
  final OfflineStore _offlineStore;
  final StudyPlanApi _studyPlanApi;
  final FocusSessionApi _focusSessionApi;
  final CheckInApi _checkInApi;
  final StatsApi _statsApi;
  final TeamApi _teamApi;
  final FriendApi _friendApi;
  final MemoApi _memoApi;
  final NotificationApi _notificationApi;
  final SettingsApi _settingsApi;
  final AdminReportApi _adminReportApi;
  final OfflineSyncApi _offlineSyncApi;

  SessionStatus _status = SessionStatus.initializing;
  AppSession? _session;
  LocalProfile? _localProfile;
  UserProfile? _profile;
  FocusSession _focusSession = FocusSession.empty();
  CheckInStatus _checkInStatus = CheckInStatus.empty();
  StatsOverview _statsOverview = StatsOverview.empty();
  TeamOverview _teamOverview = TeamOverview.empty();
  TeamChatOverview _teamChatOverview = TeamChatOverview.empty();
  FriendOverview _friendOverview = FriendOverview.empty();
  MemoOverview _memoOverview = MemoOverview.empty();
  NotificationOverview _notificationOverview = NotificationOverview.empty();
  TodayPlan _todayPlan = TodayPlan.empty();
  WeekPlanOverview _weekPlanOverview = WeekPlanOverview.empty();
  MonthPlanOverview _monthPlanOverview = MonthPlanOverview.empty();
  AnnualPlanOverview _annualPlanOverview = AnnualPlanOverview.empty();
  SettingOverview _settingOverview = SettingOverview.empty();
  List<BlacklistItem> _blacklist = const [];
  CurrentDeviceSession? _currentDeviceSession;
  String? _weekAnchorDate;
  int _statsRangeDays = 7;
  List<WeeklyPlanTemplate> _weeklyTemplates = const [];
  bool _isBusy = false;
  bool _didInitialize = false;
  bool _isReconcilingFocusCompletion = false;
  String? _bannerMessage;
  Timer? _focusTicker;
  OfflineImportPreview? _offlineImportPreview;

  bool get _isChineseLanguage => _languageController.currentLanguage.isChinese;

  SessionStatus get status => _status;
  AppSession? get session => _session;
  UserProfile? get profile => _profile;
  FocusSession get focusSession => _focusSession;
  CheckInStatus get checkInStatus => _checkInStatus;
  StatsOverview get statsOverview => _statsOverview;
  TeamOverview get teamOverview => _teamOverview;
  TeamChatOverview get teamChatOverview => _teamChatOverview;
  FriendOverview get friendOverview => _friendOverview;
  MemoOverview get memoOverview => _memoOverview;
  NotificationOverview get notificationOverview => _notificationOverview;
  TodayPlan get todayPlan => _todayPlan;
  WeekPlanOverview get weekPlanOverview => _weekPlanOverview;
  MonthPlanOverview get monthPlanOverview => _monthPlanOverview;
  AnnualPlanOverview get annualPlanOverview => _annualPlanOverview;
  SettingOverview get settingOverview => _settingOverview;
  List<BlacklistItem> get blacklist => _blacklist;
  CurrentDeviceSession? get currentDeviceSession => _currentDeviceSession;
  List<WeeklyPlanTemplate> get weeklyTemplates => _weeklyTemplates;
  bool get isBusy => _isBusy;
  bool get isOffline => _status == SessionStatus.offline;
  String? get localOwnerScope => _localProfile?.ownerScope;
  String? get bannerMessage => _bannerMessage;
  int get unreadNotificationCount => _notificationOverview.unreadCount;
  OfflineImportPreview? get offlineImportPreview => _offlineImportPreview;
  ThemeMode get themeMode => _settingOverview.appearanceSetting.isLightMode
      ? ThemeMode.light
      : ThemeMode.dark;

  String _message(String zh, String en) {
    return _isChineseLanguage ? zh : en;
  }

  String _weeklyTemplateSavedMessage() {
    return _message('周模板已保存。', 'Weekly template saved.');
  }

  Future<void> initialize() async {
    if (_didInitialize) {
      return;
    }
    _didInitialize = true;

    final savedSession = _localStorage.readSession();
    if (savedSession == null) {
      _status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _status = SessionStatus.initializing;
    notifyListeners();

    try {
      final settingsOverview = await _settingsApi.getOverview(savedSession);
      final focusSession =
          await _focusSessionApi.getCurrentSession(savedSession);
      final checkInStatus = await _checkInApi.getTodayStatus(savedSession);
      final statsOverview = await _statsApi.getOverview(
        savedSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(savedSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(savedSession)
          : TeamChatOverview.empty();
      final friendOverview = await _friendApi.getOverview(savedSession);
      final memoOverview = await _memoApi.getWidgetSummary(savedSession);
      final notificationOverview =
          await _notificationApi.getOverview(savedSession);
      final todayPlan = await _studyPlanApi.getTodayPlan(savedSession);
      final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
        savedSession,
        anchorDate: _weekAnchorDate,
      );
      final weeklyTemplates = await _studyPlanApi.getDayTemplates(savedSession);
      _session = savedSession;
      _applySettingOverview(settingsOverview);
      _focusSession = focusSession;
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _friendOverview = friendOverview;
      _memoOverview = memoOverview;
      _notificationOverview = notificationOverview;
      _todayPlan = todayPlan;
      _weekPlanOverview = weekPlanOverview;
      _weeklyTemplates = weeklyTemplates;
      _bannerMessage = null;
      _status = SessionStatus.authenticated;
      _syncFocusTicker();
    } on ApiException catch (error) {
      final authenticationFailure = _isAuthenticationFailure(error);
      if (authenticationFailure) {
        await _localStorage.clearSession();
      }
      _session = null;
      _profile = null;
      _focusSession = FocusSession.empty();
      _checkInStatus = CheckInStatus.empty();
      _statsOverview = StatsOverview.empty();
      _teamOverview = TeamOverview.empty();
      _teamChatOverview = TeamChatOverview.empty();
      _friendOverview = FriendOverview.empty();
      _memoOverview = MemoOverview.empty();
      _notificationOverview = NotificationOverview.empty();
      _todayPlan = TodayPlan.empty();
      _weekPlanOverview = WeekPlanOverview.empty();
      _monthPlanOverview = MonthPlanOverview.empty();
      _annualPlanOverview = AnnualPlanOverview.empty();
      _settingOverview = SettingOverview.empty();
      _blacklist = const [];
      _currentDeviceSession = null;
      _weeklyTemplates = const [];
      _bannerMessage = authenticationFailure
          ? _message(
              '会话已失效，请重新登录。',
              'Session expired. Please sign in again.',
            )
          : _message(
              '暂时无法恢复联网数据；登录凭据已保留，可重试或使用离线模式。',
              'Online data could not be restored. Your sign-in is preserved; retry or use offline mode.',
            );
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    } catch (_) {
      _session = null;
      _profile = null;
      _focusSession = FocusSession.empty();
      _checkInStatus = CheckInStatus.empty();
      _statsOverview = StatsOverview.empty();
      _teamOverview = TeamOverview.empty();
      _teamChatOverview = TeamChatOverview.empty();
      _friendOverview = FriendOverview.empty();
      _memoOverview = MemoOverview.empty();
      _notificationOverview = NotificationOverview.empty();
      _todayPlan = TodayPlan.empty();
      _weekPlanOverview = WeekPlanOverview.empty();
      _monthPlanOverview = MonthPlanOverview.empty();
      _annualPlanOverview = AnnualPlanOverview.empty();
      _settingOverview = SettingOverview.empty();
      _blacklist = const [];
      _currentDeviceSession = null;
      _weeklyTemplates = const [];
      _bannerMessage = _message(
        '恢复上一次会话失败；登录凭据未被清除。',
        'Failed to restore the previous session. Your sign-in was not cleared.',
      );
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    }

    if (_status == SessionStatus.authenticated && _session != null) {
      try {
        await _prepareOfflineImportPreview(_session!);
      } on ApiException {
        _bannerMessage = _message(
          '离线数据仍保存在本机，联网恢复后可再次导入。',
          'Offline data remains on this device and can be imported after reconnecting.',
        );
      }
    }

    notifyListeners();
  }

  Future<void> enterOfflineMode() async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    _bannerMessage = null;
    notifyListeners();
    try {
      final localProfile = await _offlineStore.getOrCreateLocalProfile();
      final todayDate = _formatDate(DateTime.now());
      final profile = localProfile.toUserProfile();
      _localProfile = localProfile;
      _session = null;
      _profile = profile;
      _focusSession =
          await _offlineStore.loadActiveFocusSession(localProfile.ownerScope);
      _todayPlan = await _offlineStore.loadDailyPlan(
        localProfile.ownerScope,
        todayDate,
      );
      _memoOverview =
          await _offlineStore.loadMemoOverview(localProfile.ownerScope);
      _checkInStatus = await _buildOfflineCheckInStatus(
        localProfile.ownerScope,
        _todayPlan,
      );
      _statsOverview = await _offlineStore.loadStatsOverview(
        localProfile.ownerScope,
        days: _statsRangeDays,
      );
      _teamOverview = TeamOverview.empty();
      _teamChatOverview = TeamChatOverview.empty();
      _friendOverview = FriendOverview.empty();
      _notificationOverview = NotificationOverview.empty();
      _weekPlanOverview = WeekPlanOverview.empty();
      _monthPlanOverview = await _offlineStore.loadMonthOverview(
        localProfile.ownerScope,
        MonthPlanOverview.formatMonth(DateTime.now()),
      );
      _annualPlanOverview = await _offlineStore.loadAnnualOverview(
        localProfile.ownerScope,
        DateTime.now().year,
      );
      final localWidgetSetting =
          await _offlineStore.loadLocalWidgetSetting(localProfile.ownerScope);
      _settingOverview = SettingOverview.empty(
        accountSetting: profile,
      ).copyWith(widgetSetting: localWidgetSetting);
      await _applyDesktopShellSettings(widgetSetting: localWidgetSetting);
      _blacklist = const [];
      _currentDeviceSession = null;
      _weeklyTemplates =
          await _offlineStore.loadDayTemplates(localProfile.ownerScope);
      final pendingCount = await _offlineStore.pendingOutboxCount(
        localProfile.ownerScope,
      );
      _bannerMessage = _message(
        pendingCount == 0
            ? '已进入离线模式，数据仅保存在此设备。'
            : '已进入离线模式，有 $pendingCount 项本地变更将在登录并确认后同步。',
        pendingCount == 0
            ? 'Offline mode: data stays on this device.'
            : 'Offline mode: $pendingCount local changes will sync after sign-in and confirmation.',
      );
      _status = SessionStatus.offline;
      _syncFocusTicker();
    } catch (_) {
      _status = SessionStatus.unauthenticated;
      _bannerMessage = _message(
        '无法初始化本地数据，请检查磁盘权限后重试。',
        'Could not initialize local data. Check disk permissions and retry.',
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void requireOnlineFeature(String featureName) {
    _bannerMessage = _message(
      '“$featureName”需要登录并联网后使用；离线数据不会因此丢失。',
      '$featureName requires sign-in and a network connection. Your offline data is safe.',
    );
    notifyListeners();
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.loginWithPassword(
        email: email,
        password: password,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> loginWithCode({
    required String email,
    required String emailCode,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.loginWithCode(
        email: email,
        emailCode: emailCode,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.register(
        email: email,
        password: password,
        emailCode: emailCode,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> sendLoginCode(String email) {
    return _authApi.sendLoginCode(email);
  }

  Future<void> sendRegisterCode(String email) {
    return _authApi.sendRegisterCode(email);
  }

  Future<void> sendResetPasswordCode(String email) {
    return _authApi.sendResetPasswordCode(email);
  }

  Future<bool> resetPassword({
    required String email,
    required String emailCode,
    required String newPassword,
  }) async {
    var succeeded = false;
    await _runBusyAction(
      () async {
        await _authApi.resetPassword(
          email: email,
          emailCode: emailCode,
          newPassword: newPassword,
        );
        succeeded = true;
        _bannerMessage = _message(
          '密码已重置，请使用新密码登录。',
          'Password reset. Sign in with your new password.',
        );
      },
      fallbackMessage: _message(
        '重置密码失败，请稍后重试。',
        'Failed to reset the password. Please try again.',
      ),
    );
    return succeeded;
  }

  Future<void> refreshProfile() async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _focusSession = await _offlineStore.loadActiveFocusSession(ownerScope);
        _todayPlan = await _offlineStore.loadDailyPlan(
          ownerScope,
          _formatDate(DateTime.now()),
        );
        _memoOverview = await _offlineStore.loadMemoOverview(ownerScope);
        _statsOverview = await _offlineStore.loadStatsOverview(
          ownerScope,
          days: _statsRangeDays,
        );
        _checkInStatus = await _buildOfflineCheckInStatus(
          ownerScope,
          _todayPlan,
        );
        _bannerMessage = _message(
          '本地数据已刷新。',
          'Local data refreshed.',
        );
        _syncFocusTicker();
      },
          fallbackMessage:
              _message('刷新本地数据失败。', 'Failed to refresh local data.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final settingsOverview = await _settingsApi.getOverview(currentSession);
      final focusSession =
          await _focusSessionApi.getCurrentSession(currentSession);
      final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final friendOverview = await _friendApi.getOverview(currentSession);
      final memoOverview = await _memoApi.getWidgetSummary(currentSession);
      final notificationOverview =
          await _notificationApi.getOverview(currentSession);
      final todayPlan = await _studyPlanApi.getTodayPlan(currentSession);
      final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
        currentSession,
        anchorDate: _weekAnchorDate,
      );
      final weeklyTemplates =
          await _studyPlanApi.getDayTemplates(currentSession);
      _applySettingOverview(settingsOverview);
      _focusSession = focusSession;
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _friendOverview = friendOverview;
      _memoOverview = memoOverview;
      _notificationOverview = notificationOverview;
      _todayPlan = todayPlan;
      _weekPlanOverview = weekPlanOverview;
      _monthPlanOverview = await _studyPlanApi.getMonthPlanOverview(
        currentSession,
        month: _monthPlanOverview.month,
      );
      _annualPlanOverview = await _studyPlanApi.getAnnualPlanOverview(
        currentSession,
        year: _annualPlanOverview.year,
      );
      _weeklyTemplates = weeklyTemplates;
      _bannerMessage = null;
      _syncFocusTicker();
    }, fallbackMessage: _message('刷新资料失败。', 'Failed to refresh the profile.'));
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();
    try {
      await _localStorage.clearSession();
      _session = null;
      _localProfile = null;
      _profile = null;
      _focusSession = FocusSession.empty();
      _checkInStatus = CheckInStatus.empty();
      _statsOverview = StatsOverview.empty();
      _teamOverview = TeamOverview.empty();
      _teamChatOverview = TeamChatOverview.empty();
      _friendOverview = FriendOverview.empty();
      _memoOverview = MemoOverview.empty();
      _notificationOverview = NotificationOverview.empty();
      _todayPlan = TodayPlan.empty();
      _weekPlanOverview = WeekPlanOverview.empty();
      _settingOverview = SettingOverview.empty();
      _blacklist = const [];
      _currentDeviceSession = null;
      _weeklyTemplates = const [];
      _offlineImportPreview = null;
      _bannerMessage = null;
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void clearBanner() {
    if (_bannerMessage == null) {
      return;
    }
    _bannerMessage = null;
    notifyListeners();
  }

  Future<void> saveTodayPlan(TodayPlan plan) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        final savedPlan = await _offlineStore.saveDailyPlan(ownerScope, plan);
        if (savedPlan.planDate == _todayPlan.planDate) {
          _todayPlan = savedPlan;
          _checkInStatus = await _buildOfflineCheckInStatus(
            ownerScope,
            savedPlan,
          );
        }
        _monthPlanOverview = await _offlineStore.loadMonthOverview(
          ownerScope,
          savedPlan.planDate.substring(0, 7),
        );
        _annualPlanOverview = await _offlineStore.loadAnnualOverview(
          ownerScope,
          DateTime.parse(savedPlan.planDate).year,
        );
        _bannerMessage = _message(
          '计划已保存在本机，登录并确认后可同步。',
          'Plan saved on this device. Sign in and confirm to sync it.',
        );
      },
          fallbackMessage:
              _message('本地计划保存失败。', 'Failed to save the local plan.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final savedPlan = await _studyPlanApi.saveTodayPlan(currentSession, plan);
      final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
        currentSession,
        anchorDate: _weekAnchorDate,
      );
      if (savedPlan.planDate == _todayPlan.planDate) {
        _todayPlan = savedPlan;
      }
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _weekPlanOverview = weekPlanOverview;
      if (_monthPlanOverview.month == savedPlan.planDate.substring(0, 7)) {
        _monthPlanOverview = await _studyPlanApi.getMonthPlanOverview(
          currentSession,
          month: _monthPlanOverview.month,
        );
      }
      if (_annualPlanOverview.year == DateTime.parse(savedPlan.planDate).year) {
        _annualPlanOverview = await _studyPlanApi.getAnnualPlanOverview(
          currentSession,
          year: _annualPlanOverview.year,
        );
      }
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('保存今日计划失败。', 'Failed to save the today plan.'));
  }

  Future<void> toggleTodayPlanItem(int index, bool completed) async {
    if (index < 0 || index >= _todayPlan.items.length) {
      return;
    }
    final updatedPlan = _todayPlan.toggleAt(index, completed);
    await saveTodayPlan(updatedPlan);
  }

  Future<void> saveWeeklyTemplate(String templateName) async {
    await savePlanAsWeeklyTemplate(
      templateName,
      _todayPlan,
      successMessage: _message('周模板已保存。', 'Weekly template saved.'),
    );
  }

  Future<void> savePlanAsWeeklyTemplate(
    String templateName,
    TodayPlan sourcePlan, {
    String successMessage = '',
  }) async {
    final resolvedSuccessMessage =
        successMessage.isEmpty ? _weeklyTemplateSavedMessage() : successMessage;
    if (!sourcePlan.hasItems) {
      _bannerMessage = _message(
        '请先为这一天创建任务，再保存为日计划模板。',
        'Create tasks for that day before saving a day template.',
      );
      notifyListeners();
      return;
    }

    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _weeklyTemplates = await _offlineStore.saveDayTemplate(
          ownerScope,
          templateName: templateName,
          sourcePlan: sourcePlan,
        );
        _bannerMessage = _message(
          '日计划模板已保存在本机。',
          'Day template saved on this device.',
        );
      },
          fallbackMessage:
              _message('保存本地日模板失败。', 'Failed to save the local day template.'));
      return;
    }

    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final templates = await _studyPlanApi.saveDayTemplate(
        currentSession,
        templateName: templateName,
        sourcePlan: sourcePlan,
      );
      _weeklyTemplates = templates;
      _bannerMessage = resolvedSuccessMessage;
    },
        fallbackMessage:
            _message('保存日模板失败。', 'Failed to save the day template.'));
  }

  Future<void> deleteWeeklyTemplate(int templateId) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final templates = await _studyPlanApi.deleteWeeklyTemplate(
        currentSession,
        templateId: templateId,
      );
      _weeklyTemplates = templates;
      _bannerMessage = _message('周模板已删除。', 'Weekly template deleted.');
    },
        fallbackMessage:
            _message('删除周模板失败。', 'Failed to delete the weekly template.'));
  }

  Future<void> copyPlanToDate(
    String sourcePlanDate,
    String targetPlanDate,
  ) async {
    await copyPlanToDates(sourcePlanDate, [targetPlanDate]);
  }

  Future<void> copyPlanToDates(
    String sourcePlanDate,
    List<String> targetPlanDates,
  ) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    final uniqueTargetDates = targetPlanDates
        .where(
            (date) => date.trim().isNotEmpty && date.trim() != sourcePlanDate)
        .map((date) => date.trim())
        .toSet()
        .toList()
      ..sort();
    if (uniqueTargetDates.isEmpty) {
      _bannerMessage = _message(
        '请选择一个不同的目标日期进行复制。',
        'Choose a different target day to copy into.',
      );
      notifyListeners();
      return;
    }

    await _runBusyAction(() async {
      final sourcePlan = await _studyPlanApi.getTodayPlan(
        currentSession,
        planDate: sourcePlanDate,
      );
      if (!sourcePlan.hasItems) {
        throw ApiException(
          _message('源日期没有可复制的任务。', 'The source day has no tasks to copy.'),
        );
      }

      final copiedPlan = _buildReusablePlanCopy(
        sourcePlan,
        planDate: uniqueTargetDates.first,
      );
      var updatedTodayPlan = false;
      for (final targetPlanDate in uniqueTargetDates) {
        final nextPlan = targetPlanDate == uniqueTargetDates.first
            ? copiedPlan
            : _buildReusablePlanCopy(
                sourcePlan,
                planDate: targetPlanDate,
              );
        final savedPlan =
            await _studyPlanApi.saveTodayPlan(currentSession, nextPlan);
        if (savedPlan.planDate == _todayPlan.planDate) {
          _todayPlan = savedPlan;
          updatedTodayPlan = true;
        }
      }
      await _refreshAfterPlanMutation(
        currentSession,
        reloadTodayPlan: !updatedTodayPlan &&
            uniqueTargetDates.contains(_todayPlan.planDate),
      );
      _bannerMessage = uniqueTargetDates.length == 1
          ? _message(
              '已将 $sourcePlanDate 复制到 ${uniqueTargetDates.first}。',
              'Copied $sourcePlanDate into ${uniqueTargetDates.first}.',
            )
          : _message(
              '已将 $sourcePlanDate 复制到 ${uniqueTargetDates.length} 天。',
              'Copied $sourcePlanDate into ${uniqueTargetDates.length} days.',
            );
    },
        fallbackMessage:
            _message('复制指定日期计划失败。', 'Failed to copy the selected day plan.'));
  }

  Future<void> clearPlanDate(String planDate) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final emptyPlan = TodayPlan.empty(planDate).copyWith(
        planName: '',
        items: const [],
      );
      await _studyPlanApi.saveTodayPlan(currentSession, emptyPlan);
      await _refreshAfterPlanMutation(
        currentSession,
        reloadTodayPlan: planDate == _todayPlan.planDate,
      );
      _bannerMessage = _message(
        '已清空 $planDate 的计划。',
        'Cleared the $planDate plan.',
      );
    },
        fallbackMessage:
            _message('清空指定日期计划失败。', 'Failed to clear the selected day plan.'));
  }

  Future<void> applyWeeklyTemplate(int templateId) async {
    await applyWeeklyTemplateToDate(
      templateId,
      _todayPlan.planDate,
      successMessage:
          _message('周模板已应用到今天。', 'Weekly template applied to today.'),
    );
  }

  Future<void> applyWeeklyTemplateToDate(
    int templateId,
    String planDate, {
    String successMessage = '',
  }) async {
    await applyDayTemplateToDate(
      templateId,
      planDate,
      strategy: PlanApplyStrategy.overwrite,
      successMessage: successMessage,
    );
  }

  Future<void> applyDayTemplateToDate(
    int templateId,
    String planDate, {
    required PlanApplyStrategy strategy,
    String successMessage = '',
  }) async {
    final resolvedSuccessMessage = successMessage.isEmpty
        ? _message('日模板已应用。', 'Day template applied.')
        : successMessage;
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        final appliedPlan = await _offlineStore.applyDayTemplate(
          ownerScope,
          templateId: templateId,
          planDate: planDate,
          strategy: strategy,
        );
        if (appliedPlan.planDate == _todayPlan.planDate) {
          _todayPlan = appliedPlan;
        }
        _monthPlanOverview = await _offlineStore.loadMonthOverview(
          ownerScope,
          planDate.substring(0, 7),
        );
        _annualPlanOverview = await _offlineStore.loadAnnualOverview(
          ownerScope,
          DateTime.parse(planDate).year,
        );
        _bannerMessage = resolvedSuccessMessage;
      },
          fallbackMessage: _message(
              '应用本地日模板失败。', 'Failed to apply the local day template.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final plans = await _studyPlanApi.applyDayTemplateBatch(
        currentSession,
        templateId: templateId,
        planDates: [planDate],
        strategy: strategy,
      );
      final appliedPlan = plans.isEmpty
          ? await _studyPlanApi.getTodayPlan(
              currentSession,
              planDate: planDate,
            )
          : plans.first;
      if (appliedPlan.planDate == _todayPlan.planDate) {
        _todayPlan = appliedPlan;
      }
      await _refreshAfterPlanMutation(
        currentSession,
        reloadTodayPlan: false,
      );
      _bannerMessage = resolvedSuccessMessage;
    },
        fallbackMessage:
            _message('应用日模板失败。', 'Failed to apply the day template.'));
  }

  Future<void> applyWeeklyTemplateToDates(
    int templateId,
    List<String> planDates,
  ) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    final uniqueDates = planDates
        .where((date) => date.trim().isNotEmpty)
        .map((date) => date.trim())
        .toSet()
        .toList()
      ..sort();
    if (uniqueDates.isEmpty) {
      _bannerMessage = _message(
        '请至少选择一天再应用模板。',
        'Choose at least one day before applying a template.',
      );
      notifyListeners();
      return;
    }

    await _runBusyAction(() async {
      for (final planDate in uniqueDates) {
        final appliedPlan = await _studyPlanApi.applyWeeklyTemplate(
          currentSession,
          templateId: templateId,
          planDate: planDate,
        );
        if (appliedPlan.planDate == _todayPlan.planDate) {
          _todayPlan = appliedPlan;
        }
      }
      await _refreshAfterPlanMutation(
        currentSession,
        reloadTodayPlan: false,
      );
      _bannerMessage = uniqueDates.length == 1
          ? _message('周模板已应用。', 'Weekly template applied.')
          : _message(
              '周模板已应用到 ${uniqueDates.length} 天。',
              'Weekly template applied to ${uniqueDates.length} days.',
            );
    },
        fallbackMessage: _message(
            '批量应用周模板失败。', 'Failed to batch-apply the weekly template.'));
  }

  Future<void> quickArrangeWeek(
    Map<String, int> templateAssignments,
    List<String> clearDates,
  ) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    final normalizedAssignments = <String, int>{};
    for (final entry in templateAssignments.entries) {
      final planDate = entry.key.trim();
      if (planDate.isEmpty) {
        continue;
      }
      normalizedAssignments[planDate] = entry.value;
    }

    final normalizedClearDates = clearDates
        .where((date) => date.trim().isNotEmpty)
        .map((date) => date.trim())
        .toSet()
        .toList()
      ..sort();

    normalizedClearDates.removeWhere(normalizedAssignments.containsKey);

    if (normalizedAssignments.isEmpty && normalizedClearDates.isEmpty) {
      _bannerMessage = _message(
        '请至少选择一个本周安排操作。',
        'Choose at least one weekly arrangement action.',
      );
      notifyListeners();
      return;
    }

    await _runBusyAction(() async {
      var updatedTodayPlan = false;

      for (final planDate in normalizedClearDates) {
        final emptyPlan = TodayPlan.empty(planDate).copyWith(
          planName: '',
          items: const [],
        );
        await _studyPlanApi.saveTodayPlan(currentSession, emptyPlan);
        if (planDate == _todayPlan.planDate) {
          _todayPlan = TodayPlan.empty(planDate);
          updatedTodayPlan = true;
        }
      }

      final assignmentDates = normalizedAssignments.keys.toList()..sort();
      for (final planDate in assignmentDates) {
        final appliedPlan = await _studyPlanApi.applyWeeklyTemplate(
          currentSession,
          templateId: normalizedAssignments[planDate]!,
          planDate: planDate,
        );
        if (appliedPlan.planDate == _todayPlan.planDate) {
          _todayPlan = appliedPlan;
          updatedTodayPlan = true;
        }
      }

      await _refreshAfterPlanMutation(
        currentSession,
        reloadTodayPlan: !updatedTodayPlan &&
            (assignmentDates.contains(_todayPlan.planDate) ||
                normalizedClearDates.contains(_todayPlan.planDate)),
      );

      final totalChanged =
          normalizedAssignments.length + normalizedClearDates.length;
      _bannerMessage = totalChanged == 1
          ? _message('本周安排已更新。', 'Weekly arrangement updated.')
          : _message(
              '已更新 $totalChanged 天的本周安排。',
              'Weekly arrangement updated for $totalChanged days.',
            );
    },
        fallbackMessage: _message(
            '应用本周快速安排失败。', 'Failed to apply the weekly quick arrangement.'));
  }

  Future<void> _refreshAfterPlanMutation(
    AppSession currentSession, {
    bool reloadTodayPlan = false,
  }) async {
    final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
    final statsOverview = await _statsApi.getOverview(
      currentSession,
      days: _statsRangeDays,
    );
    final teamOverview = await _teamApi.getCurrentTeam(currentSession);
    final teamChatOverview = teamOverview.inTeam
        ? await _teamApi.getTeamChat(currentSession)
        : TeamChatOverview.empty();
    final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
      currentSession,
      anchorDate: _weekAnchorDate,
    );
    final refreshedTodayPlan = reloadTodayPlan
        ? await _studyPlanApi.getTodayPlan(currentSession)
        : null;

    if (refreshedTodayPlan != null) {
      _todayPlan = refreshedTodayPlan;
    }
    _checkInStatus = checkInStatus;
    _statsOverview = statsOverview;
    _statsRangeDays = statsOverview.rangeDays;
    _teamOverview = teamOverview;
    _teamChatOverview = teamChatOverview;
    _weekPlanOverview = weekPlanOverview;
  }

  TodayPlan _buildReusablePlanCopy(
    TodayPlan sourcePlan, {
    required String planDate,
  }) {
    final resetItems = sourcePlan.items.map((item) {
      return item.copyWith(
        completed: false,
        actualMinutes: 0,
      );
    }).toList();
    return sourcePlan.copyWith(
      planDate: planDate,
      items: resetItems,
    );
  }

  Future<void> _completeAuthentication(AuthResult result) async {
    await _localStorage.saveSession(result.session);
    _session = result.session;
    _profile = result.userInfo;
    _settingOverview = SettingOverview.empty(accountSetting: result.userInfo);
    try {
      final settingsOverview = await _settingsApi.getOverview(result.session);
      final focusSession =
          await _focusSessionApi.getCurrentSession(result.session);
      final checkInStatus = await _checkInApi.getTodayStatus(result.session);
      final statsOverview = await _statsApi.getOverview(
        result.session,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(result.session);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(result.session)
          : TeamChatOverview.empty();
      final friendOverview = await _friendApi.getOverview(result.session);
      final memoOverview = await _memoApi.getWidgetSummary(result.session);
      final notificationOverview = await _notificationApi.getOverview(
        result.session,
      );
      final todayPlan = await _studyPlanApi.getTodayPlan(result.session);
      final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
        result.session,
        anchorDate: _weekAnchorDate,
      );
      final weeklyTemplates =
          await _studyPlanApi.getDayTemplates(result.session);
      _session = result.session;
      _applySettingOverview(settingsOverview);
      _focusSession = focusSession;
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _friendOverview = friendOverview;
      _memoOverview = memoOverview;
      _notificationOverview = notificationOverview;
      _todayPlan = todayPlan;
      _weekPlanOverview = weekPlanOverview;
      _weeklyTemplates = weeklyTemplates;
      _bannerMessage = null;
      _status = SessionStatus.authenticated;
      _syncFocusTicker();
    } on ApiException catch (error) {
      if (!_isAuthenticationFailure(error)) {
        _status = SessionStatus.authenticated;
        _bannerMessage = _message(
          '登录成功，但部分联网数据暂时无法加载。',
          'Signed in, but some online data is temporarily unavailable.',
        );
        _stopFocusTicker();
      } else {
        await _localStorage.clearSession();
        _session = null;
        _profile = null;
        _focusSession = FocusSession.empty();
        _checkInStatus = CheckInStatus.empty();
        _statsOverview = StatsOverview.empty();
        _teamOverview = TeamOverview.empty();
        _teamChatOverview = TeamChatOverview.empty();
        _friendOverview = FriendOverview.empty();
        _memoOverview = MemoOverview.empty();
        _notificationOverview = NotificationOverview.empty();
        _todayPlan = TodayPlan.empty();
        _weekPlanOverview = WeekPlanOverview.empty();
        _settingOverview = SettingOverview.empty();
        _blacklist = const [];
        _currentDeviceSession = null;
        _weeklyTemplates = const [];
        _status = SessionStatus.unauthenticated;
        _stopFocusTicker();
        rethrow;
      }
    } catch (_) {
      _status = SessionStatus.authenticated;
      _bannerMessage = _message(
        '登录成功，但本地界面初始化未完全完成。',
        'Signed in, but the local interface did not fully initialize.',
      );
      _stopFocusTicker();
    }

    if (_status == SessionStatus.authenticated) {
      try {
        await _prepareOfflineImportPreview(result.session);
      } on ApiException {
        _bannerMessage = _message(
          '离线数据仍保存在本机，联网恢复后可再次导入。',
          'Offline data remains on this device and can be imported after reconnecting.',
        );
      }
    }
  }

  Future<void> _prepareOfflineImportPreview(AppSession currentSession) async {
    final localProfile = await _offlineStore.readLocalProfile();
    if (localProfile == null) {
      _offlineImportPreview = null;
      return;
    }
    final manifest = await _offlineStore.buildImportManifest(
      localProfile.ownerScope,
      localProfile.localProfileId,
    );
    if (manifest.pendingOperationCount <= 0) {
      _offlineImportPreview = null;
      return;
    }
    _offlineImportPreview = await _offlineSyncApi.preview(
      currentSession,
      manifest,
    );
  }

  Future<void> importOfflineData(OfflineConflictStrategy strategy) async {
    final preview = _offlineImportPreview;
    final currentSession = _session;
    if (preview == null || currentSession == null || _isBusy) {
      return;
    }
    await _runBusyAction(() async {
      final localProfile = await _offlineStore.readLocalProfile();
      if (localProfile == null ||
          localProfile.localProfileId != preview.localProfileId) {
        throw StateError('The local profile changed before import.');
      }
      final operations = await _offlineStore.loadPendingSyncOperations(
        localProfile.ownerScope,
      );
      final result = await _offlineSyncApi.import(
        currentSession,
        localProfileId: localProfile.localProfileId,
        targetUserNo: preview.targetUserNo,
        conflictStrategy: strategy,
        operations: operations,
      );
      await _offlineStore.applyImportResult(
        localProfile.ownerScope,
        localProfileId: localProfile.localProfileId,
        serverUserId: currentSession.userId,
        result: result,
      );
      _offlineImportPreview = null;
      _bannerMessage = _message(
        '离线导入完成：成功 ${result.acceptedCount} 项，冲突 ${result.conflictCount} 项，失败 ${result.rejectedCount} 项。本地原始数据已保留。',
        'Offline import finished: ${result.acceptedCount} accepted, ${result.conflictCount} conflicts, ${result.rejectedCount} rejected. Original local data was retained.',
      );
      await _reloadOnlineDataAfterImport(currentSession);
    },
        fallbackMessage: _message('离线数据导入失败，本地数据未删除。',
            'Offline import failed. Local data was not deleted.'));
  }

  void dismissOfflineImport() {
    if (_offlineImportPreview == null) {
      return;
    }
    _offlineImportPreview = null;
    _bannerMessage = _message(
      '已取消导入，离线数据继续保存在本机。',
      'Import cancelled. Offline data remains on this device.',
    );
    notifyListeners();
  }

  Future<void> _reloadOnlineDataAfterImport(AppSession currentSession) async {
    _todayPlan = await _studyPlanApi.getTodayPlan(currentSession);
    _weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
      currentSession,
      anchorDate: _weekAnchorDate,
    );
    _monthPlanOverview = await _studyPlanApi.getMonthPlanOverview(
      currentSession,
      month: _monthPlanOverview.month,
    );
    _annualPlanOverview = await _studyPlanApi.getAnnualPlanOverview(
      currentSession,
      year: _annualPlanOverview.year,
    );
    _weeklyTemplates = await _studyPlanApi.getDayTemplates(currentSession);
    _memoOverview = await _memoApi.getWidgetSummary(currentSession);
    _checkInStatus = await _checkInApi.getTodayStatus(currentSession);
    _statsOverview = await _statsApi.getOverview(
      currentSession,
      days: _statsRangeDays,
    );
  }

  bool _isAuthenticationFailure(ApiException error) {
    return error.statusCode == 401 || error.code == 2000;
  }

  Future<void> startFocusSession({
    required DateTime endTime,
    String? taskName,
    bool bindPomodoro = false,
    int pomodoroStudyMinutes = 0,
    int pomodoroBreakMinutes = 0,
  }) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _focusSession = await _offlineStore.startFocusSession(
          ownerScope,
          endTime: endTime,
          taskName: taskName,
          bindPomodoro: bindPomodoro,
          pomodoroStudyMinutes: pomodoroStudyMinutes,
          pomodoroBreakMinutes: pomodoroBreakMinutes,
        );
        _bannerMessage = _message(
          '离线专注已开始，记录保存在本机。',
          'Offline focus started and saved on this device.',
        );
        _syncFocusTicker();
      },
          fallbackMessage:
              _message('开始离线专注失败。', 'Failed to start offline focus.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final focusSession = await _focusSessionApi.startSession(
        currentSession,
        endTime: endTime,
        taskName: taskName,
        bindPomodoro: bindPomodoro,
        pomodoroStudyMinutes: pomodoroStudyMinutes,
        pomodoroBreakMinutes: pomodoroBreakMinutes,
      );
      final profile = await _authApi.getProfile(currentSession);
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      _focusSession = focusSession;
      _syncProfile(profile);
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _bannerMessage = _message('专注已开始。', 'Focus session started.');
      _syncFocusTicker();
    },
        fallbackMessage:
            _message('开始专注失败。', 'Failed to start the focus session.'));
  }

  Future<void> finishFocusSession() async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _focusSession = await _offlineStore.finishFocusSession(
          ownerScope,
          _focusSession.sessionId,
        );
        _bannerMessage = _message(
          '离线专注已结束，记录保存在本机。',
          'Offline focus finished and saved on this device.',
        );
        _stopFocusTicker();
      },
          fallbackMessage:
              _message('结束离线专注失败。', 'Failed to finish offline focus.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final focusSession = await _focusSessionApi.finishSession(
        currentSession,
        sessionId: _focusSession.sessionId,
      );
      final profile = await _authApi.getProfile(currentSession);
      final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      _focusSession = focusSession;
      _syncProfile(profile);
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _bannerMessage = _message('专注已结束。', 'Focus session finished.');
      _stopFocusTicker();
    },
        fallbackMessage:
            _message('结束专注失败。', 'Failed to finish the focus session.'));
  }

  Future<void> submitTodayCheckIn() async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      if (!_todayPlan.hasItems ||
          _todayPlan.completedCount != _todayPlan.totalCount) {
        _bannerMessage = _message(
          '完成当天全部计划后才能记录离线签到。',
          'Complete every task before recording an offline check-in.',
        );
        notifyListeners();
        return;
      }
      await _runBusyAction(() async {
        await _offlineStore.recordCheckInIntent(
          ownerScope,
          _todayPlan.planDate,
        );
        _checkInStatus = await _buildOfflineCheckInStatus(
          ownerScope,
          _todayPlan,
        );
        _bannerMessage = _message(
          '离线签到已记录；登录后需由服务器校验。',
          'Offline check-in recorded; the server will validate it after sign-in.',
        );
      },
          fallbackMessage:
              _message('记录离线签到失败。', 'Failed to record the offline check-in.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final result = await _checkInApi.submitTodayCheckIn(currentSession);
      final profile = await _authApi.getProfile(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _checkInStatus = result.status;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _notificationOverview = notificationOverview;
      _syncProfile(profile);
      _bannerMessage = result.message;
    },
        fallbackMessage:
            _message('提交今日签到失败。', 'Failed to submit today check-in.'));
  }

  Future<bool> deleteCheckInFailureRecord(String date) async {
    final currentSession = _session;
    if (currentSession == null || date.trim().isEmpty) {
      return false;
    }

    var deleted = false;
    await _runBusyAction(() async {
      deleted = await _checkInApi.deleteFailureRecord(
        currentSession,
        date: date,
      );
      final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _bannerMessage = deleted
          ? _message('失败记录已删除。', 'Failure record removed.')
          : _message('没有删除任何失败记录。', 'No failure record was removed.');
    },
        fallbackMessage:
            _message('删除失败记录失败。', 'Failed to delete the failure record.'));
    return deleted;
  }

  Future<SettingOverview?> loadSettingsOverview() async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    SettingOverview? latestOverview;
    await _runBusyAction(() async {
      final settingsOverview = await _settingsApi.getOverview(currentSession);
      _applySettingOverview(settingsOverview);
      latestOverview = settingsOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载设置概览失败。', 'Failed to load the settings overview.'));
    return latestOverview;
  }

  Future<List<BlacklistItem>> loadBlacklist() async {
    final currentSession = _session;
    if (currentSession == null) {
      return const [];
    }

    var latest = _blacklist;
    await _runBusyAction(() async {
      latest = await _settingsApi.getBlacklist(currentSession);
      _blacklist = latest;
    },
        fallbackMessage: _message(
          '加载黑名单失败。',
          'Failed to load the blacklist.',
        ));
    return latest;
  }

  Future<bool> addBlacklist(int targetUserId) async {
    final currentSession = _session;
    if (currentSession == null || targetUserId <= 0) {
      return false;
    }

    var added = false;
    await _runBusyAction(() async {
      added = await _settingsApi.addBlacklist(currentSession, targetUserId);
      if (added) {
        _blacklist = await _settingsApi.getBlacklist(currentSession);
        _bannerMessage = _message('已加入黑名单。', 'Added to the blacklist.');
      }
    },
        fallbackMessage: _message(
          '加入黑名单失败。',
          'Failed to add the blacklist entry.',
        ));
    return added;
  }

  Future<bool> removeBlacklist(int blockedUserId) async {
    final currentSession = _session;
    if (currentSession == null || blockedUserId <= 0) {
      return false;
    }

    var removed = false;
    await _runBusyAction(() async {
      removed = await _settingsApi.removeBlacklist(
        currentSession,
        blockedUserId,
      );
      if (removed) {
        _blacklist = _blacklist
            .where((item) => item.blockedUserId != blockedUserId)
            .toList(growable: false);
        _bannerMessage = _message('已解除拉黑。', 'Removed from the blacklist.');
      }
    },
        fallbackMessage: _message(
          '解除拉黑失败。',
          'Failed to remove the blacklist entry.',
        ));
    return removed;
  }

  Future<CurrentDeviceSession?> loadCurrentDeviceSession() async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    CurrentDeviceSession? latest = _currentDeviceSession;
    await _runBusyAction(() async {
      latest = await _settingsApi.getCurrentDeviceSession(currentSession);
      _currentDeviceSession = latest;
    },
        fallbackMessage: _message(
          '加载当前设备会话失败。',
          'Failed to load the current device session.',
        ));
    return latest;
  }

  Future<UserProfile?> updateMySettingProfile({
    required String nickname,
    required String avatarUrl,
    required String bio,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    UserProfile? updatedProfile;
    await _runBusyAction(() async {
      updatedProfile = await _settingsApi.updateProfile(
        currentSession,
        nickname: nickname.trim(),
        avatarUrl: avatarUrl.trim(),
        bio: bio.trim(),
      );
      if (updatedProfile != null) {
        _syncProfile(updatedProfile!);
      }
      _bannerMessage = _message('资料已更新。', 'Profile updated.');
    }, fallbackMessage: _message('更新资料失败。', 'Failed to update the profile.'));
    return updatedProfile;
  }

  Future<UserProfile?> uploadMyAvatar({
    required List<int> bytes,
    required String filename,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    UserProfile? updatedProfile;
    await _runBusyAction(() async {
      await _settingsApi.uploadAvatar(
        currentSession,
        bytes: bytes,
        filename: filename,
      );
      updatedProfile = await _authApi.getProfile(currentSession);
      _syncProfile(updatedProfile!);
      _bannerMessage = _message('头像已更新。', 'Avatar updated.');
    }, fallbackMessage: _message('头像上传失败。', 'Failed to upload the avatar.'));
    return updatedProfile;
  }

  Future<PrivacySetting?> updateMyPrivacySetting({
    required bool allowFriendViewProfile,
    required bool allowTeammateViewStudy,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    PrivacySetting? updatedSetting;
    await _runBusyAction(() async {
      updatedSetting = await _settingsApi.updatePrivacy(
        currentSession,
        allowFriendViewProfile: allowFriendViewProfile,
        allowTeammateViewStudy: allowTeammateViewStudy,
      );
      if (updatedSetting != null) {
        _settingOverview = _settingOverview.copyWith(
          privacySetting: updatedSetting,
        );
      }
      _bannerMessage = _message('隐私设置已更新。', 'Privacy settings updated.');
    },
        fallbackMessage:
            _message('更新隐私设置失败。', 'Failed to update privacy settings.'));
    return updatedSetting;
  }

  Future<NotificationSetting?> updateNotificationSetting({
    required bool mobilePushEnabled,
    required bool desktopNoticeEnabled,
    required bool teamRemindEnabled,
    required bool systemAnnouncementEnabled,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationSetting? updatedSetting;
    await _runBusyAction(() async {
      updatedSetting = await _settingsApi.updateNotifications(
        currentSession,
        mobilePushEnabled: mobilePushEnabled,
        desktopNoticeEnabled: desktopNoticeEnabled,
        teamRemindEnabled: teamRemindEnabled,
        systemAnnouncementEnabled: systemAnnouncementEnabled,
      );
      if (updatedSetting != null) {
        _settingOverview = _settingOverview.copyWith(
          notificationSetting: updatedSetting,
        );
      }
      _bannerMessage = _message('通知设置已更新。', 'Notification settings updated.');
    },
        fallbackMessage: _message(
          '更新通知设置失败。',
          'Failed to update notification settings.',
        ));
    return updatedSetting;
  }

  Future<WidgetSetting?> updateWidgetSetting({
    required bool autoStart,
    required bool alwaysOnTop,
    required bool showPlan,
    required bool showTimer,
    required bool showMemo,
  }) async {
    final currentSession = _session;
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      WidgetSetting? updatedSetting;
      await _runBusyAction(() async {
        updatedSetting = await _offlineStore.saveLocalWidgetSetting(
          ownerScope,
          WidgetSetting(
            autoStart: autoStart,
            alwaysOnTop: alwaysOnTop,
            showPlan: showPlan,
            showTimer: showTimer,
            showMemo: showMemo,
          ),
        );
        _settingOverview = _settingOverview.copyWith(
          widgetSetting: updatedSetting,
        );
        await _applyDesktopShellSettings(widgetSetting: updatedSetting!);
        _bannerMessage = _message(
          '桌面偏好已保存到本机。',
          'Desktop preferences were saved on this device.',
        );
      },
          fallbackMessage: _message(
            '保存本机桌面偏好失败。',
            'Failed to save desktop preferences on this device.',
          ));
      return updatedSetting;
    }
    if (currentSession == null) {
      return null;
    }

    WidgetSetting? updatedSetting;
    await _runBusyAction(() async {
      updatedSetting = await _settingsApi.updateWidget(
        currentSession,
        autoStart: autoStart,
        alwaysOnTop: alwaysOnTop,
        showPlan: showPlan,
        showTimer: showTimer,
        showMemo: showMemo,
      );
      if (updatedSetting != null) {
        _settingOverview = _settingOverview.copyWith(
          widgetSetting: updatedSetting,
        );
        await _applyDesktopShellSettings(
          widgetSetting: updatedSetting!,
        );
      }
      _bannerMessage = _message('挂件设置已更新。', 'Widget settings updated.');
    },
        fallbackMessage:
            _message('更新挂件设置失败。', 'Failed to update widget settings.'));
    return updatedSetting;
  }

  Future<AppearanceSetting?> updateAppearanceSetting({
    required String themeMode,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    AppearanceSetting? updatedSetting;
    await _runBusyAction(() async {
      updatedSetting = await _settingsApi.updateAppearance(
        currentSession,
        themeMode: themeMode,
      );
      if (updatedSetting != null) {
        _settingOverview = _settingOverview.copyWith(
          appearanceSetting: updatedSetting,
        );
      }
      _bannerMessage = _message('外观设置已更新。', 'Appearance settings updated.');
    },
        fallbackMessage:
            _message('更新外观设置失败。', 'Failed to update appearance settings.'));
    return updatedSetting;
  }

  Future<bool> clearSettingsCache() async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }

    var cleared = false;
    await _runBusyAction(() async {
      cleared = await _settingsApi.clearCache(currentSession);
      _bannerMessage = cleared
          ? _message('缓存已清理。', 'Cache cleared.')
          : _message('没有清理任何缓存。', 'No cache was cleared.');
    }, fallbackMessage: _message('清理缓存失败。', 'Failed to clear the cache.'));
    return cleared;
  }

  Future<void> sendCancelAccountCode(String email) {
    return _settingsApi.sendCancelCode(email.trim());
  }

  Future<bool> cancelAccount({
    String password = '',
    String emailCode = '',
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }

    var cancelled = false;
    await _runBusyAction(() async {
      cancelled = await _settingsApi.cancelAccount(
        currentSession,
        password: password.trim(),
        emailCode: emailCode.trim(),
      );
      if (!cancelled) {
        return;
      }
      await _localStorage.clearSession();
      _session = null;
      _profile = null;
      _focusSession = FocusSession.empty();
      _checkInStatus = CheckInStatus.empty();
      _statsOverview = StatsOverview.empty();
      _teamOverview = TeamOverview.empty();
      _friendOverview = FriendOverview.empty();
      _memoOverview = MemoOverview.empty();
      _notificationOverview = NotificationOverview.empty();
      _todayPlan = TodayPlan.empty();
      _weekPlanOverview = WeekPlanOverview.empty();
      _settingOverview = SettingOverview.empty();
      _blacklist = const [];
      _currentDeviceSession = null;
      _weeklyTemplates = const [];
      _bannerMessage = _message('账号已注销。', 'Account cancelled.');
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    }, fallbackMessage: _message('注销账号失败。', 'Failed to cancel the account.'));
    return cancelled;
  }

  Future<StatsOverview?> loadStatsOverview({int days = 7}) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      StatsOverview? latestOverview;
      await _runBusyAction(() async {
        latestOverview = await _offlineStore.loadStatsOverview(
          ownerScope,
          days: days,
        );
        _statsRangeDays = days == 30 ? 30 : 7;
        _statsOverview = latestOverview!;
        _bannerMessage = _message(
          '显示的是本机离线记录；签到结果仍需登录后由服务端验证。',
          'Showing local offline records. Check-ins still require server validation after sign-in.',
        );
      },
          fallbackMessage:
              _message('加载本地统计失败。', 'Failed to load local statistics.'));
      return latestOverview;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    StatsOverview? latestOverview;
    await _runBusyAction(() async {
      final statsOverview =
          await _statsApi.getOverview(currentSession, days: days);
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final friendOverview = await _friendApi.getOverview(currentSession);
      _statsRangeDays = days;
      _statsOverview = statsOverview;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _friendOverview = friendOverview;
      latestOverview = statsOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载统计概览失败。', 'Failed to load the statistics overview.'));
    return latestOverview;
  }

  Future<bool> remindTeammate(int teammateUserId) async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }

    bool sent = false;
    await _runBusyAction(() async {
      final reminderCount = await _teamApi.remindTeammate(
        currentSession,
        teammateUserId: teammateUserId,
      );
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _bannerMessage = reminderCount == null
          ? _message('已向队友发送提醒。', 'Reminder sent to your teammate.')
          : _message(
              '提醒已发送，今日已用 $reminderCount/5 次。',
              'Reminder sent. Today: $reminderCount/5.',
            );
      sent = true;
    },
        fallbackMessage:
            _message('发送队友提醒失败。', 'Failed to send the teammate reminder.'));
    return sent;
  }

  Future<FriendOverview?> loadFriendOverview() async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.getOverview(currentSession);
      _friendOverview = friendOverview;
      latestOverview = friendOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载好友概览失败。', 'Failed to load the friend overview.'));
    return latestOverview;
  }

  Future<List<FriendSearchItemModel>> searchFriends(String keyword) async {
    final currentSession = _session;
    final trimmedKeyword = keyword.trim();
    if (currentSession == null || trimmedKeyword.isEmpty) {
      return const [];
    }

    _isBusy = true;
    notifyListeners();
    try {
      final items = await _friendApi.search(
        currentSession,
        keyword: trimmedKeyword,
      );
      _bannerMessage = null;
      return items;
    } on ApiException catch (error) {
      _bannerMessage = error.message;
      return const [];
    } catch (_) {
      _bannerMessage = _message('搜索用户失败。', 'Failed to search for users.');
      return const [];
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<FriendOverview?> sendFriendRequest(
    int targetUserId, {
    String message = '',
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.createRequest(
        currentSession,
        targetUserId: targetUserId,
        message: message.trim(),
      );
      _friendOverview = friendOverview;
      latestOverview = friendOverview;
      _bannerMessage = _message('好友申请已发送。', 'Friend request sent.');
    },
        fallbackMessage:
            _message('发送好友申请失败。', 'Failed to send the friend request.'));
    return latestOverview;
  }

  Future<FriendOverview?> respondToFriendRequest(
    int requestId, {
    required bool accept,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.respondRequest(
        currentSession,
        requestId: requestId,
        accept: accept,
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _friendOverview = friendOverview;
      _notificationOverview = notificationOverview;
      latestOverview = friendOverview;
      _bannerMessage = accept
          ? _message('已接受好友申请。', 'Friend request accepted.')
          : _message('已拒绝好友申请。', 'Friend request declined.');
    },
        fallbackMessage:
            _message('处理好友申请失败。', 'Failed to respond to the friend request.'));
    return latestOverview;
  }

  Future<NotificationOverview?> respondNotificationFriendRequest(
    int requestId, {
    required bool accept,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.respondRequest(
        currentSession,
        requestId: requestId,
        accept: accept,
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _friendOverview = friendOverview;
      _notificationOverview = notificationOverview;
      latestOverview = notificationOverview;
      _bannerMessage = accept
          ? _message('已接受好友申请。', 'Friend request accepted.')
          : _message('已拒绝好友申请。', 'Friend request declined.');
    },
        fallbackMessage:
            _message('处理好友申请失败。', 'Failed to respond to the friend request.'));
    return latestOverview;
  }

  Future<FriendOverview?> createFriendGroup(String groupName) async {
    final currentSession = _session;
    final trimmedGroupName = groupName.trim();
    if (currentSession == null || trimmedGroupName.isEmpty) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.createGroup(
        currentSession,
        groupName: trimmedGroupName,
      );
      _friendOverview = friendOverview;
      latestOverview = friendOverview;
      _bannerMessage = _message('好友分组已创建。', 'Friend group created.');
    },
        fallbackMessage:
            _message('创建好友分组失败。', 'Failed to create the friend group.'));
    return latestOverview;
  }

  Future<FriendOverview?> moveFriendToGroup(
    int friendUserId, {
    required int groupId,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.moveToGroup(
        currentSession,
        friendUserId: friendUserId,
        groupId: groupId,
      );
      _friendOverview = friendOverview;
      latestOverview = friendOverview;
      _bannerMessage =
          _message('好友已移动到所选分组。', 'Friend moved to the selected group.');
    }, fallbackMessage: _message('移动好友失败。', 'Failed to move the friend.'));
    return latestOverview;
  }

  Future<FriendOverview?> deleteFriend(int friendUserId) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    FriendOverview? latestOverview;
    await _runBusyAction(() async {
      final friendOverview = await _friendApi.deleteFriend(
        currentSession,
        friendUserId: friendUserId,
      );
      _friendOverview = friendOverview;
      latestOverview = friendOverview;
      _bannerMessage = _message('好友已移除。', 'Friend removed.');
    }, fallbackMessage: _message('移除好友失败。', 'Failed to remove the friend.'));
    return latestOverview;
  }

  Future<MemoOverview?> loadMemoOverview() async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      _memoOverview = await _offlineStore.loadMemoOverview(ownerScope);
      notifyListeners();
      return _memoOverview;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    MemoOverview? latestOverview;
    await _runBusyAction(() async {
      final memoOverview = await _memoApi.getOverview(currentSession);
      _memoOverview = memoOverview;
      latestOverview = memoOverview;
      _bannerMessage = null;
    }, fallbackMessage: _message('加载备忘录失败。', 'Failed to load memos.'));
    return latestOverview;
  }

  Future<MemoCardModel?> loadMemoDetail(int memoId) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      return _offlineStore.loadMemo(ownerScope, memoId);
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    MemoCardModel? memoDetail;
    await _runBusyAction(() async {
      memoDetail = await _memoApi.getDetail(
        currentSession,
        memoId: memoId,
      );
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载备忘录详情失败。', 'Failed to load the memo detail.'));
    return memoDetail;
  }

  Future<MemoOverview?> createMemo(MemoCardModel draft) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _memoOverview = await _offlineStore.saveMemo(ownerScope, draft);
        _bannerMessage = _message(
          '备忘录已保存在本机。',
          'Memo saved on this device.',
        );
      },
          fallbackMessage:
              _message('本地备忘录保存失败。', 'Failed to save the local memo.'));
      return _memoOverview;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    MemoOverview? latestOverview;
    await _runBusyAction(() async {
      await _memoApi.createMemo(
        currentSession,
        draft: draft,
      );
      final memoOverview = await _memoApi.getOverview(currentSession);
      _memoOverview = memoOverview;
      latestOverview = memoOverview;
      _bannerMessage = _message('备忘录已保存。', 'Memo saved.');
    }, fallbackMessage: _message('保存备忘录失败。', 'Failed to save the memo.'));
    return latestOverview;
  }

  Future<MemoOverview?> updateMemo(
    int memoId,
    MemoCardModel draft,
  ) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _memoOverview = await _offlineStore.saveMemo(
          ownerScope,
          draft,
          memoId: memoId,
        );
        _bannerMessage = _message(
          '备忘录已在本机更新。',
          'Memo updated on this device.',
        );
      },
          fallbackMessage:
              _message('本地备忘录更新失败。', 'Failed to update the local memo.'));
      return _memoOverview;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    MemoOverview? latestOverview;
    await _runBusyAction(() async {
      await _memoApi.updateMemo(
        currentSession,
        memoId: memoId,
        draft: draft,
      );
      final memoOverview = await _memoApi.getOverview(currentSession);
      _memoOverview = memoOverview;
      latestOverview = memoOverview;
      _bannerMessage = _message('备忘录已更新。', 'Memo updated.');
    }, fallbackMessage: _message('更新备忘录失败。', 'Failed to update the memo.'));
    return latestOverview;
  }

  Future<MemoOverview?> deleteMemo(int memoId) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _memoOverview = await _offlineStore.deleteMemo(ownerScope, memoId);
        _bannerMessage = _message(
          '本地备忘录已删除。',
          'Local memo deleted.',
        );
      },
          fallbackMessage:
              _message('删除本地备忘录失败。', 'Failed to delete the local memo.'));
      return _memoOverview;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    MemoOverview? latestOverview;
    await _runBusyAction(() async {
      final deleted = await _memoApi.deleteMemo(
        currentSession,
        memoId: memoId,
      );
      final memoOverview = await _memoApi.getOverview(currentSession);
      _memoOverview = memoOverview;
      latestOverview = memoOverview;
      _bannerMessage = deleted
          ? _message('备忘录已删除。', 'Memo deleted.')
          : _message('没有删除任何备忘录。', 'No memo was deleted.');
    }, fallbackMessage: _message('删除备忘录失败。', 'Failed to delete the memo.'));
    return latestOverview;
  }

  Future<NotificationOverview?> loadNotifications({int limit = 40}) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationOverview? latestOverview;
    await _runBusyAction(() async {
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
        limit: limit,
      );
      _notificationOverview = notificationOverview;
      latestOverview = notificationOverview;
      _bannerMessage = null;
    }, fallbackMessage: _message('加载通知失败。', 'Failed to load notifications.'));
    return latestOverview;
  }

  Future<TeamChatOverview?> loadTeamChatMessages({int limit = 50}) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }
    if (!_teamOverview.inTeam) {
      _teamChatOverview = TeamChatOverview.empty();
      notifyListeners();
      return _teamChatOverview;
    }

    TeamChatOverview? latestOverview;
    await _runBusyAction(() async {
      final teamChatOverview = await _teamApi.getTeamChat(
        currentSession,
        limit: limit,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      _teamChatOverview = teamChatOverview;
      _teamOverview = teamOverview;
      latestOverview = teamChatOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载团队群聊消息失败。', 'Failed to load team chat messages.'));
    return latestOverview;
  }

  Future<TeamChatOverview?> sendTeamChatMessage(String content) async {
    final currentSession = _session;
    final trimmedContent = content.trim();
    if (currentSession == null || trimmedContent.isEmpty) {
      return null;
    }

    TeamChatOverview? latestOverview;
    await _runBusyAction(() async {
      final teamChatOverview = await _teamApi.sendTeamChatMessage(
        currentSession,
        content: trimmedContent,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _teamChatOverview = teamChatOverview;
      _teamOverview = teamOverview;
      _notificationOverview = notificationOverview;
      latestOverview = teamChatOverview;
      _bannerMessage = _message('团队消息已发送。', 'Team message sent.');
    },
        fallbackMessage:
            _message('发送团队消息失败。', 'Failed to send the team message.'));
    return latestOverview;
  }

  Future<TeamChatOverview?> markTeamChatRead() async {
    final currentSession = _session;
    if (currentSession == null || !_teamOverview.inTeam) {
      return null;
    }

    TeamChatOverview? latestOverview;
    await _runBusyAction(() async {
      final teamChatOverview = await _teamApi.markTeamChatRead(currentSession);
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _teamChatOverview = teamChatOverview;
      _teamOverview = teamOverview;
      _notificationOverview = notificationOverview;
      latestOverview = teamChatOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('更新团队群聊状态失败。', 'Failed to update the team chat state.'));
    return latestOverview;
  }

  Future<TeamWorkspaceSnapshot?> loadTeamWorkspaceSnapshot() async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    TeamWorkspaceSnapshot? snapshot;
    await _runBusyAction(() async {
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final friendOverview = await _friendApi.getOverview(currentSession);
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _friendOverview = friendOverview;
      snapshot = TeamWorkspaceSnapshot(
        teamOverview: teamOverview,
        friendOverview: friendOverview,
        teamChatOverview: teamChatOverview,
        bannerMessage: _bannerMessage,
      );
    },
        fallbackMessage:
            _message('刷新团队工作区失败。', 'Failed to refresh the team workspace.'));
    return snapshot;
  }

  Future<bool> reportTeamChatMessage(
    int messageId, {
    required String reason,
    String description = '',
  }) async {
    final currentSession = _session;
    final trimmedReason = reason.trim();
    final trimmedDescription = description.trim();
    if (currentSession == null || messageId <= 0 || trimmedReason.isEmpty) {
      return false;
    }

    var reported = false;
    await _runBusyAction(() async {
      final result = await _teamApi.reportTeamChatMessage(
        currentSession,
        messageId: messageId,
        reason: trimmedReason,
        description: trimmedDescription,
      );
      _bannerMessage = result.message.isEmpty
          ? _message('举报已提交。', 'Report submitted.')
          : result.message;
      reported = true;
    },
        fallbackMessage:
            _message('提交聊天举报失败。', 'Failed to submit the chat report.'));
    return reported;
  }

  Future<List<AdminReportListItem>> loadAdminReports({
    String status = 'pending',
    String reportType = 'team_chat',
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return const [];
    }

    List<AdminReportListItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.getReports(
        currentSession,
        status: status,
        reportType: reportType,
        limit: limit,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载举报列表失败。', 'Failed to load report list.'));
    return items;
  }

  Future<AdminReportDetail?> loadAdminReportDetail(int reportId) async {
    final currentSession = _session;
    if (currentSession == null || reportId <= 0) {
      return null;
    }

    AdminReportDetail? detail;
    await _runBusyAction(() async {
      detail = await _adminReportApi.getReportDetail(
        currentSession,
        reportId: reportId,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载举报详情失败。', 'Failed to load report detail.'));
    return detail;
  }

  Future<AdminReportReviewResult?> reviewAdminReport(
    int reportId, {
    required String decision,
    required bool deleteContent,
    required String punishmentType,
    required int durationDays,
    required String reason,
  }) async {
    final currentSession = _session;
    if (currentSession == null || reportId <= 0) {
      return null;
    }

    AdminReportReviewResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.reviewReport(
        currentSession,
        reportId: reportId,
        decision: decision,
        deleteContent: deleteContent,
        punishmentType: punishmentType,
        durationDays: durationDays,
        reason: reason.trim(),
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _notificationOverview = notificationOverview;
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('举报审核已提交。', 'Report review submitted.');
    },
        fallbackMessage:
            _message('提交举报审核失败。', 'Failed to submit the report review.'));
    return result;
  }

  Future<List<AdminUserSearchItem>> searchAdminUsers({
    String keyword = '',
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return const [];
    }

    List<AdminUserSearchItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.searchUsers(
        currentSession,
        keyword: keyword,
        limit: limit,
      );
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载用户搜索结果失败。', 'Failed to load user search results.'));
    return items;
  }

  Future<AdminUserDetail?> loadAdminUserDetail(int userId) async {
    final currentSession = _session;
    if (currentSession == null || userId <= 0) {
      return null;
    }

    AdminUserDetail? detail;
    await _runBusyAction(() async {
      detail = await _adminReportApi.getUserDetail(
        currentSession,
        userId: userId,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载用户详情失败。', 'Failed to load user detail.'));
    return detail;
  }

  Future<List<AdminUserReportItem>> loadAdminUserReports(
    int userId, {
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null || userId <= 0) {
      return const [];
    }

    List<AdminUserReportItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.getUserReports(
        currentSession,
        userId: userId,
        limit: limit,
      );
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载用户举报历史失败。', 'Failed to load user report history.'));
    return items;
  }

  Future<List<AdminUserPunishmentItem>> loadAdminUserPunishments(
    int userId, {
    String status = 'active',
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null || userId <= 0) {
      return const [];
    }

    List<AdminUserPunishmentItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.getUserPunishments(
        currentSession,
        userId: userId,
        status: status,
        limit: limit,
      );
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载用户处罚历史失败。', 'Failed to load user punishment history.'));
    return items;
  }

  Future<AdminLiftPunishmentResult?> liftAdminUserPunishment(
    int userId, {
    required int punishmentId,
  }) async {
    final currentSession = _session;
    if (currentSession == null || userId <= 0 || punishmentId <= 0) {
      return null;
    }

    AdminLiftPunishmentResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.liftPunishment(
        currentSession,
        userId: userId,
        punishmentId: punishmentId,
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _notificationOverview = notificationOverview;
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('处罚已解除。', 'Punishment lifted.');
    }, fallbackMessage: _message('解除处罚失败。', 'Failed to lift the punishment.'));
    return result;
  }

  Future<List<AdminTeamListItem>> loadAdminTeams({
    String keyword = '',
    int? status,
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return const [];
    }

    List<AdminTeamListItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.getTeams(
        currentSession,
        keyword: keyword,
        status: status,
        limit: limit,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载团队列表失败。', 'Failed to load team list.'));
    return items;
  }

  Future<AdminTeamDetail?> loadAdminTeamDetail(int teamId) async {
    final currentSession = _session;
    if (currentSession == null || teamId <= 0) {
      return null;
    }

    AdminTeamDetail? detail;
    await _runBusyAction(() async {
      detail = await _adminReportApi.getTeamDetail(
        currentSession,
        teamId: teamId,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载团队详情失败。', 'Failed to load team detail.'));
    return detail;
  }

  Future<AdminTeamActionResult?> removeAdminTeamMember(
    int teamId, {
    required int memberUserId,
  }) async {
    final currentSession = _session;
    if (currentSession == null || teamId <= 0 || memberUserId <= 0) {
      return null;
    }

    AdminTeamActionResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.removeTeamMember(
        currentSession,
        teamId: teamId,
        memberUserId: memberUserId,
      );
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('团队成员已移除。', 'Team member removed.');
    },
        fallbackMessage:
            _message('移除团队成员失败。', 'Failed to remove the team member.'));
    return result;
  }

  Future<AdminTeamActionResult?> dissolveAdminTeam(int teamId) async {
    final currentSession = _session;
    if (currentSession == null || teamId <= 0) {
      return null;
    }

    AdminTeamActionResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.dissolveTeam(
        currentSession,
        teamId: teamId,
      );
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('团队已解散。', 'Team dissolved.');
    }, fallbackMessage: _message('解散团队失败。', 'Failed to dissolve the team.'));
    return result;
  }

  Future<List<AdminAnnouncementItem>> loadAdminAnnouncements({
    int limit = 50,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return const [];
    }

    List<AdminAnnouncementItem> items = const [];
    await _runBusyAction(() async {
      items = await _adminReportApi.getAnnouncements(
        currentSession,
        limit: limit,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载公告失败。', 'Failed to load announcements.'));
    return items;
  }

  Future<AdminAnnouncementActionResult?> createAdminAnnouncement({
    required String title,
    required String content,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    AdminAnnouncementActionResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.createAnnouncement(
        currentSession,
        title: title.trim(),
        content: content.trim(),
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _notificationOverview = notificationOverview;
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('公告已发布。', 'Announcement published.');
    },
        fallbackMessage:
            _message('发布公告失败。', 'Failed to publish the announcement.'));
    return result;
  }

  Future<AdminAnnouncementActionResult?> deleteAdminAnnouncement(
    int announcementId,
  ) async {
    final currentSession = _session;
    if (currentSession == null || announcementId <= 0) {
      return null;
    }

    AdminAnnouncementActionResult? result;
    await _runBusyAction(() async {
      result = await _adminReportApi.deleteAnnouncement(
        currentSession,
        announcementId: announcementId,
      );
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _notificationOverview = notificationOverview;
      _bannerMessage = result?.message.isNotEmpty == true
          ? result!.message
          : _message('公告已删除。', 'Announcement deleted.');
    },
        fallbackMessage:
            _message('删除公告失败。', 'Failed to delete the announcement.'));
    return result;
  }

  Future<NotificationOverview?> markNotificationRead(int notificationId) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationOverview? latestOverview;
    await _runBusyAction(() async {
      final notificationOverview = await _notificationApi.markRead(
        currentSession,
        notificationId: notificationId,
      );
      _notificationOverview = notificationOverview;
      latestOverview = notificationOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('更新通知失败。', 'Failed to update the notification.'));
    return latestOverview;
  }

  Future<NotificationOverview?> markAllNotificationsRead() async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationOverview? latestOverview;
    await _runBusyAction(() async {
      final notificationOverview = await _notificationApi.markAllRead(
        currentSession,
      );
      _notificationOverview = notificationOverview;
      latestOverview = notificationOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('批量更新通知失败。', 'Failed to update the notifications.'));
    return latestOverview;
  }

  Future<void> createTeam(String teamName) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final teamOverview = await _teamApi.createTeam(
        currentSession,
        teamName: teamName.trim(),
      );
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _bannerMessage = _message(
        '团队已创建，可以把邀请码分享给可信好友。',
        'Team created. You can now share the invite code with trusted friends.',
      );
    }, fallbackMessage: _message('创建团队失败。', 'Failed to create the team.'));
  }

  Future<void> joinTeam(String inviteCode) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final teamOverview = await _teamApi.joinTeam(
        currentSession,
        inviteCode: inviteCode.trim(),
      );
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _bannerMessage = _message('已成功加入团队。', 'Joined the team successfully.');
    }, fallbackMessage: _message('加入团队失败。', 'Failed to join the team.'));
  }

  Future<void> inviteTeamMember(int targetUserId) async {
    final currentSession = _session;
    if (currentSession == null || targetUserId <= 0) {
      return;
    }

    await _runBusyAction(() async {
      final teamOverview = await _teamApi.inviteMember(
        currentSession,
        targetUserId: targetUserId,
      );
      final friendOverview = await _friendApi.getOverview(currentSession);
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _teamOverview = teamOverview;
      _friendOverview = friendOverview;
      _notificationOverview = notificationOverview;
      _bannerMessage = _message('团队邀请已发送。', 'Team invitation sent.');
    },
        fallbackMessage:
            _message('发送团队邀请失败。', 'Failed to send the team invitation.'));
  }

  Future<NotificationOverview?> respondNotificationTeamInvitation(
    int invitationId, {
    required bool accept,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    NotificationOverview? latestOverview;
    await _runBusyAction(() async {
      final teamOverview = await _teamApi.respondInvitation(
        currentSession,
        invitationId: invitationId,
        accept: accept,
      );
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final friendOverview = await _friendApi.getOverview(currentSession);
      final notificationOverview = await _notificationApi.getOverview(
        currentSession,
      );
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _friendOverview = friendOverview;
      _notificationOverview = notificationOverview;
      latestOverview = notificationOverview;
      _bannerMessage = accept
          ? _message('已接受团队邀请。', 'Team invitation accepted.')
          : _message('已拒绝团队邀请。', 'Team invitation declined.');
    },
        fallbackMessage:
            _message('处理团队邀请失败。', 'Failed to respond to the team invitation.'));
    return latestOverview;
  }

  Future<bool> removeTeamMember(int memberUserId) async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }

    var removed = false;
    await _runBusyAction(() async {
      removed = await _teamApi.removeMember(
        currentSession,
        memberUserId: memberUserId,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _bannerMessage = removed
          ? _message('团队成员已移除。', 'Team member removed.')
          : _message('没有移除任何团队成员。', 'No team member was removed.');
    },
        fallbackMessage:
            _message('移除团队成员失败。', 'Failed to remove the team member.'));
    return removed;
  }

  Future<bool> dissolveTeam() async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }

    var dissolved = false;
    await _runBusyAction(() async {
      dissolved = await _teamApi.dissolveTeam(currentSession);
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _bannerMessage = dissolved
          ? _message('团队已解散。', 'Team dissolved.')
          : _message('团队未被解散。', 'The team was not dissolved.');
    }, fallbackMessage: _message('解散团队失败。', 'Failed to dissolve the team.'));
    return dissolved;
  }

  void _applySettingOverview(SettingOverview overview) {
    _settingOverview = overview;
    _profile = overview.accountSetting;
    unawaited(
      _applyDesktopShellSettings(
        widgetSetting: overview.widgetSetting,
      ),
    );
  }

  void _syncProfile(UserProfile profile) {
    _profile = profile;
    _settingOverview = _settingOverview.copyWith(
      accountSetting: profile,
    );
  }

  void _syncFocusTicker() {
    if (_focusSession.active) {
      _focusTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_focusSession.active) {
          _stopFocusTicker();
          return;
        }
        _focusSession = _focusSession.tick();
        notifyListeners();
        if (!_focusSession.active) {
          _stopFocusTicker();
          unawaited(_reconcileFocusCompletion());
        }
      });
      return;
    }
    _stopFocusTicker();
  }

  void _stopFocusTicker() {
    _focusTicker?.cancel();
    _focusTicker = null;
  }

  Future<void> _applyDesktopShellSettings({
    required WidgetSetting widgetSetting,
  }) {
    return DesktopWidgetBridge.applySettings(
      widgetSetting: widgetSetting,
    );
  }

  Future<void> _reconcileFocusCompletion() async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      _focusSession = await _offlineStore.finishFocusSession(
        ownerScope,
        _focusSession.sessionId,
      );
      notifyListeners();
      return;
    }
    final currentSession = _session;
    if (currentSession == null || _isReconcilingFocusCompletion) {
      return;
    }

    _isReconcilingFocusCompletion = true;
    try {
      final focusSession =
          await _focusSessionApi.getCurrentSession(currentSession);
      final profile = await _authApi.getProfile(currentSession);
      final checkInStatus = await _checkInApi.getTodayStatus(currentSession);
      final statsOverview = await _statsApi.getOverview(
        currentSession,
        days: _statsRangeDays,
      );
      final teamOverview = await _teamApi.getCurrentTeam(currentSession);
      final teamChatOverview = teamOverview.inTeam
          ? await _teamApi.getTeamChat(currentSession)
          : TeamChatOverview.empty();
      _focusSession = focusSession;
      _profile = profile;
      _checkInStatus = checkInStatus;
      _statsOverview = statsOverview;
      _statsRangeDays = statsOverview.rangeDays;
      _teamOverview = teamOverview;
      _teamChatOverview = teamChatOverview;
      notifyListeners();
    } catch (_) {
      // Keep the local completed state if the silent refresh fails.
    } finally {
      _isReconcilingFocusCompletion = false;
    }
  }

  Future<TodayPlan?> loadPlanByDate(String planDate) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      try {
        final plan = await _offlineStore.loadDailyPlan(ownerScope, planDate);
        _bannerMessage = null;
        return plan;
      } catch (_) {
        _bannerMessage = _message(
          '加载本地计划失败。',
          'Failed to load the local plan.',
        );
        notifyListeners();
        return null;
      }
    }
    final currentSession = _session;
    if (currentSession == null) {
      return null;
    }

    _isBusy = true;
    notifyListeners();
    try {
      final plan = await _studyPlanApi.getTodayPlan(
        currentSession,
        planDate: planDate,
      );
      _bannerMessage = null;
      return plan;
    } on ApiException catch (error) {
      _bannerMessage = error.message;
      return null;
    } catch (_) {
      _bannerMessage =
          _message('加载所选日期计划失败。', 'Failed to load the selected day plan.');
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthOverview(String month) async {
    if (DateTime.tryParse('$month-01') == null) {
      _bannerMessage = _message(
        '月份格式无效。',
        'Invalid month value.',
      );
      notifyListeners();
      return;
    }
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _monthPlanOverview =
            await _offlineStore.loadMonthOverview(ownerScope, month);
        _bannerMessage = null;
      },
          fallbackMessage:
              _message('加载本地月计划失败。', 'Failed to load the local month plan.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    await _runBusyAction(() async {
      _monthPlanOverview = await _studyPlanApi.getMonthPlanOverview(
        currentSession,
        month: month,
      );
      _bannerMessage = null;
    }, fallbackMessage: _message('加载月计划失败。', 'Failed to load the month plan.'));
  }

  Future<void> loadCurrentMonth() => loadMonthOverview(
        MonthPlanOverview.formatMonth(DateTime.now()),
      );

  Future<void> loadPreviousMonth() => _shiftMonth(-1);

  Future<void> loadNextMonth() => _shiftMonth(1);

  Future<void> _shiftMonth(int offset) {
    final current =
        DateTime.tryParse('${_monthPlanOverview.month}-01') ?? DateTime.now();
    return loadMonthOverview(
      MonthPlanOverview.formatMonth(
        DateTime(current.year, current.month + offset),
      ),
    );
  }

  Future<void> loadAnnualOverview(int year) async {
    if (year < 1 || year > 9999) {
      _bannerMessage = _message('年份无效。', 'Invalid year value.');
      notifyListeners();
      return;
    }
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _annualPlanOverview =
            await _offlineStore.loadAnnualOverview(ownerScope, year);
        _bannerMessage = null;
      },
          fallbackMessage:
              _message('加载本地年计划失败。', 'Failed to load the local annual plan.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    await _runBusyAction(() async {
      _annualPlanOverview = await _studyPlanApi.getAnnualPlanOverview(
        currentSession,
        year: year,
      );
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载年计划失败。', 'Failed to load the annual plan.'));
  }

  Future<void> loadCurrentYear() => loadAnnualOverview(DateTime.now().year);

  Future<void> loadPreviousYear() =>
      loadAnnualOverview(_annualPlanOverview.year - 1);

  Future<void> loadNextYear() =>
      loadAnnualOverview(_annualPlanOverview.year + 1);

  Future<void> saveAnnualSegment(AnnualPlanSegment segment) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _annualPlanOverview =
            await _offlineStore.saveAnnualSegment(ownerScope, segment);
        _bannerMessage = _message(
          '年度区间已保存在本机。',
          'Annual segment saved on this device.',
        );
      },
          fallbackMessage: _message(
              '保存本地年度区间失败。', 'Failed to save the local annual segment.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    await _runBusyAction(() async {
      _annualPlanOverview =
          await _studyPlanApi.saveAnnualSegment(currentSession, segment);
      _bannerMessage = _message('年度区间已保存。', 'Annual segment saved.');
    },
        fallbackMessage:
            _message('保存年度区间失败。', 'Failed to save the annual segment.'));
  }

  Future<void> deleteAnnualSegment(AnnualPlanSegment segment) async {
    final ownerScope = localOwnerScope;
    if (isOffline && ownerScope != null) {
      await _runBusyAction(() async {
        _annualPlanOverview =
            await _offlineStore.deleteAnnualSegment(ownerScope, segment);
        _bannerMessage = _message(
          '年度区间已从本机删除。',
          'Annual segment deleted from this device.',
        );
      },
          fallbackMessage: _message(
              '删除本地年度区间失败。', 'Failed to delete the local annual segment.'));
      return;
    }
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    await _runBusyAction(() async {
      _annualPlanOverview =
          await _studyPlanApi.deleteAnnualSegment(currentSession, segment);
      _bannerMessage = _message('年度区间已删除。', 'Annual segment deleted.');
    },
        fallbackMessage:
            _message('删除年度区间失败。', 'Failed to delete the annual segment.'));
  }

  Future<void> loadCurrentWeek() async {
    await _reloadWeekOverview();
  }

  Future<void> loadPreviousWeek() async {
    await _shiftWeek(-7);
  }

  Future<void> loadNextWeek() async {
    await _shiftWeek(7);
  }

  Future<void> _shiftWeek(int days) async {
    final baseAnchorDate = _weekAnchorDate ?? _todayPlan.planDate;
    final nextAnchorDate = _formatDate(
      _parseDate(baseAnchorDate).add(Duration(days: days)),
    );
    await _reloadWeekOverview(anchorDate: nextAnchorDate);
  }

  Future<void> _reloadWeekOverview({String? anchorDate}) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final weekPlanOverview = await _studyPlanApi.getWeekPlanOverview(
        currentSession,
        anchorDate: anchorDate,
      );
      _weekAnchorDate = anchorDate;
      _weekPlanOverview = weekPlanOverview;
      _bannerMessage = null;
    },
        fallbackMessage:
            _message('加载周视图失败。', 'Failed to load the weekly overview.'));
  }

  static DateTime _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<CheckInStatus> _buildOfflineCheckInStatus(
    String ownerScope,
    TodayPlan plan,
  ) async {
    final checkedIn = await _offlineStore.hasCheckInIntent(
      ownerScope,
      plan.planDate,
    );
    final completed = plan.hasItems && plan.completedCount == plan.totalCount;
    return CheckInStatus(
      checkInDate: plan.planDate,
      checkedInToday: checkedIn,
      canCheckInToday: !checkedIn && completed,
      todayPlanCompleted: completed,
      todayPlanCompletedCount: plan.completedCount,
      todayPlanTotalCount: plan.totalCount,
      consecutiveDays: checkedIn ? 1 : 0,
      totalDays: checkedIn ? 1 : 0,
      totalStudyDurationMinutes: 0,
      todayFailedAttempts: 0,
      latestFailureReason: '',
      lastCheckInTime: checkedIn ? DateTime.now().toIso8601String() : '',
      lastFailureTime: '',
    );
  }

  Future<void> _runBusyAction(
    Future<void> Function() action, {
    String fallbackMessage = '',
  }) async {
    final resolvedFallbackMessage = fallbackMessage.isEmpty
        ? _message('操作失败，请稍后重试。', 'Operation failed. Please try again.')
        : fallbackMessage;
    _isBusy = true;
    notifyListeners();

    try {
      await action();
    } on ApiException catch (error) {
      _bannerMessage = error.message;
    } catch (_) {
      _bannerMessage = resolvedFallbackMessage;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopFocusTicker();
    unawaited(_offlineStore.close());
    super.dispose();
  }
}
