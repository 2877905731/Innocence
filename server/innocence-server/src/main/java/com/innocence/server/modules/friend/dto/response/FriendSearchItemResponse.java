package com.innocence.server.modules.friend.dto.response;

public class FriendSearchItemResponse {

    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private boolean alreadyFriend;
    private boolean outgoingPending;
    private boolean incomingPending;
    private boolean blockedByMe;
    private boolean blockedMe;
    private boolean sameTeam;

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserNo() {
        return userNo;
    }

    public void setUserNo(String userNo) {
        this.userNo = userNo;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public boolean isAlreadyFriend() {
        return alreadyFriend;
    }

    public void setAlreadyFriend(boolean alreadyFriend) {
        this.alreadyFriend = alreadyFriend;
    }

    public boolean isOutgoingPending() {
        return outgoingPending;
    }

    public void setOutgoingPending(boolean outgoingPending) {
        this.outgoingPending = outgoingPending;
    }

    public boolean isIncomingPending() {
        return incomingPending;
    }

    public void setIncomingPending(boolean incomingPending) {
        this.incomingPending = incomingPending;
    }

    public boolean isBlockedByMe() {
        return blockedByMe;
    }

    public void setBlockedByMe(boolean blockedByMe) {
        this.blockedByMe = blockedByMe;
    }

    public boolean isBlockedMe() {
        return blockedMe;
    }

    public void setBlockedMe(boolean blockedMe) {
        this.blockedMe = blockedMe;
    }

    public boolean isSameTeam() {
        return sameTeam;
    }

    public void setSameTeam(boolean sameTeam) {
        this.sameTeam = sameTeam;
    }
}
