package com.innocence.server.modules.report.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ReviewReportRequest {

    @NotBlank(message = "Review decision is required.")
    private String decision;

    @NotNull(message = "Delete content flag is required.")
    private Boolean deleteContent;

    @NotBlank(message = "Punishment type is required.")
    private String punishmentType;

    private Integer durationDays;

    @Size(max = 255, message = "Review reason must be 255 characters or fewer.")
    private String reason;

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public Boolean getDeleteContent() {
        return deleteContent;
    }

    public void setDeleteContent(Boolean deleteContent) {
        this.deleteContent = deleteContent;
    }

    public String getPunishmentType() {
        return punishmentType;
    }

    public void setPunishmentType(String punishmentType) {
        this.punishmentType = punishmentType;
    }

    public Integer getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(Integer durationDays) {
        this.durationDays = durationDays;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
