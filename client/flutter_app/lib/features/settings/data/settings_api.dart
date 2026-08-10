import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/account/domain/models/blacklist_item.dart';
import 'package:innocence_flutter/features/account/domain/models/current_device_session.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/settings/domain/models/appearance_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/notification_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/privacy_setting.dart';
import 'package:innocence_flutter/features/settings/domain/models/setting_overview.dart';
import 'package:innocence_flutter/features/settings/domain/models/widget_setting.dart';

class SettingsApi {
  SettingsApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SettingOverview> getOverview(AppSession session) async {
    final data = await _apiClient.get(
      'settings/profile',
      headers: session.authHeaders,
    );
    return SettingOverview.fromJson(
      _requireMap(data, 'Failed to load the settings overview.'),
    );
  }

  Future<List<BlacklistItem>> getBlacklist(AppSession session) async {
    final data = await _apiClient.get(
      'account/blacklist',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load the blacklist.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(BlacklistItem.fromJson)
        .where((item) => item.blockedUserId > 0)
        .toList(growable: false);
  }

  Future<bool> addBlacklist(
    AppSession session,
    int targetUserId,
  ) async {
    final data = await _apiClient.post(
      'account/blacklist/$targetUserId',
      headers: session.authHeaders,
    );
    return _readSuccess(data);
  }

  Future<bool> removeBlacklist(
    AppSession session,
    int blockedUserId,
  ) async {
    final data = await _apiClient.delete(
      'account/blacklist/$blockedUserId',
      headers: session.authHeaders,
    );
    return _readSuccess(data);
  }

  Future<CurrentDeviceSession> getCurrentDeviceSession(
    AppSession session,
  ) async {
    final data = await _apiClient.get(
      'account/sessions/current',
      headers: session.authHeaders,
    );
    return CurrentDeviceSession.fromJson(
      _requireMap(data, 'Failed to load the current device session.'),
    );
  }

  Future<UserProfile> updateProfile(
    AppSession session, {
    required String nickname,
    required String avatarUrl,
    required String bio,
  }) async {
    final data = await _apiClient.put(
      'account/profile',
      headers: session.authHeaders,
      body: {
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'bio': bio,
      },
    );
    return UserProfile.fromJson(
      _requireMap(data, 'Failed to update the profile.'),
    );
  }

  Future<String> uploadAvatar(
    AppSession session, {
    required List<int> bytes,
    required String filename,
  }) async {
    if (bytes.isEmpty) {
      throw const ApiException('请选择头像文件。');
    }
    if (bytes.length > 5 * 1024 * 1024) {
      throw const ApiException('头像文件不能超过 5 MiB。');
    }

    final normalizedFilename = filename.trim().toLowerCase();
    final contentType = switch (normalizedFilename) {
      String value when value.endsWith('.jpg') || value.endsWith('.jpeg') =>
        'image/jpeg',
      String value when value.endsWith('.png') => 'image/png',
      _ => throw const ApiException('头像仅支持 JPEG 或 PNG 图片。'),
    };
    final data = await _apiClient.postMultipart(
      'account/avatar/upload',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
      headers: session.authHeaders,
    );
    final response = _requireMap(data, '头像上传响应无效。');
    final avatarUrl = '${response['avatarUrl'] ?? ''}'.trim();
    if (avatarUrl.isEmpty) {
      throw const ApiException('头像上传响应缺少 avatarUrl。');
    }
    return avatarUrl;
  }

  Future<PrivacySetting> updatePrivacy(
    AppSession session, {
    required bool allowFriendViewProfile,
    required bool allowTeammateViewStudy,
  }) async {
    final data = await _apiClient.put(
      'account/privacy',
      headers: session.authHeaders,
      body: {
        'allowFriendViewProfile': allowFriendViewProfile ? 1 : 0,
        'allowTeammateViewStudy': allowTeammateViewStudy ? 1 : 0,
      },
    );
    return PrivacySetting.fromJson(
      _requireMap(data, 'Failed to update privacy settings.'),
    );
  }

  Future<NotificationSetting> updateNotifications(
    AppSession session, {
    required bool mobilePushEnabled,
    required bool desktopNoticeEnabled,
    required bool teamRemindEnabled,
    required bool systemAnnouncementEnabled,
  }) async {
    final data = await _apiClient.put(
      'settings/notifications',
      headers: session.authHeaders,
      body: {
        'mobilePushEnabled': mobilePushEnabled ? 1 : 0,
        'desktopNoticeEnabled': desktopNoticeEnabled ? 1 : 0,
        'teamRemindEnabled': teamRemindEnabled ? 1 : 0,
        'systemAnnouncementEnabled': systemAnnouncementEnabled ? 1 : 0,
      },
    );
    return NotificationSetting.fromJson(
      _requireMap(data, 'Failed to update notification settings.'),
    );
  }

  Future<WidgetSetting> updateWidget(
    AppSession session, {
    required bool autoStart,
    required bool alwaysOnTop,
    required bool showPlan,
    required bool showTimer,
    required bool showMemo,
  }) async {
    final data = await _apiClient.put(
      'settings/widget',
      headers: session.authHeaders,
      body: {
        'autoStart': autoStart ? 1 : 0,
        'alwaysOnTop': alwaysOnTop ? 1 : 0,
        'showPlan': showPlan ? 1 : 0,
        'showTimer': showTimer ? 1 : 0,
        'showMemo': showMemo ? 1 : 0,
      },
    );
    return WidgetSetting.fromJson(
      _requireMap(data, 'Failed to update widget settings.'),
    );
  }

  Future<AppearanceSetting> updateAppearance(
    AppSession session, {
    required String themeMode,
    required String desktopEffect,
  }) async {
    final data = await _apiClient.put(
      'settings/appearance',
      headers: session.authHeaders,
      body: {
        'themeMode': themeMode,
        'desktopEffect': desktopEffect,
      },
    );
    return AppearanceSetting.fromJson(
      _requireMap(data, 'Failed to update appearance settings.'),
    );
  }

  Future<bool> clearCache(AppSession session) async {
    final data = await _apiClient.post(
      'settings/cache/clear',
      headers: session.authHeaders,
    );
    return _readSuccess(data);
  }

  Future<void> sendCancelCode(String email) async {
    await _apiClient.post(
      'auth/password/send-reset-code',
      body: {'email': email},
    );
  }

  Future<bool> cancelAccount(
    AppSession session, {
    required String password,
    required String emailCode,
  }) async {
    final data = await _apiClient.post(
      'account/cancel',
      headers: session.authHeaders,
      body: {
        'password': password,
        'emailCode': emailCode,
      },
    );
    return _readSuccess(data);
  }

  static Map<String, dynamic> _requireMap(dynamic data, String message) {
    if (data is! Map<String, dynamic>) {
      throw ApiException(message);
    }
    return data;
  }

  static bool _readSuccess(dynamic data) {
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success is bool) {
        return success;
      }
      if (success is num) {
        return success != 0;
      }
    }
    return false;
  }
}
