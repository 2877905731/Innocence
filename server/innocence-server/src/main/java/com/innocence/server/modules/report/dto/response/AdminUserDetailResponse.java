package com.innocence.server.modules.report.dto.response;

public class AdminUserDetailResponse {

    private Long userId;
    private String userNo;
    private String nickname;
    private String displayName;
    private String avatarUrl;
    private String email;
    private int statusCode;
    private String statusLabel;
    private String bio;
    private String timezone;
    private boolean allowFriendViewProfile;
    private boolean allowTeammateViewStudy;
    private boolean allowStrangerMessage;
    private int totalStudyMinutes;
    private int totalCheckInDays;
    private int consecutiveCheckInDays;
    private Long teamId;
    private String teamName;
    private String teamInviteCode;
    private String teamRole;
    private String teamJoinedTime;
    private String lastLoginTime;
    private String createTime;

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

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    public String getStatusLabel() {
        return statusLabel;
    }

    public void setStatusLabel(String statusLabel) {
        this.statusLabel = statusLabel;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }

    public boolean isAllowFriendViewProfile() {
        return allowFriendViewProfile;
    }

    public void setAllowFriendViewProfile(boolean allowFriendViewProfile) {
        this.allowFriendViewProfile = allowFriendViewProfile;
    }

    public boolean isAllowTeammateViewStudy() {
        return allowTeammateViewStudy;
    }

    public void setAllowTeammateViewStudy(boolean allowTeammateViewStudy) {
        this.allowTeammateViewStudy = allowTeammateViewStudy;
    }

    public boolean isAllowStrangerMessage() {
        return allowStrangerMessage;
    }

    public void setAllowStrangerMessage(boolean allowStrangerMessage) {
        this.allowStrangerMessage = allowStrangerMessage;
    }

    public int getTotalStudyMinutes() {
        return totalStudyMinutes;
    }

    public void setTotalStudyMinutes(int totalStudyMinutes) {
        this.totalStudyMinutes = totalStudyMinutes;
    }

    public int getTotalCheckInDays() {
        return totalCheckInDays;
    }

    public void setTotalCheckInDays(int totalCheckInDays) {
        this.totalCheckInDays = totalCheckInDays;
    }

    public int getConsecutiveCheckInDays() {
        return consecutiveCheckInDays;
    }

    public void setConsecutiveCheckInDays(int consecutiveCheckInDays) {
        this.consecutiveCheckInDays = consecutiveCheckInDays;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getTeamInviteCode() {
        return teamInviteCode;
    }

    public void setTeamInviteCode(String teamInviteCode) {
        this.teamInviteCode = teamInviteCode;
    }

    public String getTeamRole() {
        return teamRole;
    }

    public void setTeamRole(String teamRole) {
        this.teamRole = teamRole;
    }

    public String getTeamJoinedTime() {
        return teamJoinedTime;
    }

    public void setTeamJoinedTime(String teamJoinedTime) {
        this.teamJoinedTime = teamJoinedTime;
    }

    public String getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(String lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }
}
