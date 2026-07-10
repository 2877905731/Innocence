package com.innocence.server.modules.report.dto.response;

public class AdminLiftPunishmentResponse {

    private Long punishmentId;
    private String status;
    private String message;

    public Long getPunishmentId() {
        return punishmentId;
    }

    public void setPunishmentId(Long punishmentId) {
        this.punishmentId = punishmentId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
