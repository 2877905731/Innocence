package com.innocence.server.modules.setting.domain;

import java.time.LocalDateTime;

public class UserNotificationSetting {

    private Long id;
    private Long userId;
    private Integer mobilePushEnabled;
    private Integer desktopNoticeEnabled;
    private Integer teamRemindEnabled;
    private Integer systemAnnouncementEnabled;
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

    public Integer getMobilePushEnabled() {
        return mobilePushEnabled;
    }

    public void setMobilePushEnabled(Integer mobilePushEnabled) {
        this.mobilePushEnabled = mobilePushEnabled;
    }

    public Integer getDesktopNoticeEnabled() {
        return desktopNoticeEnabled;
    }

    public void setDesktopNoticeEnabled(Integer desktopNoticeEnabled) {
        this.desktopNoticeEnabled = desktopNoticeEnabled;
    }

    public Integer getTeamRemindEnabled() {
        return teamRemindEnabled;
    }

    public void setTeamRemindEnabled(Integer teamRemindEnabled) {
        this.teamRemindEnabled = teamRemindEnabled;
    }

    public Integer getSystemAnnouncementEnabled() {
        return systemAnnouncementEnabled;
    }

    public void setSystemAnnouncementEnabled(Integer systemAnnouncementEnabled) {
        this.systemAnnouncementEnabled = systemAnnouncementEnabled;
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
