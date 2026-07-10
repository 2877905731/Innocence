package com.innocence.server.modules.team.dto.response;

public class TeamMemberResponse {

    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private String role;
    private boolean allowStudyView;
    private int totalStudyDurationMinutes;
    private int totalCheckInDays;
    private int todayCompletedCount;
    private int todayTotalCount;
    private int todayStudyDurationMinutes;
    private boolean activeStudy;
    private String activeTaskName;
    private String activeStageName;
    private boolean owner;

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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isAllowStudyView() {
        return allowStudyView;
    }

    public void setAllowStudyView(boolean allowStudyView) {
        this.allowStudyView = allowStudyView;
    }

    public int getTotalStudyDurationMinutes() {
        return totalStudyDurationMinutes;
    }

    public void setTotalStudyDurationMinutes(int totalStudyDurationMinutes) {
        this.totalStudyDurationMinutes = totalStudyDurationMinutes;
    }

    public int getTotalCheckInDays() {
        return totalCheckInDays;
    }

    public void setTotalCheckInDays(int totalCheckInDays) {
        this.totalCheckInDays = totalCheckInDays;
    }

    public int getTodayCompletedCount() {
        return todayCompletedCount;
    }

    public void setTodayCompletedCount(int todayCompletedCount) {
        this.todayCompletedCount = todayCompletedCount;
    }

    public int getTodayTotalCount() {
        return todayTotalCount;
    }

    public void setTodayTotalCount(int todayTotalCount) {
        this.todayTotalCount = todayTotalCount;
    }

    public int getTodayStudyDurationMinutes() {
        return todayStudyDurationMinutes;
    }

    public void setTodayStudyDurationMinutes(int todayStudyDurationMinutes) {
        this.todayStudyDurationMinutes = todayStudyDurationMinutes;
    }

    public boolean isActiveStudy() {
        return activeStudy;
    }

    public void setActiveStudy(boolean activeStudy) {
        this.activeStudy = activeStudy;
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

    public boolean isOwner() {
        return owner;
    }

    public void setOwner(boolean owner) {
        this.owner = owner;
    }
}
