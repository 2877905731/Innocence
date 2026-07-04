import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

class StudyPlanApi {
  StudyPlanApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TodayPlan> getTodayPlan(AppSession session) async {
    final data = await _apiClient.get(
      'plans/today',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the today plan.');
    }
    return TodayPlan.fromJson(data);
  }

  Future<TodayPlan> saveTodayPlan(
    AppSession session,
    TodayPlan plan,
  ) async {
    final data = await _apiClient.put(
      'plans/today',
      body: plan.toSaveJson(),
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to save the today plan.');
    }
    return TodayPlan.fromJson(data);
  }
}
