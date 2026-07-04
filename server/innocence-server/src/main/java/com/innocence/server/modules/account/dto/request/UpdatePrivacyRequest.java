package com.innocence.server.modules.account.dto.request;

import jakarta.validation.constraints.NotNull;

public class UpdatePrivacyRequest {

    @NotNull(message = "仅好友可看资料开关不能为空")
    private Integer allowFriendViewProfile;

    @NotNull(message = "仅队友可见学习数据开关不能为空")
    private Integer allowTeammateViewStudy;

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
}
