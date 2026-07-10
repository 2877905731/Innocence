package com.innocence.server.modules.stats.domain;

import java.time.LocalDate;

public class StatsPlanDayValue {

    private LocalDate statsDate;
    private Integer completedCount;
    private Integer totalCount;

    public LocalDate getStatsDate() {
        return statsDate;
    }

    public void setStatsDate(LocalDate statsDate) {
        this.statsDate = statsDate;
    }

    public Integer getCompletedCount() {
        return completedCount;
    }

    public void setCompletedCount(Integer completedCount) {
        this.completedCount = completedCount;
    }

    public Integer getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(Integer totalCount) {
        this.totalCount = totalCount;
    }
}
