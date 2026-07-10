package com.innocence.server.modules.focus.domain;

import java.time.LocalDateTime;

public class StudyTimerRecord {

    private Long id;
    private Long userId;
    private String taskName;
    private LocalDateTime plannedEndTime;
    private LocalDateTime actualEndTime;
    private Integer plannedMinutes;
    private Integer durationSeconds;
    private String status;
    private Integer bindPomodoroFlag;
    private Integer pomodoroStudyMinutes;
    private Integer pomodoroBreakMinutes;
    private Integer completedPomodoroCount;
    private Integer completionNotifiedFlag;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public LocalDateTime getPlannedEndTime() {
        return plannedEndTime;
    }

    public void setPlannedEndTime(LocalDateTime plannedEndTime) {
        this.plannedEndTime = plannedEndTime;
    }

    public LocalDateTime getActualEndTime() {
        return actualEndTime;
    }

    public void setActualEndTime(LocalDateTime actualEndTime) {
        this.actualEndTime = actualEndTime;
    }

    public Integer getPlannedMinutes() {
        return plannedMinutes;
    }

    public void setPlannedMinutes(Integer plannedMinutes) {
        this.plannedMinutes = plannedMinutes;
    }

    public Integer getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(Integer durationSeconds) {
        this.durationSeconds = durationSeconds;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getBindPomodoroFlag() {
        return bindPomodoroFlag;
    }

    public void setBindPomodoroFlag(Integer bindPomodoroFlag) {
        this.bindPomodoroFlag = bindPomodoroFlag;
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

    public Integer getCompletedPomodoroCount() {
        return completedPomodoroCount;
    }

    public void setCompletedPomodoroCount(Integer completedPomodoroCount) {
        this.completedPomodoroCount = completedPomodoroCount;
    }

    public Integer getCompletionNotifiedFlag() {
        return completionNotifiedFlag;
    }

    public void setCompletionNotifiedFlag(Integer completionNotifiedFlag) {
        this.completionNotifiedFlag = completionNotifiedFlag;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
}
