class AdminReportListItem {
  const AdminReportListItem({
    required this.reportId,
    required this.reportType,
    required this.status,
    required this.reason,
    required this.reportUserId,
    required this.reportUserDisplayName,
    required this.targetId,
    required this.targetUserId,
    required this.targetUserDisplayName,
    required this.teamId,
    required this.teamName,
    required this.contentPreview,
    required this.targetDeleted,
    required this.createTime,
  });

  final int reportId;
  final String reportType;
  final String status;
  final String reason;
  final int reportUserId;
  final String reportUserDisplayName;
  final int targetId;
  final int targetUserId;
  final String targetUserDisplayName;
  final int teamId;
  final String teamName;
  final String contentPreview;
  final bool targetDeleted;
  final String createTime;

  factory AdminReportListItem.fromJson(Map<String, dynamic> json) {
    return AdminReportListItem(
      reportId: _toInt(json['reportId']),
      reportType: '${json['reportType'] ?? ''}',
      status: '${json['status'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      reportUserId: _toInt(json['reportUserId']),
      reportUserDisplayName: '${json['reportUserDisplayName'] ?? ''}',
      targetId: _toInt(json['targetId']),
      targetUserId: _toInt(json['targetUserId']),
      targetUserDisplayName: '${json['targetUserDisplayName'] ?? ''}',
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      contentPreview: '${json['contentPreview'] ?? ''}',
      targetDeleted: json['targetDeleted'] == true || json['targetDeleted'] == 1,
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminReportDetail {
  const AdminReportDetail({
    required this.reportId,
    required this.reportType,
    required this.status,
    required this.reason,
    required this.description,
    required this.reportUserId,
    required this.reportUserDisplayName,
    required this.targetId,
    required this.targetUserId,
    required this.targetUserDisplayName,
    required this.teamId,
    required this.teamName,
    required this.targetContent,
    required this.targetMasked,
    required this.targetDeleted,
    required this.targetDeletedReason,
    required this.handledUserId,
    required this.handledUserDisplayName,
    required this.handledTime,
    required this.createTime,
    required this.auditHistory,
  });

  final int reportId;
  final String reportType;
  final String status;
  final String reason;
  final String description;
  final int reportUserId;
  final String reportUserDisplayName;
  final int targetId;
  final int targetUserId;
  final String targetUserDisplayName;
  final int teamId;
  final String teamName;
  final String targetContent;
  final bool targetMasked;
  final bool targetDeleted;
  final String targetDeletedReason;
  final int handledUserId;
  final String handledUserDisplayName;
  final String handledTime;
  final String createTime;
  final List<AdminReportAuditItem> auditHistory;

  factory AdminReportDetail.fromJson(Map<String, dynamic> json) {
    final historyJson = json['auditHistory'] as List<dynamic>? ?? const [];
    return AdminReportDetail(
      reportId: _toInt(json['reportId']),
      reportType: '${json['reportType'] ?? ''}',
      status: '${json['status'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      description: '${json['description'] ?? ''}',
      reportUserId: _toInt(json['reportUserId']),
      reportUserDisplayName: '${json['reportUserDisplayName'] ?? ''}',
      targetId: _toInt(json['targetId']),
      targetUserId: _toInt(json['targetUserId']),
      targetUserDisplayName: '${json['targetUserDisplayName'] ?? ''}',
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      targetContent: '${json['targetContent'] ?? ''}',
      targetMasked: json['targetMasked'] == true || json['targetMasked'] == 1,
      targetDeleted: json['targetDeleted'] == true || json['targetDeleted'] == 1,
      targetDeletedReason: '${json['targetDeletedReason'] ?? ''}',
      handledUserId: _toInt(json['handledUserId']),
      handledUserDisplayName: '${json['handledUserDisplayName'] ?? ''}',
      handledTime: '${json['handledTime'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
      auditHistory: historyJson
          .whereType<Map<String, dynamic>>()
          .map(AdminReportAuditItem.fromJson)
          .toList(),
    );
  }
}

class AdminReportAuditItem {
  const AdminReportAuditItem({
    required this.auditId,
    required this.decision,
    required this.deleteContent,
    required this.punishmentType,
    required this.durationDays,
    required this.reason,
    required this.adminUserId,
    required this.adminDisplayName,
    required this.createTime,
  });

  final int auditId;
  final String decision;
  final bool deleteContent;
  final String punishmentType;
  final int durationDays;
  final String reason;
  final int adminUserId;
  final String adminDisplayName;
  final String createTime;

  factory AdminReportAuditItem.fromJson(Map<String, dynamic> json) {
    return AdminReportAuditItem(
      auditId: _toInt(json['auditId']),
      decision: '${json['decision'] ?? ''}',
      deleteContent: json['deleteContent'] == true || json['deleteContent'] == 1,
      punishmentType: '${json['punishmentType'] ?? ''}',
      durationDays: _toInt(json['durationDays']),
      reason: '${json['reason'] ?? ''}',
      adminUserId: _toInt(json['adminUserId']),
      adminDisplayName: '${json['adminDisplayName'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminReportReviewResult {
  const AdminReportReviewResult({
    required this.reportId,
    required this.status,
    required this.decision,
    required this.message,
  });

  final int reportId;
  final String status;
  final String decision;
  final String message;

  factory AdminReportReviewResult.fromJson(Map<String, dynamic> json) {
    return AdminReportReviewResult(
      reportId: _toInt(json['reportId']),
      status: '${json['status'] ?? ''}',
      decision: '${json['decision'] ?? ''}',
      message: '${json['message'] ?? ''}',
    );
  }
}

class AdminUserSearchItem {
  const AdminUserSearchItem({
    required this.userId,
    required this.userNo,
    required this.displayName,
    required this.avatarUrl,
    required this.statusCode,
    required this.statusLabel,
    required this.teamId,
    required this.teamName,
    required this.lastLoginTime,
    required this.createTime,
  });

  final int userId;
  final String userNo;
  final String displayName;
  final String avatarUrl;
  final int statusCode;
  final String statusLabel;
  final int teamId;
  final String teamName;
  final String lastLoginTime;
  final String createTime;

  factory AdminUserSearchItem.fromJson(Map<String, dynamic> json) {
    return AdminUserSearchItem(
      userId: _toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      statusCode: _toInt(json['statusCode']),
      statusLabel: '${json['statusLabel'] ?? ''}',
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      lastLoginTime: '${json['lastLoginTime'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.displayName,
    required this.avatarUrl,
    required this.email,
    required this.statusCode,
    required this.statusLabel,
    required this.bio,
    required this.timezone,
    required this.allowFriendViewProfile,
    required this.allowTeammateViewStudy,
    required this.allowStrangerMessage,
    required this.totalStudyMinutes,
    required this.totalCheckInDays,
    required this.consecutiveCheckInDays,
    required this.teamId,
    required this.teamName,
    required this.teamInviteCode,
    required this.teamRole,
    required this.teamJoinedTime,
    required this.lastLoginTime,
    required this.createTime,
  });

  final int userId;
  final String userNo;
  final String nickname;
  final String displayName;
  final String avatarUrl;
  final String email;
  final int statusCode;
  final String statusLabel;
  final String bio;
  final String timezone;
  final bool allowFriendViewProfile;
  final bool allowTeammateViewStudy;
  final bool allowStrangerMessage;
  final int totalStudyMinutes;
  final int totalCheckInDays;
  final int consecutiveCheckInDays;
  final int teamId;
  final String teamName;
  final String teamInviteCode;
  final String teamRole;
  final String teamJoinedTime;
  final String lastLoginTime;
  final String createTime;

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    return AdminUserDetail(
      userId: _toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      displayName: '${json['displayName'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      email: '${json['email'] ?? ''}',
      statusCode: _toInt(json['statusCode']),
      statusLabel: '${json['statusLabel'] ?? ''}',
      bio: '${json['bio'] ?? ''}',
      timezone: '${json['timezone'] ?? ''}',
      allowFriendViewProfile:
          json['allowFriendViewProfile'] == true || json['allowFriendViewProfile'] == 1,
      allowTeammateViewStudy:
          json['allowTeammateViewStudy'] == true || json['allowTeammateViewStudy'] == 1,
      allowStrangerMessage:
          json['allowStrangerMessage'] == true || json['allowStrangerMessage'] == 1,
      totalStudyMinutes: _toInt(json['totalStudyMinutes']),
      totalCheckInDays: _toInt(json['totalCheckInDays']),
      consecutiveCheckInDays: _toInt(json['consecutiveCheckInDays']),
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      teamInviteCode: '${json['teamInviteCode'] ?? ''}',
      teamRole: '${json['teamRole'] ?? ''}',
      teamJoinedTime: '${json['teamJoinedTime'] ?? ''}',
      lastLoginTime: '${json['lastLoginTime'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminUserReportItem {
  const AdminUserReportItem({
    required this.reportId,
    required this.reportType,
    required this.status,
    required this.reason,
    required this.description,
    required this.reportUserId,
    required this.reportUserDisplayName,
    required this.teamId,
    required this.teamName,
    required this.contentPreview,
    required this.targetDeleted,
    required this.createTime,
  });

  final int reportId;
  final String reportType;
  final String status;
  final String reason;
  final String description;
  final int reportUserId;
  final String reportUserDisplayName;
  final int teamId;
  final String teamName;
  final String contentPreview;
  final bool targetDeleted;
  final String createTime;

  factory AdminUserReportItem.fromJson(Map<String, dynamic> json) {
    return AdminUserReportItem(
      reportId: _toInt(json['reportId']),
      reportType: '${json['reportType'] ?? ''}',
      status: '${json['status'] ?? ''}',
      reason: '${json['reason'] ?? ''}',
      description: '${json['description'] ?? ''}',
      reportUserId: _toInt(json['reportUserId']),
      reportUserDisplayName: '${json['reportUserDisplayName'] ?? ''}',
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      contentPreview: '${json['contentPreview'] ?? ''}',
      targetDeleted: json['targetDeleted'] == true || json['targetDeleted'] == 1,
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminUserPunishmentItem {
  const AdminUserPunishmentItem({
    required this.punishmentId,
    required this.reportId,
    required this.punishmentType,
    required this.status,
    required this.active,
    required this.liftable,
    required this.durationDays,
    required this.reason,
    required this.operatorUserId,
    required this.operatorDisplayName,
    required this.startTime,
    required this.endTime,
    required this.createTime,
  });

  final int punishmentId;
  final int reportId;
  final String punishmentType;
  final String status;
  final bool active;
  final bool liftable;
  final int durationDays;
  final String reason;
  final int operatorUserId;
  final String operatorDisplayName;
  final String startTime;
  final String endTime;
  final String createTime;

  factory AdminUserPunishmentItem.fromJson(Map<String, dynamic> json) {
    return AdminUserPunishmentItem(
      punishmentId: _toInt(json['punishmentId']),
      reportId: _toInt(json['reportId']),
      punishmentType: '${json['punishmentType'] ?? ''}',
      status: '${json['status'] ?? ''}',
      active: json['active'] == true || json['active'] == 1,
      liftable: json['liftable'] == true || json['liftable'] == 1,
      durationDays: _toInt(json['durationDays']),
      reason: '${json['reason'] ?? ''}',
      operatorUserId: _toInt(json['operatorUserId']),
      operatorDisplayName: '${json['operatorDisplayName'] ?? ''}',
      startTime: '${json['startTime'] ?? ''}',
      endTime: '${json['endTime'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminLiftPunishmentResult {
  const AdminLiftPunishmentResult({
    required this.punishmentId,
    required this.status,
    required this.message,
  });

  final int punishmentId;
  final String status;
  final String message;

  factory AdminLiftPunishmentResult.fromJson(Map<String, dynamic> json) {
    return AdminLiftPunishmentResult(
      punishmentId: _toInt(json['punishmentId']),
      status: '${json['status'] ?? ''}',
      message: '${json['message'] ?? ''}',
    );
  }
}

class AdminTeamListItem {
  const AdminTeamListItem({
    required this.teamId,
    required this.teamName,
    required this.inviteCode,
    required this.ownerUserId,
    required this.ownerDisplayName,
    required this.statusCode,
    required this.statusLabel,
    required this.memberCount,
    required this.createTime,
  });

  final int teamId;
  final String teamName;
  final String inviteCode;
  final int ownerUserId;
  final String ownerDisplayName;
  final int statusCode;
  final String statusLabel;
  final int memberCount;
  final String createTime;

  factory AdminTeamListItem.fromJson(Map<String, dynamic> json) {
    return AdminTeamListItem(
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      inviteCode: '${json['inviteCode'] ?? ''}',
      ownerUserId: _toInt(json['ownerUserId']),
      ownerDisplayName: '${json['ownerDisplayName'] ?? ''}',
      statusCode: _toInt(json['statusCode']),
      statusLabel: '${json['statusLabel'] ?? ''}',
      memberCount: _toInt(json['memberCount']),
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminTeamMember {
  const AdminTeamMember({
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

  factory AdminTeamMember.fromJson(Map<String, dynamic> json) {
    return AdminTeamMember(
      userId: _toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      role: '${json['role'] ?? ''}',
      allowStudyView: json['allowStudyView'] == true || json['allowStudyView'] == 1,
      totalStudyDurationMinutes: _toInt(json['totalStudyDurationMinutes']),
      totalCheckInDays: _toInt(json['totalCheckInDays']),
      todayCompletedCount: _toInt(json['todayCompletedCount']),
      todayTotalCount: _toInt(json['todayTotalCount']),
      todayStudyDurationMinutes: _toInt(json['todayStudyDurationMinutes']),
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
    return owner ? 'Captain' : 'Member';
  }
}

class AdminTeamDetail {
  const AdminTeamDetail({
    required this.teamId,
    required this.teamName,
    required this.inviteCode,
    required this.ownerUserId,
    required this.ownerDisplayName,
    required this.statusCode,
    required this.statusLabel,
    required this.memberLimit,
    required this.memberCount,
    required this.latestChatPreview,
    required this.createTime,
    required this.members,
  });

  final int teamId;
  final String teamName;
  final String inviteCode;
  final int ownerUserId;
  final String ownerDisplayName;
  final int statusCode;
  final String statusLabel;
  final int memberLimit;
  final int memberCount;
  final String latestChatPreview;
  final String createTime;
  final List<AdminTeamMember> members;

  factory AdminTeamDetail.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? const [];
    return AdminTeamDetail(
      teamId: _toInt(json['teamId']),
      teamName: '${json['teamName'] ?? ''}',
      inviteCode: '${json['inviteCode'] ?? ''}',
      ownerUserId: _toInt(json['ownerUserId']),
      ownerDisplayName: '${json['ownerDisplayName'] ?? ''}',
      statusCode: _toInt(json['statusCode']),
      statusLabel: '${json['statusLabel'] ?? ''}',
      memberLimit: _toInt(json['memberLimit'], fallback: 5),
      memberCount: _toInt(json['memberCount']),
      latestChatPreview: '${json['latestChatPreview'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
      members: membersJson
          .whereType<Map<String, dynamic>>()
          .map(AdminTeamMember.fromJson)
          .toList(),
    );
  }
}

class AdminTeamActionResult {
  const AdminTeamActionResult({
    required this.teamId,
    required this.success,
    required this.message,
  });

  final int teamId;
  final bool success;
  final String message;

  factory AdminTeamActionResult.fromJson(Map<String, dynamic> json) {
    return AdminTeamActionResult(
      teamId: _toInt(json['teamId']),
      success: json['success'] == true || json['success'] == 1,
      message: '${json['message'] ?? ''}',
    );
  }
}

class AdminAnnouncementItem {
  const AdminAnnouncementItem({
    required this.announcementId,
    required this.title,
    required this.content,
    required this.recipientCount,
    required this.createTime,
  });

  final int announcementId;
  final String title;
  final String content;
  final int recipientCount;
  final String createTime;

  factory AdminAnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AdminAnnouncementItem(
      announcementId: _toInt(json['announcementId']),
      title: '${json['title'] ?? ''}',
      content: '${json['content'] ?? ''}',
      recipientCount: _toInt(json['recipientCount']),
      createTime: '${json['createTime'] ?? ''}',
    );
  }
}

class AdminAnnouncementActionResult {
  const AdminAnnouncementActionResult({
    required this.announcementId,
    required this.success,
    required this.message,
    required this.recipientCount,
  });

  final int announcementId;
  final bool success;
  final String message;
  final int recipientCount;

  factory AdminAnnouncementActionResult.fromJson(Map<String, dynamic> json) {
    return AdminAnnouncementActionResult(
      announcementId: _toInt(json['announcementId']),
      success: json['success'] == true || json['success'] == 1,
      message: '${json['message'] ?? ''}',
      recipientCount: _toInt(json['recipientCount']),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  return int.tryParse('$value') ?? fallback;
}
