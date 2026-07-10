class TeamChatOverview {
  const TeamChatOverview({
    required this.teamId,
    required this.teamName,
    required this.unreadCount,
    required this.messages,
  });

  final int teamId;
  final String teamName;
  final int unreadCount;
  final List<TeamChatMessage> messages;

  factory TeamChatOverview.empty() {
    return const TeamChatOverview(
      teamId: 0,
      teamName: '',
      unreadCount: 0,
      messages: [],
    );
  }

  factory TeamChatOverview.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? const [];
    return TeamChatOverview(
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      unreadCount: _toInt(json['unreadCount']),
      messages: messagesJson
          .whereType<Map<String, dynamic>>()
          .map(TeamChatMessage.fromJson)
          .toList(),
    );
  }

  bool get hasMessages => messages.isNotEmpty;

  TeamChatMessage? get latestMessage => hasMessages ? messages.last : null;

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class TeamChatMessage {
  const TeamChatMessage({
    required this.messageId,
    required this.senderUserId,
    required this.senderUserNo,
    required this.senderNickname,
    required this.senderAvatarUrl,
    required this.content,
    required this.masked,
    required this.deleted,
    required this.deletedReason,
    required this.ownMessage,
    required this.createTime,
  });

  final int messageId;
  final int senderUserId;
  final String senderUserNo;
  final String senderNickname;
  final String senderAvatarUrl;
  final String content;
  final bool masked;
  final bool deleted;
  final String deletedReason;
  final bool ownMessage;
  final String createTime;

  factory TeamChatMessage.fromJson(Map<String, dynamic> json) {
    return TeamChatMessage(
      messageId: TeamChatOverview._toInt(json['messageId']),
      senderUserId: TeamChatOverview._toInt(json['senderUserId']),
      senderUserNo: '${json['senderUserNo'] ?? ''}',
      senderNickname: '${json['senderNickname'] ?? ''}',
      senderAvatarUrl: '${json['senderAvatarUrl'] ?? ''}',
      content: '${json['content'] ?? ''}',
      masked: json['masked'] == true || json['masked'] == 1,
      deleted: json['deleted'] == true || json['deleted'] == 1,
      deletedReason: '${json['deletedReason'] ?? ''}',
      ownMessage: json['ownMessage'] == true || json['ownMessage'] == 1,
      createTime: '${json['createTime'] ?? ''}',
    );
  }

  String get senderDisplayName {
    if (senderNickname.trim().isNotEmpty) {
      return senderNickname.trim();
    }
    if (senderUserNo.trim().isNotEmpty) {
      return senderUserNo.trim();
    }
    return ownMessage ? '我' : '队友';
  }
}
