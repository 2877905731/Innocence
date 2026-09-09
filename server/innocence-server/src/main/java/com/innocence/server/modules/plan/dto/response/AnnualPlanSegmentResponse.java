package com.innocence.server.modules.plan.dto.response;

public record AnnualPlanSegmentResponse(
        String id,
        String clientEntityId,
        int year,
        String title,
        int startMonth,
        int endMonth,
        String colorKey,
        int sortOrder,
        String note,
        int revision,
        String updateTime
) {
}
