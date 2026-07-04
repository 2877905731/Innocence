package com.innocence.server.modules.account.dto.response;

public class UserProfileResponse {

    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private String bio;
    private String timezone;
    private int studyDurationTotal;
    private int checkInDaysTotal;

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

    public int getStudyDurationTotal() {
        return studyDurationTotal;
    }

    public void setStudyDurationTotal(int studyDurationTotal) {
        this.studyDurationTotal = studyDurationTotal;
    }

    public int getCheckInDaysTotal() {
        return checkInDaysTotal;
    }

    public void setCheckInDaysTotal(int checkInDaysTotal) {
        this.checkInDaysTotal = checkInDaysTotal;
    }
}
