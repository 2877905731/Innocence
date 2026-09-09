package com.innocence.server.modules.plan.dto.response;

import java.util.List;

public record AnnualPlanOverviewResponse(
        int year,
        List<AnnualMonthSummaryResponse> months,
        List<AnnualPlanSegmentResponse> segments
) {
}
