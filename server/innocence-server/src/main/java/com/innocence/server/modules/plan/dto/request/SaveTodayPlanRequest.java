package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.Valid;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class SaveTodayPlanRequest {

    private LocalDate planDate;
    private String planName;

    @Valid
    private List<TodayPlanItemRequest> items = new ArrayList<>();

    public LocalDate getPlanDate() {
        return planDate;
    }

    public void setPlanDate(LocalDate planDate) {
        this.planDate = planDate;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(String planName) {
        this.planName = planName;
    }

    public List<TodayPlanItemRequest> getItems() {
        return items;
    }

    public void setItems(List<TodayPlanItemRequest> items) {
        this.items = items == null ? new ArrayList<>() : items;
    }
}
