package com.innocence.server.modules.account.dto.response;

public class PrivacySettingResponse {

    private Integer allowFriendViewProfile;
    private Integer allowTeammateViewStudy;
    private Integer allowStrangerMessage;

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
}
