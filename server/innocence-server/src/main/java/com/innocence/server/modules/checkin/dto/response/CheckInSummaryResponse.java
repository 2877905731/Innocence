package com.innocence.server.modules.checkin.dto.response;

public class CheckInSummaryResponse {

    private int consecutiveDays;
    private int totalDays;
    private int totalStudyDurationMinutes;

    public int getConsecutiveDays() {
        return consecutiveDays;
    }

    public void setConsecutiveDays(int consecutiveDays) {
        this.consecutiveDays = consecutiveDays;
    }

    public int getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }

    public int getTotalStudyDurationMinutes() {
        return totalStudyDurationMinutes;
    }

    public void setTotalStudyDurationMinutes(int totalStudyDurationMinutes) {
        this.totalStudyDurationMinutes = totalStudyDurationMinutes;
    }
}
