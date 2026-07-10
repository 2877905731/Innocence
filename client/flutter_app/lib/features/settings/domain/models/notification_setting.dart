class NotificationSetting {
  const NotificationSetting({
    required this.mobilePushEnabled,
    required this.desktopNoticeEnabled,
    required this.teamRemindEnabled,
    required this.systemAnnouncementEnabled,
  });

  final bool mobilePushEnabled;
  final bool desktopNoticeEnabled;
  final bool teamRemindEnabled;
  final bool systemAnnouncementEnabled;

  factory NotificationSetting.empty() {
    return const NotificationSetting(
      mobilePushEnabled: true,
      desktopNoticeEnabled: true,
      teamRemindEnabled: true,
      systemAnnouncementEnabled: true,
    );
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      mobilePushEnabled: _toBool(json['mobilePushEnabled'], fallback: true),
      desktopNoticeEnabled:
          _toBool(json['desktopNoticeEnabled'], fallback: true),
      teamRemindEnabled: _toBool(json['teamRemindEnabled'], fallback: true),
      systemAnnouncementEnabled:
          _toBool(json['systemAnnouncementEnabled'], fallback: true),
    );
  }

  NotificationSetting copyWith({
    bool? mobilePushEnabled,
    bool? desktopNoticeEnabled,
    bool? teamRemindEnabled,
    bool? systemAnnouncementEnabled,
  }) {
    return NotificationSetting(
      mobilePushEnabled: mobilePushEnabled ?? this.mobilePushEnabled,
      desktopNoticeEnabled:
          desktopNoticeEnabled ?? this.desktopNoticeEnabled,
      teamRemindEnabled: teamRemindEnabled ?? this.teamRemindEnabled,
      systemAnnouncementEnabled:
          systemAnnouncementEnabled ?? this.systemAnnouncementEnabled,
    );
  }

  int get enabledCount {
    var count = 0;
    if (mobilePushEnabled) {
      count++;
    }
    if (desktopNoticeEnabled) {
      count++;
    }
    if (teamRemindEnabled) {
      count++;
    }
    if (systemAnnouncementEnabled) {
      count++;
    }
    return count;
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
