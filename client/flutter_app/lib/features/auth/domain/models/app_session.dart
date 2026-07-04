class AppSession {
  const AppSession({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.deviceType,
    required this.deviceSlot,
    required this.deviceId,
  });

  final String accessToken;
  final String tokenType;
  final int userId;
  final String deviceType;
  final String deviceSlot;
  final String deviceId;

  Map<String, String> get authHeaders {
    return {
      'Authorization': '$tokenType $accessToken',
      'X-User-Id': userId.toString(),
      'X-Device-Type': deviceType,
      'X-Device-Id': deviceId,
    };
  }
}
