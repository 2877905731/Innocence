package com.innocence.server.modules.friend.dto.response;

import java.util.ArrayList;
import java.util.List;

public class FriendOverviewResponse {

    private int friendCount;
    private int maxFriendCount;
    private Long defaultGroupId;
    private List<FriendGroupResponse> groups = new ArrayList<>();
    private List<FriendItemResponse> friends = new ArrayList<>();
    private List<FriendRequestResponse> incomingRequests = new ArrayList<>();
    private List<FriendRequestResponse> outgoingRequests = new ArrayList<>();

    public int getFriendCount() {
        return friendCount;
    }

    public void setFriendCount(int friendCount) {
        this.friendCount = friendCount;
    }

    public int getMaxFriendCount() {
        return maxFriendCount;
    }

    public void setMaxFriendCount(int maxFriendCount) {
        this.maxFriendCount = maxFriendCount;
    }

    public Long getDefaultGroupId() {
        return defaultGroupId;
    }

    public void setDefaultGroupId(Long defaultGroupId) {
        this.defaultGroupId = defaultGroupId;
    }

    public List<FriendGroupResponse> getGroups() {
        return groups;
    }

    public void setGroups(List<FriendGroupResponse> groups) {
        this.groups = groups == null ? new ArrayList<>() : groups;
    }

    public List<FriendItemResponse> getFriends() {
        return friends;
    }

    public void setFriends(List<FriendItemResponse> friends) {
        this.friends = friends == null ? new ArrayList<>() : friends;
    }

    public List<FriendRequestResponse> getIncomingRequests() {
        return incomingRequests;
    }

    public void setIncomingRequests(List<FriendRequestResponse> incomingRequests) {
        this.incomingRequests = incomingRequests == null ? new ArrayList<>() : incomingRequests;
    }

    public List<FriendRequestResponse> getOutgoingRequests() {
        return outgoingRequests;
    }

    public void setOutgoingRequests(List<FriendRequestResponse> outgoingRequests) {
        this.outgoingRequests = outgoingRequests == null ? new ArrayList<>() : outgoingRequests;
    }
}
