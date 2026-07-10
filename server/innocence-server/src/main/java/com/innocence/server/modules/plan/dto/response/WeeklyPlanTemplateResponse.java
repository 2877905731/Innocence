package com.innocence.server.modules.plan.dto.response;

import java.util.ArrayList;
import java.util.List;

public class WeeklyPlanTemplateResponse {

    private Long id;
    private String templateName;
    private String sourcePlanName;
    private int itemCount;
    private int totalPlannedMinutes;
    private List<TodayPlanItemResponse> items = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }

    public int getTotalPlannedMinutes() {
        return totalPlannedMinutes;
    }

    public void setTotalPlannedMinutes(int totalPlannedMinutes) {
        this.totalPlannedMinutes = totalPlannedMinutes;
    }

    public List<TodayPlanItemResponse> getItems() {
        return items;
    }

    public void setItems(List<TodayPlanItemResponse> items) {
        this.items = items == null ? new ArrayList<>() : items;
    }
}
