class PrivacySetting {
  const PrivacySetting({
    required this.allowFriendViewProfile,
    required this.allowTeammateViewStudy,
    required this.allowStrangerMessage,
  });

  final bool allowFriendViewProfile;
  final bool allowTeammateViewStudy;
  final bool allowStrangerMessage;

  factory PrivacySetting.empty() {
    return const PrivacySetting(
      allowFriendViewProfile: true,
      allowTeammateViewStudy: true,
      allowStrangerMessage: false,
    );
  }

  factory PrivacySetting.fromJson(Map<String, dynamic> json) {
    return PrivacySetting(
      allowFriendViewProfile: _toBool(json['allowFriendViewProfile']),
      allowTeammateViewStudy: _toBool(json['allowTeammateViewStudy']),
      allowStrangerMessage: _toBool(json['allowStrangerMessage']),
    );
  }

  PrivacySetting copyWith({
    bool? allowFriendViewProfile,
    bool? allowTeammateViewStudy,
    bool? allowStrangerMessage,
  }) {
    return PrivacySetting(
      allowFriendViewProfile:
          allowFriendViewProfile ?? this.allowFriendViewProfile,
      allowTeammateViewStudy:
          allowTeammateViewStudy ?? this.allowTeammateViewStudy,
      allowStrangerMessage:
          allowStrangerMessage ?? this.allowStrangerMessage,
    );
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = '$value'.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return fallback;
  }
}
