package com.innocence.server.modules.friend.domain;

public class FriendRequestRow extends FriendRequest {

    private Long counterpartUserId;
    private String counterpartUserNo;
    private String counterpartNickname;
    private String counterpartAvatarUrl;
    private Integer sameTeamFlag;

    public Long getCounterpartUserId() {
        return counterpartUserId;
    }

    public void setCounterpartUserId(Long counterpartUserId) {
        this.counterpartUserId = counterpartUserId;
    }

    public String getCounterpartUserNo() {
        return counterpartUserNo;
    }

    public void setCounterpartUserNo(String counterpartUserNo) {
        this.counterpartUserNo = counterpartUserNo;
    }

    public String getCounterpartNickname() {
        return counterpartNickname;
    }

    public void setCounterpartNickname(String counterpartNickname) {
        this.counterpartNickname = counterpartNickname;
    }

    public String getCounterpartAvatarUrl() {
        return counterpartAvatarUrl;
    }

    public void setCounterpartAvatarUrl(String counterpartAvatarUrl) {
        this.counterpartAvatarUrl = counterpartAvatarUrl;
    }

    public Integer getSameTeamFlag() {
        return sameTeamFlag;
    }

    public void setSameTeamFlag(Integer sameTeamFlag) {
        this.sameTeamFlag = sameTeamFlag;
    }
}
