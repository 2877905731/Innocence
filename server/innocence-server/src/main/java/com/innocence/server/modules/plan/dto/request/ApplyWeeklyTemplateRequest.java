package com.innocence.server.modules.plan.dto.request;

import java.time.LocalDate;

public class ApplyWeeklyTemplateRequest {

    private LocalDate planDate;

    public LocalDate getPlanDate() {
        return planDate;
    }

    public void setPlanDate(LocalDate planDate) {
        this.planDate = planDate;
    }
}
