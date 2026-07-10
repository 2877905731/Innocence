package com.innocence.server.modules.setting.dto.response;

import com.innocence.server.modules.account.dto.response.PrivacySettingResponse;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;

public class SettingOverviewResponse {

    private UserProfileResponse accountSetting;
    private PrivacySettingResponse privacySetting;
    private NotificationSettingResponse notificationSetting;
    private WidgetSettingResponse widgetSetting;
    private AppearanceSettingResponse appearanceSetting;

    public UserProfileResponse getAccountSetting() {
        return accountSetting;
    }

    public void setAccountSetting(UserProfileResponse accountSetting) {
        this.accountSetting = accountSetting;
    }

    public PrivacySettingResponse getPrivacySetting() {
        return privacySetting;
    }

    public void setPrivacySetting(PrivacySettingResponse privacySetting) {
        this.privacySetting = privacySetting;
    }

    public NotificationSettingResponse getNotificationSetting() {
        return notificationSetting;
    }

    public void setNotificationSetting(NotificationSettingResponse notificationSetting) {
        this.notificationSetting = notificationSetting;
    }

    public WidgetSettingResponse getWidgetSetting() {
        return widgetSetting;
    }

    public void setWidgetSetting(WidgetSettingResponse widgetSetting) {
        this.widgetSetting = widgetSetting;
    }

    public AppearanceSettingResponse getAppearanceSetting() {
        return appearanceSetting;
    }

    public void setAppearanceSetting(AppearanceSettingResponse appearanceSetting) {
        this.appearanceSetting = appearanceSetting;
    }
}
