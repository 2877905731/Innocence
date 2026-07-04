import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';

import 'app_session.dart';

class AuthResult {
  const AuthResult({
    required this.session,
    required this.userInfo,
  });

  final AppSession session;
  final UserProfile userInfo;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userInfoJson = json['userInfo'];
    if (userInfoJson is! Map<String, dynamic>) {
      throw const FormatException('Missing userInfo in auth response');
    }

    final profile = UserProfile.fromJson(userInfoJson);
    return AuthResult(
      session: AppSession(
        accessToken: '${json['accessToken'] ?? ''}',
        tokenType: '${json['tokenType'] ?? 'Bearer'}',
        userId: profile.userId,
        deviceType: '${json['deviceType'] ?? ''}',
        deviceSlot: '${json['deviceSlot'] ?? ''}',
        deviceId: '${json['deviceId'] ?? ''}',
      ),
      userInfo: profile,
    );
  }
}
