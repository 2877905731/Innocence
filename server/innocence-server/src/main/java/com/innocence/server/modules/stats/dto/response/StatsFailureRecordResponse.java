package com.innocence.server.modules.stats.dto.response;

public class StatsFailureRecordResponse {

    private String date;
    private String label;
    private int attemptCount;
    private String latestReason;
    private int planCompletedCount;
    private int planTotalCount;
    private int studyDurationMinutes;
    private String lastAttemptTime;

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

    public int getAttemptCount() {
        return attemptCount;
    }

    public void setAttemptCount(int attemptCount) {
        this.attemptCount = attemptCount;
    }

    public String getLatestReason() {
        return latestReason;
    }

    public void setLatestReason(String latestReason) {
        this.latestReason = latestReason;
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

    public int getStudyDurationMinutes() {
        return studyDurationMinutes;
    }

    public void setStudyDurationMinutes(int studyDurationMinutes) {
        this.studyDurationMinutes = studyDurationMinutes;
    }

    public String getLastAttemptTime() {
        return lastAttemptTime;
    }

    public void setLastAttemptTime(String lastAttemptTime) {
        this.lastAttemptTime = lastAttemptTime;
    }
}
