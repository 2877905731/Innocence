import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';

class LocalProfile {
  const LocalProfile({
    required this.localProfileId,
    required this.nickname,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  final String localProfileId;
  final String nickname;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get ownerScope => 'local:$localProfileId';

  UserProfile toUserProfile() {
    return UserProfile.local(
      localProfileId: localProfileId,
      nickname: nickname,
      timezone: timezone,
    );
  }
}
