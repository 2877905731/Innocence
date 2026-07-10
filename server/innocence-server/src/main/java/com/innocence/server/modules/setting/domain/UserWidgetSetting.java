package com.innocence.server.modules.setting.domain;

import java.time.LocalDateTime;

public class UserWidgetSetting {

    private Long id;
    private Long userId;
    private Integer autoStartFlag;
    private Integer alwaysOnTopFlag;
    private Integer showPlanFlag;
    private Integer showTimerFlag;
    private Integer showMemoFlag;
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

    public Integer getAutoStartFlag() {
        return autoStartFlag;
    }

    public void setAutoStartFlag(Integer autoStartFlag) {
        this.autoStartFlag = autoStartFlag;
    }

    public Integer getAlwaysOnTopFlag() {
        return alwaysOnTopFlag;
    }

    public void setAlwaysOnTopFlag(Integer alwaysOnTopFlag) {
        this.alwaysOnTopFlag = alwaysOnTopFlag;
    }

    public Integer getShowPlanFlag() {
        return showPlanFlag;
    }

    public void setShowPlanFlag(Integer showPlanFlag) {
        this.showPlanFlag = showPlanFlag;
    }

    public Integer getShowTimerFlag() {
        return showTimerFlag;
    }

    public void setShowTimerFlag(Integer showTimerFlag) {
        this.showTimerFlag = showTimerFlag;
    }

    public Integer getShowMemoFlag() {
        return showMemoFlag;
    }

    public void setShowMemoFlag(Integer showMemoFlag) {
        this.showMemoFlag = showMemoFlag;
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
