package com.innocence.server.modules.setting.domain;

import java.time.LocalDateTime;

public class UserAppearanceSetting {

    private Long id;
    private Long userId;
    private String themeMode;
    private String desktopEffect;
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
