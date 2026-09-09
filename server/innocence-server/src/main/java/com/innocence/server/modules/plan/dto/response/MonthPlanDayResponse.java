package com.innocence.server.modules.plan.dto.response;

public record MonthPlanDayResponse(
        String planDate,
        boolean hasPlan,
        String planName,
        int completedCount,
        int totalCount,
        int totalPlannedMinutes,
        boolean templateApplied
) {
}
