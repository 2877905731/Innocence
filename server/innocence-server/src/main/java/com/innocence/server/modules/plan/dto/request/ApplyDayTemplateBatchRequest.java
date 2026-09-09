package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ApplyDayTemplateBatchRequest {

    @NotEmpty(message = "At least one plan date is required")
    @Size(max = 62, message = "At most 62 dates may be changed at once")
    private List<LocalDate> planDates = new ArrayList<>();

    private String strategy = "skip";

    public List<LocalDate> getPlanDates() { return planDates; }
    public void setPlanDates(List<LocalDate> planDates) {
        this.planDates = planDates == null ? new ArrayList<>() : planDates;
    }
    public String getStrategy() { return strategy; }
    public void setStrategy(String strategy) { this.strategy = strategy; }
}
