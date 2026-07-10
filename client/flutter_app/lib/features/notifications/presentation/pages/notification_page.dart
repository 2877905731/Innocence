import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.initialOverview,
    required this.onLoadNotifications,
    required this.onMarkNotificationRead,
    required this.onMarkAllNotificationsRead,
    required this.onRespondFriendRequest,
    required this.onRespondTeamInvitation,
  });

  final NotificationOverview initialOverview;
  final Future<NotificationOverview?> Function({int limit}) onLoadNotifications;
  final Future<NotificationOverview?> Function(int notificationId)
      onMarkNotificationRead;
  final Future<NotificationOverview?> Function() onMarkAllNotificationsRead;
  final Future<NotificationOverview?> Function(
    int requestId, {
    required bool accept,
  }) onRespondFriendRequest;
  final Future<NotificationOverview?> Function(
    int invitationId, {
    required bool accept,
  }) onRespondTeamInvitation;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationOverview _overview;
  bool _isLoading = false;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  String _notificationTypeLabel(AppNotificationItem item) {
    switch (item.notificationType) {
      case 'friend_request':
        return _text('好友申请', 'Friend request');
      case 'team_invitation':
        return _text('团队邀请', 'Team invitation');
      case 'team_reminder':
        return _text('队友提醒', 'Teammate reminder');
      case 'teammate_completion':
        return _text('队友完成通知', 'Teammate finished');
      case 'plan_completion':
        return _text('计划完成通知', 'Plan completed');
      case 'check_in_success':
        return _text('签到成功', 'Check-in success');
      case 'check_in_failure':
        return _text('签到待完成', 'Check-in pending');
      case 'system_announcement':
        return _text('系统公告', 'System announcement');
      default:
        return _text('通知', 'Notification');
    }
  }

  String _senderDisplayName(AppNotificationItem item) {
    if (item.senderNickname.trim().isNotEmpty) {
      return item.senderNickname.trim();
    }
    if (item.senderUserNo.trim().isNotEmpty) {
      return item.senderUserNo.trim();
    }
    return item.isSystem ? _text('系统', 'System') : _text('队友', 'Teammate');
  }

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
  }

  Future<void> _refresh() async {
    await _runAction(
      () => widget.onLoadNotifications(limit: 40),
      fallbackMessage: _text(
        '当前无法刷新通知列表。',
        'Unable to refresh notifications right now.',
      ),
    );
  }

  Future<void> _markAllRead() async {
    if (!_overview.hasUnread) {
      return;
    }
    await _runAction(
      widget.onMarkAllNotificationsRead,
      fallbackMessage: _text(
        '当前无法全部标记为已读。',
        'Unable to mark all notifications as read.',
      ),
    );
  }

  Future<void> _markRead(AppNotificationItem item) async {
    if (item.read) {
      return;
    }
    await _runAction(
      () => widget.onMarkNotificationRead(item.id),
      fallbackMessage: _text(
        '当前无法标记这条通知为已读。',
        'Unable to mark this notification as read.',
      ),
    );
  }

  Future<void> _respondFriendRequest(
    AppNotificationItem item,
    bool accept,
  ) async {
    await _runAction(
      () => widget.onRespondFriendRequest(item.relatedId, accept: accept),
      fallbackMessage: _text(
        '当前无法处理这条好友申请。',
        'Unable to respond to this friend request.',
      ),
    );
  }

  Future<void> _respondTeamInvitation(
    AppNotificationItem item,
    bool accept,
  ) async {
    await _runAction(
      () => widget.onRespondTeamInvitation(item.relatedId, accept: accept),
      fallbackMessage: _text(
        '当前无法处理这条团队邀请。',
        'Unable to respond to this team invitation.',
      ),
    );
  }

  Future<void> _runAction(
    Future<NotificationOverview?> Function() action, {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMessage)),
        );
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

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('通知中心', 'Notification center'),
      description: _text(
        '这里只保留最近 30 天的通知，队友提醒、完成通知和签到结果都会集中显示。',
        'Only the latest 30 days are kept here. Team reminders, teammate completion, and check-in results all gather in one place.',
      ),
      headerActions: [
        _UnreadPill(
          count: _overview.unreadCount,
          isChinese: _isChinese,
        ),
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
        FilledButton.icon(
          onPressed: _isLoading || !_overview.hasUnread ? null : _markAllRead,
          icon: const Icon(Icons.done_all_rounded),
          label: Text(_text('全部已读', 'Mark all read')),
        ),
      ],
      children: [
        if (!_overview.hasItems)
          GlassPanel(
            lightStyle: true,
            child: _EmptyNotificationState(isChinese: _isChinese),
          )
        else
          ..._overview.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassPanel(
                lightStyle: true,
                child: _NotificationTile(
                  item: item,
                  isChinese: _isChinese,
                  typeLabel: _notificationTypeLabel(item),
                  senderLabel: _senderDisplayName(item),
                  onTap: _isLoading ? null : () => _markRead(item),
                  onAcceptFriendRequest:
                      item.canRespondFriendRequest && !_isLoading
                          ? () => _respondFriendRequest(item, true)
                          : null,
                  onDeclineFriendRequest:
                      item.canRespondFriendRequest && !_isLoading
                          ? () => _respondFriendRequest(item, false)
                          : null,
                  onAcceptTeamInvitation:
                      item.canRespondTeamInvitation && !_isLoading
                          ? () => _respondTeamInvitation(item, true)
                          : null,
                  onDeclineTeamInvitation:
                      item.canRespondTeamInvitation && !_isLoading
                          ? () => _respondTeamInvitation(item, false)
                          : null,
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isChinese,
    required this.typeLabel,
    required this.senderLabel,
    this.onTap,
    this.onAcceptFriendRequest,
    this.onDeclineFriendRequest,
    this.onAcceptTeamInvitation,
    this.onDeclineTeamInvitation,
  });

  final AppNotificationItem item;
  final bool isChinese;
  final String typeLabel;
  final String senderLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAcceptFriendRequest;
  final VoidCallback? onDeclineFriendRequest;
  final VoidCallback? onAcceptTeamInvitation;
  final VoidCallback? onDeclineTeamInvitation;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentColor(item.notificationType);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: item.read ? SurfacePalette.softSurface : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: item.read ? 0.18 : 0.34),
            ),
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.read ? SurfacePalette.subtle : accent,
                          boxShadow: item.read
                              ? const []
                              : [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.40),
                                    blurRadius: 12,
                                  ),
                                ],
                        ),
                      ),
                      Text(
                        typeLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(item.createTime, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: textTheme.titleMedium?.copyWith(
                  color: SurfacePalette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(item.content, style: textTheme.bodyLarge),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetaTag(label: senderLabel),
                  _MetaTag(
                      label: item.read
                          ? _text('已读', 'Read')
                          : _text('未读', 'Unread')),
                  _MetaTag(
                    label: item.canRespondFriendRequest ||
                            item.canRespondTeamInvitation
                        ? _text('可处理', 'Action available')
                        : _text('点击可标记已读', 'Tap to mark read'),
                  ),
                ],
              ),
              if (item.canRespondFriendRequest) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: onDeclineFriendRequest,
                      child: Text(_text('拒绝', 'Decline')),
                    ),
                    FilledButton(
                      onPressed: onAcceptFriendRequest,
                      child: Text(_text('同意', 'Accept')),
                    ),
                  ],
                ),
              ],
              if (item.canRespondTeamInvitation) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: onDeclineTeamInvitation,
                      child: Text(_text('拒绝', 'Decline')),
                    ),
                    FilledButton(
                      onPressed: onAcceptTeamInvitation,
                      child: Text(_text('加入团队', 'Join team')),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _accentColor(String notificationType) {
    switch (notificationType) {
      case 'team_reminder':
        return AppColors.glow;
      case 'team_invitation':
        return const Color(0xFF98C7FF);
      case 'teammate_completion':
        return AppColors.mint;
      case 'plan_completion':
        return const Color(0xFF7FE7D4);
      case 'check_in_success':
        return const Color(0xFF8EF0B5);
      case 'check_in_failure':
        return const Color(0xFFFFB087);
      default:
        return SurfacePalette.ink;
    }
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState({required this.isChinese});

  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('暂时没有通知', 'Nothing here yet'), style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          _text(
            '当队友提醒你、完成学习、或者你提交签到结果后，这里就会自动出现通知。',
            'Once teammates remind you, finish study sessions, or you submit check-in results, this list will start filling automatically.',
          ),
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _UnreadPill extends StatelessWidget {
  const _UnreadPill({
    required this.count,
    required this.isChinese,
  });

  final int count;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Text(
        count > 0
            ? _text('$count 条未读', '$count unread')
            : _text('已全部查看', 'All caught up'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.label});

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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}
