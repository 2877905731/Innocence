package com.innocence.server.modules.focus.dto.request;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public class StartFocusSessionRequest {

    private String taskName;

    @NotNull(message = "End time is required.")
    private LocalDateTime endTime;

    private Boolean bindPomodoro;
    private Integer pomodoroStudyMinutes;
    private Integer pomodoroBreakMinutes;

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public Boolean getBindPomodoro() {
        return bindPomodoro;
    }

    public void setBindPomodoro(Boolean bindPomodoro) {
        this.bindPomodoro = bindPomodoro;
    }

    public Integer getPomodoroStudyMinutes() {
        return pomodoroStudyMinutes;
    }

    public void setPomodoroStudyMinutes(Integer pomodoroStudyMinutes) {
        this.pomodoroStudyMinutes = pomodoroStudyMinutes;
    }

    public Integer getPomodoroBreakMinutes() {
        return pomodoroBreakMinutes;
    }

    public void setPomodoroBreakMinutes(Integer pomodoroBreakMinutes) {
        this.pomodoroBreakMinutes = pomodoroBreakMinutes;
    }
}
