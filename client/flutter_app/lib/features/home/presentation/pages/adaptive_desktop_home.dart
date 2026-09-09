import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/widgets/adaptive_canvas_shell.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/status_banner.dart';
import 'package:innocence_flutter/core/widgets/wabi_sabi_paper.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/domain/theme_daily_slogan.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

class AdaptiveDesktopHome extends StatefulWidget {
  const AdaptiveDesktopHome({
    super.key,
    required this.appLanguage,
    required this.visualTheme,
    required this.profile,
    required this.focusSession,
    required this.checkInStatus,
    required this.statsOverview,
    required this.teamOverview,
    required this.teamChatOverview,
    required this.friendOverview,
    required this.memoOverview,
    required this.notificationOverview,
    required this.todayPlan,
    required this.monthPlanOverview,
    required this.annualPlanOverview,
    required this.weeklyTemplates,
    required this.isOfflineMode,
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
    required this.onToggleFocus,
    required this.onSubmitCheckIn,
    required this.onEditTodayPlan,
    required this.onToggleTodayPlanItem,
    required this.onOpenPlanDate,
    required this.onLoadMonthOverview,
    required this.onPreviousMonth,
    required this.onCurrentMonth,
    required this.onNextMonth,
    required this.onLoadAnnualOverview,
    required this.onPreviousYear,
    required this.onCurrentYear,
    required this.onNextYear,
    required this.onApplyDayTemplateToDate,
    required this.onSaveAnnualSegment,
    required this.onDeleteAnnualSegment,
    this.bannerMessage,
  });

  final AppLanguage appLanguage;
  final AppVisualTheme visualTheme;
  final UserProfile profile;
  final FocusSession focusSession;
  final CheckInStatus checkInStatus;
  final StatsOverview statsOverview;
  final TeamOverview teamOverview;
  final TeamChatOverview teamChatOverview;
  final FriendOverview friendOverview;
  final MemoOverview memoOverview;
  final NotificationOverview notificationOverview;
  final TodayPlan todayPlan;
  final MonthPlanOverview monthPlanOverview;
  final AnnualPlanOverview annualPlanOverview;
  final List<WeeklyPlanTemplate> weeklyTemplates;
  final bool isOfflineMode;
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
  final Future<void> Function() onToggleFocus;
  final Future<void> Function() onSubmitCheckIn;
  final Future<void> Function() onEditTodayPlan;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final Future<void> Function(String planDate) onOpenPlanDate;
  final Future<void> Function(String month) onLoadMonthOverview;
  final Future<void> Function() onPreviousMonth;
  final Future<void> Function() onCurrentMonth;
  final Future<void> Function() onNextMonth;
  final Future<void> Function(int year) onLoadAnnualOverview;
  final Future<void> Function() onPreviousYear;
  final Future<void> Function() onCurrentYear;
  final Future<void> Function() onNextYear;
  final Future<void> Function(
    int templateId,
    String planDate, {
    required PlanApplyStrategy strategy,
  }) onApplyDayTemplateToDate;
  final Future<void> Function(AnnualPlanSegment segment) onSaveAnnualSegment;
  final Future<void> Function(AnnualPlanSegment segment) onDeleteAnnualSegment;

  @override
  State<AdaptiveDesktopHome> createState() => _AdaptiveDesktopHomeState();
}

class _AdaptiveDesktopHomeState extends State<AdaptiveDesktopHome> {
  static const _primaryIds = <String>[
    'home',
    'plans',
    'focus',
    'companions',
    'inbox',
    'stats',
  ];

  String _selectedDestinationId = 'home';
  String _windowMode = 'canvas';
  _PlanHorizon _planHorizon = _PlanHorizon.day;
  Timer? _sloganRefreshTimer;

