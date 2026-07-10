package com.innocence.server.modules.friend.dto.request;

public class CreateFriendRequestRequest {

    private Long targetUserId;
    private String message;

    public Long getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(Long targetUserId) {
        this.targetUserId = targetUserId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
