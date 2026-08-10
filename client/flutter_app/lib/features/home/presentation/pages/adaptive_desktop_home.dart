import 'dart:async';

import 'package:flutter/material.dart';

import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/core/layout/desktop_presentation.dart';
import 'package:innocence_flutter/core/platform/desktop_widget_bridge.dart';
import 'package:innocence_flutter/core/widgets/adaptive_canvas_shell.dart';
import 'package:innocence_flutter/core/widgets/desktop_drag_region.dart';
import 'package:innocence_flutter/core/widgets/status_banner.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

class AdaptiveDesktopHome extends StatefulWidget {
  const AdaptiveDesktopHome({
    super.key,
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

  bool get _isChinese => widget.appLanguage.isChinese;

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    DesktopWidgetBridge.setWindowModeListener(_handleWindowModeChanged);
  }

  @override
  void dispose() {
    DesktopWidgetBridge.setWindowModeListener(null);
    super.dispose();
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
      await widget.onFinishFocus();
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
        return _text('一次只做好眼前这一件事', 'Give the current task your full attention');
      case 'companions':
        return _text('与可信的人一起保持节奏', 'Stay in rhythm with people you trust');
      case 'inbox':
        return _text('消息、提醒与通知集中处理', 'Messages, reminders and notices in one place');
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
          isChinese: _isChinese,
          isBusy: widget.isBusy,
          onRestore: _restoreCanvas,
          onAction: _handleOrbAction,
        ),
      );
    }

    return AdaptiveCanvasShell(
      destinations: _destinations,
      selectedDestinationId: _selectedDestinationId,
      onDestinationSelected: _selectDestination,
      pageTitle: _pageTitle,
      pageSubtitle: _pageSubtitle,
      userDisplayName: widget.profile.displayName,
      syncLabel: _text('状态已连接', 'Connected'),
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
    final palette = _HomePalette.of(context);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.home'),
      spec: spec,
      palette: palette,
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
          eyebrow: _text('INNOCENCE · DAILY CANVAS', 'INNOCENCE · DAILY CANVAS'),
          title: widget.focusSession.active
              ? _text('此刻，保持专注。', 'Stay with this moment.')
              : _text('今天，从一件事开始。', 'Begin today with one thing.'),
          description: widget.focusSession.active
              ? (widget.focusSession.taskName.trim().isEmpty
                  ? _text('当前学习状态正在双端同步。',
                      'Your current focus state is syncing across devices.')
                  : widget.focusSession.taskName)
              : _text('计划、专注、签到与陪伴都在同一条节奏里。',
                  'Plans, focus, check-in and companionship share one rhythm.'),
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
              note: _text('今日 ${widget.todayPlan.completedCount}/${widget.todayPlan.totalCount}',
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
    final palette = _HomePalette.of(context);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.plans'),
      spec: spec,
      palette: palette,
      children: [
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
        const SizedBox(height: 20),
        _SummaryPanel(
          palette: palette,
          title: _text('计划层级', 'Planning horizons'),
          lines: [
            _SummaryLine(
              icon: Icons.today_outlined,
              title: _text('短计划', 'Daily plan'),
              detail: _text('以半小时为单位安排今天', 'Arrange today in 30-minute blocks'),
            ),
            _SummaryLine(
              icon: Icons.date_range_outlined,
              title: _text('长计划', 'Weekly plan'),
              detail: _text('组织一周并复用日计划模板', 'Organize a week and reuse daily templates'),
            ),
            _SummaryLine(
              icon: Icons.route_outlined,
              title: _text('超长计划', 'Long-term plan'),
              detail: _text('按天推进更长期的目标', 'Move longer goals forward day by day'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusPage(DesktopPresentationSpec spec) {
    final palette = _HomePalette.of(context);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.focus'),
      spec: spec,
      palette: palette,
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
        ),
        const SizedBox(height: 20),
        _MetricGrid(
          spec: spec,
          palette: palette,
          metrics: [
            _MetricData(
              label: _text('本次已进行', 'Elapsed'),
              value: widget.focusSession.elapsedLabel,
              note: _text('状态持续同步', 'State stays synchronized'),
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
    final palette = _HomePalette.of(context);
    final teammates = widget.teamOverview.members
        .where((member) => member.userId != widget.profile.userId)
        .take(spec.tier == DesktopPresentationTier.small ? 3 : 5)
        .toList();
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.companions'),
      spec: spec,
      palette: palette,
      children: [
        _ResponsivePair(
          spec: spec,
          primaryFlex: 5,
          secondaryFlex: 5,
          primary: _ActionPanel(
            palette: palette,
            icon: Icons.people_outline_rounded,
            title: _text('好友', 'Friends'),
            value: '${widget.friendOverview.friendCount}/${widget.friendOverview.maxFriendCount}',
            description: widget.friendOverview.incomingRequests.isEmpty
                ? _text('熟人关系保持轻量、清晰和可控。',
                    'Keep trusted relationships light and clear.')
                : _text('${widget.friendOverview.incomingRequests.length} 个申请待处理',
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
    final palette = _HomePalette.of(context);
    final notifications = widget.notificationOverview.previewItems;
    final latestTeamMessage = widget.teamChatOverview.latestMessage;
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.inbox'),
      spec: spec,
      palette: palette,
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
                  subtitle: _text('${widget.notificationOverview.unreadCount} 条未读',
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
    final palette = _HomePalette.of(context);
    return _PageCanvas(
      pageKey: const PageStorageKey<String>('desktop.stats'),
      spec: spec,
      palette: palette,
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
    required this.isChinese,
    required this.isBusy,
    required this.onRestore,
    required this.onAction,
  });

  final FocusSession session;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onRestore;
  final Future<void> Function() onAction;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark
        ? const Color(0xFF24221F)
        : const Color(0xFFF4EEE3);
    final ink = dark ? const Color(0xFFF2EBDD) : const Color(0xFF272420);
    final muted = dark ? const Color(0xFFB8AFA1) : const Color(0xFF726B62);
    final rule = dark ? const Color(0xFF4A453E) : const Color(0xFFBFB5A7);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          const Positioned.fill(child: DesktopDragRegion()),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: DesktopDragRegion(
                            child: _OrbActionButton(
                              tooltip:
                                  _text('拖动或返回画布', 'Drag or restore canvas'),
                              icon: Icons.open_in_full_rounded,
                              color: ink,
                              borderColor: rule,
                              onPressed: () => unawaited(onRestore()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        SizedBox(
                          width: 40,
                          child: _OrbActionButton(
                            tooltip: _text('关闭', 'Close'),
                            icon: Icons.close_rounded,
                            color: muted,
                            borderColor: rule,
                            onPressed: () =>
                                unawaited(DesktopWidgetBridge.closeWindow()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : () => unawaited(onAction()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ink,
                        side: BorderSide(color: rule),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(),
                      ),
                      icon: Icon(
                        session.active
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: 14,
                      ),
                      label: Text(
                        session.active
                            ? session.remainingLabel
                            : _text('开始', 'Start'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbActionButton extends StatelessWidget {
  const _OrbActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
        ),
      ),
    );
  }
}

class _PageCanvas extends StatelessWidget {
  const _PageCanvas({
    required this.pageKey,
    required this.spec,
    required this.palette,
    required this.children,
  });

  final PageStorageKey<String> pageKey;
  final DesktopPresentationSpec spec;
  final _HomePalette palette;
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

    return ColoredBox(
      color: palette.background,
      child: SingleChildScrollView(
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
      ),
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
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final _HomePalette palette;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
      color: palette.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              color: palette.accentSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              color: palette.onInk,
              fontSize: 32,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: palette.onInkMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.palette,
    required this.session,
    required this.isChinese,
    required this.isBusy,
    required this.onAction,
    this.expanded = false,
  });

  final _HomePalette palette;
  final FocusSession session;
  final bool isChinese;
  final bool isBusy;
  final Future<void> Function() onAction;
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
                ? _text('结束于 ${session.endTimeLabel}', 'Ends at ${session.endTimeLabel}')
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isBusy ? null : () => unawaited(onAction()),
              icon: Icon(
                session.active ? Icons.stop_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                session.active
                    ? _text('结束本次专注', 'Finish focus')
                    : _text('开始专注', 'Start focus'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: palette.ink,
                foregroundColor: palette.onInk,
                minimumSize: const Size.fromHeight(48),
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),
        ],
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
      ComponentPresentationDensity.glance => 4,
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
                onChanged: (completed) =>
                    onToggle(entry.key, completed),
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
            onPressed: isBusy || status.checkedInToday || !status.canCheckInToday
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
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(18),
      color: palette.surfaceStrong,
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
    required this.actionLabel,
    required this.onAction,
  });

  final _HomePalette palette;
  final String title;
  final String description;
  final String actionLabel;
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
          FilledButton(
            onPressed:
                onAction == null ? null : () => unawaited(onAction!()),
            style: FilledButton.styleFrom(
              backgroundColor: palette.ink,
              foregroundColor: palette.onInk,
              shape: const RoundedRectangleBorder(),
              minimumSize: const Size(160, 46),
            ),
            child: Text(actionLabel),
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: emphasized ? palette.surfaceStrong : palette.surface,
        border: Border.all(
          color: emphasized ? palette.ink : palette.rule,
          width: emphasized ? 1.2 : 1,
        ),
      ),
      child: child,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      color: palette.background,
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

  static _HomePalette of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const _HomePalette(
        background: Color(0xFF1B1A18),
        surface: Color(0xFF292724),
        surfaceStrong: Color(0xFF332F2A),
        ink: Color(0xFFF2EBDD),
        muted: Color(0xFFB8AFA1),
        rule: Color(0xFF4A453E),
        accent: Color(0xFFD27A5E),
        accentSoft: Color(0xFF554038),
        onInk: Color(0xFF24211E),
        onInkMuted: Color(0xFF655F57),
      );
    }
    return const _HomePalette(
      background: Color(0xFFE8E2D7),
      surface: Color(0xFFF8F3EA),
      surfaceStrong: Color(0xFFDDD3C5),
      ink: Color(0xFF272420),
      muted: Color(0xFF726B62),
      rule: Color(0xFFBFB5A7),
      accent: Color(0xFFB9573F),
      accentSoft: Color(0xFFE3B9A9),
      onInk: Color(0xFFF7F0E4),
      onInkMuted: Color(0xFFD2C7B8),
    );
  }
}
