import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';

class MemoApi {
  MemoApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MemoOverview> getOverview(
    AppSession session, {
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final data = await _apiClient.get(
      'memos?pageNo=$pageNo&pageSize=$pageSize',
      headers: session.authHeaders,
    );
    return MemoOverview.fromJson(data);
  }

  Future<MemoOverview> getWidgetSummary(AppSession session) async {
    final data = await _apiClient.get(
      'memos/widget-summary',
      headers: session.authHeaders,
    );
    return MemoOverview.fromJson(data);
  }

  Future<MemoCardModel> getDetail(
    AppSession session, {
    required int memoId,
  }) async {
    final data = await _apiClient.get(
      'memos/$memoId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the memo detail.');
    }
    return MemoCardModel.fromJson(data);
  }

  Future<MemoCardModel> createMemo(
    AppSession session, {
    required MemoCardModel draft,
  }) async {
    final data = await _apiClient.post(
      'memos',
      body: draft.toSaveJson(),
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to create the memo.');
    }
    return MemoCardModel.fromJson(data);
  }

  Future<MemoCardModel> updateMemo(
    AppSession session, {
    required int memoId,
    required MemoCardModel draft,
  }) async {
    final data = await _apiClient.put(
      'memos/$memoId',
      body: draft.toSaveJson(),
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to update the memo.');
    }
    return MemoCardModel.fromJson(data);
  }

  Future<bool> deleteMemo(
    AppSession session, {
    required int memoId,
  }) async {
    final data = await _apiClient.delete(
      'memos/$memoId',
      headers: session.authHeaders,
    );
    return data == true;
  }
}
