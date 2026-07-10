package com.innocence.server.modules.stats.domain;

import java.time.LocalDate;

public class StatsDayValue {

    private LocalDate statsDate;
    private Integer value;

    public LocalDate getStatsDate() {
        return statsDate;
    }

    public void setStatsDate(LocalDate statsDate) {
        this.statsDate = statsDate;
    }

    public Integer getValue() {
        return value;
    }

    public void setValue(Integer value) {
        this.value = value;
    }
}
