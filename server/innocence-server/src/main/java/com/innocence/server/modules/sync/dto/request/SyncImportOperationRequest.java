package com.innocence.server.modules.sync.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.Map;

public record SyncImportOperationRequest(
        @NotBlank @Size(max = 64) String operationId,
        @NotBlank @Size(max = 32) String aggregateType,
        @NotBlank @Size(max = 128) String aggregateId,
        @NotBlank @Size(max = 24) String operationType,
        @NotNull Map<String, Object> payload,
        @Min(1) Integer clientVersion,
        @NotBlank @Size(max = 64) String idempotencyKey,
        @NotBlank @Size(max = 64) String createdAt
) {
}
