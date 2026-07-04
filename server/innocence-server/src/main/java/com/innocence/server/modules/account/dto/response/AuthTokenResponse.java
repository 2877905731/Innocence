package com.innocence.server.modules.account.dto.response;

public class AuthTokenResponse {

    private String accessToken;
    private String tokenType;
    private String deviceType;
    private String deviceSlot;
    private String deviceId;
    private UserProfileResponse userInfo;

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

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

    public UserProfileResponse getUserInfo() {
        return userInfo;
    }

    public void setUserInfo(UserProfileResponse userInfo) {
        this.userInfo = userInfo;
    }
}
