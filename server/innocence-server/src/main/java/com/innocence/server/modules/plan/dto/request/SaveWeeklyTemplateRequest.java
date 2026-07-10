package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

import java.util.ArrayList;
import java.util.List;

public class SaveWeeklyTemplateRequest {

    @NotBlank(message = "Template name is required")
    private String templateName;

    private String sourcePlanName;

    @Valid
    private List<TodayPlanItemRequest> items = new ArrayList<>();

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public String getSourcePlanName() {
        return sourcePlanName;
    }

    public void setSourcePlanName(String sourcePlanName) {
        this.sourcePlanName = sourcePlanName;
    }

    public List<TodayPlanItemRequest> getItems() {
        return items;
    }

    public void setItems(List<TodayPlanItemRequest> items) {
        this.items = items == null ? new ArrayList<>() : items;
    }
}
