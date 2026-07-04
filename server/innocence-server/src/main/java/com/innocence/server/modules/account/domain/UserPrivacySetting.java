package com.innocence.server.modules.account.domain;

import java.time.LocalDateTime;

public class UserPrivacySetting {

    private Long id;
    private Long userId;
    private Integer allowFriendViewProfile;
    private Integer allowTeammateViewStudy;
    private Integer allowStrangerMessage;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
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

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
}
