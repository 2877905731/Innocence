package com.innocence.server.modules.plan.dto.response;

public record AnnualMonthSummaryResponse(
        int month,
        int plannedDayCount,
        int completedTaskCount,
        int totalTaskCount,
        int totalPlannedMinutes
) {
}
