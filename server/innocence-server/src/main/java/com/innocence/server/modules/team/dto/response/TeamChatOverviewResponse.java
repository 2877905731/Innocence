package com.innocence.server.modules.team.dto.response;

import java.util.ArrayList;
import java.util.List;

public class TeamChatOverviewResponse {

    private Long teamId;
    private String teamName;
    private int unreadCount;
    private List<TeamChatMessageResponse> messages = new ArrayList<>();

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

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public List<TeamChatMessageResponse> getMessages() {
        return messages;
    }

    public void setMessages(List<TeamChatMessageResponse> messages) {
        this.messages = messages == null ? new ArrayList<>() : messages;
    }
}
