package com.innocence.server.modules.stats.dto.response;

import com.innocence.server.modules.team.dto.response.TeammateStatsResponse;

import java.util.ArrayList;
import java.util.List;

public class StatsOverviewResponse {

    private int rangeDays;
    private int activePlanDays;
    private int totalStudyDurationMinutes;
    private int totalPomodoroCompleted;
    private int totalCheckInDays;
    private int totalFailedCheckInAttempts;
    private int planCompletionRate;
    private int checkInSuccessRate;
    private List<StatsTrendPointResponse> trend = new ArrayList<>();
    private List<StatsFailureRecordResponse> failures = new ArrayList<>();
    private List<TeammateStatsResponse> teammates = new ArrayList<>();

    public int getRangeDays() {
        return rangeDays;
    }

    public void setRangeDays(int rangeDays) {
        this.rangeDays = rangeDays;
    }

    public int getActivePlanDays() {
        return activePlanDays;
    }

    public void setActivePlanDays(int activePlanDays) {
        this.activePlanDays = activePlanDays;
    }

    public int getTotalStudyDurationMinutes() {
        return totalStudyDurationMinutes;
    }

    public void setTotalStudyDurationMinutes(int totalStudyDurationMinutes) {
        this.totalStudyDurationMinutes = totalStudyDurationMinutes;
    }

    public int getTotalPomodoroCompleted() {
        return totalPomodoroCompleted;
    }

    public void setTotalPomodoroCompleted(int totalPomodoroCompleted) {
        this.totalPomodoroCompleted = totalPomodoroCompleted;
    }

    public int getTotalCheckInDays() {
        return totalCheckInDays;
    }

    public void setTotalCheckInDays(int totalCheckInDays) {
        this.totalCheckInDays = totalCheckInDays;
    }

    public int getTotalFailedCheckInAttempts() {
        return totalFailedCheckInAttempts;
    }

    public void setTotalFailedCheckInAttempts(int totalFailedCheckInAttempts) {
        this.totalFailedCheckInAttempts = totalFailedCheckInAttempts;
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

    public List<StatsTrendPointResponse> getTrend() {
        return trend;
    }

    public void setTrend(List<StatsTrendPointResponse> trend) {
        this.trend = trend == null ? new ArrayList<>() : trend;
    }

    public List<StatsFailureRecordResponse> getFailures() {
        return failures;
    }

    public void setFailures(List<StatsFailureRecordResponse> failures) {
        this.failures = failures == null ? new ArrayList<>() : failures;
    }

    public List<TeammateStatsResponse> getTeammates() {
        return teammates;
    }

    public void setTeammates(List<TeammateStatsResponse> teammates) {
        this.teammates = teammates == null ? new ArrayList<>() : teammates;
    }
}
