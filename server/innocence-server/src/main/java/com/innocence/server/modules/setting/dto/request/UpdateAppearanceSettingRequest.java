package com.innocence.server.modules.setting.dto.request;

import jakarta.validation.constraints.NotBlank;

public class UpdateAppearanceSettingRequest {

    @NotBlank(message = "Theme mode is required.")
    private String themeMode;

    @NotBlank(message = "Desktop effect is required.")
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
