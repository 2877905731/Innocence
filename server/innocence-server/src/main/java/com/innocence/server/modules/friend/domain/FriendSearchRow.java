package com.innocence.server.modules.friend.domain;

public class FriendSearchRow {

    private Long userId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private Integer alreadyFriendFlag;
    private Integer outgoingPendingFlag;
    private Integer incomingPendingFlag;
    private Integer blockedByMeFlag;
    private Integer blockedMeFlag;
    private Integer sameTeamFlag;

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

    public Integer getAlreadyFriendFlag() {
        return alreadyFriendFlag;
    }

    public void setAlreadyFriendFlag(Integer alreadyFriendFlag) {
        this.alreadyFriendFlag = alreadyFriendFlag;
    }

    public Integer getOutgoingPendingFlag() {
        return outgoingPendingFlag;
    }

    public void setOutgoingPendingFlag(Integer outgoingPendingFlag) {
        this.outgoingPendingFlag = outgoingPendingFlag;
    }

    public Integer getIncomingPendingFlag() {
        return incomingPendingFlag;
    }

    public void setIncomingPendingFlag(Integer incomingPendingFlag) {
        this.incomingPendingFlag = incomingPendingFlag;
    }

    public Integer getBlockedByMeFlag() {
        return blockedByMeFlag;
    }

    public void setBlockedByMeFlag(Integer blockedByMeFlag) {
        this.blockedByMeFlag = blockedByMeFlag;
    }

    public Integer getBlockedMeFlag() {
        return blockedMeFlag;
    }

    public void setBlockedMeFlag(Integer blockedMeFlag) {
        this.blockedMeFlag = blockedMeFlag;
    }

    public Integer getSameTeamFlag() {
        return sameTeamFlag;
    }

    public void setSameTeamFlag(Integer sameTeamFlag) {
        this.sameTeamFlag = sameTeamFlag;
    }
}
