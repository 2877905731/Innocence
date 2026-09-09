package com.innocence.server.modules.sync.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;

public record SyncImportPreviewRequest(
        @NotBlank @Size(max = 64) String localProfileId,
        @Min(0) @Max(10000) int pendingOperationCount,
        @Size(max = 3660) List<LocalDate> dailyPlanDates,
        @Valid @Size(max = 20) List<SyncManifestEntryRequest> entries,
        @Min(1) Integer clientVersion
) {
    public SyncImportPreviewRequest {
        dailyPlanDates = dailyPlanDates == null ? List.of() : List.copyOf(dailyPlanDates);
        entries = entries == null ? List.of() : List.copyOf(entries);
    }
}
