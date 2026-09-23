package com.innocence.server.modules.plan.dto.response;

import java.util.List;

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
        int progressPercent,
        int revision,
        String updateTime,
        List<AnnualPlanSubtaskResponse> subtasks
) {
}
