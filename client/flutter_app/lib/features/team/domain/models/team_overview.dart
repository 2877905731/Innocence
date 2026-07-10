class TeamOverview {
  const TeamOverview({
    required this.inTeam,
    required this.teamId,
    required this.teamName,
    required this.inviteCode,
    required this.ownerUserId,
    required this.owner,
    required this.memberLimit,
    required this.unreadChatCount,
    required this.latestChatPreview,
    required this.members,
  });

  final bool inTeam;
  final int teamId;
  final String teamName;
  final String inviteCode;
  final int ownerUserId;
  final bool owner;
  final int memberLimit;
  final int unreadChatCount;
  final String latestChatPreview;
  final List<TeamMember> members;

  factory TeamOverview.empty() {
    return const TeamOverview(
      inTeam: false,
      teamId: 0,
      teamName: '',
      inviteCode: '',
      ownerUserId: 0,
      owner: false,
      memberLimit: 5,
      unreadChatCount: 0,
      latestChatPreview: '',
      members: [],
    );
  }

  factory TeamOverview.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? const [];
    return TeamOverview(
      inTeam: json['inTeam'] == true || json['inTeam'] == 1,
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      inviteCode: '${json['inviteCode'] ?? ''}',
      ownerUserId: _toInt(json['ownerUserId']),
      owner: json['owner'] == true || json['owner'] == 1,
      memberLimit: _toInt(json['memberLimit'], fallback: 5),
      unreadChatCount: _toInt(json['unreadChatCount']),
      latestChatPreview: '${json['latestChatPreview'] ?? ''}',
      members: membersJson
          .whereType<Map<String, dynamic>>()
          .map(TeamMember.fromJson)
          .toList(),
    );
  }

  int get memberCount => members.length;

  bool get isFull => memberCount >= memberLimit;

  bool get hasUnreadChat => unreadChatCount > 0;

  String get subtitle {
    if (!inTeam) {
      return '创建一个可信小团队，或通过邀请码加入。';
    }
    return '$memberCount/$memberLimit 人';
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class TeamMember {
  const TeamMember({
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.role,
    required this.allowStudyView,
    required this.totalStudyDurationMinutes,
    required this.totalCheckInDays,
    required this.todayCompletedCount,
    required this.todayTotalCount,
    required this.todayStudyDurationMinutes,
    required this.activeStudy,
    required this.activeTaskName,
    required this.activeStageName,
    required this.owner,
  });

  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final String role;
  final bool allowStudyView;
  final int totalStudyDurationMinutes;
  final int totalCheckInDays;
  final int todayCompletedCount;
  final int todayTotalCount;
  final int todayStudyDurationMinutes;
  final bool activeStudy;
  final String activeTaskName;
  final String activeStageName;
  final bool owner;

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: TeamOverview._toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      role: '${json['role'] ?? ''}',
      allowStudyView:
          json['allowStudyView'] == true || json['allowStudyView'] == 1,
      totalStudyDurationMinutes:
          TeamOverview._toInt(json['totalStudyDurationMinutes']),
      totalCheckInDays: TeamOverview._toInt(json['totalCheckInDays']),
      todayCompletedCount: TeamOverview._toInt(json['todayCompletedCount']),
      todayTotalCount: TeamOverview._toInt(json['todayTotalCount']),
      todayStudyDurationMinutes:
          TeamOverview._toInt(json['todayStudyDurationMinutes']),
      activeStudy: json['activeStudy'] == true || json['activeStudy'] == 1,
      activeTaskName: '${json['activeTaskName'] ?? ''}',
      activeStageName: '${json['activeStageName'] ?? ''}',
      owner: json['owner'] == true || json['owner'] == 1,
    );
  }

  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (userNo.trim().isNotEmpty) {
      return userNo.trim();
    }
    return owner ? '队长' : '队友';
  }

  String get totalStudyDurationLabel =>
      _formatMinutes(totalStudyDurationMinutes);

  String get todayStudyDurationLabel =>
      _formatMinutes(todayStudyDurationMinutes);

  String get todayPlanProgressLabel => '$todayCompletedCount/$todayTotalCount';

  bool get completedTodayPlan =>
      todayTotalCount > 0 && todayCompletedCount >= todayTotalCount;

  String get todayStatusLabel {
    if (completedTodayPlan) {
      return '计划完成';
    }
    if (activeStudy) {
      return stageLabel;
    }
    if (todayTotalCount <= 0) {
      return '暂无计划';
    }
    return '进行中';
  }

  String get stageLabel {
    switch (activeStageName) {
      case 'study':
        return '学习中';
      case 'break':
        return '休息中';
      case 'finished':
        return '已完成';
      default:
        return activeStudy ? '学习中' : '空闲';
    }
  }

  static String _formatMinutes(int minutes) {
    final normalized = minutes < 0 ? 0 : minutes;
    final hours = normalized ~/ 60;
    final remainingMinutes = normalized % 60;
    if (hours == 0) {
      return '$remainingMinutes min';
    }
    if (remainingMinutes == 0) {
      return '$hours h';
    }
    return '$hours h $remainingMinutes min';
  }
}
