package com.innocence.server.modules.notification.domain;

public class AppNotificationRow extends AppNotification {

    private String senderUserNo;
    private String senderNickname;
    private String senderAvatarUrl;

    public String getSenderUserNo() {
        return senderUserNo;
    }

    public void setSenderUserNo(String senderUserNo) {
        this.senderUserNo = senderUserNo;
    }

    public String getSenderNickname() {
        return senderNickname;
    }

    public void setSenderNickname(String senderNickname) {
        this.senderNickname = senderNickname;
    }

    public String getSenderAvatarUrl() {
        return senderAvatarUrl;
    }

    public void setSenderAvatarUrl(String senderAvatarUrl) {
        this.senderAvatarUrl = senderAvatarUrl;
    }
}
