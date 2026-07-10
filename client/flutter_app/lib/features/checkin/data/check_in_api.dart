import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';
import 'package:innocence_flutter/features/checkin/domain/models/check_in_submit_result.dart';

class CheckInApi {
  CheckInApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CheckInStatus> getTodayStatus(AppSession session) async {
    final data = await _apiClient.get(
      'check-in/today',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load today check-in status.');
    }
    return CheckInStatus.fromJson(data);
  }

  Future<CheckInSubmitResult> submitTodayCheckIn(AppSession session) async {
    final data = await _apiClient.post(
      'check-in/submit',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to submit today check-in.');
    }
    return CheckInSubmitResult.fromJson(data);
  }

  Future<bool> deleteFailureRecord(
    AppSession session, {
    required String date,
  }) async {
    final data = await _apiClient.delete(
      'check-in/failure?date=$date',
      headers: session.authHeaders,
    );
    if (data is bool) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return data == true;
  }
}
