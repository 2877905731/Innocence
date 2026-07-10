package com.innocence.server.modules.friend.domain;

public class FriendItemRow {

    private Long friendUserId;
    private String userNo;
    private String nickname;
    private String avatarUrl;
    private String bio;
    private Integer allowFriendViewProfile;
    private Long groupId;
    private String groupName;
    private Integer sameTeamFlag;

    public Long getFriendUserId() {
        return friendUserId;
    }

    public void setFriendUserId(Long friendUserId) {
        this.friendUserId = friendUserId;
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

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public Integer getAllowFriendViewProfile() {
        return allowFriendViewProfile;
    }

    public void setAllowFriendViewProfile(Integer allowFriendViewProfile) {
        this.allowFriendViewProfile = allowFriendViewProfile;
    }

    public Long getGroupId() {
        return groupId;
    }

    public void setGroupId(Long groupId) {
        this.groupId = groupId;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public Integer getSameTeamFlag() {
        return sameTeamFlag;
    }

    public void setSameTeamFlag(Integer sameTeamFlag) {
        this.sameTeamFlag = sameTeamFlag;
    }
}
