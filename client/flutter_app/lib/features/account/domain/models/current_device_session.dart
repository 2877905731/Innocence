class CurrentDeviceSession {
  const CurrentDeviceSession({
    required this.deviceType,
    required this.deviceSlot,
    required this.deviceId,
    required this.online,
    required this.replaced,
    required this.loginTime,
    required this.logoutTime,
  });

  final String deviceType;
  final String deviceSlot;
  final String deviceId;
  final bool online;
  final bool replaced;
  final String loginTime;
  final String logoutTime;

  factory CurrentDeviceSession.fromJson(Map<String, dynamic> json) {
    return CurrentDeviceSession(
      deviceType: '${json['deviceType'] ?? ''}',
      deviceSlot: '${json['deviceSlot'] ?? ''}',
      deviceId: '${json['deviceId'] ?? ''}',
      online: _toBool(json['online']),
      replaced: _toBool(json['replaced']),
      loginTime: '${json['loginTime'] ?? ''}',
      logoutTime: '${json['logoutTime'] ?? ''}',
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    return '$value'.trim().toLowerCase() == 'true';
  }
}
