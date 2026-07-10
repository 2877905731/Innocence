package com.innocence.server.modules.focus.dto.response;

public class FocusSessionResponse {

    private Long sessionId;
    private boolean active;
    private String taskName;
    private String stageName;
    private String startTime;
    private String plannedEndTime;
    private String actualEndTime;
    private int plannedMinutes;
    private int elapsedSeconds;
    private int remainingSeconds;
    private boolean bindPomodoro;
    private int pomodoroStudyMinutes;
    private int pomodoroBreakMinutes;
    private int currentCycleNo;
    private int completedPomodoroCount;
    private int stageRemainingSeconds;

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public String getStageName() {
        return stageName;
    }

    public void setStageName(String stageName) {
        this.stageName = stageName;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getPlannedEndTime() {
        return plannedEndTime;
    }

    public void setPlannedEndTime(String plannedEndTime) {
        this.plannedEndTime = plannedEndTime;
    }

    public String getActualEndTime() {
        return actualEndTime;
    }

    public void setActualEndTime(String actualEndTime) {
        this.actualEndTime = actualEndTime;
    }

    public int getPlannedMinutes() {
        return plannedMinutes;
    }

    public void setPlannedMinutes(int plannedMinutes) {
        this.plannedMinutes = plannedMinutes;
    }

    public int getElapsedSeconds() {
        return elapsedSeconds;
    }

    public void setElapsedSeconds(int elapsedSeconds) {
        this.elapsedSeconds = elapsedSeconds;
    }

    public int getRemainingSeconds() {
        return remainingSeconds;
    }

    public void setRemainingSeconds(int remainingSeconds) {
        this.remainingSeconds = remainingSeconds;
    }

    public boolean isBindPomodoro() {
        return bindPomodoro;
    }

    public void setBindPomodoro(boolean bindPomodoro) {
        this.bindPomodoro = bindPomodoro;
    }

    public int getPomodoroStudyMinutes() {
        return pomodoroStudyMinutes;
    }

    public void setPomodoroStudyMinutes(int pomodoroStudyMinutes) {
        this.pomodoroStudyMinutes = pomodoroStudyMinutes;
    }

    public int getPomodoroBreakMinutes() {
        return pomodoroBreakMinutes;
    }

    public void setPomodoroBreakMinutes(int pomodoroBreakMinutes) {
        this.pomodoroBreakMinutes = pomodoroBreakMinutes;
    }

    public int getCurrentCycleNo() {
        return currentCycleNo;
    }

    public void setCurrentCycleNo(int currentCycleNo) {
        this.currentCycleNo = currentCycleNo;
    }

    public int getCompletedPomodoroCount() {
        return completedPomodoroCount;
    }

    public void setCompletedPomodoroCount(int completedPomodoroCount) {
        this.completedPomodoroCount = completedPomodoroCount;
    }

    public int getStageRemainingSeconds() {
        return stageRemainingSeconds;
    }

    public void setStageRemainingSeconds(int stageRemainingSeconds) {
        this.stageRemainingSeconds = stageRemainingSeconds;
    }
}
