package com.innocence.server.modules.team.dto.response;

public class TeammateReminderResponse {

    private boolean success;
    private String message;
    private int reminderCountToday;

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

    public int getReminderCountToday() {
        return reminderCountToday;
    }

    public void setReminderCountToday(int reminderCountToday) {
        this.reminderCountToday = reminderCountToday;
    }
}
