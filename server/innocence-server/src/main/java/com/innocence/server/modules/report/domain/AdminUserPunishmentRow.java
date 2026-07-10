package com.innocence.server.modules.report.domain;

import java.time.LocalDateTime;

public class AdminUserPunishmentRow {

    private Long punishmentId;
    private Long userId;
    private Long reportId;
    private String punishmentType;
    private String status;
    private Integer durationDays;
    private String reasonText;
    private Long operatorUserId;
    private String operatorUserNo;
    private String operatorUserNickname;
    private Integer activeFlag;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime createTime;

    public Long getPunishmentId() {
        return punishmentId;
    }

    public void setPunishmentId(Long punishmentId) {
        this.punishmentId = punishmentId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public String getPunishmentType() {
        return punishmentType;
    }

    public void setPunishmentType(String punishmentType) {
        this.punishmentType = punishmentType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(Integer durationDays) {
        this.durationDays = durationDays;
    }

    public String getReasonText() {
        return reasonText;
    }

    public void setReasonText(String reasonText) {
        this.reasonText = reasonText;
    }

    public Long getOperatorUserId() {
        return operatorUserId;
    }

    public void setOperatorUserId(Long operatorUserId) {
        this.operatorUserId = operatorUserId;
    }

    public String getOperatorUserNo() {
        return operatorUserNo;
    }

    public void setOperatorUserNo(String operatorUserNo) {
        this.operatorUserNo = operatorUserNo;
    }

    public String getOperatorUserNickname() {
        return operatorUserNickname;
    }

    public void setOperatorUserNickname(String operatorUserNickname) {
        this.operatorUserNickname = operatorUserNickname;
    }

    public Integer getActiveFlag() {
        return activeFlag;
    }

    public void setActiveFlag(Integer activeFlag) {
        this.activeFlag = activeFlag;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
