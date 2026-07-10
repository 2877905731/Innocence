package com.innocence.server.modules.setting.dto.response;

public class WidgetSettingResponse {

    private Integer autoStart;
    private Integer alwaysOnTop;
    private Integer showPlan;
    private Integer showTimer;
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
