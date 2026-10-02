import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/widgets/citrus_white_hero.dart';
import 'package:innocence_flutter/core/widgets/glass_motion_backdrop.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/soft_spectrum_backdrop.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/home/domain/theme_daily_slogan.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

enum AndroidHomeDestination { home, plans, focus, companion, inbox }

/// The Android navigation layer. Detailed feature pages are rebuilt separately.
class AndroidHomeShell extends StatefulWidget {
  const AndroidHomeShell({
    super.key,
    required this.language,
    required this.profile,
    required this.todayPlan,
    required this.focusSession,
    required this.checkInStatus,
    required this.teamOverview,
    required this.friendOverview,
    required this.notificationOverview,
    required this.isOfflineMode,
    required this.isBusy,
    required this.bannerMessage,
    required this.onClearBanner,
    required this.onRefresh,
    required this.onLogout,
    required this.onOpenPlanEditor,
    required this.onToggleTodayPlanItem,
    required this.onStartFocus,
    required this.onToggleFocusPause,
    required this.onFinishFocus,
    required this.onSubmitCheckIn,
    required this.onOpenFriends,
    required this.onOpenTeam,
    required this.onOpenNotifications,
    required this.onOpenMemos,
    required this.onOpenStats,
    required this.onOpenSettings,
  });

  final AppLanguage language;
  final UserProfile profile;
  final TodayPlan todayPlan;
  final FocusSession focusSession;
  final CheckInStatus checkInStatus;
  final TeamOverview teamOverview;
  final FriendOverview friendOverview;
  final NotificationOverview notificationOverview;
  final bool isOfflineMode;
  final bool isBusy;
  final String? bannerMessage;
  final VoidCallback onClearBanner;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenPlanEditor;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final Future<void> Function() onStartFocus;
  final Future<void> Function() onToggleFocusPause;
  final Future<void> Function() onFinishFocus;
  final Future<void> Function() onSubmitCheckIn;
  final Future<void> Function() onOpenFriends;
  final Future<void> Function() onOpenTeam;
  final Future<void> Function() onOpenNotifications;
  final Future<void> Function() onOpenMemos;
  final Future<void> Function() onOpenStats;
  final Future<void> Function() onOpenSettings;

  @override
  State<AndroidHomeShell> createState() => _AndroidHomeShellState();
}

