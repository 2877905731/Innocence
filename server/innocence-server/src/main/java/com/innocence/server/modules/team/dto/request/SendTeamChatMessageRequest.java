package com.innocence.server.modules.team.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class SendTeamChatMessageRequest {

    @NotBlank(message = "Message content is required.")
    @Size(max = 500, message = "Message content must be 500 characters or fewer.")
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
