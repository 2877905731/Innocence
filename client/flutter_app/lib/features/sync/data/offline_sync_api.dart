import 'package:innocence_flutter/core/local/offline_sync_models.dart';
import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';

class OfflineSyncApi {
  OfflineSyncApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<OfflineImportPreview> preview(
    AppSession session,
    OfflineImportManifest manifest,
  ) async {
    final data = await _apiClient.post(
      'sync/import-preview',
      body: manifest.toJson(),
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to preview offline data import.');
    }
    return OfflineImportPreview.fromJson(manifest.localProfileId, data);
  }

  Future<OfflineImportResult> import(
    AppSession session, {
    required String localProfileId,
    required String targetUserNo,
    required OfflineConflictStrategy conflictStrategy,
    required List<OfflineSyncOperation> operations,
  }) async {
    final data = await _apiClient.post(
      'sync/import',
      body: {
        'localProfileId': localProfileId,
        'targetUserNo': targetUserNo,
        'conflictStrategy': conflictStrategy.apiValue,
        'operations': operations.map((item) => item.toJson()).toList(),
      },
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to import offline data.');
    }
    return OfflineImportResult.fromJson(data);
  }
}
