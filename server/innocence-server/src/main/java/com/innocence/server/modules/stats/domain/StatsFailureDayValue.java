package com.innocence.server.modules.stats.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class StatsFailureDayValue {

    private LocalDate statsDate;
    private Integer attemptCount;
    private String latestReason;
    private Integer planCompletedCount;
    private Integer planTotalCount;
    private Integer studyDurationMinutes;
    private LocalDateTime lastAttemptTime;

    public LocalDate getStatsDate() {
        return statsDate;
    }

    public void setStatsDate(LocalDate statsDate) {
        this.statsDate = statsDate;
    }

    public Integer getAttemptCount() {
        return attemptCount;
    }

    public void setAttemptCount(Integer attemptCount) {
        this.attemptCount = attemptCount;
    }

    public String getLatestReason() {
        return latestReason;
    }

    public void setLatestReason(String latestReason) {
        this.latestReason = latestReason;
    }

    public Integer getPlanCompletedCount() {
        return planCompletedCount;
    }

    public void setPlanCompletedCount(Integer planCompletedCount) {
        this.planCompletedCount = planCompletedCount;
    }

    public Integer getPlanTotalCount() {
        return planTotalCount;
    }

    public void setPlanTotalCount(Integer planTotalCount) {
        this.planTotalCount = planTotalCount;
    }

    public Integer getStudyDurationMinutes() {
        return studyDurationMinutes;
    }

    public void setStudyDurationMinutes(Integer studyDurationMinutes) {
        this.studyDurationMinutes = studyDurationMinutes;
    }

    public LocalDateTime getLastAttemptTime() {
        return lastAttemptTime;
    }

    public void setLastAttemptTime(LocalDateTime lastAttemptTime) {
        this.lastAttemptTime = lastAttemptTime;
    }
}
