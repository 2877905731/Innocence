package com.innocence.server.modules.setting.dto.request;

import jakarta.validation.constraints.NotBlank;

public class UpdateAppearanceSettingRequest {

    @NotBlank(message = "Theme mode is required.")
    private String themeMode;

    public String getThemeMode() {
        return themeMode;
    }

    public void setThemeMode(String themeMode) {
        this.themeMode = themeMode;
    }

}
