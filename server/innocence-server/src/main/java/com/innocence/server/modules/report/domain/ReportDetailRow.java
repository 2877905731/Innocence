package com.innocence.server.modules.report.domain;

import java.time.LocalDateTime;

public class ReportDetailRow {

    private Long reportId;
    private String reportType;
    private String reportStatus;
    private String reasonText;
    private String descriptionText;
    private Long reportUserId;
    private String reportUserNo;
    private String reportUserNickname;
    private Long targetId;
    private Long targetUserId;
    private String targetUserNo;
    private String targetUserNickname;
    private Long teamId;
    private String teamName;
    private String targetContent;
    private Integer targetMaskedFlag;
    private Integer targetDeletedFlag;
    private String targetDeletedReason;
    private Long handledUserId;
    private String handledUserNo;
    private String handledUserNickname;
    private LocalDateTime handledTime;
    private LocalDateTime createTime;

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public String getReportType() {
        return reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public String getReportStatus() {
        return reportStatus;
    }

    public void setReportStatus(String reportStatus) {
        this.reportStatus = reportStatus;
    }

    public String getReasonText() {
        return reasonText;
    }

    public void setReasonText(String reasonText) {
        this.reasonText = reasonText;
    }

    public String getDescriptionText() {
        return descriptionText;
    }

    public void setDescriptionText(String descriptionText) {
        this.descriptionText = descriptionText;
    }

    public Long getReportUserId() {
        return reportUserId;
    }

    public void setReportUserId(Long reportUserId) {
        this.reportUserId = reportUserId;
    }

    public String getReportUserNo() {
        return reportUserNo;
    }

    public void setReportUserNo(String reportUserNo) {
        this.reportUserNo = reportUserNo;
    }

    public String getReportUserNickname() {
        return reportUserNickname;
    }

    public void setReportUserNickname(String reportUserNickname) {
        this.reportUserNickname = reportUserNickname;
    }

    public Long getTargetId() {
        return targetId;
    }

    public void setTargetId(Long targetId) {
        this.targetId = targetId;
    }

    public Long getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(Long targetUserId) {
        this.targetUserId = targetUserId;
    }

    public String getTargetUserNo() {
        return targetUserNo;
    }

    public void setTargetUserNo(String targetUserNo) {
        this.targetUserNo = targetUserNo;
    }

    public String getTargetUserNickname() {
        return targetUserNickname;
    }

    public void setTargetUserNickname(String targetUserNickname) {
        this.targetUserNickname = targetUserNickname;
    }

    public Long getTeamId() {
        return teamId;
    }

    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getTargetContent() {
        return targetContent;
    }

    public void setTargetContent(String targetContent) {
        this.targetContent = targetContent;
    }

    public Integer getTargetMaskedFlag() {
        return targetMaskedFlag;
    }

    public void setTargetMaskedFlag(Integer targetMaskedFlag) {
        this.targetMaskedFlag = targetMaskedFlag;
    }

    public Integer getTargetDeletedFlag() {
        return targetDeletedFlag;
    }

    public void setTargetDeletedFlag(Integer targetDeletedFlag) {
        this.targetDeletedFlag = targetDeletedFlag;
    }

    public String getTargetDeletedReason() {
        return targetDeletedReason;
    }

    public void setTargetDeletedReason(String targetDeletedReason) {
        this.targetDeletedReason = targetDeletedReason;
    }

    public Long getHandledUserId() {
        return handledUserId;
    }

    public void setHandledUserId(Long handledUserId) {
        this.handledUserId = handledUserId;
    }

    public String getHandledUserNo() {
        return handledUserNo;
    }

    public void setHandledUserNo(String handledUserNo) {
        this.handledUserNo = handledUserNo;
    }

    public String getHandledUserNickname() {
        return handledUserNickname;
    }

    public void setHandledUserNickname(String handledUserNickname) {
        this.handledUserNickname = handledUserNickname;
    }

    public LocalDateTime getHandledTime() {
        return handledTime;
    }

    public void setHandledTime(LocalDateTime handledTime) {
        this.handledTime = handledTime;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
