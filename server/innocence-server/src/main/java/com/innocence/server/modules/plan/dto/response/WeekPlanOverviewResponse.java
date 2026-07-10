package com.innocence.server.modules.plan.dto.response;

import java.util.ArrayList;
import java.util.List;

public class WeekPlanOverviewResponse {

    private String weekStartDate;
    private String weekEndDate;
    private List<WeekPlanDayResponse> days = new ArrayList<>();

    public String getWeekStartDate() {
        return weekStartDate;
    }

    public void setWeekStartDate(String weekStartDate) {
        this.weekStartDate = weekStartDate;
    }

    public String getWeekEndDate() {
        return weekEndDate;
    }

    public void setWeekEndDate(String weekEndDate) {
        this.weekEndDate = weekEndDate;
    }

    public List<WeekPlanDayResponse> getDays() {
        return days;
    }

    public void setDays(List<WeekPlanDayResponse> days) {
        this.days = days == null ? new ArrayList<>() : days;
    }
}
