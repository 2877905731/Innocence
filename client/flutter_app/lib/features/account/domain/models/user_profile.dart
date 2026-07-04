class UserProfile {
  const UserProfile({
    required this.userId,
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.bio,
    required this.timezone,
    required this.studyDurationTotal,
    required this.checkInDaysTotal,
  });

  final int userId;
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final String bio;
  final String timezone;
  final int studyDurationTotal;
  final int checkInDaysTotal;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: _toInt(json['userId']),
      userNo: '${json['userNo'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
      bio: '${json['bio'] ?? ''}',
      timezone: '${json['timezone'] ?? ''}',
      studyDurationTotal: _toInt(json['studyDurationTotal']),
      checkInDaysTotal: _toInt(json['checkInDaysTotal']),
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

  String get studyDurationLabel {
    final hours = studyDurationTotal ~/ 60;
    final minutes = studyDurationTotal % 60;
    if (hours <= 0) {
      return '$minutes min';
    }
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? 0;
  }
}
