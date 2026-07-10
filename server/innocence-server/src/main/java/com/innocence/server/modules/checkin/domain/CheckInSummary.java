package com.innocence.server.modules.checkin.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class CheckInSummary {

    private Long id;
    private Long userId;
    private Integer consecutiveDays;
    private Integer totalDays;
    private LocalDate lastSuccessDate;
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

    public Integer getConsecutiveDays() {
        return consecutiveDays;
    }

    public void setConsecutiveDays(Integer consecutiveDays) {
        this.consecutiveDays = consecutiveDays;
    }

    public Integer getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(Integer totalDays) {
        this.totalDays = totalDays;
    }

    public LocalDate getLastSuccessDate() {
        return lastSuccessDate;
    }

    public void setLastSuccessDate(LocalDate lastSuccessDate) {
        this.lastSuccessDate = lastSuccessDate;
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
