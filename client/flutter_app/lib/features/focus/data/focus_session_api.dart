import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

class FocusSessionApi {
  FocusSessionApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<FocusSession> getCurrentSession(AppSession session) async {
    final data = await _apiClient.get(
      'focus/session/current',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the current focus session.');
    }
    return FocusSession.fromJson(data);
  }

  Future<FocusSession> startSession(
    AppSession session, {
    required DateTime endTime,
    String? taskName,
    bool bindPomodoro = false,
    int pomodoroStudyMinutes = 0,
    int pomodoroBreakMinutes = 0,
  }) async {
    final data = await _apiClient.post(
      'focus/session/start',
      headers: session.authHeaders,
      body: {
        'taskName': taskName,
        'endTime': endTime.toIso8601String(),
        'bindPomodoro': bindPomodoro,
        'pomodoroStudyMinutes': pomodoroStudyMinutes,
        'pomodoroBreakMinutes': pomodoroBreakMinutes,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to start the focus session.');
    }
    return FocusSession.fromJson(data);
  }

  Future<FocusSession> finishSession(
    AppSession session, {
    int? sessionId,
  }) async {
    final data = await _apiClient.post(
      'focus/session/finish',
      headers: session.authHeaders,
      body: {
        if (sessionId != null && sessionId > 0) 'sessionId': sessionId,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to finish the focus session.');
    }
    return FocusSession.fromJson(data);
  }
}
