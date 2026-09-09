class OfflineImportManifest {
  const OfflineImportManifest({
    required this.localProfileId,
    required this.pendingOperationCount,
    required this.dailyPlanDates,
    required this.operationCounts,
    this.clientVersion = 1,
  });

  final String localProfileId;
  final int pendingOperationCount;
  final List<String> dailyPlanDates;
  final Map<String, int> operationCounts;
  final int clientVersion;

  Map<String, dynamic> toJson() => {
        'localProfileId': localProfileId,
        'pendingOperationCount': pendingOperationCount,
        'dailyPlanDates': dailyPlanDates,
        'entries': operationCounts.entries
            .map(
              (entry) => {
                'aggregateType': entry.key,
                'operationCount': entry.value,
              },
            )
            .toList(),
        'clientVersion': clientVersion,
      };
}

class OfflineSyncOperation {
  const OfflineSyncOperation({
    required this.operationId,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationType,
    required this.payload,
    required this.clientVersion,
    required this.createdAt,
    required this.idempotencyKey,
  });

  final String operationId;
  final String aggregateType;
  final String aggregateId;
  final String operationType;
  final Map<String, dynamic> payload;
  final int clientVersion;
  final String createdAt;
  final String idempotencyKey;

  Map<String, dynamic> toJson() => {
        'operationId': operationId,
        'aggregateType': aggregateType,
        'aggregateId': aggregateId,
        'operationType': operationType,
        'payload': payload,
        'clientVersion': clientVersion,
        'createdAt': createdAt,
        'idempotencyKey': idempotencyKey,
      };
}

class OfflineImportPreview {
  const OfflineImportPreview({
    required this.localProfileId,
    required this.targetUserId,
    required this.targetUserNo,
    required this.targetNickname,
    required this.pendingOperationCount,
    required this.conflictCount,
    required this.dailyPlanConflictDates,
  });

  final String localProfileId;
  final int targetUserId;
  final String targetUserNo;
  final String targetNickname;
  final int pendingOperationCount;
  final int conflictCount;
  final List<String> dailyPlanConflictDates;

  factory OfflineImportPreview.fromJson(
    String localProfileId,
    Map<String, dynamic> json,
  ) {
    final conflicts =
        json['dailyPlanConflictDates'] as List<dynamic>? ?? const [];
    return OfflineImportPreview(
      localProfileId: localProfileId,
      targetUserId: _toInt(json['targetUserId']),
      targetUserNo: '${json['targetUserNo'] ?? ''}',
      targetNickname: '${json['targetNickname'] ?? ''}',
      pendingOperationCount: _toInt(json['pendingOperationCount']),
      conflictCount: _toInt(json['conflictCount']),
      dailyPlanConflictDates: conflicts.map((item) => '$item').toList(),
    );
  }
}

enum OfflineConflictStrategy {
  keepServer('keep_server'),
  overwrite('overwrite');

  const OfflineConflictStrategy(this.apiValue);
  final String apiValue;
}

class OfflineImportItemResult {
  const OfflineImportItemResult({
    required this.operationId,
    required this.aggregateType,
    required this.aggregateId,
    required this.status,
    required this.message,
    required this.serverAggregateId,
  });

  final String operationId;
  final String aggregateType;
  final String aggregateId;
  final String status;
  final String message;
  final String serverAggregateId;

  bool get accepted => status == 'accepted';

  factory OfflineImportItemResult.fromJson(Map<String, dynamic> json) =>
      OfflineImportItemResult(
        operationId: '${json['operationId'] ?? ''}',
        aggregateType: '${json['aggregateType'] ?? ''}',
        aggregateId: '${json['aggregateId'] ?? ''}',
        status: '${json['status'] ?? 'rejected'}',
        message: '${json['message'] ?? ''}',
        serverAggregateId: '${json['serverAggregateId'] ?? ''}',
      );
}

class OfflineImportResult {
  const OfflineImportResult({
    required this.acceptedCount,
    required this.rejectedCount,
    required this.conflictCount,
    required this.items,
  });

  final int acceptedCount;
  final int rejectedCount;
  final int conflictCount;
  final List<OfflineImportItemResult> items;

  factory OfflineImportResult.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];
    return OfflineImportResult(
      acceptedCount: _toInt(json['acceptedCount']),
      rejectedCount: _toInt(json['rejectedCount']),
      conflictCount: _toInt(json['conflictCount']),
      items: items
          .whereType<Map<String, dynamic>>()
          .map(OfflineImportItemResult.fromJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('$value') ?? 0;
}
