import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/week_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';

class StudyPlanApi {
  StudyPlanApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TodayPlan> getTodayPlan(
    AppSession session, {
    String? planDate,
  }) async {
    final data = await _apiClient.get(
      _withQuery(
        'plans/today',
        {'date': planDate},
      ),
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

  Future<WeekPlanOverview> getWeekPlanOverview(
    AppSession session, {
    String? anchorDate,
  }) async {
    final data = await _apiClient.get(
      _withQuery(
        'plans/week',
        {'anchorDate': anchorDate},
      ),
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the week plan overview.');
    }
    return WeekPlanOverview.fromJson(data);
  }

  Future<List<WeeklyPlanTemplate>> getWeeklyTemplates(AppSession session) async {
    final data = await _apiClient.get(
      'plans/weekly-templates',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load weekly templates.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(WeeklyPlanTemplate.fromJson)
        .toList();
  }

  Future<List<WeeklyPlanTemplate>> saveWeeklyTemplate(
    AppSession session, {
    required String templateName,
    required TodayPlan sourcePlan,
  }) async {
    await _apiClient.put(
      'plans/weekly-templates',
      body: {
        'templateName': templateName,
        'sourcePlanName': sourcePlan.planName,
        'items': sourcePlan.items.map((item) => item.toSaveJson()).toList(),
      },
      headers: session.authHeaders,
    );
    return getWeeklyTemplates(session);
  }

  Future<List<WeeklyPlanTemplate>> deleteWeeklyTemplate(
    AppSession session, {
    required int templateId,
  }) async {
    await _apiClient.delete(
      'plans/weekly-templates/$templateId',
      headers: session.authHeaders,
    );
    return getWeeklyTemplates(session);
  }

  Future<TodayPlan> applyWeeklyTemplate(
    AppSession session, {
    required int templateId,
    String? planDate,
  }) async {
    final data = await _apiClient.post(
      'plans/weekly-templates/$templateId/apply',
      body: {
        if (planDate != null && planDate.isNotEmpty) 'planDate': planDate,
      },
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to apply weekly template.');
    }
    return TodayPlan.fromJson(data);
  }

  String _withQuery(String path, Map<String, String?> query) {
    final entries = query.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value!)}',
        )
        .toList();
    if (entries.isEmpty) {
      return path;
    }
    return '$path?${entries.join('&')}';
  }
}