class _AndroidHomeShellState extends State<AndroidHomeShell>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AndroidHomeDestination _destination = AndroidHomeDestination.home;
  bool _drawerOpen = false;
  Timer? _sloganRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleSloganRefresh();
  }

  void _scheduleSloganRefresh() {
    _sloganRefreshTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _sloganRefreshTimer = Timer(midnight.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleSloganRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _scheduleSloganRefresh();
    } else {
      _sloganRefreshTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _sloganRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool get _zh => widget.language.isChinese;

  AppVisualTheme get _visualTheme =>
      Theme.of(context).extension<AppVisualThemeMarker>()?.visualTheme ??
      AppVisualTheme.minimalism;

  String _text(String zh, String en) => _zh ? zh : en;

  String _destinationLabel(AndroidHomeDestination destination) {
    switch (destination) {
      case AndroidHomeDestination.home:
        return _text('首页', 'Home');
      case AndroidHomeDestination.plans:
        return _text('计划', 'Plans');
      case AndroidHomeDestination.focus:
        return _text('专注', 'Focus');
      case AndroidHomeDestination.companion:
        return _text('陪伴', 'Companion');
      case AndroidHomeDestination.inbox:
        return _text('收件箱', 'Inbox');
    }
  }

  void _select(AndroidHomeDestination destination) {
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _destination = destination);
  }

  Future<void> _openSecondary(Future<void> Function() open) async {
    _scaffoldKey.currentState?.closeDrawer();
    await open();
  }

  Color _drawerForeground(bool active) {
    if (_visualTheme == AppVisualTheme.minimalism && active) {
      return Colors.white;
    }
    final colors = Theme.of(context).colorScheme;
    return active ? colors.onSurface : colors.onSurface.withValues(alpha: .72);
  }

  Widget _drawerIcon(IconData icon, {bool selected = false}) {
    final foreground = _drawerForeground(selected);
    if ((icon == Icons.inbox_outlined || icon == Icons.inbox_rounded) &&
        widget.notificationOverview.unreadCount > 0 &&
        !widget.isOfflineMode) {
      final count = widget.notificationOverview.unreadCount;
      return Badge(
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(selected ? Icons.inbox_rounded : icon, color: foreground),
      );
    }
    return Icon(icon, color: foreground);
  }

  NavigationDrawerDestination _drawerDestination(
    AndroidHomeDestination destination,
    IconData icon,
    IconData selectedIcon,
  ) {
    return NavigationDrawerDestination(
      icon: _drawerIcon(icon),
      selectedIcon: _drawerIcon(selectedIcon, selected: true),
      label: Text(
        _destinationLabel(destination),
        style: TextStyle(
          color: _drawerForeground(_destination == destination),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return NavigationDrawer(
      backgroundColor: switch (_visualTheme) {
        AppVisualTheme.glass => const Color(0x99000000),
        AppVisualTheme.minimalism => const Color(0xEAF9F8F5),
        _ => null,
      },
      selectedIndex: _destination.index,
      onDestinationSelected: (index) =>
          _select(AndroidHomeDestination.values[index]),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Innocence', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.isOfflineMode
                  ? _text('仅本机资料', 'On-device profile')
                  : widget.profile.displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      children: [
        _drawerDestination(AndroidHomeDestination.home, Icons.home_outlined,
            Icons.home_rounded),
        _drawerDestination(AndroidHomeDestination.plans,
            Icons.calendar_month_outlined, Icons.calendar_month_rounded),
        _drawerDestination(AndroidHomeDestination.focus, Icons.timer_outlined,
            Icons.timer_rounded),
        _drawerDestination(AndroidHomeDestination.companion,
            Icons.groups_outlined, Icons.groups_rounded),
        _drawerDestination(AndroidHomeDestination.inbox, Icons.inbox_outlined,
            Icons.inbox_rounded),
        const Divider(indent: 28, endIndent: 28),
        ListTile(
          leading: const Icon(Icons.query_stats_outlined),
          title: Text(_text('统计', 'Statistics')),
          onTap: () => _openSecondary(widget.onOpenStats),
        ),
        ListTile(
          leading: const Icon(Icons.sticky_note_2_outlined),
          title: Text(_text('备忘录', 'Memos')),
          onTap: () => _openSecondary(widget.onOpenMemos),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(_text('设置', 'Settings')),
          onTap: () => _openSecondary(widget.onOpenSettings),
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: Text(_text('退出', 'Sign out')),
          onTap: widget.isBusy ? null : () => _openSecondary(widget.onLogout),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required String body,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? extra,
    bool frosted = false,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              if (_visualTheme == AppVisualTheme.minimalism)
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: const Color(0xFFAF511B)),
                )
              else
                Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
        if (extra != null) ...[const SizedBox(height: 14), extra],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ],
    );
    return _themedCard(content,
        padding: const EdgeInsets.all(20), frosted: frosted);
  }

  Widget _themedCard(Widget content,
      {Key? key, EdgeInsets padding = EdgeInsets.zero, bool frosted = false}) {
    if (_visualTheme == AppVisualTheme.glass ||
        _visualTheme == AppVisualTheme.minimalism) {
      return Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassPanel(
          frosted: frosted,
          padding: padding,
          child: Material(type: MaterialType.transparency, child: content),
        ),
      );
    }
    return Card(
      key: key,
      child: Padding(padding: padding, child: content),
    );
  }

  List<Widget> _homeContent() {
    final plan = widget.todayPlan;
    final focus = widget.focusSession;
    final checkIn = widget.checkInStatus;
    final slogan = ThemeDailySlogans.resolve(
      theme: _visualTheme,
      localDate: DateTime.now(),
    );
    return [
      if (_visualTheme == AppVisualTheme.minimalism)
        _citrusWelcome()
      else ...[
        Text(
          _text('你好，${widget.profile.displayName}',
              'Hello, ${widget.profile.displayName}'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isOfflineMode
              ? _text('本机资料 · 数据尚未绑定账号',
                  'On-device profile · data is not linked to an account')
              : _text('今天从一个清晰的步骤开始。', 'Start today with one clear next step.'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
      const SizedBox(height: 20),
      _themedCard(
        key: const ValueKey('android-daily-slogan'),
        frosted: true,
        padding: const EdgeInsets.all(20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_text('每日标语', 'Daily inspiration'),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 10),
            Text(slogan.title(isChinese: _zh),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(slogan.subtitle(isChinese: _zh),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
      _sectionCard(
        title: _text('今日计划', 'Today’s plan'),
        body: _text('已完成 ${plan.completedCount}/${plan.totalCount} 项',
            '${plan.completedCount} of ${plan.totalCount} complete'),
        icon: Icons.calendar_today_outlined,
        extra: LinearProgressIndicator(value: plan.completionRatio.clamp(0, 1)),
        actionLabel: _text('查看计划', 'View plans'),
        onAction: () => _select(AndroidHomeDestination.plans),
      ),
      _sectionCard(
        title: _text('专注', 'Focus'),
        frosted: true,
        body: focus.active
            ? _text('剩余 ${focus.remainingLabel}${focus.paused ? ' · 已暂停' : ''}',
                '${focus.remainingLabel} remaining${focus.paused ? ' · paused' : ''}')
            : _text('当前没有进行中的专注', 'No active focus session'),
        icon: Icons.timer_outlined,
        actionLabel: _text('进入专注', 'Open focus'),
        onAction: () => _select(AndroidHomeDestination.focus),
      ),
      _sectionCard(
        title: _text('签到', 'Check-in'),
        frosted: true,
        body: checkIn.checkedInToday
            ? _text('今日已签到', 'Checked in today')
            : checkIn.canCheckInToday
                ? _text('今日计划已完成，可以签到',
                    'Today’s plan is complete. You can check in.')
                : _text(
                    '完成今日计划后再签到', 'Complete today’s plan before checking in.'),
        icon: Icons.verified_outlined,
        actionLabel: checkIn.canCheckInToday && !checkIn.checkedInToday
            ? _text('签到', 'Check in')
            : null,
        onAction: checkIn.canCheckInToday && !widget.isBusy
            ? () => widget.onSubmitCheckIn()
            : null,
      ),
      if (!widget.isOfflineMode)
        _sectionCard(
          title: _text('收件箱', 'Inbox'),
          frosted: true,
          body: _text('未读 ${widget.notificationOverview.unreadCount} 条',
              '${widget.notificationOverview.unreadCount} unread'),
          icon: Icons.inbox_outlined,
          actionLabel: _text('查看消息', 'View messages'),
          onAction: () => _select(AndroidHomeDestination.inbox),
        ),
    ];
  }

  Widget _citrusWelcome() {
    final now = DateTime.now();
    return CitrusWhiteHero(
      eyebrow: _text('TODAY / 今日', 'TODAY'),
      title: _text('你好，${widget.profile.displayName}',
          'Hello, ${widget.profile.displayName}'),
      description: widget.isOfflineMode
          ? _text('本机资料 · 尚未绑定账号', 'On-device profile')
          : _text('从一个清晰的步骤开始', 'Begin with one clear step'),
      indexLabel:
          '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}',
      titleSize: 28,
    );
  }

  List<Widget> _plansContent() {
    final plan = widget.todayPlan;
    return [
      Text(_text('今日计划', 'Today’s plan'),
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(plan.planDate, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: widget.isBusy ? null : widget.onOpenPlanEditor,
        icon: const Icon(Icons.edit_calendar_outlined),
        label: Text(_text('编辑今日计划', 'Edit today’s plan')),
      ),
      const SizedBox(height: 16),
      if (plan.items.isEmpty)
        _sectionCard(
          title: _text('还没有今日任务', 'No tasks for today'),
          body: _text('从今日计划编辑器安排第一个学习时段。',
              'Use the plan editor to schedule your first study block.'),
          icon: Icons.event_note_outlined,
        )
      else
        for (final entry in plan.items.asMap().entries)
          _themedCard(
            CheckboxListTile(
              value: entry.value.completed,
              onChanged: widget.isBusy
                  ? null
                  : (value) =>
                      widget.onToggleTodayPlanItem(entry.key, value ?? false),
              title: Text(entry.value.title),
              subtitle: Text(entry.value.hasSchedule
                  ? entry.value.scheduleLabel
                  : _text('弹性任务', 'Flexible task')),
            ),
          ),
      const SizedBox(height: 8),
      Text(
        _text('月计划和年度任务的独立手机页面仍在重建。',
            'Dedicated mobile month and year views are still being rebuilt.'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> _focusContent() {
    final focus = widget.focusSession;
    final checkIn = widget.checkInStatus;
    return [
      Text(_text('专注时段', 'Focus session'),
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      _sectionCard(
        title: focus.active
            ? (focus.taskName.isEmpty
                ? _text('进行中', 'In progress')
                : focus.taskName)
            : _text('准备开始', 'Ready to focus'),
        body: focus.active
            ? _text('剩余 ${focus.remainingLabel}${focus.paused ? ' · 已暂停' : ''}',
                '${focus.remainingLabel} remaining${focus.paused ? ' · paused' : ''}')
            : _text('选择结束时间，开始一个专注时段。',
                'Choose an end time to start a focus session.'),
        icon: Icons.timer_outlined,
        extra: focus.active
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: widget.isBusy ? null : widget.onToggleFocusPause,
                    child: Text(focus.paused
                        ? _text('继续', 'Resume')
                        : _text('暂停', 'Pause')),
                  ),
                  OutlinedButton(
                    onPressed: widget.isBusy ? null : widget.onFinishFocus,
                    child: Text(_text('结束', 'Finish')),
                  ),
                ],
              )
            : FilledButton(
                onPressed: widget.isBusy ? null : widget.onStartFocus,
                child: Text(_text('开始专注', 'Start focus')),
              ),
      ),
      _sectionCard(
        title: _text('今日签到', 'Today’s check-in'),
        body: checkIn.checkedInToday
            ? _text('已经完成', 'Completed')
            : checkIn.canCheckInToday
                ? _text('可以签到', 'Ready to check in')
                : _text('尚未满足签到条件', 'Not ready to check in'),
        icon: Icons.verified_outlined,
        extra: checkIn.canCheckInToday && !checkIn.checkedInToday
            ? FilledButton.tonal(
                onPressed: widget.isBusy ? null : widget.onSubmitCheckIn,
                child: Text(_text('提交签到', 'Submit check-in')),
              )
            : null,
      ),
    ];
  }

  List<Widget> _companionContent() {
    if (widget.isOfflineMode) {
      return [
        _sectionCard(
          title: AppConfig.offlineOnlyBuild
              ? _text('联网功能后续接入', 'Online features are coming later')
              : _text('需要登录', 'Sign-in required'),
          body: AppConfig.offlineOnlyBuild
              ? _text('当前版本使用本机资料。好友和团队将在后续版本接入。',
                  'This edition uses on-device data. Friends and teams will be added in a future version.')
              : _text('好友和团队数据仅在登录后可用；本机计划不会上传。',
                  'Friends and teams require sign-in. On-device plans are not uploaded.'),
          icon: Icons.lock_outline_rounded,
        ),
      ];
    }
    return [
      _sectionCard(
        title: _text('好友', 'Friends'),
        body: _text('当前 ${widget.friendOverview.friendCount} 位好友',
            '${widget.friendOverview.friendCount} friends'),
        icon: Icons.people_outline_rounded,
        actionLabel: _text('打开好友', 'Open friends'),
        onAction: () => widget.onOpenFriends(),
      ),
      _sectionCard(
        title: _text('团队', 'Team'),
        body: widget.teamOverview.inTeam
            ? '${widget.teamOverview.teamName} · ${widget.teamOverview.memberCount}/${widget.teamOverview.memberLimit}'
            : _text('尚未加入团队', 'Not in a team yet'),
        icon: Icons.groups_outlined,
        actionLabel: _text('打开团队', 'Open team'),
        onAction: () => widget.onOpenTeam(),
      ),
    ];
  }

  List<Widget> _inboxContent() {
    if (widget.isOfflineMode) {
      return [
        _sectionCard(
          title: AppConfig.offlineOnlyBuild
              ? _text('联网功能后续接入', 'Online features are coming later')
              : _text('需要登录', 'Sign-in required'),
          body: AppConfig.offlineOnlyBuild
              ? _text('通知和消息将在后续版本接入。当前本机数据不会上传。',
                  'Notifications and messages will be added in a future version. Current on-device data is not uploaded.')
              : _text('收件箱需要账号和网络连接。',
                  'Inbox requires an account and network connection.'),
          icon: Icons.lock_outline_rounded,
        ),
      ];
    }
    final notifications = widget.notificationOverview;
    return [
      _sectionCard(
        title: _text('消息与通知', 'Messages and notifications'),
        body: _text('未读 ${notifications.unreadCount} 条',
            '${notifications.unreadCount} unread'),
        icon: Icons.inbox_outlined,
        actionLabel: _text('打开通知中心', 'Open notification center'),
        onAction: () => widget.onOpenNotifications(),
      ),
      if (notifications.items.isEmpty)
        _sectionCard(
          title: _text('暂无消息', 'No messages yet'),
          body: _text('新通知到达后会显示在这里。', 'New notifications will appear here.'),
          icon: Icons.mark_email_read_outlined,
        )
      else
        for (final item in notifications.previewItems)
          _themedCard(
            ListTile(
              leading: Icon(item.read
                  ? Icons.mark_email_read_outlined
                  : Icons.mark_email_unread_outlined),
              title: Text(item.title),
              subtitle: Text(item.content, maxLines: 2),
              onTap: widget.onOpenNotifications,
            ),
          ),
    ];
  }

  List<Widget> _destinationContent() {
    switch (_destination) {
      case AndroidHomeDestination.home:
        return _homeContent();
      case AndroidHomeDestination.plans:
        return _plansContent();
      case AndroidHomeDestination.focus:
        return _focusContent();
      case AndroidHomeDestination.companion:
        return _companionContent();
      case AndroidHomeDestination.inbox:
        return _inboxContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visualTheme = _visualTheme;
    final themed = visualTheme == AppVisualTheme.glass ||
        visualTheme == AppVisualTheme.minimalism;
    final shell = PopScope(
      canPop: _drawerOpen || _destination == AndroidHomeDestination.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _destination != AndroidHomeDestination.home) {
          setState(() => _destination = AndroidHomeDestination.home);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: themed ? Colors.transparent : null,
        drawerEnableOpenDragGesture: false,
        onDrawerChanged: (open) {
          if (mounted) setState(() => _drawerOpen = open);
        },
        drawer: visualTheme == AppVisualTheme.glass
            ? ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: _buildDrawer(),
                ),
              )
            : _buildDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: themed ? Colors.transparent : null,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            key: const ValueKey('android-more-navigation'),
            tooltip: _text('打开功能侧边栏', 'Open navigation drawer'),
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(_destinationLabel(_destination)),
          actions: [
            IconButton(
              tooltip: _text('刷新', 'Refresh'),
              icon: widget.isBusy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              onPressed: widget.isBusy ? null : widget.onRefresh,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                key: ValueKey('android-${_destination.name}-content'),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  if (widget.bannerMessage != null) ...[
                    _themedCard(
                      ListTile(
                        title: Text(widget.bannerMessage!),
                        trailing: IconButton(
                          tooltip: _text('关闭提示', 'Dismiss notice'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: widget.onClearBanner,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ..._destinationContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return switch (visualTheme) {
      AppVisualTheme.glass => GlassMotionBackdrop(child: shell),
      AppVisualTheme.minimalism => SoftSpectrumBackdrop(child: shell),
      _ => shell,
    };
  }
}
