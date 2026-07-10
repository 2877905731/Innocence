class FriendOverview {
  const FriendOverview({
    required this.friendCount,
    required this.maxFriendCount,
    required this.defaultGroupId,
    required this.groups,
    required this.friends,
    required this.incomingRequests,
    required this.outgoingRequests,
  });

  final int friendCount;
  final int maxFriendCount;
  final int defaultGroupId;
  final List<FriendGroupModel> groups;
  final List<FriendItemModel> friends;
  final List<FriendRequestModel> incomingRequests;
  final List<FriendRequestModel> outgoingRequests;

  factory FriendOverview.empty() {
    return const FriendOverview(
      friendCount: 0,
      maxFriendCount: 200,
      defaultGroupId: 0,
      groups: [],
      friends: [],
      incomingRequests: [],
      outgoingRequests: [],
    );
  }

  factory FriendOverview.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['groups'] as List<dynamic>? ?? const [];
    final friendsJson = json['friends'] as List<dynamic>? ?? const [];
    final incomingJson = json['incomingRequests'] as List<dynamic>? ?? const [];
    final outgoingJson = json['outgoingRequests'] as List<dynamic>? ?? const [];
    return FriendOverview(
      friendCount: _toInt(json['friendCount']),
      maxFriendCount: _toInt(json['maxFriendCount'], fallback: 200),
      defaultGroupId: _toInt(json['defaultGroupId']),
      groups: groupsJson
          .whereType<Map<String, dynamic>>()
          .map(FriendGroupModel.fromJson)
          .toList(),
      friends: friendsJson
          .whereType<Map<String, dynamic>>()
          .map(FriendItemModel.fromJson)
          .toList(),
      incomingRequests: incomingJson
          .whereType<Map<String, dynamic>>()
          .map(FriendRequestModel.fromJson)
          .toList(),
      outgoingRequests: outgoingJson
          .whereType<Map<String, dynamic>>()
          .map(FriendRequestModel.fromJson)
          .toList(),
    );
  }

  bool get hasFriends => friends.isNotEmpty;

  bool get hasPendingRequests =>
      incomingRequests.isNotEmpty || outgoingRequests.isNotEmpty;

  List<FriendItemModel> friendsInGroup(int groupId) {
    return friends.where((friend) => friend.groupId == groupId).toList();
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}

class FriendGroupModel {
  const FriendGroupModel({
    required this.groupId,
    required this.groupName,
    required this.system,
    required this.friendCount,
  });

  final int groupId;
  final String groupName;
  final bool system;
  final int friendCount;

  factory FriendGroupModel.fromJson(Map<String, dynamic> json) {
    return FriendGroupModel(
      groupId: FriendOverview._toInt(json['groupId']),
      groupName: '${json['groupName'] ?? ''}',
      system: json['system'] == true || json['system'] == 1,
      friendCount: FriendOverview._toInt(json['friendCount']),
    );
  }
}

class FriendItemModel {
  const FriendItemModel({
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.bio,
    required this.groupId,
    required this.groupName,
    required this.sameTeam,
    required this.profileVisible,
  });

  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final String bio;
  final int groupId;
  final String groupName;
  final bool sameTeam;
  final bool profileVisible;

  factory FriendItemModel.fromJson(Map<String, dynamic> json) {
    return FriendItemModel(
      userId: FriendOverview._toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      bio: '${json['bio'] ?? ''}',
      groupId: FriendOverview._toInt(json['groupId']),
      groupName: '${json['groupName'] ?? ''}',
      sameTeam: json['sameTeam'] == true || json['sameTeam'] == 1,
      profileVisible: json['profileVisible'] == true || json['profileVisible'] == 1,
    );
  }

  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (userNo.trim().isNotEmpty) {
      return userNo.trim();
    }
    return 'Friend';
  }
}

class FriendRequestModel {
  const FriendRequestModel({
    required this.requestId,
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.requestMessage,
    required this.createTime,
    required this.incoming,
    required this.sameTeam,
  });

  final int requestId;
  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final String requestMessage;
  final String createTime;
  final bool incoming;
  final bool sameTeam;

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: FriendOverview._toInt(json['requestId']),
      userId: FriendOverview._toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      requestMessage: '${json['requestMessage'] ?? ''}',
      createTime: '${json['createTime'] ?? ''}',
      incoming: json['incoming'] == true || json['incoming'] == 1,
      sameTeam: json['sameTeam'] == true || json['sameTeam'] == 1,
    );
  }

  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (userNo.trim().isNotEmpty) {
      return userNo.trim();
    }
    return 'User';
  }
}

class FriendSearchItemModel {
  const FriendSearchItemModel({
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.alreadyFriend,
    required this.outgoingPending,
    required this.incomingPending,
    required this.blockedByMe,
    required this.blockedMe,
    required this.sameTeam,
  });

  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final bool alreadyFriend;
  final bool outgoingPending;
  final bool incomingPending;
  final bool blockedByMe;
  final bool blockedMe;
  final bool sameTeam;

  factory FriendSearchItemModel.fromJson(Map<String, dynamic> json) {
    return FriendSearchItemModel(
      userId: FriendOverview._toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      alreadyFriend: json['alreadyFriend'] == true || json['alreadyFriend'] == 1,
      outgoingPending: json['outgoingPending'] == true || json['outgoingPending'] == 1,
      incomingPending: json['incomingPending'] == true || json['incomingPending'] == 1,
      blockedByMe: json['blockedByMe'] == true || json['blockedByMe'] == 1,
      blockedMe: json['blockedMe'] == true || json['blockedMe'] == 1,
      sameTeam: json['sameTeam'] == true || json['sameTeam'] == 1,
    );
  }

  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (userNo.trim().isNotEmpty) {
      return userNo.trim();
    }
    return 'User';
  }
}
