package com.innocence.server.modules.report.domain;

import java.time.LocalDateTime;

public class AdminUserDetailRow {

    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private Integer status;
    private String email;
    private String bio;
    private String timezone;
    private Integer allowFriendViewProfile;
    private Integer allowTeammateViewStudy;
    private Integer allowStrangerMessage;
    private Integer totalStudySeconds;
    private Integer totalCheckInDays;
    private Integer consecutiveCheckInDays;
    private Long teamId;
    private String teamName;
    private String teamInviteCode;
    private String teamRole;
    private LocalDateTime teamJoinedTime;
    private LocalDateTime lastLoginTime;
    private LocalDateTime createTime;

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

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
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

    public Integer getAllowFriendViewProfile() {
        return allowFriendViewProfile;
    }

    public void setAllowFriendViewProfile(Integer allowFriendViewProfile) {
        this.allowFriendViewProfile = allowFriendViewProfile;
    }

    public Integer getAllowTeammateViewStudy() {
        return allowTeammateViewStudy;
    }

    public void setAllowTeammateViewStudy(Integer allowTeammateViewStudy) {
        this.allowTeammateViewStudy = allowTeammateViewStudy;
    }

    public Integer getAllowStrangerMessage() {
        return allowStrangerMessage;
    }

    public void setAllowStrangerMessage(Integer allowStrangerMessage) {
        this.allowStrangerMessage = allowStrangerMessage;
    }

    public Integer getTotalStudySeconds() {
        return totalStudySeconds;
    }

    public void setTotalStudySeconds(Integer totalStudySeconds) {
        this.totalStudySeconds = totalStudySeconds;
    }

    public Integer getTotalCheckInDays() {
        return totalCheckInDays;
    }

    public void setTotalCheckInDays(Integer totalCheckInDays) {
        this.totalCheckInDays = totalCheckInDays;
    }

    public Integer getConsecutiveCheckInDays() {
        return consecutiveCheckInDays;
    }

    public void setConsecutiveCheckInDays(Integer consecutiveCheckInDays) {
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

    public LocalDateTime getTeamJoinedTime() {
        return teamJoinedTime;
    }

    public void setTeamJoinedTime(LocalDateTime teamJoinedTime) {
        this.teamJoinedTime = teamJoinedTime;
    }

    public LocalDateTime getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(LocalDateTime lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
