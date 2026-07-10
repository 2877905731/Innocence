package com.innocence.server.modules.plan.dto.response;

public class WeekPlanDayResponse {

    private String planDate;
    private String weekdayLabel;
    private boolean today;
    private boolean hasPlan;
    private String planName;
    private int completedCount;
    private int totalCount;
    private int totalPlannedMinutes;
    private int completedPlannedMinutes;

    public String getPlanDate() {
        return planDate;
    }

    public void setPlanDate(String planDate) {
        this.planDate = planDate;
    }

    public String getWeekdayLabel() {
        return weekdayLabel;
    }

    public void setWeekdayLabel(String weekdayLabel) {
        this.weekdayLabel = weekdayLabel;
    }

    public boolean isToday() {
        return today;
    }

    public void setToday(boolean today) {
        this.today = today;
    }

    public boolean isHasPlan() {
        return hasPlan;
    }

    public void setHasPlan(boolean hasPlan) {
        this.hasPlan = hasPlan;
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
}
