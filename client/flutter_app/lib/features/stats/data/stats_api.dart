import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';

class StatsApi {
  StatsApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<StatsOverview> getOverview(
    AppSession session, {
    int days = 7,
  }) async {
    final data = await _apiClient.get(
      'stats/overview?days=$days',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the statistics overview.');
    }
    return StatsOverview.fromJson(data);
  }
}
