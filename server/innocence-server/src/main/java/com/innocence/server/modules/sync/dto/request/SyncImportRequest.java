package com.innocence.server.modules.sync.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public record SyncImportRequest(
        @NotBlank @Size(max = 64) String localProfileId,
        @NotBlank @Size(max = 32) String targetUserNo,
        @Size(max = 24) String conflictStrategy,
        @Valid @Size(max = 500) List<SyncImportOperationRequest> operations
) {
    public SyncImportRequest {
        operations = operations == null ? List.of() : List.copyOf(operations);
    }
}
