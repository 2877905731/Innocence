package com.innocence.server.modules.team.domain;

public class TeammateStatsRow {

    private Long teamId;
    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private Integer allowTeammateViewStudy;
    private Integer studyDurationTotalMinutes;
    private Integer checkInDaysTotal;
    private Integer todayCompletedCount;
    private Integer todayTotalCount;
    private Integer todayStudyDurationMinutes;
    private Integer activeStudyFlag;
    private String activeTaskName;
    private String activeStageName;
    private Integer reminderCountToday;

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserNo() {
        return userNo;
    }

    public void setUserNo(String userNo) {
        this.userNo = userNo;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public Integer getAllowTeammateViewStudy() {
        return allowTeammateViewStudy;
    }

    public void setAllowTeammateViewStudy(Integer allowTeammateViewStudy) {
        this.allowTeammateViewStudy = allowTeammateViewStudy;
    }

    public Integer getStudyDurationTotalMinutes() {
        return studyDurationTotalMinutes;
    }

    public void setStudyDurationTotalMinutes(Integer studyDurationTotalMinutes) {
        this.studyDurationTotalMinutes = studyDurationTotalMinutes;
    }

    public Integer getCheckInDaysTotal() {
        return checkInDaysTotal;
    }

    public void setCheckInDaysTotal(Integer checkInDaysTotal) {
        this.checkInDaysTotal = checkInDaysTotal;
    }

    public Integer getTodayCompletedCount() {
        return todayCompletedCount;
    }

    public void setTodayCompletedCount(Integer todayCompletedCount) {
        this.todayCompletedCount = todayCompletedCount;
    }

    public Integer getTodayTotalCount() {
        return todayTotalCount;
    }

    public void setTodayTotalCount(Integer todayTotalCount) {
        this.todayTotalCount = todayTotalCount;
    }

    public Integer getTodayStudyDurationMinutes() {
        return todayStudyDurationMinutes;
    }

    public void setTodayStudyDurationMinutes(Integer todayStudyDurationMinutes) {
        this.todayStudyDurationMinutes = todayStudyDurationMinutes;
    }

    public Integer getActiveStudyFlag() {
        return activeStudyFlag;
    }

    public void setActiveStudyFlag(Integer activeStudyFlag) {
        this.activeStudyFlag = activeStudyFlag;
    }

    public String getActiveTaskName() {
        return activeTaskName;
    }

    public void setActiveTaskName(String activeTaskName) {
        this.activeTaskName = activeTaskName;
    }

    public String getActiveStageName() {
        return activeStageName;
    }

    public void setActiveStageName(String activeStageName) {
        this.activeStageName = activeStageName;
    }

    public Integer getReminderCountToday() {
        return reminderCountToday;
    }

    public void setReminderCountToday(Integer reminderCountToday) {
        this.reminderCountToday = reminderCountToday;
    }
}
