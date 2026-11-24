package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.util.List;

public record ReorderPlanRequest(
        @NotNull @Pattern(regexp = "today|annual|subtasks") String scope,
        LocalDate planDate,
        @Min(1) @Max(9999) Integer year,
        @Positive Long segmentId,
        @PositiveOrZero Long baseRevision,
        @NotNull @Size(max = 1000) List<@NotNull @Valid Item> items
) {
    public record Item(@NotNull @Positive Long id, @PositiveOrZero Integer revision) {}
}
