class NotificationOverview {
  const NotificationOverview({
    required this.unreadCount,
    required this.items,
  });

  final int unreadCount;
  final List<AppNotificationItem> items;

  factory NotificationOverview.empty() {
    return const NotificationOverview(
      unreadCount: 0,
      items: [],
    );
  }

  factory NotificationOverview.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return NotificationOverview(
      unreadCount: _toInt(json['unreadCount']),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(AppNotificationItem.fromJson)
          .toList(),
    );
  }

  bool get hasUnread => unreadCount > 0;

  bool get hasItems => items.isNotEmpty;

  List<AppNotificationItem> get previewItems {
    if (items.length <= 3) {
      return items;
    }
    return items.sublist(0, 3);
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.content,
    required this.relatedType,
    required this.relatedId,
    required this.actionable,
    required this.read,
    required this.createTime,
    required this.senderUserId,
    required this.senderUserNo,
    required this.senderNickname,
    required this.senderAvatarUrl,
  });

  final int id;
  final String notificationType;
  final String title;
  final String content;
  final String relatedType;
  final int relatedId;
  final bool actionable;
  final bool read;
  final String createTime;
  final int senderUserId;
  final String senderUserNo;
  final String senderNickname;
  final String senderAvatarUrl;

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: NotificationOverview._toInt(json['id']),
      notificationType: '${json['notificationType'] ?? ''}',
      title: '${json['title'] ?? ''}',
      content: '${json['content'] ?? ''}',
      relatedType: '${json['relatedType'] ?? ''}',
      relatedId: NotificationOverview._toInt(json['relatedId']),
      actionable: json['actionable'] == true || json['actionable'] == 1,
      read: json['read'] == true || json['read'] == 1,
      createTime: '${json['createTime'] ?? ''}',
      senderUserId: NotificationOverview._toInt(json['senderUserId']),
      senderUserNo: '${json['senderUserNo'] ?? ''}',
      senderNickname: '${json['senderNickname'] ?? ''}',
      senderAvatarUrl: '${json['senderAvatarUrl'] ?? ''}',
    );
  }

  String get senderDisplayName {
    if (senderNickname.trim().isNotEmpty) {
      return senderNickname.trim();
    }
    if (senderUserNo.trim().isNotEmpty) {
      return senderUserNo.trim();
    }
    return isSystem ? 'System' : 'Teammate';
  }

  bool get isSystem => senderUserId <= 0;

  bool get canRespondFriendRequest =>
      actionable &&
      notificationType == 'friend_request' &&
      relatedId > 0;

  bool get canRespondTeamInvitation =>
      actionable &&
      notificationType == 'team_invitation' &&
      relatedId > 0;

  String get typeLabel {
    switch (notificationType) {
      case 'friend_request':
        return 'Friend request';
      case 'team_invitation':
        return 'Team invitation';
      case 'team_reminder':
        return 'Teammate reminder';
      case 'teammate_completion':
        return 'Teammate finished';
      case 'plan_completion':
        return 'Plan completed';
      case 'check_in_success':
        return 'Check-in success';
      case 'check_in_failure':
        return 'Check-in pending';
      case 'system_announcement':
        return 'System announcement';
      default:
        return 'Notification';
    }
  }
}
