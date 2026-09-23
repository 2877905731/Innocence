package com.innocence.server.modules.plan.dto.response;

public record AnnualPlanSubtaskResponse(
        String id,
        String title,
        String detail,
        boolean completed,
        int sortOrder
) {
}
