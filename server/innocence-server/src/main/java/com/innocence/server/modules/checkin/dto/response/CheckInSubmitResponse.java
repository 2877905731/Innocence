package com.innocence.server.modules.checkin.dto.response;

public class CheckInSubmitResponse {

    private boolean success;
    private String message;
    private CheckInStatusResponse status;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public CheckInStatusResponse getStatus() {
        return status;
    }

    public void setStatus(CheckInStatusResponse status) {
        this.status = status;
    }
}
