package com.innocence.server.modules.stats.domain;

import java.time.LocalDate;

public class StatsCheckInDayValue {

    private LocalDate statsDate;
    private Integer successCount;
    private Integer failedAttempts;

    public LocalDate getStatsDate() {
        return statsDate;
    }

    public void setStatsDate(LocalDate statsDate) {
        this.statsDate = statsDate;
    }

    public Integer getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }

    public Integer getFailedAttempts() {
        return failedAttempts;
    }

    public void setFailedAttempts(Integer failedAttempts) {
        this.failedAttempts = failedAttempts;
    }
}
