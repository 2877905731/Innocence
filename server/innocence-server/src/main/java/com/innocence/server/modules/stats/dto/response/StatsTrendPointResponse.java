package com.innocence.server.modules.stats.dto.response;

public class StatsTrendPointResponse {

    private String date;
    private String label;
    private boolean hasPlan;
    private int studyDurationMinutes;
    private int pomodoroCompletedCount;
    private int checkInSuccessCount;
    private int failedCheckInAttempts;
    private int planCompletedCount;
    private int planTotalCount;
    private int planCompletionRate;
    private int checkInSuccessRate;

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public boolean isHasPlan() {
        return hasPlan;
    }

    public void setHasPlan(boolean hasPlan) {
        this.hasPlan = hasPlan;
    }

    public int getStudyDurationMinutes() {
        return studyDurationMinutes;
    }

    public void setStudyDurationMinutes(int studyDurationMinutes) {
        this.studyDurationMinutes = studyDurationMinutes;
    }

    public int getPomodoroCompletedCount() {
        return pomodoroCompletedCount;
    }

    public void setPomodoroCompletedCount(int pomodoroCompletedCount) {
        this.pomodoroCompletedCount = pomodoroCompletedCount;
    }

    public int getCheckInSuccessCount() {
        return checkInSuccessCount;
    }

    public void setCheckInSuccessCount(int checkInSuccessCount) {
        this.checkInSuccessCount = checkInSuccessCount;
    }

    public int getFailedCheckInAttempts() {
        return failedCheckInAttempts;
    }

    public void setFailedCheckInAttempts(int failedCheckInAttempts) {
        this.failedCheckInAttempts = failedCheckInAttempts;
    }

    public int getPlanCompletedCount() {
        return planCompletedCount;
    }

    public void setPlanCompletedCount(int planCompletedCount) {
        this.planCompletedCount = planCompletedCount;
    }

    public int getPlanTotalCount() {
        return planTotalCount;
    }

    public void setPlanTotalCount(int planTotalCount) {
        this.planTotalCount = planTotalCount;
    }

    public int getPlanCompletionRate() {
        return planCompletionRate;
    }

    public void setPlanCompletionRate(int planCompletionRate) {
        this.planCompletionRate = planCompletionRate;
    }

    public int getCheckInSuccessRate() {
        return checkInSuccessRate;
    }

    public void setCheckInSuccessRate(int checkInSuccessRate) {
        this.checkInSuccessRate = checkInSuccessRate;
    }
}
