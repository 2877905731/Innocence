package com.innocence.server.modules.account.dto.response;

public class CurrentSessionResponse {

    private String deviceType;
    private String deviceSlot;
    private String deviceId;
    private Integer online;
    private Integer replaced;
    private String sessionToken;
    private String loginTime;
    private String logoutTime;

    public String getDeviceType() {
        return deviceType;
    }

    public void setDeviceType(String deviceType) {
        this.deviceType = deviceType;
    }

    public String getDeviceSlot() {
        return deviceSlot;
    }

    public void setDeviceSlot(String deviceSlot) {
        this.deviceSlot = deviceSlot;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public Integer getOnline() {
        return online;
    }

    public void setOnline(Integer online) {
        this.online = online;
    }

    public Integer getReplaced() {
        return replaced;
    }

    public void setReplaced(Integer replaced) {
        this.replaced = replaced;
    }

    public String getSessionToken() {
        return sessionToken;
    }

    public void setSessionToken(String sessionToken) {
        this.sessionToken = sessionToken;
    }

    public String getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(String loginTime) {
        this.loginTime = loginTime;
    }

    public String getLogoutTime() {
        return logoutTime;
    }

    public void setLogoutTime(String logoutTime) {
        this.logoutTime = logoutTime;
    }
}
