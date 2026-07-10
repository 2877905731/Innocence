package com.innocence.server.modules.setting.dto.response;

public class AppearanceSettingResponse {

    private String themeMode;
    private String desktopEffect;

    public String getThemeMode() {
        return themeMode;
    }

    public void setThemeMode(String themeMode) {
        this.themeMode = themeMode;
    }

    public String getDesktopEffect() {
        return desktopEffect;
    }

    public void setDesktopEffect(String desktopEffect) {
        this.desktopEffect = desktopEffect;
    }
}
