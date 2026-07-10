package com.innocence.server.modules.setting.dto.response;

public class NotificationSettingResponse {

    private Integer mobilePushEnabled;
    private Integer desktopNoticeEnabled;
    private Integer teamRemindEnabled;
    private Integer systemAnnouncementEnabled;

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
}
