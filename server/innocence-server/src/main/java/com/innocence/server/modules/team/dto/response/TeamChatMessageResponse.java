package com.innocence.server.modules.team.dto.response;

public class TeamChatMessageResponse {

    private Long messageId;
    private Long senderUserId;
    private String senderUserNo;
    private String senderNickname;
    private String senderAvatarUrl;
    private String content;
    private boolean masked;
    private boolean deleted;
    private String deletedReason;
    private boolean ownMessage;
    private String createTime;

    public Long getMessageId() {
        return messageId;
    }

    public void setMessageId(Long messageId) {
        this.messageId = messageId;
    }

    public Long getSenderUserId() {
        return senderUserId;
    }

    public void setSenderUserId(Long senderUserId) {
        this.senderUserId = senderUserId;
    }

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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isMasked() {
        return masked;
    }

    public void setMasked(boolean masked) {
        this.masked = masked;
    }

    public boolean isDeleted() {
        return deleted;
    }

    public void setDeleted(boolean deleted) {
        this.deleted = deleted;
    }

    public String getDeletedReason() {
        return deletedReason;
    }

    public void setDeletedReason(String deletedReason) {
        this.deletedReason = deletedReason;
    }

    public boolean isOwnMessage() {
        return ownMessage;
    }

    public void setOwnMessage(boolean ownMessage) {
        this.ownMessage = ownMessage;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }
}
