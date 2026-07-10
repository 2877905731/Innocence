package com.innocence.server.modules.setting.dto.request;

import jakarta.validation.constraints.NotNull;

public class UpdateWidgetSettingRequest {

    @NotNull(message = "Auto-start switch is required.")
    private Integer autoStart;

    @NotNull(message = "Always-on-top switch is required.")
    private Integer alwaysOnTop;

    @NotNull(message = "Show plan switch is required.")
    private Integer showPlan;

    @NotNull(message = "Show timer switch is required.")
    private Integer showTimer;

    @NotNull(message = "Show memo switch is required.")
    private Integer showMemo;

    public Integer getAutoStart() {
        return autoStart;
    }

    public void setAutoStart(Integer autoStart) {
        this.autoStart = autoStart;
    }

    public Integer getAlwaysOnTop() {
        return alwaysOnTop;
    }

    public void setAlwaysOnTop(Integer alwaysOnTop) {
        this.alwaysOnTop = alwaysOnTop;
    }

    public Integer getShowPlan() {
        return showPlan;
    }

    public void setShowPlan(Integer showPlan) {
        this.showPlan = showPlan;
    }

    public Integer getShowTimer() {
        return showTimer;
    }

    public void setShowTimer(Integer showTimer) {
        this.showTimer = showTimer;
    }

    public Integer getShowMemo() {
        return showMemo;
    }

    public void setShowMemo(Integer showMemo) {
        this.showMemo = showMemo;
    }
}
