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
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';
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
    required this.onApplyDayTemplateToDates,
    required this.onSavePlanAsDayTemplate,
    required this.onDeleteDayTemplate,
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
  final Future<void> Function(
    int templateId,
    List<String> planDates, {
    required PlanApplyStrategy strategy,
  }) onApplyDayTemplateToDates;
  final Future<bool> Function(String templateName, TodayPlan sourcePlan)
      onSavePlanAsDayTemplate;
  final Future<void> Function(int templateId) onDeleteDayTemplate;
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
  bool _showAnnualMonthInDay = false;
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

  void _selectDayPlanTab(bool showAnnualMonth) {
    if (_showAnnualMonthInDay == showAnnualMonth) {
      return;
    }
    setState(() => _showAnnualMonthInDay = showAnnualMonth);
    if (showAnnualMonth) {
      unawaited(widget.onLoadAnnualOverview(DateTime.now().year));
    }
  }

  Future<void> _openAnnualYearFromDay() async {
    setState(() => _planHorizon = _PlanHorizon.year);
    await widget.onLoadAnnualOverview(DateTime.now().year);
  }

  Future<void> _openDayAnnualFromHome() async {
    setState(() {
      _selectedDestinationId = 'plans';
      _planHorizon = _PlanHorizon.day;
      _showAnnualMonthInDay = true;
    });
    await widget.onLoadAnnualOverview(DateTime.now().year);
  }

  Future<void> _saveCurrentPlanAsArchive() async {
    if (!widget.todayPlan.hasItems) {
      return;
    }
    var enteredArchiveName = widget.todayPlan.planName == 'Today'
        ? _text('今日安排存档', 'Today archive')
        : widget.todayPlan.planName;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('保存为任务存档', 'Save as task archive')),
        content: TextFormField(
          initialValue: enteredArchiveName,
          autofocus: true,
          decoration: InputDecoration(
            labelText: _text('存档名称', 'Archive name'),
          ),
          onChanged: (value) => enteredArchiveName = value,
          onFieldSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(enteredArchiveName.trim()),
            child: Text(_text('保存存档', 'Save archive')),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) {
      return;
    }
    await widget.onSavePlanAsDayTemplate(name, widget.todayPlan);
  }

  Future<void> _openArchiveEditor({WeeklyPlanTemplate? template}) async {
    final initialPlan = TodayPlan.empty(widget.todayPlan.planDate).copyWith(
      planName: template?.templateName ?? '',
      items: template?.items ?? const [],
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TodayPlanEditorDialog(
        initialPlan: initialPlan,
        archiveMode: true,
        lockPlanName: template != null,
        onSaveArchive: (plan) => widget.onSavePlanAsDayTemplate(
          plan.planName,
          plan,
        ),
      ),
    );
  }

  Future<void> _deleteArchive(WeeklyPlanTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('删除任务存档？', 'Delete task archive?')),
        content: Text(template.templateName),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text('删除', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onDeleteDayTemplate(template.id);
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
          secondary: _HomePlanTabs(
            palette: palette,
            plan: widget.todayPlan,
            annualOverview: widget.annualPlanOverview,
            isChinese: _isChinese,
            isBusy: widget.isBusy,
            density: spec.defaultDensity,
            onEdit: widget.onEditTodayPlan,
            onToggle: widget.onToggleTodayPlanItem,
            onLoadAnnual: () =>
                widget.onLoadAnnualOverview(DateTime.now().year),
            onOpenAnnualBoard: _openDayAnnualFromHome,
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
              label: _text('今日计划完成率', 'Today plan completion'),
              value: '${(widget.todayPlan.completionRatio * 100).round()}%',
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
    if (_planHorizon == _PlanHorizon.year) {
      return _AnnualPlanBoard(
        palette: palette,
        overview: widget.annualPlanOverview,
        isChinese: _isChinese,
        isBusy: widget.isBusy,
        pageSpec: spec,
        pageVisualTheme: widget.visualTheme,
        pageIntro: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionLead(
              palette: palette,
              title: horizonTitle,
              description: _text(
                '超长计划独立管理年内目标。月份刻度会随任务列表保持在顶部。',
                'Annual goals are independent. The month ruler stays visible as tasks scroll.',
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
          ],
        ),
        onPreviousYear: widget.onPreviousYear,
        onCurrentYear: widget.onCurrentYear,
        onNextYear: widget.onNextYear,
        onSaveSegment: widget.onSaveAnnualSegment,
        onDeleteSegment: widget.onDeleteAnnualSegment,
      );
    }
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
            '短计划管理当天安排，长计划负责按月套用任务存档，超长计划独立管理年内目标。',
            'Daily plans manage today, monthly plans apply task archives, and annual plans manage independent goals.',
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
          _Panel(
            palette: palette,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final tab in [false, true])
                  OutlinedButton.icon(
                    key: ValueKey(tab
                        ? 'day-plan-tab-annual-month'
                        : 'day-plan-tab-today'),
                    onPressed: () => _selectDayPlanTab(tab),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _showAnnualMonthInDay == tab
                          ? palette.accentSoft
                          : palette.surface,
                      foregroundColor: _showAnnualMonthInDay == tab
                          ? palette.accent
                          : palette.ink,
                      side: BorderSide(
                        color: _showAnnualMonthInDay == tab
                            ? palette.accent
                            : palette.rule,
                      ),
                    ),
                    icon: Icon(tab
                        ? Icons.calendar_view_month_outlined
                        : Icons.today_outlined),
                    label: Text(tab
                        ? _text('本月超长任务', 'Annual tasks this month')
                        : _text('今日安排', 'Today schedule')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!_showAnnualMonthInDay) ...[
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
            const SizedBox(height: 14),
            _Panel(
              palette: palette,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('save-current-plan-as-archive'),
                    onPressed: widget.isBusy || !widget.todayPlan.hasItems
                        ? null
                        : _saveCurrentPlanAsArchive,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(_text(
                      '保存当前安排为任务存档',
                      'Save current plan as archive',
                    )),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.isBusy ? null : _openArchiveEditor,
                    icon: const Icon(Icons.add_box_outlined),
                    label: Text(_text(
                      '新建空白任务存档',
                      'Create blank task archive',
                    )),
                  ),
                  Text(
                    _text(
                      '存档不绑定日期，可在长计划中重复套用。',
                      'Archives are date-free and reusable in monthly plans.',
                    ),
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else
            _AnnualPlanBoard(
              key: ValueKey(
                  'day-annual-${DateTime.now().year}-${DateTime.now().month}'),
              palette: palette,
              overview: widget.annualPlanOverview,
              previewMonth: DateTime.now().month,
              isChinese: _isChinese,
              isBusy: widget.isBusy,
              onOpenFullYear: _openAnnualYearFromDay,
              onPreviousYear: widget.onPreviousYear,
              onCurrentYear: widget.onCurrentYear,
              onNextYear: widget.onNextYear,
              onSaveSegment: widget.onSaveAnnualSegment,
              onDeleteSegment: widget.onDeleteAnnualSegment,
            ),
        ] else
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
            onApplyTemplateBatch: widget.onApplyDayTemplateToDates,
            onCreateTemplate: _openArchiveEditor,
            onEditTemplate: (template) =>
                _openArchiveEditor(template: template),
            onDeleteTemplate: _deleteArchive,
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
    required this.onApplyTemplateBatch,
    required this.onCreateTemplate,
    required this.onEditTemplate,
    required this.onDeleteTemplate,
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
  final Future<void> Function(
    int templateId,
    List<String> planDates, {
    required PlanApplyStrategy strategy,
  }) onApplyTemplateBatch;
  final Future<void> Function() onCreateTemplate;
  final Future<void> Function(WeeklyPlanTemplate template) onEditTemplate;
  final Future<void> Function(WeeklyPlanTemplate template) onDeleteTemplate;

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

  Future<void> _applyTemplateBatch(
    BuildContext context,
    WeeklyPlanTemplate template,
  ) async {
    final result = await showDialog<_TemplateBatchSelection>(
      context: context,
      builder: (context) => _TemplateBatchApplyDialog(
        isChinese: isChinese,
        overview: overview,
        template: template,
      ),
    );
    if (result == null || result.planDates.isEmpty) {
      return;
    }
    await onApplyTemplateBatch(
      template.id,
      result.planDates,
      strategy: result.strategy,
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
            const SizedBox(height: 16),
            _DayTemplateArchiveShelf(
              palette: palette,
              templates: templates,
              isChinese: isChinese,
              isBusy: isBusy,
              onCreate: onCreateTemplate,
              onApply: (template) => _applyTemplateBatch(context, template),
              onEdit: onEditTemplate,
              onDelete: onDeleteTemplate,
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
                  ? '左右滑动切换月份；点击日期编辑短计划，或从上方任务存档架直接套用。'
                  : 'Swipe to change month. Open a date to edit its daily plan or apply an archive above.',
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

class _DayTemplateArchiveShelf extends StatelessWidget {
  const _DayTemplateArchiveShelf({
    required this.palette,
    required this.templates,
    required this.isChinese,
    required this.isBusy,
    required this.onCreate,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final _HomePalette palette;
  final List<WeeklyPlanTemplate> templates;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onCreate;
  final Future<void> Function(WeeklyPlanTemplate template) onApply;
  final Future<void> Function(WeeklyPlanTemplate template) onEdit;
  final Future<void> Function(WeeklyPlanTemplate template) onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('monthly-task-archive-shelf'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.accentSoft.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChinese ? '任务存档' : 'Task archives',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese
                          ? '从存档直接选择一个或多个日期套用，也可以从零制作新存档。'
                          : 'Apply an archive to one or more dates, or create a new archive from scratch.',
                      style: TextStyle(color: palette.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                key: const ValueKey('create-task-archive'),
                onPressed: isBusy ? null : onCreate,
                icon: const Icon(Icons.add_rounded),
                label: Text(isChinese ? '新建存档' : 'New archive'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (templates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: palette.rule),
              ),
              child: Text(
                isChinese
                    ? '还没有任务存档。可以从短计划保存当前安排，或在这里新建。'
                    : 'No task archives yet. Save a daily plan or create one here.',
                style: TextStyle(color: palette.muted),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: templates.map((template) {
                return Container(
                  constraints:
                      const BoxConstraints(minWidth: 250, maxWidth: 340),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.rule),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: palette.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: palette.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.templateName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isChinese
                                  ? '${template.itemCount} 个任务 · ${template.plannedDurationLabel}'
                                  : '${template.itemCount} tasks · ${template.plannedDurationLabel}',
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isChinese ? '直接套用' : 'Apply',
                        onPressed: isBusy ? null : () => onApply(template),
                        icon: const Icon(Icons.playlist_add_check_rounded),
                      ),
                      PopupMenuButton<String>(
                        enabled: !isBusy,
                        tooltip: isChinese ? '存档操作' : 'Archive actions',
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit(template);
                          } else if (value == 'delete') {
                            onDelete(template);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(isChinese ? '编辑存档' : 'Edit archive'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(isChinese ? '删除存档' : 'Delete archive'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _TemplateBatchSelection {
  const _TemplateBatchSelection({
    required this.planDates,
    required this.strategy,
  });

  final List<String> planDates;
  final PlanApplyStrategy strategy;
}

class _TemplateBatchApplyDialog extends StatefulWidget {
  const _TemplateBatchApplyDialog({
    required this.isChinese,
    required this.overview,
    required this.template,
  });

  final bool isChinese;
  final MonthPlanOverview overview;
  final WeeklyPlanTemplate template;

  @override
  State<_TemplateBatchApplyDialog> createState() =>
      _TemplateBatchApplyDialogState();
}

class _TemplateBatchApplyDialogState extends State<_TemplateBatchApplyDialog> {
  final Set<String> _selectedDates = {};
  PlanApplyStrategy _strategy = PlanApplyStrategy.skip;

  @override
  Widget build(BuildContext context) {
    final monthStart =
        DateTime.tryParse('${widget.overview.month}-01') ?? DateTime.now();
    final dayCount = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    String dateFor(int day) => '${monthStart.year.toString().padLeft(4, '0')}-'
        '${monthStart.month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: Text(
        widget.isChinese
            ? '套用“${widget.template.templateName}”'
            : 'Apply “${widget.template.templateName}”',
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isChinese
                  ? '选择本月一个或多个日期。带圆点的日期已有计划。'
                  : 'Choose one or more dates. Dotted dates already contain a plan.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(dayCount, (index) {
                final day = index + 1;
                final date = dateFor(day);
                final existing = widget.overview.dayFor(date).hasPlan;
                return FilterChip(
                  key: ValueKey('archive-apply-day-$day'),
                  selected: _selectedDates.contains(date),
                  avatar: existing ? const Icon(Icons.circle, size: 7) : null,
                  label: Text('$day'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDates.add(date);
                      } else {
                        _selectedDates.remove(date);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 18),
            Text(
              widget.isChinese ? '已有计划时' : 'When a plan already exists',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  selected: _strategy == PlanApplyStrategy.skip,
                  label: Text(widget.isChinese ? '跳过' : 'Skip'),
                  onSelected: (_) =>
                      setState(() => _strategy = PlanApplyStrategy.skip),
                ),
                ChoiceChip(
                  selected: _strategy == PlanApplyStrategy.overwrite,
                  label: Text(widget.isChinese ? '覆盖' : 'Overwrite'),
                  onSelected: (_) => setState(
                    () => _strategy = PlanApplyStrategy.overwrite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.isChinese ? '取消' : 'Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey('apply-task-archive-batch'),
          onPressed: _selectedDates.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _TemplateBatchSelection(
                      planDates: _selectedDates.toList()..sort(),
                      strategy: _strategy,
                    ),
                  ),
          icon: const Icon(Icons.playlist_add_check_rounded),
          label: Text(
            widget.isChinese
                ? '套用到 ${_selectedDates.length} 天'
                : 'Apply to ${_selectedDates.length} days',
          ),
        ),
      ],
    );
  }
}

class _AnnualPlanBoard extends StatefulWidget {
  const _AnnualPlanBoard({
    super.key,
    required this.palette,
    required this.overview,
    this.previewMonth,
    this.onOpenFullYear,
    this.pageSpec,
    this.pageVisualTheme,
    this.pageIntro,
    required this.isChinese,
    required this.isBusy,
    required this.onPreviousYear,
    required this.onCurrentYear,
    required this.onNextYear,
    required this.onSaveSegment,
    required this.onDeleteSegment,
  }) : assert(
            pageSpec == null || (pageVisualTheme != null && pageIntro != null));

  final _HomePalette palette;
  final AnnualPlanOverview overview;
  final int? previewMonth;
  final Future<void> Function()? onOpenFullYear;
  final DesktopPresentationSpec? pageSpec;
  final AppVisualTheme? pageVisualTheme;
  final Widget? pageIntro;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onPreviousYear;
  final Future<void> Function() onCurrentYear;
  final Future<void> Function() onNextYear;
  final Future<void> Function(AnnualPlanSegment segment) onSaveSegment;
  final Future<void> Function(AnnualPlanSegment segment) onDeleteSegment;

  @override
  State<_AnnualPlanBoard> createState() => _AnnualPlanBoardState();
}

class _AnnualPlanBoardState extends State<_AnnualPlanBoard> {
  int? _selectedMonth;

  Future<void> _openSegmentEditor(
    BuildContext context, {
    AnnualPlanSegment? initial,
    int startMonth = 1,
    int endMonth = 1,
  }) async {
    final result = await showDialog<AnnualPlanSegment>(
      context: context,
      builder: (context) => _AnnualSegmentDialog(
        isChinese: widget.isChinese,
        year: widget.overview.year,
        initial: initial,
        startMonth: startMonth,
        endMonth: endMonth,
      ),
    );
    if (result != null && mounted) {
      await widget.onSaveSegment(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AnnualPlanSegment segment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.isChinese ? '删除年度任务？' : 'Delete annual task?',
        ),
        content: Text(segment.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.isChinese ? '取消' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.onDeleteSegment(segment);
    }
  }

  Future<void> _toggleSubtask(
    AnnualPlanSegment segment,
    AnnualPlanSubtask subtask,
  ) async {
    final updated = segment.subtasks
        .map(
          (item) => identical(item, subtask) || item.id == subtask.id
              ? item.copyWith(completed: !item.completed)
              : item,
        )
        .toList();
    await widget.onSaveSegment(segment.copyWith(subtasks: updated));
  }

  Future<void> _adjustTaskProgress(
    AnnualPlanSegment segment,
    int delta,
  ) async {
    if ((delta > 0 && segment.isCompleted) ||
        (delta < 0 && segment.progressPercent == 0)) {
      return;
    }
    await widget.onSaveSegment(segment.adjustProgress(delta));
  }

  Future<void> _completeTask(AnnualPlanSegment segment) async {
    if (segment.isCompleted) return;
    await widget.onSaveSegment(segment.copyWith(progressPercent: 100));
  }

  Future<void> _editSubtask(
    BuildContext context,
    AnnualPlanSegment segment, {
    AnnualPlanSubtask? initial,
  }) async {
    final result = await showDialog<AnnualPlanSubtask>(
      context: context,
      builder: (context) => _AnnualSubtaskDialog(
        isChinese: widget.isChinese,
        initial: initial,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    final subtasks = [...segment.subtasks];
    if (initial == null) {
      subtasks.add(result.copyWith(sortOrder: subtasks.length));
    } else {
      final index = subtasks.indexWhere(
        (item) => identical(item, initial) || item.id == initial.id,
      );
      if (index >= 0) {
        subtasks[index] = result.copyWith(sortOrder: index);
      }
    }
    await widget.onSaveSegment(segment.copyWith(subtasks: subtasks));
  }

  Future<void> _deleteSubtask(
    BuildContext context,
    AnnualPlanSegment segment,
    AnnualPlanSubtask subtask,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isChinese ? '删除子任务？' : 'Delete subtask?'),
        content: Text(subtask.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.isChinese ? '取消' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.isChinese ? '删除' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final subtasks = segment.subtasks
        .where(
          (item) => !(identical(item, subtask) || item.id == subtask.id),
        )
        .toList();
    await widget.onSaveSegment(
      segment.copyWith(
        subtasks: [
          for (var index = 0; index < subtasks.length; index += 1)
            subtasks[index].copyWith(sortOrder: index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMonth = widget.previewMonth ?? _selectedMonth;
    final visibleSegments = effectiveMonth == null
        ? widget.overview.segments
        : widget.overview.segments
            .where(
              (segment) =>
                  effectiveMonth >= segment.startMonth &&
                  effectiveMonth <= segment.endMonth,
            )
            .toList();
    if (widget.pageSpec != null) {
      return _buildFullPage(visibleSegments);
    }
    return _Panel(
      palette: widget.palette,
      emphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.previewMonth == null)
            _PlanRangeHeader(
              palette: widget.palette,
              title: widget.isChinese
                  ? '${widget.overview.year} 年度任务'
                  : '${widget.overview.year} annual tasks',
              subtitle: widget.isChinese
                  ? '年度任务独立于长计划；充能框标示月份跨度，框内色彩显示任务进度。'
                  : 'Annual tasks are independent from monthly plans. The charge frame marks the month span; its fill shows task progress.',
              isBusy: widget.isBusy,
              currentLabel: widget.isChinese ? '今年' : 'This year',
              previousTooltip: widget.isChinese ? '上一年' : 'Previous year',
              nextTooltip: widget.isChinese ? '下一年' : 'Next year',
              onPrevious: widget.onPreviousYear,
              onCurrent: widget.onCurrentYear,
              onNext: widget.onNextYear,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isChinese
                      ? '${widget.overview.year} 年 ${widget.previewMonth} 月超长任务'
                      : 'Annual tasks · ${widget.previewMonth}/${widget.overview.year}',
                  style: TextStyle(
                    color: widget.palette.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isChinese
                      ? '只显示覆盖本月的独立年度任务；进度可在这里直接更新。'
                      : 'Independent annual tasks spanning this month. Update their progress here.',
                  style: TextStyle(color: widget.palette.muted),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: widget.onOpenFullYear == null
                        ? null
                        : () => unawaited(widget.onOpenFullYear!()),
                    icon: const Icon(Icons.open_in_full_rounded),
                    label: Text(widget.isChinese ? '查看全年' : 'View full year'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.previewMonth == null
                      ? (widget.isChinese ? '月份导航' : 'Month navigation')
                      : (widget.isChinese
                          ? '本月任务 · ${visibleSegments.length} 项'
                          : '${visibleSegments.length} tasks this month'),
                  style: TextStyle(
                    color: widget.palette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.previewMonth == null)
                TextButton.icon(
                  onPressed: widget.isBusy
                      ? null
                      : () => setState(() => _selectedMonth = null),
                  icon: const Icon(Icons.apps_rounded),
                  label: Text(widget.isChinese ? '全部任务' : 'All tasks'),
                ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const ValueKey('create-annual-task'),
                onPressed: widget.isBusy
                    ? null
                    : () => _openSegmentEditor(
                          context,
                          startMonth: effectiveMonth ?? 1,
                          endMonth: effectiveMonth ?? 1,
                        ),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  widget.isChinese ? '新建年度任务' : 'New annual task',
                ),
              ),
            ],
          ),
          if (widget.previewMonth == null) ...[
            const SizedBox(height: 10),
            _AnnualMonthSelector(
              palette: widget.palette,
              selectedMonth: _selectedMonth,
              segments: widget.overview.segments,
              onSelected: (month) => setState(
                () => _selectedMonth = _selectedMonth == month ? null : month,
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (visibleSegments.isEmpty)
            _AnnualEmptyState(
              palette: widget.palette,
              isChinese: widget.isChinese,
              selectedMonth: effectiveMonth,
              onCreate: widget.isBusy
                  ? null
                  : () => _openSegmentEditor(
                        context,
                        startMonth: effectiveMonth ?? 1,
                        endMonth: effectiveMonth ?? 1,
                      ),
            )
          else
            ...visibleSegments.map(_buildTaskCard),
        ],
      ),
    );
  }

  Widget _buildFullPage(List<AnnualPlanSegment> visibleSegments) {
    final spec = widget.pageSpec!;
    final horizontal = _pageCanvasHorizontal(spec);
    final maxWidth = _pageCanvasMaxWidth(spec);
    Widget centered(Widget child) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(width: double.infinity, child: child),
          ),
        );

    return _ThemedHomeBackdrop(
      visualTheme: widget.pageVisualTheme!,
      palette: widget.palette,
      child: CustomScrollView(
        key: const PageStorageKey<String>('desktop.plans.annual'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 0),
              child: centered(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.pageIntro!,
                  _Panel(
                    palette: widget.palette,
                    emphasized: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlanRangeHeader(
                          palette: widget.palette,
                          title: widget.isChinese
                              ? '${widget.overview.year} 年度任务'
                              : '${widget.overview.year} annual tasks',
                          subtitle: widget.isChinese
                              ? '年度任务独立于长计划；充能框标示月份跨度，框内色彩显示任务进度。'
                              : 'Annual tasks are independent from monthly plans. The charge frame marks the month span; its fill shows task progress.',
                          isBusy: widget.isBusy,
                          currentLabel: widget.isChinese ? '今年' : 'This year',
                          previousTooltip:
                              widget.isChinese ? '上一年' : 'Previous year',
                          nextTooltip: widget.isChinese ? '下一年' : 'Next year',
                          onPrevious: widget.onPreviousYear,
                          onCurrent: widget.onCurrentYear,
                          onNext: widget.onNextYear,
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              widget.isChinese ? '月份导航' : 'Month navigation',
                              style: TextStyle(
                                color: widget.palette.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: widget.isBusy
                                  ? null
                                  : () => setState(() => _selectedMonth = null),
                              icon: const Icon(Icons.apps_rounded),
                              label:
                                  Text(widget.isChinese ? '全部任务' : 'All tasks'),
                            ),
                            FilledButton.icon(
                              key: const ValueKey('create-annual-task'),
                              onPressed: widget.isBusy
                                  ? null
                                  : () => _openSegmentEditor(
                                        context,
                                        startMonth: _selectedMonth ?? 1,
                                        endMonth: _selectedMonth ?? 1,
                                      ),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(widget.isChinese
                                  ? '新建年度任务'
                                  : 'New annual task'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _AnnualStickyMonthHeader(
              palette: widget.palette,
              horizontal: horizontal,
              maxWidth: maxWidth,
              child: _AnnualMonthSelector(
                palette: widget.palette,
                selectedMonth: _selectedMonth,
                segments: widget.overview.segments,
                onSelected: (month) => setState(() =>
                    _selectedMonth = _selectedMonth == month ? null : month),
              ),
            ),
          ),
          if (visibleSegments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
                child: centered(_AnnualEmptyState(
                  palette: widget.palette,
                  isChinese: widget.isChinese,
                  selectedMonth: _selectedMonth,
                  onCreate: widget.isBusy
                      ? null
                      : () => _openSegmentEditor(
                            context,
                            startMonth: _selectedMonth ?? 1,
                            endMonth: _selectedMonth ?? 1,
                          ),
                )),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
              sliver: SliverList.builder(
                itemCount: visibleSegments.length,
                itemBuilder: (context, index) =>
                    centered(_buildTaskCard(visibleSegments[index])),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(AnnualPlanSegment segment) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _AnnualTaskCard(
          palette: widget.palette,
          segment: segment,
          isChinese: widget.isChinese,
          isBusy: widget.isBusy,
          onEdit: () => _openSegmentEditor(context, initial: segment),
          onDelete: () => _confirmDelete(context, segment),
          onAddSubtask: () => _editSubtask(context, segment),
          onEditSubtask: (subtask) =>
              _editSubtask(context, segment, initial: subtask),
          onDeleteSubtask: (subtask) =>
              _deleteSubtask(context, segment, subtask),
          onToggleSubtask: (subtask) => _toggleSubtask(segment, subtask),
          onProgressChange: (delta) => _adjustTaskProgress(segment, delta),
          onCompleteTask: () => _completeTask(segment),
        ),
      );
}

class _AnnualStickyMonthHeader extends SliverPersistentHeaderDelegate {
  _AnnualStickyMonthHeader({
    required this.palette,
    required this.horizontal,
    required this.maxWidth,
    required this.child,
  });

  final _HomePalette palette;
  final double horizontal;
  final double maxWidth;
  final Widget child;

  @override
  double get minExtent => 74;

  @override
  double get maxExtent => 74;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final glass = palette.visualTheme == AppVisualTheme.glass;
    final header = Container(
      key: const ValueKey('annual-sticky-month-ruler'),
      decoration: BoxDecoration(
        color: glass ? null : palette.background,
        gradient: glass
            ? const LinearGradient(
                colors: [Color(0xBC253988), Color(0xBC5B318C)],
              )
            : null,
        border: Border(
          bottom: BorderSide(
            color: glass ? const Color(0x58E0E8FF) : palette.rule,
          ),
        ),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: palette.ink.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 10),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
    return glass
        ? ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: header,
            ),
          )
        : header;
  }

  @override
  bool shouldRebuild(covariant _AnnualStickyMonthHeader oldDelegate) => true;
}

class _AnnualMonthSelector extends StatelessWidget {
  const _AnnualMonthSelector({
    required this.palette,
    required this.selectedMonth,
    required this.segments,
    required this.onSelected,
  });

  final _HomePalette palette;
  final int? selectedMonth;
  final List<AnnualPlanSegment> segments;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final grid = _AnnualMonthGrid(constraints.maxWidth);
          return SizedBox(
            height: 54,
            child: Stack(
              children: [
                for (var month = 1; month <= 12; month += 1)
                  Positioned(
                    left: grid.left(month),
                    width: grid.cellWidth,
                    top: 0,
                    bottom: 0,
                    child: _AnnualMonthButton(
                      palette: palette,
                      month: month,
                      selected: selectedMonth == month,
                      count: segments
                          .where((segment) =>
                              month >= segment.startMonth &&
                              month <= segment.endMonth)
                          .length,
                      onPressed: () => onSelected(month),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnnualMonthGrid {
  const _AnnualMonthGrid(this.width);

  static const gap = 4.0;
  final double width;

  double get cellWidth => (width - gap * 11) / 12;
  double left(int month) => (month - 1) * (cellWidth + gap);
  double spanWidth(int startMonth, int endMonth) =>
      left(endMonth) + cellWidth - left(startMonth);
}

class _AnnualMonthButton extends StatelessWidget {
  const _AnnualMonthButton({
    required this.palette,
    required this.month,
    required this.selected,
    required this.count,
    required this.onPressed,
  });

  final _HomePalette palette;
  final int month;
  final bool selected;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final glass = palette.visualTheme == AppVisualTheme.glass;
    return OutlinedButton(
      key: ValueKey('annual-month-$month'),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: selected ? palette.accent : palette.surface,
        foregroundColor: selected
            ? (glass ? palette.background : palette.onInk)
            : palette.ink,
        side: BorderSide(
          color: selected
              ? palette.accent
              : glass
                  ? const Color(0x58E0E8FF)
                  : palette.rule,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$month',
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          if (count > 0)
            Text('$count',
                style: TextStyle(
                  fontSize: 9,
                  color: selected
                      ? (glass ? palette.background : palette.onInk)
                          .withValues(alpha: 0.78)
                      : palette.muted,
                )),
        ],
      ),
    );
  }
}

class _AnnualEmptyState extends StatelessWidget {
  const _AnnualEmptyState({
    required this.palette,
    required this.isChinese,
    required this.selectedMonth,
    required this.onCreate,
  });

  final _HomePalette palette;
  final bool isChinese;
  final int? selectedMonth;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.rule),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.route_outlined, color: palette.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedMonth == null
                  ? (isChinese ? '还没有年度任务。' : 'No annual tasks yet.')
                  : (isChinese
                      ? '$selectedMonth 月暂无跨期任务。'
                      : 'No task spans month $selectedMonth.'),
              style: TextStyle(color: palette.muted),
            ),
          ),
          TextButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(isChinese ? '新建' : 'Create'),
          ),
        ],
      ),
    );
  }
}

class _AnnualTaskCard extends StatelessWidget {
  const _AnnualTaskCard({
    required this.palette,
    required this.segment,
    required this.isChinese,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSubtask,
    required this.onEditSubtask,
    required this.onDeleteSubtask,
    required this.onToggleSubtask,
    required this.onProgressChange,
    required this.onCompleteTask,
  });

  final _HomePalette palette;
  final AnnualPlanSegment segment;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function() onAddSubtask;
  final Future<void> Function(AnnualPlanSubtask subtask) onEditSubtask;
  final Future<void> Function(AnnualPlanSubtask subtask) onDeleteSubtask;
  final Future<void> Function(AnnualPlanSubtask subtask) onToggleSubtask;
  final Future<void> Function(int delta) onProgressChange;
  final Future<void> Function() onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final color = _annualColor(segment.colorKey);
    return Container(
      key: ValueKey('annual-task-${segment.id}-${segment.clientEntityId}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.title,
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChinese
                          ? '${segment.startMonth} 月 — ${segment.endMonth} 月 · ${segment.completedSubtaskCount}/${segment.subtasks.length} 完成'
                          : 'Month ${segment.startMonth} — ${segment.endMonth} · ${segment.completedSubtaskCount}/${segment.subtasks.length} complete',
                      style: TextStyle(color: palette.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isChinese ? '编辑年度任务' : 'Edit annual task',
                onPressed: isBusy ? null : () => unawaited(onEdit()),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: isChinese ? '删除年度任务' : 'Delete annual task',
                onPressed: isBusy ? null : () => unawaited(onDelete()),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isChinese ? '任务进度' : 'Task progress',
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${segment.progressPercent}%',
                key: ValueKey('annual-progress-value-${segment.id}'),
                style: TextStyle(
                  color: segment.isCompleted ? color : palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ChargingMonthSpan(
            key: ValueKey(
                'annual-charge-${segment.id}-${segment.clientEntityId}'),
            palette: palette,
            color: color,
            startMonth: segment.startMonth,
            endMonth: segment.endMonth,
            progressPercent: segment.progressPercent,
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final step in const [10, 5, 1])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      key: ValueKey('annual-progress-plus$step-${segment.id}'),
                      onPressed: isBusy || segment.isCompleted
                          ? null
                          : () => unawaited(onProgressChange(step)),
                      child: Text('+$step%'),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton(
                      key: ValueKey('annual-progress-minus$step-${segment.id}'),
                      onPressed: isBusy || segment.progressPercent == 0
                          ? null
                          : () => unawaited(onProgressChange(-step)),
                      child: Text('−$step%'),
                    ),
                  ],
                ),
              FilledButton.icon(
                key: ValueKey('annual-task-complete-${segment.id}'),
                onPressed: isBusy || segment.isCompleted
                    ? null
                    : () => unawaited(onCompleteTask()),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(isChinese
                    ? (segment.isCompleted ? '已完成' : '完成任务')
                    : (segment.isCompleted ? 'Completed' : 'Complete task')),
              ),
            ],
          ),
          if (segment.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              segment.note,
              style: TextStyle(color: palette.muted, height: 1.45),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  isChinese ? '子任务' : 'Subtasks',
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isBusy ? null : () => unawaited(onAddSubtask()),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(isChinese ? '添加子任务' : 'Add subtask'),
              ),
            ],
          ),
          if (segment.subtasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                isChinese
                    ? '还没有子任务，可以为这个年度任务继续拆分。'
                    : 'No subtasks yet. Break this annual task into actionable steps.',
                style: TextStyle(color: palette.muted),
              ),
            )
          else
            ...segment.subtasks.map(
              (subtask) => _AnnualSubtaskRow(
                palette: palette,
                subtask: subtask,
                isChinese: isChinese,
                isBusy: isBusy,
                color: color,
                onToggle: () => onToggleSubtask(subtask),
                onEdit: () => onEditSubtask(subtask),
                onDelete: () => onDeleteSubtask(subtask),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnnualSubtaskRow extends StatelessWidget {
  const _AnnualSubtaskRow({
    required this.palette,
    required this.subtask,
    required this.isChinese,
    required this.isBusy,
    required this.color,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final _HomePalette palette;
  final AnnualPlanSubtask subtask;
  final bool isChinese;
  final bool isBusy;
  final Color color;
  final Future<void> Function() onToggle;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(13, 10, 7, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.rule),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                    decoration:
                        subtask.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (subtask.detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtask.detail,
                    style: TextStyle(color: palette.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: isChinese ? '编辑子任务' : 'Edit subtask',
            onPressed: isBusy ? null : () => unawaited(onEdit()),
            icon: const Icon(Icons.edit_outlined, size: 19),
          ),
          IconButton(
            tooltip: isChinese ? '删除子任务' : 'Delete subtask',
            onPressed: isBusy ? null : () => unawaited(onDelete()),
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
          ),
          const SizedBox(width: 2),
          Semantics(
            button: true,
            label: subtask.completed
                ? (isChinese ? '取消完成' : 'Mark incomplete')
                : (isChinese ? '确认完成' : 'Confirm completion'),
            child: IconButton.filledTonal(
              key: ValueKey('annual-subtask-complete-${subtask.id}'),
              tooltip: subtask.completed
                  ? (isChinese ? '已完成，点击撤销' : 'Completed. Click to undo')
                  : (isChinese ? '确认完成' : 'Confirm completion'),
              onPressed: isBusy ? null : () => unawaited(onToggle()),
              style: IconButton.styleFrom(
                foregroundColor: subtask.completed ? palette.onInk : color,
                backgroundColor:
                    subtask.completed ? color : color.withValues(alpha: 0.12),
              ),
              icon: Icon(
                subtask.completed
                    ? Icons.check_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargingMonthSpan extends StatefulWidget {
  const _ChargingMonthSpan({
    super.key,
    required this.palette,
    required this.color,
    required this.startMonth,
    required this.endMonth,
    required this.progressPercent,
  });

  final _HomePalette palette;
  final Color color;
  final int startMonth;
  final int endMonth;
  final int progressPercent;

  @override
  State<_ChargingMonthSpan> createState() => _ChargingMonthSpanState();
}

class _ChargingMonthSpanState extends State<_ChargingMonthSpan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startMonth.clamp(1, 12);
    final end = widget.endMonth.clamp(start, 12);
    final glass = widget.palette.visualTheme == AppVisualTheme.glass;
    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = _AnnualMonthGrid(constraints.maxWidth);
        final spanWidth = grid.spanWidth(start, end);
        return SizedBox(
          key: ValueKey(
              'annual-month-span-${widget.startMonth}-${widget.endMonth}'),
          height: 28,
          child: Stack(
            children: [
              for (var month = 1; month <= 12; month += 1)
                Positioned(
                  left: grid.left(month),
                  width: grid.cellWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    key: ValueKey('annual-month-track-$month'),
                    decoration: BoxDecoration(
                      color: glass
                          ? const Color(0x55334490)
                          : widget.palette.rule.withValues(alpha: 0.55),
                      border: glass
                          ? Border.all(color: const Color(0x38E0E8FF))
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              Positioned(
                left: grid.left(start),
                width: spanWidth,
                top: 0,
                bottom: 0,
                child: Stack(
                  key: ValueKey('annual-month-active-$start-$end'),
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: glass
                              ? const Color(0x36243571)
                              : widget.palette.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            end: widget.progressPercent.clamp(0, 100) / 100),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 550),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, child) => Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            key: ValueKey(
                                'annual-month-charge-fill-$start-$end'),
                            width: spanWidth * progress,
                            height: 28,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) => RepaintBoundary(
                                  child: CustomPaint(
                                    painter: _SeamlessChargePainter(
                                      color: widget.color,
                                      phase: _controller.value,
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: widget.color, width: 1.25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeamlessChargePainter extends CustomPainter {
  const _SeamlessChargePainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
    );
    final deep = Color.lerp(color, Colors.black, 0.13)!;
    final bright = Color.lerp(color, Colors.white, 0.24)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [deep, color, bright, color, deep],
          stops: const [0, 0.25, 0.52, 0.78, 1],
        ).createShader(rect),
    );

    final pulse = 0.13 + 0.045 * sin(2 * pi * phase);
    for (final seed in const [0.05, 0.55]) {
      final x = ((phase + seed) % 1) * size.width;
      for (final offset in [-size.width, 0.0, size.width]) {
        final center = Offset(x + offset, size.height * 0.50);
        final radius = max(42.0, size.width * 0.28);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withValues(alpha: pulse),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
      }
    }

    for (var index = 0; index < 18; index += 1) {
      final cycle = index.isEven ? 1 : 2;
      final seed = (index * 0.61803398875) % 1;
      final x = ((seed + phase * cycle) % 1) * size.width;
      final y = 4.5 + (index * 7.1) % max(5.0, size.height - 9);
      final opacity = 0.30 + (index % 4) * 0.12;
      final dotRadius = index % 5 == 0 ? 1.5 : 0.8;
      for (final offset in [-size.width, 0.0, size.width]) {
        canvas.drawCircle(
          Offset(x + offset, y),
          dotRadius,
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        if (index % 3 == 0) {
          canvas.drawLine(
            Offset(x + offset - 3, y + 1.2),
            Offset(x + offset + 2, y - 1.2),
            Paint()
              ..color = Colors.white.withValues(alpha: opacity * 0.65)
              ..strokeWidth = 0.9
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.width, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeamlessChargePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.phase != phase;
}

class _AnnualColorOption {
  const _AnnualColorOption(this.key, this.zh, this.en, this.color);

  final String key;
  final String zh;
  final String en;
  final Color color;
}

const _annualColorOptions = <_AnnualColorOption>[
  _AnnualColorOption('accent', '电光紫', 'Electric violet', Color(0xFF7657F7)),
  _AnnualColorOption('warm', '跃动橙', 'Vivid orange', Color(0xFFF46A25)),
  _AnnualColorOption('cool', '亮蓝', 'Bright blue', Color(0xFF2675E8)),
  _AnnualColorOption('neutral', '翠绿', 'Emerald green', Color(0xFF0BAD70)),
  _AnnualColorOption('coral', '珊瑚红', 'Coral red', Color(0xFFF3445A)),
  _AnnualColorOption('gold', '鎏金黄', 'Golden yellow', Color(0xFFE6A300)),
  _AnnualColorOption('cyan', '湖水青', 'Clear cyan', Color(0xFF00A8BE)),
];

Color _annualColor(String colorKey) {
  for (final option in _annualColorOptions) {
    if (option.key == colorKey) return option.color;
  }
  return _annualColorOptions.first.color;
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
  late int _progressPercent;
  late List<AnnualPlanSubtask> _subtasks;
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
    _progressPercent = widget.initial?.progressPercent ?? 0;
    _subtasks = [...?widget.initial?.subtasks];
  }

  Future<void> _editSubtask({AnnualPlanSubtask? initial}) async {
    final result = await showDialog<AnnualPlanSubtask>(
      context: context,
      builder: (context) => _AnnualSubtaskDialog(
        isChinese: widget.isChinese,
        initial: initial,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      if (initial == null) {
        _subtasks.add(result.copyWith(sortOrder: _subtasks.length));
      } else {
        final index = _subtasks.indexOf(initial);
        if (index >= 0) {
          _subtasks[index] = result.copyWith(sortOrder: index);
        }
      }
    });
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
        progressPercent: _progressPercent,
        revision: initial?.revision ?? 0,
        updateTime: initial?.updateTime ?? '',
        subtasks: [
          for (var index = 0; index < _subtasks.length; index += 1)
            _subtasks[index].copyWith(sortOrder: index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? (widget.isChinese ? '新建年度任务' : 'New annual task')
            : (widget.isChinese ? '编辑年度任务' : 'Edit annual task'),
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: widget.isChinese ? '任务名称' : 'Task name',
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
              Text(
                widget.isChinese
                    ? '任务进度 · $_progressPercent%'
                    : 'Task progress · $_progressPercent%',
              ),
              Slider(
                value: _progressPercent.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '$_progressPercent%',
                onChanged: (value) =>
                    setState(() => _progressPercent = value.round()),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _colorKey,
                decoration: InputDecoration(
                  labelText: widget.isChinese ? '标记颜色' : 'Color marker',
                ),
                items: [
                  for (final option in _annualColorOptions)
                    DropdownMenuItem(
                      value: option.key,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(widget.isChinese ? option.zh : option.en),
                        ],
                      ),
                    ),
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isChinese ? '子任务' : 'Subtasks',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _editSubtask,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(widget.isChinese ? '添加' : 'Add'),
                  ),
                ],
              ),
              if (_subtasks.isEmpty)
                Text(
                  widget.isChinese
                      ? '可以现在拆分子任务，也可以保存后再添加。'
                      : 'Add subtasks now, or add them after saving.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                ..._subtasks.asMap().entries.map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(entry.value.title),
                        subtitle: entry.value.detail.isEmpty
                            ? null
                            : Text(entry.value.detail),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: widget.isChinese ? '编辑' : 'Edit',
                              onPressed: () =>
                                  _editSubtask(initial: entry.value),
                              icon: const Icon(Icons.edit_outlined, size: 19),
                            ),
                            IconButton(
                              tooltip: widget.isChinese ? '删除' : 'Delete',
                              onPressed: () => setState(
                                () => _subtasks.removeAt(entry.key),
                              ),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
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

class _AnnualSubtaskDialog extends StatefulWidget {
  const _AnnualSubtaskDialog({
    required this.isChinese,
    this.initial,
  });

  final bool isChinese;
  final AnnualPlanSubtask? initial;

  @override
  State<_AnnualSubtaskDialog> createState() => _AnnualSubtaskDialogState();
}

class _AnnualSubtaskDialogState extends State<_AnnualSubtaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _detailController =
        TextEditingController(text: widget.initial?.detail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorText = widget.isChinese ? '请输入子任务名称。' : 'Enter a subtask title.';
      });
      return;
    }
    final initial = widget.initial;
    Navigator.of(context).pop(
      AnnualPlanSubtask(
        id: initial?.id ?? '',
        title: title,
        detail: _detailController.text.trim(),
        completed: initial?.completed ?? false,
        sortOrder: initial?.sortOrder ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? (widget.isChinese ? '添加子任务' : 'Add subtask')
            : (widget.isChinese ? '编辑子任务' : 'Edit subtask'),
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '子任务名称' : 'Subtask title',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _detailController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: widget.isChinese ? '内容描述' : 'Description',
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
    final horizontal = _pageCanvasHorizontal(spec);
    final maxWidth = _pageCanvasMaxWidth(spec);

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

double _pageCanvasHorizontal(DesktopPresentationSpec spec) =>
    switch (spec.tier) {
      DesktopPresentationTier.large => 32.0,
      DesktopPresentationTier.medium => 24.0,
      DesktopPresentationTier.small || null => 16.0,
    };

double _pageCanvasMaxWidth(DesktopPresentationSpec spec) => switch (spec.tier) {
      DesktopPresentationTier.large => 1320.0,
      DesktopPresentationTier.medium => 980.0,
      DesktopPresentationTier.small || null => double.infinity,
    };

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

class _HeroStatement extends StatefulWidget {
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
  State<_HeroStatement> createState() => _HeroStatementState();
}

class _HeroStatementState extends State<_HeroStatement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );
  }

  void _syncMotion() {
    if (widget.palette.visualTheme == AppVisualTheme.minimalism &&
        !MediaQuery.disableAnimationsOf(context)) {
      if (!_motion.isAnimating) {
        _motion.repeat(reverse: true);
      }
    } else {
      _motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant _HeroStatement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette.visualTheme != widget.palette.visualTheme) {
      _syncMotion();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final dayIndex = widget.dayIndex;
    final eyebrow = widget.eyebrow;
    final title = widget.title;
    final description = widget.description;
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) => _buildHero(
        palette,
        dayIndex,
        eyebrow,
        title,
        description,
      ),
    );
  }

  Widget _buildHero(
    _HomePalette palette,
    int dayIndex,
    String eyebrow,
    String title,
    String description,
  ) {
    final motion = Curves.easeInOutSine.transform(_motion.value);
    final drift = (motion - 0.5) * 2;
    final decoration = switch (palette.visualTheme) {
      AppVisualTheme.minimalism => BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1 + drift * 0.52, -1 + drift * 0.22),
            end: Alignment(1 - drift * 0.22, 1 - drift * 0.38),
            colors: [
              palette.surface,
              Color.alphaBlend(
                palette.artTwo.withValues(alpha: 0.57 + motion * 0.24),
                palette.surface,
              ),
              Color.alphaBlend(
                palette.artOne.withValues(alpha: 0.28 + motion * 0.28),
                palette.surface,
              ),
            ],
            stops: [0.0, 0.44 + motion * 0.22, 1.0],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18252635),
              blurRadius: 34,
              offset: Offset(0, 16),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(
        28,
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
              right: -18,
              top: -22,
              child: ExcludeSemantics(
                child: _SoftSpectrumHeroOrnament(
                  palette: palette,
                  dayIndex: dayIndex,
                  progress: motion,
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
                        AppVisualTheme.minimalism => 46,
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
                        AppVisualTheme.minimalism => -2.2,
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

class _SoftSpectrumHeroOrnament extends StatelessWidget {
  const _SoftSpectrumHeroOrnament({
    required this.palette,
    required this.dayIndex,
    required this.progress,
  });

  final _HomePalette palette;
  final int dayIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 168,
      child: Stack(
        children: [
          Positioned(
            right: 26,
            top: 0,
            child: Transform.translate(
              offset: Offset(-19 * progress, 17 * (1 - progress)),
              child: Transform.rotate(
                angle: -0.17 + progress * 0.20,
                child: Container(
                  width: 170,
                  height: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.accent.withValues(alpha: 0.48),
                        palette.artTwo.withValues(alpha: 0.16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(19 * (1 - progress), -18 * progress),
              child: Transform.rotate(
                angle: 0.11 - progress * 0.21,
                child: Container(
                  width: 146,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.artOne.withValues(alpha: 0.52),
                        palette.artOne.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 72,
            top: 50,
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.88),
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.ink.withValues(alpha: 0.16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x17252635),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'D/${dayIndex.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
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
          palette.visualTheme == AppVisualTheme.glass ||
                  palette.visualTheme == AppVisualTheme.minimalism
              ? 14
              : 0,
        ),
      ),
    );
  }
}

class _HomePlanTabs extends StatefulWidget {
  const _HomePlanTabs({
    required this.palette,
    required this.plan,
    required this.annualOverview,
    required this.isChinese,
    required this.isBusy,
    required this.density,
    required this.onEdit,
    required this.onToggle,
    required this.onLoadAnnual,
    required this.onOpenAnnualBoard,
  });

  final _HomePalette palette;
  final TodayPlan plan;
  final AnnualPlanOverview annualOverview;
  final bool isChinese;
  final bool isBusy;
  final ComponentPresentationDensity density;
  final Future<void> Function() onEdit;
  final Future<void> Function(int index, bool completed) onToggle;
  final Future<void> Function() onLoadAnnual;
  final Future<void> Function() onOpenAnnualBoard;

  @override
  State<_HomePlanTabs> createState() => _HomePlanTabsState();
}

class _HomePlanTabsState extends State<_HomePlanTabs> {
  bool _showAnnualMonth = false;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  void _select(bool annual) {
    if (_showAnnualMonth == annual) return;
    setState(() => _showAnnualMonth = annual);
    if (annual) unawaited(widget.onLoadAnnual());
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final now = DateTime.now();
    final segments = widget.annualOverview.year == now.year
        ? widget.annualOverview.segments
            .where(
              (segment) =>
                  now.month >= segment.startMonth &&
                  now.month <= segment.endMonth,
            )
            .toList()
        : <AnnualPlanSegment>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          palette: palette,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final annual in [false, true])
                OutlinedButton(
                  key: ValueKey(annual
                      ? 'home-plan-tab-annual-month'
                      : 'home-plan-tab-today'),
                  onPressed: () => _select(annual),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _showAnnualMonth == annual
                        ? palette.accentSoft
                        : palette.surface,
                    foregroundColor: _showAnnualMonth == annual
                        ? palette.accent
                        : palette.ink,
                    side: BorderSide(
                      color: _showAnnualMonth == annual
                          ? palette.accent
                          : palette.rule,
                    ),
                  ),
                  child: Text(annual
                      ? _text('本月超长任务', 'Annual this month')
                      : _text('今日计划', 'Today plan')),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (!_showAnnualMonth)
          _PlanPanel(
            palette: palette,
            plan: widget.plan,
            isChinese: widget.isChinese,
            isBusy: widget.isBusy,
            density: widget.density,
            onEdit: widget.onEdit,
            onToggle: widget.onToggle,
          )
        else
          _Panel(
            palette: palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(
                  palette: palette,
                  title: _text('本月超长任务', 'Annual tasks this month'),
                  subtitle: _text(
                    '${now.month} 月 · ${segments.length} 项',
                    'Month ${now.month} · ${segments.length} tasks',
                  ),
                  actionLabel: _text('打开面板', 'Open board'),
                  onAction: widget.onOpenAnnualBoard,
                ),
                const SizedBox(height: 12),
                if (segments.isEmpty)
                  _EmptyMessage(
                    palette: palette,
                    icon: Icons.calendar_view_month_outlined,
                    message: _text('本月没有超长任务。', 'No annual tasks this month.'),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final segment in segments)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 11),
                              child: InkWell(
                                onTap: () =>
                                    unawaited(widget.onOpenAnnualBoard()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            segment.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: palette.ink,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${segment.progressPercent}%',
                                          style: TextStyle(
                                            color: palette.accent,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    _ChargingMonthSpan(
                                      key: ValueKey(
                                          'annual-charge-${segment.id}-${segment.clientEntityId}'),
                                      palette: palette,
                                      color: _annualColor(segment.colorKey),
                                      startMonth: segment.startMonth,
                                      endMonth: segment.endMonth,
                                      progressPercent: segment.progressPercent,
                                    ),
                                  ],
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
      ],
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
            const SizedBox(height: 18),
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
                    palette.visualTheme == AppVisualTheme.glass ||
                            palette.visualTheme == AppVisualTheme.minimalism
                        ? 14
                        : 0,
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
    final softSpectrum =
        widget.palette.visualTheme == AppVisualTheme.minimalism;
    final lift = _hovered && !reduceMotion
        ? glass
            ? -5.0
            : mid
                ? -3.0
                : softSpectrum
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
    final softSpectrum = palette.visualTheme == AppVisualTheme.minimalism;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: glass ? const Color(0x32101D3B) : palette.surface,
        borderRadius: BorderRadius.circular(
          glass
              ? 12
              : softSpectrum
                  ? 16
                  : 0,
        ),
        border: glass
            ? Border.all(color: const Color(0x42FFFFFF))
            : softSpectrum
                ? Border.all(color: palette.rule)
                : null,
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
    required this.artOne,
    required this.artTwo,
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
  final Color artOne;
  final Color artTwo;
  final Color onInk;
  final Color onInkMuted;
  final AppVisualTheme visualTheme;

  BoxDecoration panelDecoration({
    required bool emphasized,
    bool hovered = false,
  }) {
    return switch (visualTheme) {
      AppVisualTheme.minimalism => BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: emphasized
                ? [
                    surface,
                    Color.alphaBlend(
                      artTwo.withValues(alpha: hovered ? 0.52 : 0.34),
                      surface,
                    ),
                  ]
                : [
                    surface,
                    Color.alphaBlend(
                      artOne.withValues(alpha: hovered ? 0.16 : 0.08),
                      surface,
                    ),
                  ],
          ),
          borderRadius: BorderRadius.circular(emphasized ? 22 : 18),
          border: Border.all(
            color: hovered
                ? accent.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.80),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF252635)
                  .withValues(alpha: hovered ? 0.12 : 0.065),
              blurRadius: hovered ? 32 : 22,
              offset: Offset(0, hovered ? 14 : 9),
            ),
          ],
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
      artOne: tokens.artOne,
      artTwo: tokens.artTwo,
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
    if (visualTheme == AppVisualTheme.minimalism) {
      return child;
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
    if (visualTheme == AppVisualTheme.midCentury) {
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
