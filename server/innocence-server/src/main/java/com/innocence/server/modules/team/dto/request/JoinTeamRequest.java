package com.innocence.server.modules.team.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class JoinTeamRequest {

    @NotBlank(message = "Invite code is required.")
    @Size(max = 32, message = "Invite code must be 32 characters or fewer.")
    private String inviteCode;

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }
}
