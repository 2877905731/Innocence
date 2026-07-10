import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/notifications/domain/models/notification_overview.dart';

class NotificationApi {
  NotificationApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<NotificationOverview> getOverview(
    AppSession session, {
    int limit = 40,
  }) async {
    final data = await _apiClient.get(
      'notifications/overview?limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load notifications.');
    }
    return NotificationOverview.fromJson(data);
  }

  Future<NotificationOverview> markRead(
    AppSession session, {
    required int notificationId,
  }) async {
    final data = await _apiClient.post(
      'notifications/read?notificationId=$notificationId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to update the notification.');
    }
    return NotificationOverview.fromJson(data);
  }

  Future<NotificationOverview> markAllRead(AppSession session) async {
    final data = await _apiClient.post(
      'notifications/read-all',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to update notifications.');
    }
    return NotificationOverview.fromJson(data);
  }
}
