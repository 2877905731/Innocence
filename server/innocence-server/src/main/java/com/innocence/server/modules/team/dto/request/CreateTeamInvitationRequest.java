package com.innocence.server.modules.team.dto.request;

import jakarta.validation.constraints.NotNull;

public class CreateTeamInvitationRequest {

    @NotNull(message = "Target user is required.")
    private Long targetUserId;

    public Long getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(Long targetUserId) {
        this.targetUserId = targetUserId;
    }
}
