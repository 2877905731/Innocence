package com.innocence.server.modules.team.dto.response;

import java.util.ArrayList;
import java.util.List;

public class TeamOverviewResponse {

    private boolean inTeam;
    private Long teamId;
    private String teamName;
    private String inviteCode;
    private Long ownerUserId;
    private boolean owner;
    private int memberLimit;
    private int unreadChatCount;
    private String latestChatPreview;
    private List<TeamMemberResponse> members = new ArrayList<>();

    public boolean isInTeam() {
        return inTeam;
    }

    public void setInTeam(boolean inTeam) {
        this.inTeam = inTeam;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public Long getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(Long ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public boolean isOwner() {
        return owner;
    }

    public void setOwner(boolean owner) {
        this.owner = owner;
    }

    public int getMemberLimit() {
        return memberLimit;
    }

    public void setMemberLimit(int memberLimit) {
        this.memberLimit = memberLimit;
    }

    public int getUnreadChatCount() {
        return unreadChatCount;
    }

    public void setUnreadChatCount(int unreadChatCount) {
        this.unreadChatCount = unreadChatCount;
    }

    public String getLatestChatPreview() {
        return latestChatPreview;
    }

    public void setLatestChatPreview(String latestChatPreview) {
        this.latestChatPreview = latestChatPreview;
    }

    public List<TeamMemberResponse> getMembers() {
        return members;
    }

    public void setMembers(List<TeamMemberResponse> members) {
        this.members = members == null ? new ArrayList<>() : members;
    }
}
