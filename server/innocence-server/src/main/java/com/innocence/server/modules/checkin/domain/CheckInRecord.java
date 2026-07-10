package com.innocence.server.modules.checkin.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class CheckInRecord {

    private Long id;
    private Long userId;
    private LocalDate checkInDate;
    private Integer planCompletedCount;
    private Integer planTotalCount;
    private Integer studyDurationMinutes;
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

    public LocalDate getCheckInDate() {
        return checkInDate;
    }

    public void setCheckInDate(LocalDate checkInDate) {
        this.checkInDate = checkInDate;
    }

    public Integer getPlanCompletedCount() {
        return planCompletedCount;
    }

    public void setPlanCompletedCount(Integer planCompletedCount) {
        this.planCompletedCount = planCompletedCount;
    }

    public Integer getPlanTotalCount() {
        return planTotalCount;
    }

    public void setPlanTotalCount(Integer planTotalCount) {
        this.planTotalCount = planTotalCount;
    }

    public Integer getStudyDurationMinutes() {
        return studyDurationMinutes;
    }

    public void setStudyDurationMinutes(Integer studyDurationMinutes) {
        this.studyDurationMinutes = studyDurationMinutes;
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
