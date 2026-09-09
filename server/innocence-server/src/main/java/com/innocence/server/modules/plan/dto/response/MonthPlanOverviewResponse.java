package com.innocence.server.modules.plan.dto.response;

import java.util.List;

public record MonthPlanOverviewResponse(
        String month,
        List<MonthPlanDayResponse> days
) {
}
