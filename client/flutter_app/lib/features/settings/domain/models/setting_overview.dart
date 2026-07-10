import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';

import 'appearance_setting.dart';
import 'notification_setting.dart';
import 'privacy_setting.dart';
import 'widget_setting.dart';

class SettingOverview {
  const SettingOverview({
    required this.accountSetting,
    required this.privacySetting,
    required this.notificationSetting,
    required this.widgetSetting,
    required this.appearanceSetting,
  });

  final UserProfile accountSetting;
  final PrivacySetting privacySetting;
  final NotificationSetting notificationSetting;
  final WidgetSetting widgetSetting;
  final AppearanceSetting appearanceSetting;

  factory SettingOverview.empty({UserProfile? accountSetting}) {
    return SettingOverview(
      accountSetting: accountSetting ??
          const UserProfile(
            userId: 0,
            userNo: '',
            nickname: '',
            avatarUrl: '',
            bio: '',
            timezone: 'Asia/Shanghai',
            studyDurationTotal: 0,
            checkInDaysTotal: 0,
          ),
      privacySetting: PrivacySetting.empty(),
      notificationSetting: NotificationSetting.empty(),
      widgetSetting: WidgetSetting.empty(),
      appearanceSetting: AppearanceSetting.empty(),
    );
  }

  factory SettingOverview.fromJson(Map<String, dynamic> json) {
    final accountJson = json['accountSetting'] as Map<String, dynamic>?;
    final privacyJson = json['privacySetting'] as Map<String, dynamic>?;
    final notificationJson =
        json['notificationSetting'] as Map<String, dynamic>?;
    final widgetJson = json['widgetSetting'] as Map<String, dynamic>?;
    final appearanceJson =
        json['appearanceSetting'] as Map<String, dynamic>?;

    return SettingOverview(
      accountSetting: UserProfile.fromJson(accountJson ?? const {}),
      privacySetting: PrivacySetting.fromJson(privacyJson ?? const {}),
      notificationSetting:
          NotificationSetting.fromJson(notificationJson ?? const {}),
      widgetSetting: WidgetSetting.fromJson(widgetJson ?? const {}),
      appearanceSetting: AppearanceSetting.fromJson(appearanceJson ?? const {}),
    );
  }

  SettingOverview copyWith({
    UserProfile? accountSetting,
    PrivacySetting? privacySetting,
    NotificationSetting? notificationSetting,
    WidgetSetting? widgetSetting,
    AppearanceSetting? appearanceSetting,
  }) {
    return SettingOverview(
      accountSetting: accountSetting ?? this.accountSetting,
      privacySetting: privacySetting ?? this.privacySetting,
      notificationSetting: notificationSetting ?? this.notificationSetting,
      widgetSetting: widgetSetting ?? this.widgetSetting,
      appearanceSetting: appearanceSetting ?? this.appearanceSetting,
    );
  }
}
