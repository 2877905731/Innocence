package com.innocence.server.modules.sync.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SyncManifestEntryRequest(
        @NotBlank @Size(max = 32) String aggregateType,
        @Min(0) @Max(10000) int operationCount
) {
}
