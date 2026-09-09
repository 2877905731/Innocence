package com.innocence.server.modules.sync.dto.response;

public record SyncImportItemResponse(
        String operationId,
        String aggregateType,
        String aggregateId,
        String status,
        String message,
        String serverAggregateId
) {
}