  bool get _isChinese => widget.appLanguage.isChinese;

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    DesktopWidgetBridge.setWindowModeListener(_handleWindowModeChanged);
    DesktopWidgetBridge.setTrayCommandListener(_handleTrayCommand);
    unawaited(_syncTrayState());
    _scheduleSloganRefresh();
  }

  @override
  void didUpdateWidget(covariant AdaptiveDesktopHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusSession.active != widget.focusSession.active ||
        oldWidget.focusSession.paused != widget.focusSession.paused ||
        oldWidget.appLanguage != widget.appLanguage) {
      unawaited(_syncTrayState());
    }
  }

  @override
  void dispose() {
    _sloganRefreshTimer?.cancel();
    DesktopWidgetBridge.setWindowModeListener(null);
    DesktopWidgetBridge.setTrayCommandListener(null);
    unawaited(
      DesktopWidgetBridge.setTrayState(
        settingsAvailable: false,
        focusActive: false,
        focusPaused: false,
        isChinese: _isChinese,
      ),
    );
    super.dispose();
  }

  Future<void> _syncTrayState() {
    return DesktopWidgetBridge.setTrayState(
      settingsAvailable: true,
      focusActive: widget.focusSession.active,
      focusPaused: widget.focusSession.paused,
      isChinese: _isChinese,
    );
  }

  Future<void> _handleTrayCommand(String command) async {
    switch (command) {
      case 'openSettings':
        await _restoreCanvas();
        if (mounted) {
          await widget.onOpenSettings();
        }
        return;
      case 'toggleFocusPause':
        if (widget.focusSession.active && !widget.isBusy) {
          await widget.onToggleFocus();
        }
        return;
      default:
        return;
    }
  }

  void _scheduleSloganRefresh() {
    _sloganRefreshTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _sloganRefreshTimer = Timer(nextDay.difference(now), () {
      if (mounted) {
        setState(() {});
        _scheduleSloganRefresh();
      }
    });
  }

  void _selectPlanHorizon(_PlanHorizon value) {
    if (_planHorizon == value) {
      return;
    }
    setState(() => _planHorizon = value);
    switch (value) {
      case _PlanHorizon.day:
        return;
      case _PlanHorizon.month:
        unawaited(widget.onLoadMonthOverview(widget.monthPlanOverview.month));
        return;
      case _PlanHorizon.year:
        unawaited(widget.onLoadAnnualOverview(widget.annualPlanOverview.year));
        return;
    }
  }

  Future<void> _openMonthFromYear(int month) async {
    final monthValue =
        '${widget.annualPlanOverview.year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}';
    await widget.onLoadMonthOverview(monthValue);
    if (mounted) {
      setState(() => _planHorizon = _PlanHorizon.month);
    }
  }

  void _handleWindowModeChanged(String mode) {
    if (!mounted || mode == _windowMode) {
      return;
    }
    setState(() {
      _windowMode = mode;
    });
  }

  Future<void> _openFocusOrb() async {
    if (mounted) {
      setState(() {
        _windowMode = 'orb';
      });
    }
    await DesktopWidgetBridge.showOrbWindow();
  }

  Future<void> _restoreCanvas() async {
    if (mounted) {
      setState(() {
        _windowMode = 'canvas';
      });
    }
    await DesktopWidgetBridge.showCanvasWindow();
  }

  Future<void> _handleOrbAction() async {
    if (widget.focusSession.active) {
      await widget.onToggleFocus();
      return;
    }
    await _restoreCanvas();
    await widget.onStartFocus();
  }

  List<AdaptiveCanvasDestination> get _destinations => [
        AdaptiveCanvasDestination(
          id: 'home',
          label: _text('首页', 'Home'),
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          smallPrimary: true,
        ),
        AdaptiveCanvasDestination(
          id: 'plans',
          label: _text('计划', 'Plans'),
          icon: Icons.view_timeline_outlined,
          selectedIcon: Icons.view_timeline_rounded,
          smallPrimary: true,
        ),
        AdaptiveCanvasDestination(
          id: 'focus',
          label: _text('专注', 'Focus'),
          icon: Icons.adjust_outlined,
          selectedIcon: Icons.adjust_rounded,
          smallPrimary: true,
        ),
        AdaptiveCanvasDestination(
          id: 'companions',
          label: _text('陪伴', 'Companions'),
          icon: Icons.people_outline_rounded,
          selectedIcon: Icons.people_rounded,
          badgeCount: widget.friendOverview.incomingRequests.length,
        ),
        AdaptiveCanvasDestination(
          id: 'inbox',
          label: _text('收件箱', 'Inbox'),
          icon: Icons.inbox_outlined,
          selectedIcon: Icons.inbox_rounded,
          badgeCount: widget.notificationOverview.unreadCount +
              widget.teamOverview.unreadChatCount,
          smallPrimary: true,
        ),
        AdaptiveCanvasDestination(
          id: 'stats',
          label: _text('统计', 'Stats'),
          icon: Icons.query_stats_outlined,
          selectedIcon: Icons.query_stats_rounded,
        ),
        AdaptiveCanvasDestination(
          id: 'memos',
          label: _text('备忘录', 'Memos'),
          icon: Icons.sticky_note_2_outlined,
          selectedIcon: Icons.sticky_note_2_rounded,
          badgeCount: widget.memoOverview.totalCount,
          utility: true,
        ),
        AdaptiveCanvasDestination(
          id: 'settings',
          label: _text('设置', 'Settings'),
          icon: Icons.tune_outlined,
          selectedIcon: Icons.tune_rounded,
          utility: true,
        ),
      ];

  String get _pageTitle {
    switch (_selectedDestinationId) {
      case 'plans':
        return _text('计划', 'Plans');
      case 'focus':
        return _text('专注', 'Focus');
      case 'companions':
        return _text('陪伴', 'Companions');
      case 'inbox':
        return _text('收件箱', 'Inbox');
      case 'stats':
        return _text('统计', 'Stats');
      default:
        return _text('今天', 'Today');
    }
  }

  String get _pageSubtitle {
    switch (_selectedDestinationId) {
      case 'plans':
        return _text('安排时间，也给变化留出余地', 'Plan time, leave room for change');
      case 'focus':
        return _text(
            '一次只做好眼前这一件事', 'Give the current task your full attention');
      case 'companions':
        return _text('与可信的人一起保持节奏', 'Stay in rhythm with people you trust');
      case 'inbox':
        return _text(
            '消息、提醒与通知集中处理', 'Messages, reminders and notices in one place');
      case 'stats':
        return _text('看见积累，不制造压力', 'See progress without adding pressure');
      default:
        return _text('先看最重要的，再开始行动', 'See what matters, then begin');
    }
  }

  void _selectDestination(String id) {
    if (id == 'memos') {
      unawaited(widget.onOpenMemos());
      return;
    }
    if (id == 'settings') {
      unawaited(widget.onOpenSettings());
      return;
    }
    if (widget.isOfflineMode) {
      if (id == 'companions') {
        unawaited(widget.onOpenFriends());
        return;
      }
      if (id == 'inbox') {
        unawaited(widget.onOpenNotifications());
        return;
      }
      if (id == 'stats') {
        unawaited(widget.onOpenStats());
        return;
      }
    }
    if (!_primaryIds.contains(id) || id == _selectedDestinationId) {
      return;
    }
    setState(() {
      _selectedDestinationId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_windowMode == 'orb') {
      return DesktopPresentationLayout(
        surface: DesktopWindowSurface.orb,
        builder: (context, spec) => _FocusOrb(
          session: widget.focusSession,
          visualTheme: widget.visualTheme,
          isBusy: widget.isBusy,
          onRestore: _restoreCanvas,
          onAction: _handleOrbAction,
        ),
      );
    }

    return AdaptiveCanvasShell(
      visualTheme: widget.visualTheme,
      destinations: _destinations,
      selectedDestinationId: _selectedDestinationId,
      onDestinationSelected: _selectDestination,
      pageTitle: _pageTitle,
      pageSubtitle: _pageSubtitle,
      userDisplayName: widget.profile.displayName,
      syncLabel: widget.isOfflineMode
          ? _text('离线 · 仅本机', 'Offline · local only')
          : _text('状态已连接', 'Connected'),
      isRefreshing: widget.isBusy,
      onRefresh: () => unawaited(widget.onRefresh()),
      onOpenFocusOrb: () => unawaited(_openFocusOrb()),
      bodyBuilder: (context, spec) {
        return IndexedStack(
          index: _primaryIds.indexOf(_selectedDestinationId),
          children: [
            _buildHomePage(spec),
            _buildPlansPage(spec),
            _buildFocusPage(spec),
            _buildCompanionsPage(spec),
            _buildInboxPage(spec),
            _buildStatsPage(spec),
          ],
        );
      },
    );
  }

  Widget _buildHomePage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    final dailySlogan = ThemeDailySlogans.resolve(
      theme: widget.visualTheme,
      localDate: DateTime.now(),
    );
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.home'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        if (widget.bannerMessage != null) ...[
          StatusBanner(
            message: widget.bannerMessage!,
            onClose: widget.onClearBanner,
          ),
          const SizedBox(height: 18),
        ],
        _HeroStatement(
          palette: palette,
          dayIndex: dailySlogan.dayIndex,
          eyebrow:
              _text('INNOCENCE · DAILY CANVAS', 'INNOCENCE · DAILY CANVAS'),
          title: widget.focusSession.active
              ? _text('此刻，保持专注。', 'Stay with this moment.')
              : dailySlogan.title(isChinese: _isChinese),
          description: widget.focusSession.active
              ? (widget.focusSession.taskName.trim().isEmpty
                  ? (widget.isOfflineMode
                      ? _text('当前专注记录仅保存在本机。',
                          'This focus session is stored on this device.')
                      : _text('当前学习状态正在双端同步。',
                          'Your current focus state is syncing across devices.'))
                  : widget.focusSession.taskName)
              : dailySlogan.subtitle(isChinese: _isChinese),
        ),
        const SizedBox(height: 20),
        _ResponsivePair(
          spec: spec,
          primaryFlex: 6,
          secondaryFlex: 5,
          primary: _FocusPanel(
            palette: palette,
            session: widget.focusSession,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            onAction: widget.focusSession.active
                ? widget.onFinishFocus
                : widget.onStartFocus,
            onToggle: widget.onToggleFocus,
          ),
          secondary: _PlanPanel(
            palette: palette,
            plan: widget.todayPlan,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            density: spec.defaultDensity,
            onEdit: widget.onEditTodayPlan,
            onToggle: widget.onToggleTodayPlanItem,
          ),
        ),
        const SizedBox(height: 20),
        _MetricGrid(
          spec: spec,
          palette: palette,
          metrics: [
            _MetricData(
              label: _text('连续签到', 'Streak'),
              value: _text('${widget.checkInStatus.consecutiveDays} 天',
                  '${widget.checkInStatus.consecutiveDays} days'),
              note: _text('累计 ${widget.checkInStatus.totalDays} 天',
                  '${widget.checkInStatus.totalDays} total'),
            ),
            _MetricData(
              label: _text('学习时长', 'Study time'),
              value: widget.statsOverview.totalStudyDurationLabel,
              note: _text('近 ${widget.statsOverview.rangeDays} 天',
                  'Last ${widget.statsOverview.rangeDays} days'),
            ),
            _MetricData(
              label: _text('计划完成率', 'Plan completion'),
              value: '${widget.statsOverview.planCompletionRate}%',
              note: _text(
                  '今日 ${widget.todayPlan.completedCount}/${widget.todayPlan.totalCount}',
                  'Today ${widget.todayPlan.completedCount}/${widget.todayPlan.totalCount}'),
            ),
            _MetricData(
              label: _text('待处理', 'Unread'),
              value: '${widget.notificationOverview.unreadCount}',
              note: _text('通知与关系申请', 'Notices and requests'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ResponsivePair(
          spec: spec,
          primaryFlex: 5,
          secondaryFlex: 5,
          primary: _CheckInPanel(
            palette: palette,
            status: widget.checkInStatus,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            onSubmit: widget.onSubmitCheckIn,
          ),
          secondary: _SummaryPanel(
            palette: palette,
            title: _text('陪伴与记录', 'Companionship and notes'),
            lines: [
              _SummaryLine(
                icon: Icons.groups_2_outlined,
                title: widget.teamOverview.inTeam
                    ? widget.teamOverview.teamName
                    : _text('尚未加入团队', 'No team yet'),
                detail: widget.teamOverview.subtitle,
                onTap: widget.onOpenTeamWorkspace,
              ),
              _SummaryLine(
                icon: Icons.sticky_note_2_outlined,
                title: _text('备忘录 ${widget.memoOverview.totalCount}',
                    '${widget.memoOverview.totalCount} memos'),
                detail: widget.memoOverview.hasItems
                    ? widget.memoOverview.items.first.displayTitle
                    : _text('记录一条稍后要记住的事', 'Capture something for later'),
                onTap: widget.onOpenMemos,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlansPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    final horizonTitle = switch (_planHorizon) {
      _PlanHorizon.day => _text('短计划', 'Daily plan'),
      _PlanHorizon.month => _text('长计划', 'Monthly plan'),
      _PlanHorizon.year => _text('超长计划', 'Annual plan'),
    };
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.plans'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        _SectionLead(
          palette: palette,
          title: horizonTitle,
          description: _text(
            '在日计划、周计划与长期日程之间切换；所有安排都写入同一套日期计划。',
            'Switch between daily, weekly, and long-term views backed by the same dated plans.',
          ),
        ),
        const SizedBox(height: 16),
        _PlanHorizonSwitcher(
          palette: palette,
          selected: _planHorizon,
          isChinese: _isChinese,
          onSelected: _selectPlanHorizon,
        ),
        const SizedBox(height: 20),
        if (_planHorizon == _PlanHorizon.day) ...[
          _SectionLead(
            palette: palette,
            title: widget.todayPlan.planName.trim().isEmpty
                ? _text('今日计划', 'Today plan')
                : widget.todayPlan.planName,
            description: _text(
              '${widget.todayPlan.planDate} · '
                  '${widget.todayPlan.completedCount}/${widget.todayPlan.totalCount} '
                  '已完成 · ${widget.todayPlan.plannedDurationLabel}',
              '${widget.todayPlan.planDate} · '
                  '${widget.todayPlan.completedCount}/${widget.todayPlan.totalCount} '
                  'complete · ${widget.todayPlan.plannedDurationLabel}',
            ),
            actionLabel: _text('编辑今日计划', 'Edit today plan'),
            onAction: widget.isBusy ? null : widget.onEditTodayPlan,
          ),
          const SizedBox(height: 20),
          _PlanPanel(
            palette: palette,
            plan: widget.todayPlan,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            density: spec.defaultDensity,
            onEdit: widget.onEditTodayPlan,
            onToggle: widget.onToggleTodayPlanItem,
            showHeaderAction: false,
          ),
        ] else if (_planHorizon == _PlanHorizon.month)
          _MonthPlanBoard(
            palette: palette,
            overview: widget.monthPlanOverview,
            templates: widget.weeklyTemplates,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            onPreviousMonth: widget.onPreviousMonth,
            onCurrentMonth: widget.onCurrentMonth,
            onNextMonth: widget.onNextMonth,
            onOpenDate: widget.onOpenPlanDate,
            onApplyTemplate: widget.onApplyDayTemplateToDate,
          )
        else
          _AnnualPlanBoard(
            palette: palette,
            visualTheme: widget.visualTheme,
            overview: widget.annualPlanOverview,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            onPreviousYear: widget.onPreviousYear,
            onCurrentYear: widget.onCurrentYear,
            onNextYear: widget.onNextYear,
            onOpenMonth: _openMonthFromYear,
            onSaveSegment: widget.onSaveAnnualSegment,
            onDeleteSegment: widget.onDeleteAnnualSegment,
          ),
      ],
    );
  }

  Widget _buildFocusPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.focus'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        _FocusPanel(
          palette: palette,
          session: widget.focusSession,
          isChinese: _isChinese,
          isBusy: widget.isBusy,
          expanded: true,
          onAction: widget.focusSession.active
              ? widget.onFinishFocus
              : widget.onStartFocus,
          onToggle: widget.onToggleFocus,
        ),
        const SizedBox(height: 20),
        _MetricGrid(
          spec: spec,
          palette: palette,
          metrics: [
            _MetricData(
              label: _text('本次已进行', 'Elapsed'),
              value: widget.focusSession.elapsedLabel,
              note: widget.isOfflineMode
                  ? _text('仅保存在本机', 'Stored on this device')
                  : _text('状态持续同步', 'State stays synchronized'),
            ),
            _MetricData(
              label: _text('番茄完成', 'Pomodoros'),
              value: '${widget.focusSession.completedPomodoroCount}',
              note: widget.focusSession.bindPomodoro
                  ? _text('当前第 ${widget.focusSession.currentCycleNo} 轮',
                      'Cycle ${widget.focusSession.currentCycleNo}')
                  : _text('本次未绑定番茄', 'Not bound this session'),
            ),
            _MetricData(
              label: _text('历史累计', 'All-time study'),
              value: widget.profile.studyDurationLabel,
              note: _text('账户累计学习时长', 'Account total'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanionsPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    final teammates = widget.teamOverview.members
        .where((member) => member.userId != widget.profile.userId)
        .take(spec.tier == DesktopPresentationTier.small ? 3 : 5)
        .toList();
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.companions'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        _ResponsivePair(
          spec: spec,
          primaryFlex: 5,
          secondaryFlex: 5,
          primary: _ActionPanel(
            palette: palette,
            icon: Icons.people_outline_rounded,
            title: _text('好友', 'Friends'),
            value:
                '${widget.friendOverview.friendCount}/${widget.friendOverview.maxFriendCount}',
            description: widget.friendOverview.incomingRequests.isEmpty
                ? _text('熟人关系保持轻量、清晰和可控。',
                    'Keep trusted relationships light and clear.')
                : _text(
                    '${widget.friendOverview.incomingRequests.length} 个申请待处理',
                    '${widget.friendOverview.incomingRequests.length} requests waiting'),
            actionLabel: _text('打开好友中心', 'Open friends'),
            onAction: widget.onOpenFriends,
          ),
          secondary: _ActionPanel(
            palette: palette,
            icon: Icons.groups_2_outlined,
            title: widget.teamOverview.inTeam
                ? widget.teamOverview.teamName
                : _text('团队', 'Team'),
            value: widget.teamOverview.inTeam
                ? '${widget.teamOverview.memberCount}/${widget.teamOverview.memberLimit}'
                : '—',
            description: widget.teamOverview.subtitle,
            actionLabel: widget.teamOverview.inTeam
                ? _text('打开团队工作区', 'Open team workspace')
                : _text('创建或加入团队', 'Create or join a team'),
            onAction: widget.onOpenTeamWorkspace,
          ),
        ),
        const SizedBox(height: 20),
        _Panel(
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(
                palette: palette,
                title: _text('队友今天', 'Teammates today'),
                subtitle: _text('只展示团队边界内允许查看的数据',
                    'Only data allowed inside the team boundary is shown'),
              ),
              const SizedBox(height: 16),
              if (!widget.teamOverview.inTeam || teammates.isEmpty)
                _EmptyMessage(
                  palette: palette,
                  icon: Icons.group_outlined,
                  message: _text('加入团队后，这里会显示队友计划进度。',
                      'Teammate progress appears after you join a team.'),
                )
              else
                ...teammates.map(
                  (member) => _ListRow(
                    palette: palette,
                    icon: member.activeStudy
                        ? Icons.adjust_rounded
                        : Icons.person_outline_rounded,
                    title: member.displayName,
                    subtitle:
                        '${member.todayPlanProgressLabel} · ${member.todayStudyDurationLabel}',
                    trailing: member.todayStatusLabel,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInboxPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    final notifications = widget.notificationOverview.previewItems;
    final latestTeamMessage = widget.teamChatOverview.latestMessage;
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.inbox'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        _ResponsivePair(
          spec: spec,
          primaryFlex: 6,
          secondaryFlex: 4,
          primary: _Panel(
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(
                  palette: palette,
                  title: _text('通知', 'Notifications'),
                  subtitle: _text(
                      '${widget.notificationOverview.unreadCount} 条未读',
                      '${widget.notificationOverview.unreadCount} unread'),
                  actionLabel: _text('全部查看', 'View all'),
                  onAction: widget.onOpenNotifications,
                ),
                const SizedBox(height: 16),
                if (notifications.isEmpty)
                  _EmptyMessage(
                    palette: palette,
                    icon: Icons.notifications_none_rounded,
                    message: _text('暂无通知。', 'No notifications yet.'),
                  )
                else
                  ...notifications.map(
                    (item) => _ListRow(
                      palette: palette,
                      icon: item.read
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_outlined,
                      title: item.title.trim().isEmpty
                          ? item.typeLabel
                          : item.title,
                      subtitle: item.content,
                      trailing: item.read ? '' : _text('未读', 'Unread'),
                    ),
                  ),
              ],
            ),
          ),
          secondary: _ActionPanel(
            palette: palette,
            icon: Icons.forum_outlined,
            title: _text('团队群聊', 'Team chat'),
            value: '${widget.teamChatOverview.unreadCount}',
            description: latestTeamMessage == null
                ? _text('还没有团队消息。', 'No team messages yet.')
                : '${latestTeamMessage.senderDisplayName}: ${latestTeamMessage.content}',
            actionLabel: _text('打开团队会话', 'Open team conversation'),
            onAction: widget.onOpenTeamWorkspace,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context, widget.visualTheme);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.stats'),
      spec: spec,
      palette: palette,
      visualTheme: widget.visualTheme,
      children: [
        _SectionLead(
          palette: palette,
          title: _text('近 ${widget.statsOverview.rangeDays} 天',
              'Last ${widget.statsOverview.rangeDays} days'),
          description: _text('趋势、完成率和失败记录使用同一组统计数据。',
              'Trends, completion and failures share one statistics source.'),
          actionLabel: _text('打开完整统计', 'Open full statistics'),
          onAction: widget.onOpenStats,
        ),
        const SizedBox(height: 20),
        _MetricGrid(
          spec: spec,
          palette: palette,
          metrics: [
            _MetricData(
              label: _text('学习时长', 'Study time'),
              value: widget.statsOverview.totalStudyDurationLabel,
              note: _text('${widget.statsOverview.activePlanDays} 个活跃计划日',
                  '${widget.statsOverview.activePlanDays} active plan days'),
            ),
            _MetricData(
              label: _text('番茄完成', 'Pomodoros'),
              value: '${widget.statsOverview.totalPomodoroCompleted}',
              note: _text('完成的专注循环', 'Completed focus cycles'),
            ),
            _MetricData(
              label: _text('计划完成率', 'Plan completion'),
              value: '${widget.statsOverview.planCompletionRate}%',
              note: _text('计划任务完成口径', 'Plan-task completion'),
            ),
            _MetricData(
              label: _text('签到成功率', 'Check-in success'),
              value: '${widget.statsOverview.checkInSuccessRate}%',
              note: _text('${widget.statsOverview.totalCheckInDays} 个签到日',
                  '${widget.statsOverview.totalCheckInDays} check-in days'),
            ),
            _MetricData(
              label: _text('失败记录', 'Failures'),
              value: '${widget.statsOverview.totalFailedCheckInAttempts}',
              note: _text('低压力保留事实', 'Facts kept without pressure'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FocusOrb extends StatelessWidget {
  const _FocusOrb({
    required this.session,
    required this.visualTheme,
    required this.isBusy,
    required this.onRestore,
    required this.onAction,
  });

  final FocusSession session;
  final AppVisualTheme visualTheme;
  final bool isBusy;
  final Future<void> Function() onRestore;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = AppVisualTokens.of(visualTheme);
    final totalSeconds = session.plannedMinutes * 60;
    final progress = session.active && totalSeconds > 0
        ? (session.elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final remainingMinutes = (session.remainingSeconds / 60).ceil();
    final centerLabel = session.active ? '$remainingMinutes' : '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => unawaited(onRestore()),
          onDoubleTap: isBusy ? null : () => unawaited(onAction()),
          onPanStart: (_) => unawaited(DesktopWidgetBridge.startWindowDrag()),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.panel,
              border: Border.all(color: tokens.line, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: tokens.softPanel,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: session.active
                        ? Text(
                            centerLabel,
                            key: ValueKey(centerLabel),
                            style: TextStyle(
                              color: tokens.ink,
                              fontSize: 16,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            key: const ValueKey('idle'),
                            color: isBusy ? tokens.muted : tokens.ink,
                            size: 22,
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

enum _PlanHorizon { day, month, year }

class _PlanHorizonSwitcher extends StatelessWidget {
  const _PlanHorizonSwitcher({
    required this.palette,
    required this.selected,
    required this.isChinese,
    required this.onSelected,
  });

  final _HomePalette palette;
  final _PlanHorizon selected;
  final bool isChinese;
  final ValueChanged<_PlanHorizon> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <(_PlanHorizon, IconData, String, String)>[
      (_PlanHorizon.day, Icons.today_outlined, '短计划', 'Daily'),
      (_PlanHorizon.month, Icons.calendar_month_outlined, '长计划', 'Monthly'),
      (_PlanHorizon.year, Icons.calendar_view_month_outlined, '超长计划', 'Annual'),
    ];
    return _Panel(
      palette: palette,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: entries.map((entry) {
          final active = selected == entry.$1;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('plan-horizon-${entry.$1.name}'),
              onTap: () => onSelected(entry.$1),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: active ? palette.accentSoft : palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? palette.accent : palette.rule,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.$2,
                        size: 19,
                        color: active ? palette.accent : palette.muted),
                    const SizedBox(width: 8),
                    Text(
                      isChinese ? entry.$3 : entry.$4,
                      style: TextStyle(
                        color: palette.ink,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MonthPlanBoard extends StatelessWidget {
  const _MonthPlanBoard({
    required this.palette,
    required this.overview,
    required this.templates,
    required this.isChinese,
    required this.isBusy,
    required this.onPreviousMonth,
    required this.onCurrentMonth,
    required this.onNextMonth,
    required this.onOpenDate,
    required this.onApplyTemplate,
  });

  final _HomePalette palette;
  final MonthPlanOverview overview;
  final List<WeeklyPlanTemplate> templates;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onPreviousMonth;
  final Future<void> Function() onCurrentMonth;
  final Future<void> Function() onNextMonth;
  final Future<void> Function(String date) onOpenDate;
  final Future<void> Function(
    int templateId,
    String date, {
    required PlanApplyStrategy strategy,
  }) onApplyTemplate;

  Future<void> _applyTemplate(
    BuildContext context,
    MonthPlanDay day,
    int templateId,
  ) async {
    var strategy = PlanApplyStrategy.overwrite;
    if (day.hasPlan) {
      final selected = await showDialog<PlanApplyStrategy>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isChinese ? '目标日期已有计划' : 'This day has a plan'),
          content: Text(
            isChinese
                ? '请选择覆盖现有计划、跳过该日期，或取消本次操作。'
                : 'Choose whether to overwrite the existing plan, skip this date, or cancel.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isChinese ? '取消' : 'Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(PlanApplyStrategy.skip),
              child: Text(isChinese ? '跳过' : 'Skip'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(PlanApplyStrategy.overwrite),
              child: Text(isChinese ? '覆盖' : 'Overwrite'),
            ),
          ],
        ),
      );
      if (selected == null) {
        return;
      }
      strategy = selected;
    }
    await onApplyTemplate(
      templateId,
      day.planDate,
      strategy: strategy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthStart =
        DateTime.tryParse('${overview.month}-01') ?? DateTime.now();
    final dayCount = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leading = monthStart.weekday - DateTime.monday;
    final cellCount = ((leading + dayCount + 6) ~/ 7) * 7;
    final today = DateTime.now();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: isBusy
          ? null
          : (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -260) {
                unawaited(onNextMonth());
              } else if (velocity > 260) {
                unawaited(onPreviousMonth());
              }
            },
      child: _Panel(
        palette: palette,
        emphasized: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlanRangeHeader(
              palette: palette,
              title: isChinese
                  ? '${monthStart.year} 年 ${monthStart.month} 月'
                  : '${_englishMonth(monthStart.month)} ${monthStart.year}',
              subtitle: isChinese
                  ? '${overview.plannedDayCount} 个计划日 · ${overview.completedTaskCount}/${overview.totalTaskCount} 项完成'
                  : '${overview.plannedDayCount} planned days · ${overview.completedTaskCount}/${overview.totalTaskCount} tasks complete',
              isBusy: isBusy,
              currentLabel: isChinese ? '本月' : 'This month',
              previousTooltip: isChinese ? '上个月' : 'Previous month',
              nextTooltip: isChinese ? '下个月' : 'Next month',
              onPrevious: onPreviousMonth,
              onCurrent: onCurrentMonth,
              onNext: onNextMonth,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final calendarWidth = max(720.0, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: calendarWidth,
                    child: Column(
                      children: [
                        Row(
                          children: List.generate(7, (index) {
                            const zh = ['一', '二', '三', '四', '五', '六', '日'];
                            const en = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Text(
                                  isChinese ? '周${zh[index]}' : en[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: palette.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cellCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.86,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final dayNumber = index - leading + 1;
                            if (dayNumber < 1 || dayNumber > dayCount) {
                              return const SizedBox.shrink();
                            }
                            final date = DateTime(
                              monthStart.year,
                              monthStart.month,
                              dayNumber,
                            );
                            final dateText = _formatCalendarDate(date);
                            final day = overview.dayFor(dateText);
                            return _MonthDayCard(
                              palette: palette,
                              dayNumber: dayNumber,
                              day: day,
                              today: date.year == today.year &&
                                  date.month == today.month &&
                                  date.day == today.day,
                              templates: templates,
                              isChinese: isChinese,
                              isBusy: isBusy,
                              onOpen: () => onOpenDate(dateText),
                              onApplyTemplate: (id) =>
                                  _applyTemplate(context, day, id),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              isChinese
                  ? '左右滑动切换月份；点击日期编辑短计划，日期菜单可套用日模板。'
                  : 'Swipe to change month. Open a date to edit its daily plan or apply a day template.',
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static String _englishMonth(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];

  static String _formatCalendarDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _AnnualPlanBoard extends StatelessWidget {
  const _AnnualPlanBoard({
    required this.palette,
    required this.visualTheme,
    required this.overview,
    required this.isChinese,
    required this.isBusy,
    required this.onPreviousYear,
    required this.onCurrentYear,
    required this.onNextYear,
    required this.onOpenMonth,
    required this.onSaveSegment,
    required this.onDeleteSegment,
  });

  final _HomePalette palette;
  final AppVisualTheme visualTheme;
  final AnnualPlanOverview overview;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onPreviousYear;
  final Future<void> Function() onCurrentYear;
  final Future<void> Function() onNextYear;
  final Future<void> Function(int month) onOpenMonth;
  final Future<void> Function(AnnualPlanSegment segment) onSaveSegment;
  final Future<void> Function(AnnualPlanSegment segment) onDeleteSegment;

  Future<void> _openSegmentEditor(
    BuildContext context, {
    AnnualPlanSegment? initial,
    int startMonth = 1,
    int endMonth = 1,
  }) async {
    final result = await showDialog<AnnualPlanSegment>(
      context: context,
      builder: (context) => _AnnualSegmentDialog(
        isChinese: isChinese,
        year: overview.year,
        initial: initial,
        startMonth: startMonth,
        endMonth: endMonth,
      ),
    );
    if (result != null) {
      await onSaveSegment(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AnnualPlanSegment segment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isChinese ? '删除年度计划？' : 'Delete annual plan?'),
        content: Text(segment.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isChinese ? '取消' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await onDeleteSegment(segment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      emphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanRangeHeader(
            palette: palette,
            title: isChinese
                ? '${overview.year} 年计划'
                : '${overview.year} annual plan',
            subtitle: isChinese
                ? '在 12 个月上拖动划定计划区间；区间允许相互重叠。'
                : 'Drag across the 12-month track to create a plan range. Ranges may overlap.',
            isBusy: isBusy,
            currentLabel: isChinese ? '今年' : 'This year',
            previousTooltip: isChinese ? '上一年' : 'Previous year',
            nextTooltip: isChinese ? '下一年' : 'Next year',
            onPrevious: onPreviousYear,
            onCurrent: onCurrentYear,
            onNext: onNextYear,
          ),
          const SizedBox(height: 18),
          _AnnualMonthTrack(
            palette: palette,
            isChinese: isChinese,
            enabled: !isBusy,
            segments: overview.segments,
            onRangeSelected: (start, end) => _openSegmentEditor(
              context,
              startMonth: start,
              endMonth: end,
            ),
          ),
          if (overview.segments.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: overview.segments.map((segment) {
                return InputChip(
                  avatar: Icon(Icons.route_rounded,
                      size: 17, color: palette.accent),
                  label: Text(
                    '${segment.title} · ${segment.startMonth}–${segment.endMonth}',
                  ),
                  onPressed: isBusy
                      ? null
                      : () => _openSegmentEditor(context, initial: segment),
                  onDeleted:
                      isBusy ? null : () => _confirmDelete(context, segment),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 4
                  : constraints.maxWidth >= 720
                      ? 3
                      : constraints.maxWidth >= 460
                          ? 2
                          : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: overview.months.map((month) {
                  return SizedBox(
                    width: width,
                    child: _AnnualMonthCard(
                      palette: palette,
                      visualTheme: visualTheme,
                      summary: month,
                      isChinese: isChinese,
                      onOpen: isBusy ? null : () => onOpenMonth(month.month),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnnualMonthTrack extends StatefulWidget {
  const _AnnualMonthTrack({
    required this.palette,
    required this.isChinese,
    required this.enabled,
    required this.segments,
    required this.onRangeSelected,
  });

  final _HomePalette palette;
  final bool isChinese;
  final bool enabled;
  final List<AnnualPlanSegment> segments;
  final Future<void> Function(int startMonth, int endMonth) onRangeSelected;

  @override
  State<_AnnualMonthTrack> createState() => _AnnualMonthTrackState();
}

class _AnnualMonthTrackState extends State<_AnnualMonthTrack> {
  int? _anchorMonth;
  int? _currentMonth;

  int _monthAt(double dx, double width) {
    if (width <= 0) {
      return 1;
    }
    return ((dx.clamp(0, width - 0.01) / width) * 12).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final start = _anchorMonth == null || _currentMonth == null
            ? null
            : min(_anchorMonth!, _currentMonth!);
        final end = _anchorMonth == null || _currentMonth == null
            ? null
            : max(_anchorMonth!, _currentMonth!);
        final cellWidth = width / 12;
        return Semantics(
          label: widget.isChinese
              ? '年度月份区间轨道，按住并左右拖动创建计划'
              : 'Annual month range track. Drag across months to create a plan.',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: widget.enabled
                ? (details) {
                    final month = _monthAt(details.localPosition.dx, width);
                    setState(() {
                      _anchorMonth = month;
                      _currentMonth = month;
                    });
                  }
                : null,
            onHorizontalDragUpdate: widget.enabled
                ? (details) {
                    final month = _monthAt(details.localPosition.dx, width);
                    if (month != _currentMonth) {
                      setState(() => _currentMonth = month);
                    }
                  }
                : null,
            onHorizontalDragEnd: widget.enabled
                ? (_) {
                    final selectedStart = start;
                    final selectedEnd = end;
                    setState(() {
                      _anchorMonth = null;
                      _currentMonth = null;
                    });
                    if (selectedStart != null && selectedEnd != null) {
                      unawaited(
                          widget.onRangeSelected(selectedStart, selectedEnd));
                    }
                  }
                : null,
            child: SizedBox(
              height: 76,
              child: Stack(
                children: [
                  Row(
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      final covered = widget.segments.any(
                        (segment) =>
                            month >= segment.startMonth &&
                            month <= segment.endMonth,
                      );
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index == 11 ? 0 : 3),
                          decoration: BoxDecoration(
                            color: covered
                                ? widget.palette.accentSoft
                                : widget.palette.surface,
                            border: Border.all(color: widget.palette.rule),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$month',
                            style: TextStyle(
                              color: covered
                                  ? widget.palette.accent
                                  : widget.palette.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (start != null && end != null)
                    Positioned(
                      left: (start - 1) * cellWidth,
                      width: (end - start + 1) * cellWidth,
                      top: 3,
                      bottom: 3,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                widget.palette.accent.withValues(alpha: 0.24),
                            border: Border.all(
                              color: widget.palette.accent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnnualMonthCard extends StatelessWidget {
  const _AnnualMonthCard({
    required this.palette,
    required this.visualTheme,
    required this.summary,
    required this.isChinese,
    required this.onOpen,
  });

  final _HomePalette palette;
  final AppVisualTheme visualTheme;
  final AnnualMonthSummary summary;
  final bool isChinese;
  final Future<void> Function()? onOpen;

  @override
  Widget build(BuildContext context) {
    final season = (summary.month - 1) ~/ 3;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen == null ? null : () => unawaited(onOpen!()),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 176,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.rule),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isChinese
                          ? '${summary.month} 月'
                          : _shortMonth(summary.month),
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ExcludeSemantics(
                    child: CustomPaint(
                      size: const Size(54, 46),
                      painter: _SeasonArtworkPainter(
                        theme: visualTheme,
                        season: season,
                        accent: palette.accent,
                        muted: palette.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                isChinese
                    ? '${summary.plannedDayCount} 个计划日'
                    : '${summary.plannedDayCount} planned days',
                style: TextStyle(color: palette.muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: summary.completionRatio,
                minHeight: 4,
                borderRadius: BorderRadius.circular(99),
                color: palette.accent,
                backgroundColor: palette.rule,
              ),
              const SizedBox(height: 8),
              Text(
                '${summary.completedTaskCount}/${summary.totalTaskCount} · '
                '${summary.plannedDurationLabel}',
                style: TextStyle(color: palette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortMonth(int month) => const [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ][month - 1];
}

class _AnnualSegmentDialog extends StatefulWidget {
  const _AnnualSegmentDialog({
    required this.isChinese,
    required this.year,
    required this.startMonth,
    required this.endMonth,
    this.initial,
  });

  final bool isChinese;
  final int year;
  final int startMonth;
  final int endMonth;
  final AnnualPlanSegment? initial;

  @override
  State<_AnnualSegmentDialog> createState() => _AnnualSegmentDialogState();
}

class _AnnualSegmentDialogState extends State<_AnnualSegmentDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late RangeValues _months;
  late String _colorKey;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _noteController = TextEditingController(text: widget.initial?.note ?? '');
    _months = RangeValues(
      (widget.initial?.startMonth ?? widget.startMonth).toDouble(),
      (widget.initial?.endMonth ?? widget.endMonth).toDouble(),
    );
    _colorKey = widget.initial?.colorKey ?? 'accent';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(
          () => _errorText = widget.isChinese ? '请输入计划标题。' : 'Enter a title.');
      return;
    }
    final initial = widget.initial;
    Navigator.of(context).pop(
      AnnualPlanSegment(
        id: initial?.id ?? '',
        clientEntityId: initial?.clientEntityId ?? '',
        year: widget.year,
        title: title,
        startMonth: _months.start.round(),
        endMonth: _months.end.round(),
        colorKey: _colorKey,
        sortOrder: initial?.sortOrder ?? 0,
        note: _noteController.text.trim(),
        revision: initial?.revision ?? 0,
        updateTime: initial?.updateTime ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? (widget.isChinese ? '新建年度计划' : 'New annual plan')
            : (widget.isChinese ? '编辑年度计划' : 'Edit annual plan'),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '计划标题' : 'Plan title',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isChinese
                  ? '${_months.start.round()} 月 — ${_months.end.round()} 月'
                  : 'Month ${_months.start.round()} — ${_months.end.round()}',
            ),
            RangeSlider(
              min: 1,
              max: 12,
              divisions: 11,
              values: _months,
              labels: RangeLabels(
                '${_months.start.round()}',
                '${_months.end.round()}',
              ),
              onChanged: (value) => setState(() => _months = value),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _colorKey,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '标记颜色' : 'Color marker',
              ),
              items: const [
                DropdownMenuItem(value: 'accent', child: Text('Accent')),
                DropdownMenuItem(value: 'warm', child: Text('Warm')),
                DropdownMenuItem(value: 'cool', child: Text('Cool')),
                DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _colorKey = value);
                }
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '说明（可选）' : 'Note (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.isChinese ? '取消' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.isChinese ? '保存' : 'Save'),
        ),
      ],
    );
  }
}

class _SeasonArtworkPainter extends CustomPainter {
  const _SeasonArtworkPainter({
    required this.theme,
    required this.season,
    required this.accent,
    required this.muted,
  });

  final AppVisualTheme theme;
  final int season;
  final Color accent;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final primary = Paint()
      ..color =
          accent.withValues(alpha: theme == AppVisualTheme.glass ? 0.72 : 0.62)
      ..strokeWidth = theme == AppVisualTheme.wabiSabi ? 1.6 : 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color =
          accent.withValues(alpha: theme == AppVisualTheme.glass ? 0.22 : 0.16)
      ..style = PaintingStyle.fill;

    switch (theme) {
      case AppVisualTheme.minimalism:
        if (season == 0) {
          canvas.drawLine(Offset(center.dx, size.height - 6),
              Offset(center.dx, 10), primary);
          canvas.drawArc(
              Rect.fromCenter(
                  center: Offset(center.dx - 6, 17), width: 14, height: 9),
              0.1,
              2.7,
              false,
              primary);
        } else if (season == 1) {
          canvas.drawCircle(center, 10, fill);
          for (var i = 0; i < 8; i += 1) {
            final angle = i * pi / 4;
            canvas.drawLine(center + Offset(cos(angle), sin(angle)) * 15,
                center + Offset(cos(angle), sin(angle)) * 21, primary);
          }
        } else if (season == 2) {
          canvas.drawOval(
              Rect.fromCenter(
                  center: center + const Offset(-6, -3), width: 13, height: 25),
              primary);
          canvas.drawOval(
              Rect.fromCenter(
                  center: center + const Offset(7, 4), width: 13, height: 25),
              primary);
        } else {
          for (var i = 0; i < 4; i += 1) {
            final angle = i * pi / 4;
            canvas.drawLine(center - Offset(cos(angle), sin(angle)) * 18,
                center + Offset(cos(angle), sin(angle)) * 18, primary);
          }
        }
      case AppVisualTheme.wabiSabi:
        canvas.drawArc(Rect.fromCenter(center: center, width: 34, height: 31),
            -0.4, 4.7 - season * 0.25, false, primary);
        canvas.drawLine(Offset(8, size.height - 8),
            Offset(size.width - 7, 9 + season * 4), primary);
        canvas.drawCircle(center + Offset(8 - season * 3, -7 + season * 2),
            4 + season.toDouble(), fill);
      case AppVisualTheme.midCentury:
        canvas.drawCircle(center, season == 1 ? 13 : 8, fill);
        final rays = season == 1
            ? 10
            : season == 3
                ? 6
                : 5;
        for (var i = 0; i < rays; i += 1) {
          final angle = i * 2 * pi / rays + season * 0.28;
          canvas.drawLine(center + Offset(cos(angle), sin(angle)) * 11,
              center + Offset(cos(angle), sin(angle)) * 21, primary);
        }
        canvas.drawCircle(center + const Offset(15, 10), 5,
            Paint()..color = muted.withValues(alpha: 0.28));
      case AppVisualTheme.glass:
        final glow = Paint()
          ..color = accent.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(center, 14 + season.toDouble(), glow);
        canvas.drawCircle(center, 12, primary);
        for (var i = 0; i < 4 + season; i += 1) {
          final angle = i * 2 * pi / (4 + season);
          canvas.drawCircle(
              center + Offset(cos(angle), sin(angle)) * 16, 3.2, fill);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _SeasonArtworkPainter oldDelegate) =>
      theme != oldDelegate.theme ||
      season != oldDelegate.season ||
      accent != oldDelegate.accent ||
      muted != oldDelegate.muted;
}

class _PlanRangeHeader extends StatelessWidget {
  const _PlanRangeHeader({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.isBusy,
    required this.currentLabel,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onCurrent,
    required this.onNext,
  });

  final _HomePalette palette;
  final String title;
  final String subtitle;
  final bool isBusy;
  final String currentLabel;
  final String previousTooltip;
  final String nextTooltip;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onCurrent;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 14,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: palette.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(subtitle, style: TextStyle(color: palette.muted, height: 1.4)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.outlined(
              tooltip: previousTooltip,
              onPressed: isBusy ? null : () => unawaited(onPrevious()),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: isBusy ? null : () => unawaited(onCurrent()),
              child: Text(currentLabel),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: nextTooltip,
              onPressed: isBusy ? null : () => unawaited(onNext()),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthDayCard extends StatelessWidget {
  const _MonthDayCard({
    required this.palette,
    required this.dayNumber,
    required this.day,
    required this.today,
    required this.templates,
    required this.isChinese,
    required this.isBusy,
    required this.onOpen,
    required this.onApplyTemplate,
  });

  final _HomePalette palette;
  final int dayNumber;
  final MonthPlanDay day;
  final bool today;
  final List<WeeklyPlanTemplate> templates;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onOpen;
  final Future<void> Function(int templateId) onApplyTemplate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: today ? palette.accentSoft : palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: today ? palette.accent : palette.rule),
      ),
      child: InkWell(
        onTap: isBusy ? null : () => unawaited(onOpen()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                          color: palette.ink, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (templates.isNotEmpty)
                    _TemplateMenu(
                      palette: palette,
                      templates: templates,
                      enabled: !isBusy,
                      onSelected: onApplyTemplate,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                day.hasPlan ? day.planName : (isChinese ? '空白日期' : 'Open day'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: day.hasPlan ? palette.ink : palette.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (day.hasPlan) ...[
                LinearProgressIndicator(
                  value: day.completionRatio,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: palette.rule,
                  color: palette.accent,
                ),
                const SizedBox(height: 7),
              ],
              Text(
                day.hasPlan
                    ? '${day.completedCount}/${day.totalCount} · ${day.plannedDurationLabel}'
                    : (isChinese ? '点击开始安排' : 'Click to schedule'),
                style: TextStyle(color: palette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateMenu extends StatelessWidget {
  const _TemplateMenu({
    required this.palette,
    required this.templates,
    required this.enabled,
    required this.onSelected,
  });

  final _HomePalette palette;
  final List<WeeklyPlanTemplate> templates;
  final bool enabled;
  final Future<void> Function(int templateId) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: '套用模板',
      enabled: enabled,
      onSelected: (id) => unawaited(onSelected(id)),
      itemBuilder: (context) => templates
          .map(
            (template) => PopupMenuItem<int>(
              value: template.id,
              child: Text(
                  '${template.templateName} · ${template.plannedDurationLabel}'),
            ),
          )
          .toList(),
      icon: Icon(Icons.auto_awesome_outlined, size: 19, color: palette.muted),
    );
  }
}

class _PageCanvas extends StatelessWidget {
  const _PageCanvas({
    required this.pageKey,
    required this.spec,
    required this.palette,
    required this.visualTheme,
    required this.children,
  });

  final PageStorageKey<String> pageKey;
  final DesktopPresentationSpec spec;
  final _HomePalette palette;
  final AppVisualTheme visualTheme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontal = switch (spec.tier) {
      DesktopPresentationTier.large => 32.0,
      DesktopPresentationTier.medium => 24.0,
      DesktopPresentationTier.small || null => 16.0,
    };
    final maxWidth = switch (spec.tier) {
      DesktopPresentationTier.large => 1320.0,
      DesktopPresentationTier.medium => 980.0,
      DesktopPresentationTier.small || null => double.infinity,
    };

    final content = SingleChildScrollView(
      key: pageKey,
      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
    return _ThemedHomeBackdrop(
      visualTheme: visualTheme,
      palette: palette,
      child: content,
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({
    required this.spec,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
  });

  final DesktopPresentationSpec spec;
  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;

  @override
  Widget build(BuildContext context) {
    if (spec.tier == DesktopPresentationTier.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          const SizedBox(height: 16),
          secondary,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        const SizedBox(width: 18),
        Expanded(flex: secondaryFlex, child: secondary),
      ],
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement({
    required this.palette,
    required this.dayIndex,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final _HomePalette palette;
  final int dayIndex;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final decoration = switch (palette.visualTheme) {
      AppVisualTheme.minimalism => BoxDecoration(
          color: palette.background,
          border: Border(
            top: BorderSide(color: palette.ink, width: 2),
            bottom: BorderSide(color: palette.rule),
          ),
        ),
      AppVisualTheme.wabiSabi => BoxDecoration(
          color: palette.surface,
          border: Border(left: BorderSide(color: palette.accent, width: 3)),
        ),
      AppVisualTheme.midCentury => BoxDecoration(
          color: palette.ink,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(54),
            bottomLeft: Radius.circular(18),
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x242C2416), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
      AppVisualTheme.glass => const BoxDecoration(
          color: Colors.transparent,
        ),
    };
    final darkHero = palette.visualTheme == AppVisualTheme.midCentury ||
        palette.visualTheme == AppVisualTheme.glass;
    return Container(
      padding: EdgeInsets.fromLTRB(
        palette.visualTheme == AppVisualTheme.minimalism ? 4 : 28,
        28,
        28,
        30,
      ),
      decoration: decoration,
      child: Stack(
        children: [
          if (palette.visualTheme == AppVisualTheme.midCentury)
            const Positioned(right: 4, top: 0, child: _MidCenturyOrnament()),
          if (palette.visualTheme == AppVisualTheme.minimalism)
            Positioned(
              right: 2,
              top: 0,
              child: ExcludeSemantics(
                child: Text(
                  'D/${dayIndex.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
          if (palette.visualTheme == AppVisualTheme.wabiSabi)
            Positioned(
              right: 2,
              top: 2,
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: const Size(92, 92),
                  painter: _WabiHeroSealPainter(palette.accent),
                ),
              ),
            ),
          if (palette.visualTheme == AppVisualTheme.glass)
            Positioned(
              right: 12,
              top: 2,
              child: Icon(Icons.blur_circular_rounded,
                  size: 88, color: palette.accent.withValues(alpha: 0.22)),
            ),
          if (palette.visualTheme == AppVisualTheme.glass)
            Positioned(
              left: 34,
              top: 54,
              right: 0,
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: palette.accent,
                      fontFamily: 'Segoe UI Variable Display',
                      fontSize: 54,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: palette.visualTheme == AppVisualTheme.glass
                      ? palette.accent
                      : darkHero
                          ? palette.accentSoft
                          : palette.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Semantics(
                label: title,
                child: ExcludeSemantics(
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: darkHero ? palette.onInk : palette.ink,
                      fontFamily: switch (palette.visualTheme) {
                        AppVisualTheme.wabiSabi => 'Georgia',
                        AppVisualTheme.midCentury => 'Century Gothic',
                        AppVisualTheme.glass => 'Segoe UI Variable Display',
                        _ => 'Segoe UI',
                      },
                      fontSize: switch (palette.visualTheme) {
                        AppVisualTheme.minimalism => 42,
                        AppVisualTheme.glass => 52,
                        _ => 34,
                      },
                      height: 1.08,
                      fontWeight: palette.visualTheme == AppVisualTheme.wabiSabi
                          ? FontWeight.w500
                          : FontWeight.w800,
                      fontStyle: palette.visualTheme == AppVisualTheme.wabiSabi
                          ? FontStyle.italic
                          : FontStyle.normal,
                      letterSpacing: switch (palette.visualTheme) {
                        AppVisualTheme.minimalism => -1.8,
                        AppVisualTheme.wabiSabi => 0.3,
                        _ => -1.0,
                      },
                      shadows: palette.visualTheme == AppVisualTheme.glass
                          ? [
                              Shadow(
                                color: palette.accent.withValues(alpha: 0.38),
                                blurRadius: 24,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  color: darkHero ? palette.onInkMuted : palette.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WabiHeroSealPainter extends CustomPainter {
  const _WabiHeroSealPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawArc(rect, -0.35, 4.85, false, paint);
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.69),
      Offset(size.width * 0.72, size.height * 0.27),
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WabiHeroSealPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.palette,
    required this.session,
    required this.isChinese,
    required this.isBusy,
    required this.onAction,
    required this.onToggle,
    this.expanded = false,
  });

  final _HomePalette palette;
  final FocusSession session;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onAction;
  final Future<void> Function() onToggle;
  final bool expanded;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      emphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            palette: palette,
            title: _text('当前专注', 'Focus now'),
            subtitle: session.active
                ? session.paused
                    ? _text('计时已暂停', 'Timer paused')
                    : _text('结束于 ${session.endTimeLabel}',
                        'Ends at ${session.endTimeLabel}')
                : _text('设置结束时间后开始', 'Set an end time to begin'),
          ),
          SizedBox(height: expanded ? 34 : 24),
          Text(
            session.active ? session.remainingLabel : '00:00',
            style: TextStyle(
              color: palette.ink,
              fontSize: expanded ? 64 : 48,
              fontWeight: FontWeight.w800,
              height: 0.95,
              letterSpacing: -2.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            session.active
                ? (session.taskName.trim().isEmpty
                    ? _text('未命名学习时段', 'Untitled focus session')
                    : session.taskName)
                : _text('准备好时，从眼前最重要的任务开始。',
                    'When ready, begin with the most important task.'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          if (session.active)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : () => unawaited(onToggle()),
                    icon: Icon(
                      session.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                    label: Text(
                      session.paused
                          ? _text('继续计时', 'Resume timer')
                          : _text('暂停计时', 'Pause timer'),
                    ),
                    style: _primaryButtonStyle(),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : () => unawaited(onAction()),
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(_text('结束', 'Finish')),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isBusy ? null : () => unawaited(onAction()),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(_text('开始专注', 'Start focus')),
                style: _primaryButtonStyle(),
              ),
            ),
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: palette.visualTheme == AppVisualTheme.glass
          ? const Color(0x24FFFFFF)
          : palette.ink,
      foregroundColor: palette.visualTheme == AppVisualTheme.glass
          ? palette.ink
          : palette.onInk,
      minimumSize: const Size.fromHeight(48),
      side: palette.visualTheme == AppVisualTheme.glass
          ? const BorderSide(color: Color(0x42FFFFFF))
          : BorderSide.none,
      elevation: 0,
      shadowColor: palette.visualTheme == AppVisualTheme.glass
          ? palette.accent.withValues(alpha: .5)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          palette.visualTheme == AppVisualTheme.glass ? 12 : 0,
        ),
      ),
    );
  }
}

class _PlanPanel extends StatelessWidget {
  const _PlanPanel({
    required this.palette,
    required this.plan,
    required this.isChinese,
    required this.isBusy,
    required this.density,
    required this.onEdit,
    required this.onToggle,
    this.showHeaderAction = true,
  });

  final _HomePalette palette;
  final TodayPlan plan;
  final bool isChinese;
  final bool isBusy;
  final ComponentPresentationDensity density;
  final Future<void> Function() onEdit;
  final Future<void> Function(int index, bool completed) onToggle;
  final bool showHeaderAction;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final limit = switch (density) {
      ComponentPresentationDensity.full => 8,
      ComponentPresentationDensity.comfortable => 6,
      ComponentPresentationDensity.compact ||
      ComponentPresentationDensity.glance =>
        4,
    };
    final entries = plan.items.asMap().entries.take(limit).toList();
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            palette: palette,
            title: _text('今日计划', 'Today plan'),
            subtitle: _text('${plan.completedCount}/${plan.totalCount} 已完成',
                '${plan.completedCount}/${plan.totalCount} complete'),
            actionLabel: showHeaderAction ? _text('编辑', 'Edit') : null,
            onAction: showHeaderAction ? onEdit : null,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: plan.completionRatio,
            minHeight: 5,
            color: palette.accent,
            backgroundColor: palette.rule,
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            _EmptyMessage(
              palette: palette,
              icon: Icons.playlist_add_rounded,
              message: _text('还没有今日计划。', 'No plan for today yet.'),
            )
          else
            ...entries.map(
              (entry) => _PlanRow(
                palette: palette,
                item: entry.value,
                isBusy: isBusy,
                onChanged: (completed) => onToggle(entry.key, completed),
              ),
            ),
          if (plan.items.length > entries.length) ...[
            const SizedBox(height: 10),
            Text(
              _text('另有 ${plan.items.length - entries.length} 项，编辑时查看全部',
                  '${plan.items.length - entries.length} more items available in edit'),
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.palette,
    required this.item,
    required this.isBusy,
    required this.onChanged,
  });

  final _HomePalette palette;
  final TodayPlanItem item;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: item.completed,
            onChanged: isBusy
                ? null
                : (value) {
                    if (value != null) {
                      onChanged(value);
                    }
                  },
            shape: const RoundedRectangleBorder(),
            side: BorderSide(color: palette.rule),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.trim().isEmpty ? '—' : item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.completed ? palette.muted : palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration:
                        item.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.scheduleLabel} · ${item.durationLabel}',
                  style: TextStyle(color: palette.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInPanel extends StatelessWidget {
  const _CheckInPanel({
    required this.palette,
    required this.status,
    required this.isChinese,
    required this.isBusy,
    required this.onSubmit,
  });

  final _HomePalette palette;
  final CheckInStatus status;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onSubmit;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final title = status.checkedInToday
        ? _text('今天已签到', 'Checked in today')
        : status.canCheckInToday
            ? _text('可以签到', 'Ready to check in')
            : _text('签到条件未满足', 'Check-in is not ready');
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            palette: palette,
            title: title,
            subtitle: _text(
              '今日计划 ${status.todayPlanCompletedCount}/${status.todayPlanTotalCount}',
              'Today plan ${status.todayPlanCompletedCount}/${status.todayPlanTotalCount}',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _text(
              status.checkedInToday
                  ? '这一天已经计入你的坚持记录。'
                  : status.canCheckInToday
                      ? '计划完成后仍需手动确认，才会计入签到。'
                      : '完成当天计划后，再回来手动签到。',
              status.checkedInToday
                  ? 'This day is already part of your streak.'
                  : status.canCheckInToday
                      ? 'Confirm manually after completing the plan.'
                      : 'Finish today plan, then return to check in.',
            ),
            style: TextStyle(color: palette.muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed:
                isBusy || status.checkedInToday || !status.canCheckInToday
                    ? null
                    : () => unawaited(onSubmit()),
            icon: const Icon(Icons.done_rounded),
            label: Text(
              status.checkedInToday
                  ? _text('已完成', 'Completed')
                  : _text('手动签到', 'Check in'),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: const RoundedRectangleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.spec,
    required this.palette,
    required this.metrics,
  });

  final DesktopPresentationSpec spec;
  final _HomePalette palette;
  final List<_MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final columns = switch (spec.tier) {
      DesktopPresentationTier.large => 4,
      DesktopPresentationTier.medium => 3,
      DesktopPresentationTier.small || null => 2,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricTile(palette: palette, metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.palette, required this.metric});

  final _HomePalette palette;
  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    return _HoverSurface(
      palette: palette,
      emphasized: false,
      child: Container(
        constraints: const BoxConstraints(minHeight: 130),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: TextStyle(
                color: palette.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              metric.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine {
  const _SummaryLine({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Future<void> Function()? onTap;
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.palette,
    required this.title,
    required this.lines,
  });

  final _HomePalette palette;
  final String title;
  final List<_SummaryLine> lines;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(palette: palette, title: title),
          const SizedBox(height: 12),
          ...lines.map(
            (line) => _ListRow(
              palette: palette,
              icon: line.icon,
              title: line.title,
              subtitle: line.detail,
              onTap: line.onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.palette,
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final _HomePalette palette;
  final IconData icon;
  final String title;
  final String value;
  final String description;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.accent, size: 26),
          const SizedBox(height: 28),
          Text(
            value,
            style: TextStyle(
              color: palette.ink,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: palette.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.muted, height: 1.45),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => unawaited(onAction()),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: const RoundedRectangleBorder(),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({
    required this.palette,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final _HomePalette palette;
  final String title;
  final String description;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      palette: palette,
      emphasized: true,
      child: Wrap(
        spacing: 20,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: palette.muted, height: 1.45),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            FilledButton(
              onPressed: onAction == null ? null : () => unawaited(onAction!()),
              style: FilledButton.styleFrom(
                backgroundColor: palette.visualTheme == AppVisualTheme.glass
                    ? const Color(0x24FFFFFF)
                    : palette.ink,
                foregroundColor: palette.visualTheme == AppVisualTheme.glass
                    ? palette.ink
                    : palette.onInk,
                side: palette.visualTheme == AppVisualTheme.glass
                    ? const BorderSide(color: Color(0x52FFFFFF))
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    palette.visualTheme == AppVisualTheme.glass ? 12 : 0,
                  ),
                ),
                minimumSize: const Size(160, 46),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.palette,
    required this.child,
    this.emphasized = false,
  });

  final _HomePalette palette;
  final Widget child;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return _HoverSurface(
      palette: palette,
      emphasized: emphasized,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: child,
      ),
    );
  }
}

class _HoverSurface extends StatefulWidget {
  const _HoverSurface({
    required this.palette,
    required this.emphasized,
    required this.child,
  });

  final _HomePalette palette;
  final bool emphasized;
  final Widget child;

  @override
  State<_HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<_HoverSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final glass = widget.palette.visualTheme == AppVisualTheme.glass;
    final mid = widget.palette.visualTheme == AppVisualTheme.midCentury;
    final lift = _hovered && !reduceMotion
        ? glass
            ? -5.0
            : mid
                ? -3.0
                : -1.0
        : 0.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, lift, 0),
        transformAlignment: Alignment.center,
        decoration: widget.palette.panelDecoration(
          emphasized: widget.emphasized,
          hovered: _hovered,
        ),
        child: glass
            ? ClipRRect(
                borderRadius: BorderRadius.circular(
                  widget.emphasized ? 22 : 16,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _hovered ? 24 : 18,
                    sigmaY: _hovered ? 24 : 18,
                  ),
                  child: widget.child,
                ),
              )
            : widget.child,
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.palette,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final _HomePalette palette;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(color: palette.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: () => unawaited(onAction!()),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing = '',
    this.onTap,
  });

  final _HomePalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => unawaited(onTap!()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              color: palette.accentSoft,
              child: Icon(icon, color: palette.ink, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.muted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                trailing,
                style: TextStyle(
                  color: palette.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: palette.muted),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.palette,
    required this.icon,
    required this.message,
  });

  final _HomePalette palette;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final glass = palette.visualTheme == AppVisualTheme.glass;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: glass ? const Color(0x32101D3B) : palette.background,
        borderRadius: BorderRadius.circular(glass ? 12 : 0),
        border: glass ? Border.all(color: const Color(0x42FFFFFF)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: palette.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _HomePalette {
  const _HomePalette({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.ink,
    required this.muted,
    required this.rule,
    required this.accent,
    required this.accentSoft,
    required this.onInk,
    required this.onInkMuted,
    required this.visualTheme,
  });

  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color ink;
  final Color muted;
  final Color rule;
  final Color accent;
  final Color accentSoft;
  final Color onInk;
  final Color onInkMuted;
  final AppVisualTheme visualTheme;

  BoxDecoration panelDecoration({
    required bool emphasized,
    bool hovered = false,
  }) {
    return switch (visualTheme) {
      AppVisualTheme.minimalism => BoxDecoration(
          color: emphasized ? background : surface,
          border: Border(
            top: BorderSide(
                color: emphasized ? ink : rule, width: emphasized ? 2 : 1),
          ),
        ),
      AppVisualTheme.wabiSabi => BoxDecoration(
          color: emphasized ? surfaceStrong : surface,
        ),
      AppVisualTheme.midCentury => BoxDecoration(
          color: emphasized ? surfaceStrong : surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomLeft: Radius.circular(8),
          ),
          border: Border(left: BorderSide(color: accent, width: 4)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1F2C2416), blurRadius: 15, offset: Offset(0, 5)),
          ],
        ),
      AppVisualTheme.glass => BoxDecoration(
          color: hovered
              ? const Color(0x52172A55)
              : emphasized
                  ? const Color(0x4214264A)
                  : const Color(0x32101D3B),
          borderRadius: BorderRadius.circular(emphasized ? 22 : 16),
          border: Border.all(
            color: hovered ? const Color(0x66FFFFFF) : const Color(0x32FFFFFF),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  hovered ? const Color(0x665F8CFF) : const Color(0x301F2687),
              blurRadius: hovered ? 46 : (emphasized ? 32 : 22),
              spreadRadius: hovered ? -2 : -7,
              offset: Offset(0, hovered ? 14 : 8),
            ),
            if (hovered)
              const BoxShadow(
                color: Color(0x30FFFFFF),
                blurRadius: 20,
                spreadRadius: -8,
              ),
          ],
        ),
    };
  }

  static _HomePalette of(
    BuildContext context,
    AppVisualTheme visualTheme,
  ) {
    final tokens = AppVisualTokens.of(visualTheme);
    final glass = visualTheme == AppVisualTheme.glass;
    return _HomePalette(
      background: tokens.canvas,
      surface: glass ? const Color(0x32101D3B) : tokens.panel,
      surfaceStrong: glass ? const Color(0x4214264A) : tokens.softPanel,
      ink: tokens.ink,
      muted: tokens.muted,
      rule: glass ? const Color(0x32FFFFFF) : tokens.line,
      accent: tokens.accent,
      accentSoft: Color.alphaBlend(
        tokens.accent.withValues(alpha: tokens.isDark ? 0.24 : 0.18),
        tokens.softPanel,
      ),
      onInk: glass ? tokens.ink : tokens.onAccent,
      onInkMuted: glass
          ? tokens.muted
          : Color.alphaBlend(
              tokens.muted.withValues(alpha: 0.72),
              tokens.onAccent,
            ),
      visualTheme: visualTheme,
    );
  }
}

class _ThemedHomeBackdrop extends StatelessWidget {
  const _ThemedHomeBackdrop({
    required this.visualTheme,
    required this.palette,
    required this.child,
  });

  final AppVisualTheme visualTheme;
  final _HomePalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (visualTheme == AppVisualTheme.wabiSabi) {
      return WabiSabiPaper(color: palette.background, child: child);
    }
    if (visualTheme == AppVisualTheme.glass) {
      return GlassMotionBackdrop(child: child);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
      ),
      child: CustomPaint(
        painter: _HomeBackdropPainter(visualTheme, palette),
        child: child,
      ),
    );
  }
}

class _HomeBackdropPainter extends CustomPainter {
  const _HomeBackdropPainter(this.visualTheme, this.palette);
  final AppVisualTheme visualTheme;
  final _HomePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (visualTheme == AppVisualTheme.minimalism) {
      final paint = Paint()..color = palette.ink.withValues(alpha: 0.025);
      for (double y = 8; y < size.height; y += 8) {
        canvas.drawLine(
            Offset.zero.translate(0, y), Offset(size.width, y), paint);
      }
    } else if (visualTheme == AppVisualTheme.midCentury) {
      canvas.drawCircle(Offset(size.width - 72, 92), 58,
          Paint()..color = const Color(0x33E5A536));
      canvas.drawRect(Rect.fromLTWH(size.width - 150, 146, 112, 24),
          Paint()..color = const Color(0x26D45632));
    }
  }

  @override
  bool shouldRepaint(covariant _HomeBackdropPainter oldDelegate) =>
      oldDelegate.visualTheme != visualTheme || oldDelegate.palette != palette;
}

class _MidCenturyOrnament extends StatelessWidget {
  const _MidCenturyOrnament();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 112,
        height: 82,
        child: Stack(children: [
          Positioned(
              right: 0,
              child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE5A536), shape: BoxShape.circle))),
          Positioned(
              right: 42,
              top: 28,
              child: Transform.rotate(
                angle: .55,
                child: Container(
                    width: 54, height: 28, color: const Color(0xFFD45632)),
              )),
          Positioned(
              right: 78,
              top: 4,
              child: Container(
                  width: 22,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: Color(0xFF2E7771),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          bottomRight: Radius.circular(22))))),
        ]),
      );
}
