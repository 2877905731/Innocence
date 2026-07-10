package com.innocence.server.modules.setting.dto.request;

import jakarta.validation.constraints.NotNull;

public class UpdateNotificationSettingRequest {

    @NotNull(message = "Mobile push switch is required.")
    private Integer mobilePushEnabled;

    @NotNull(message = "Desktop notification switch is required.")
    private Integer desktopNoticeEnabled;

    @NotNull(message = "Teammate reminder switch is required.")
    private Integer teamRemindEnabled;

    @NotNull(message = "System announcement switch is required.")
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
