package com.innocence.server.modules.checkin.dto.response;

public class CheckInStatusResponse {

    private String checkInDate;
    private boolean checkedInToday;
    private boolean canCheckInToday;
    private boolean todayPlanCompleted;
    private int todayPlanCompletedCount;
    private int todayPlanTotalCount;
    private int consecutiveDays;
    private int totalDays;
    private int totalStudyDurationMinutes;
    private int todayFailedAttempts;
    private String latestFailureReason;
    private String lastCheckInTime;
    private String lastFailureTime;

    public String getCheckInDate() {
        return checkInDate;
    }

    public void setCheckInDate(String checkInDate) {
        this.checkInDate = checkInDate;
    }

    public boolean isCheckedInToday() {
        return checkedInToday;
    }

    public void setCheckedInToday(boolean checkedInToday) {
        this.checkedInToday = checkedInToday;
    }

    public boolean isCanCheckInToday() {
        return canCheckInToday;
    }

    public void setCanCheckInToday(boolean canCheckInToday) {
        this.canCheckInToday = canCheckInToday;
    }

    public boolean isTodayPlanCompleted() {
        return todayPlanCompleted;
    }

    public void setTodayPlanCompleted(boolean todayPlanCompleted) {
        this.todayPlanCompleted = todayPlanCompleted;
    }

    public int getTodayPlanCompletedCount() {
        return todayPlanCompletedCount;
    }

    public void setTodayPlanCompletedCount(int todayPlanCompletedCount) {
        this.todayPlanCompletedCount = todayPlanCompletedCount;
    }

    public int getTodayPlanTotalCount() {
        return todayPlanTotalCount;
    }

    public void setTodayPlanTotalCount(int todayPlanTotalCount) {
        this.todayPlanTotalCount = todayPlanTotalCount;
    }

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

    public int getTodayFailedAttempts() {
        return todayFailedAttempts;
    }

    public void setTodayFailedAttempts(int todayFailedAttempts) {
        this.todayFailedAttempts = todayFailedAttempts;
    }

    public String getLatestFailureReason() {
        return latestFailureReason;
    }

    public void setLatestFailureReason(String latestFailureReason) {
        this.latestFailureReason = latestFailureReason;
    }

    public String getLastCheckInTime() {
        return lastCheckInTime;
    }

    public void setLastCheckInTime(String lastCheckInTime) {
        this.lastCheckInTime = lastCheckInTime;
    }

    public String getLastFailureTime() {
        return lastFailureTime;
    }

    public void setLastFailureTime(String lastFailureTime) {
        this.lastFailureTime = lastFailureTime;
    }
}
