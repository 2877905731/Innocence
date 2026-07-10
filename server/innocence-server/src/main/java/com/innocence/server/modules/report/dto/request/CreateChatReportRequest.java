package com.innocence.server.modules.report.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CreateChatReportRequest {

    @NotBlank(message = "Report reason is required.")
    @Size(max = 120, message = "Report reason must be 120 characters or fewer.")
    private String reason;

    @Size(max = 255, message = "Report description must be 255 characters or fewer.")
    private String description;

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
