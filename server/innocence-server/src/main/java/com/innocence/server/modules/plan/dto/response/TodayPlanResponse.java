package com.innocence.server.modules.plan.dto.response;

import java.util.ArrayList;
import java.util.List;

public class TodayPlanResponse {

    private String planDate;
    private String planName;
    private int completedCount;
    private int totalCount;
    private int totalPlannedMinutes;
    private int completedPlannedMinutes;
    private List<TodayPlanItemResponse> items = new ArrayList<>();

    public String getPlanDate() {
        return planDate;
    }

    public void setPlanDate(String planDate) {
        this.planDate = planDate;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(String planName) {
        this.planName = planName;
    }

    public int getCompletedCount() {
        return completedCount;
    }

    public void setCompletedCount(int completedCount) {
        this.completedCount = completedCount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public int getTotalPlannedMinutes() {
        return totalPlannedMinutes;
    }

    public void setTotalPlannedMinutes(int totalPlannedMinutes) {
        this.totalPlannedMinutes = totalPlannedMinutes;
    }

    public int getCompletedPlannedMinutes() {
        return completedPlannedMinutes;
    }

    public void setCompletedPlannedMinutes(int completedPlannedMinutes) {
        this.completedPlannedMinutes = completedPlannedMinutes;
    }

    public List<TodayPlanItemResponse> getItems() {
        return items;
    }

    public void setItems(List<TodayPlanItemResponse> items) {
        this.items = items == null ? new ArrayList<>() : items;
    }
}
