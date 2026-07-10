import 'dart:async';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/team_workspace_snapshot.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
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
import 'package:innocence_flutter/features/team/data/team_api.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

enum SessionStatus {
  initializing,
  unauthenticated,
  authenticated,
}

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthApi authApi,
    required AuthLocalStorage localStorage,
    required AppLanguageController languageController,
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
  })  : _authApi = authApi,
        _localStorage = localStorage,
        _languageController = languageController,
        _studyPlanApi = studyPlanApi ?? StudyPlanApi(),
        _focusSessionApi = focusSessionApi ?? FocusSessionApi(),
        _checkInApi = checkInApi ?? CheckInApi(),
        _statsApi = statsApi ?? StatsApi(),
        _teamApi = teamApi ?? TeamApi(),
        _friendApi = friendApi ?? FriendApi(),
        _memoApi = memoApi ?? MemoApi(),
        _notificationApi = notificationApi ?? NotificationApi(),
        _settingsApi = settingsApi ?? SettingsApi(),
        _adminReportApi = adminReportApi ?? AdminReportApi();

  final AuthApi _authApi;
  final AuthLocalStorage _localStorage;
  final AppLanguageController _languageController;
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

  SessionStatus _status = SessionStatus.initializing;
  AppSession? _session;
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
  SettingOverview _settingOverview = SettingOverview.empty();
  String? _weekAnchorDate;
  int _statsRangeDays = 7;
  List<WeeklyPlanTemplate> _weeklyTemplates = const [];
  bool _isBusy = false;
  bool _didInitialize = false;
  bool _isReconcilingFocusCompletion = false;
  String? _bannerMessage;
  Timer? _focusTicker;

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
  SettingOverview get settingOverview => _settingOverview;
  List<WeeklyPlanTemplate> get weeklyTemplates => _weeklyTemplates;
  bool get isBusy => _isBusy;
  String? get bannerMessage => _bannerMessage;
  int get unreadNotificationCount => _notificationOverview.unreadCount;
  ThemeMode get themeMode => _settingOverview.appearanceSetting.isLightMode
      ? ThemeMode.light
      : ThemeMode.dark;

  String _message(String zh, String en) {
    return _isChineseLanguage ? zh : en;
  }

  String _weeklyTemplateSavedMessage() {
    return _message('周模板已保存。', 'Weekly template saved.');
  }

  String _weeklyTemplateAppliedMessage() {
    return _message('周模板已应用。', 'Weekly template applied.');
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
      final weeklyTemplates =
          await _studyPlanApi.getWeeklyTemplates(savedSession);
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
    } on ApiException {
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
      _weeklyTemplates = const [];
      _bannerMessage = _message(
        '会话已失效，请重新登录。',
        'Session expired. Please sign in again.',
      );
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    } catch (_) {
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
      _weeklyTemplates = const [];
      _bannerMessage = _message(
        '恢复上一次会话失败。',
        'Failed to restore the previous session.',
      );
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    }

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

  Future<void> refreshProfile() async {
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
          await _studyPlanApi.getWeeklyTemplates(currentSession);
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
      _syncFocusTicker();
    }, fallbackMessage: _message('刷新资料失败。', 'Failed to refresh the profile.'));
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();
    try {
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
      _weeklyTemplates = const [];
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
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }
    if (!sourcePlan.hasItems) {
      _bannerMessage =
          'Create tasks for that day first, then save them as a weekly template.';
      notifyListeners();
      return;
    }

    await _runBusyAction(() async {
      final templates = await _studyPlanApi.saveWeeklyTemplate(
        currentSession,
        templateName: templateName,
        sourcePlan: sourcePlan,
      );
      _weeklyTemplates = templates;
      _bannerMessage = resolvedSuccessMessage;
    },
        fallbackMessage:
            _message('保存周模板失败。', 'Failed to save the weekly template.'));
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
    final resolvedSuccessMessage = successMessage.isEmpty
        ? _weeklyTemplateAppliedMessage()
        : successMessage;
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final appliedPlan = await _studyPlanApi.applyWeeklyTemplate(
        currentSession,
        templateId: templateId,
        planDate: planDate,
      );
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
            _message('应用周模板失败。', 'Failed to apply the weekly template.'));
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
          await _studyPlanApi.getWeeklyTemplates(result.session);
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
    } catch (_) {
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
      _weeklyTemplates = const [];
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
      rethrow;
    }
  }

  Future<void> startFocusSession({
    required DateTime endTime,
    String? taskName,
    bool bindPomodoro = false,
    int pomodoroStudyMinutes = 0,
    int pomodoroBreakMinutes = 0,
  }) async {
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
          appearanceSetting: _settingOverview.appearanceSetting,
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
    required String desktopEffect,
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
        desktopEffect: desktopEffect,
      );
      if (updatedSetting != null) {
        _settingOverview = _settingOverview.copyWith(
          appearanceSetting: updatedSetting,
        );
        await _applyDesktopShellSettings(
          widgetSetting: _settingOverview.widgetSetting,
          appearanceSetting: updatedSetting!,
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
      _weeklyTemplates = const [];
      _bannerMessage = _message('账号已注销。', 'Account cancelled.');
      _status = SessionStatus.unauthenticated;
      _stopFocusTicker();
    }, fallbackMessage: _message('注销账号失败。', 'Failed to cancel the account.'));
    return cancelled;
  }

  Future<StatsOverview?> loadStatsOverview({int days = 7}) async {
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
        appearanceSetting: overview.appearanceSetting,
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
    required AppearanceSetting appearanceSetting,
  }) {
    return DesktopWidgetBridge.applySettings(
      widgetSetting: widgetSetting,
      appearanceSetting: appearanceSetting,
    );
  }

  Future<void> _reconcileFocusCompletion() async {
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
    super.dispose();
  }
}
