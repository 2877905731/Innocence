package com.innocence.server.modules.report.domain;

import java.time.LocalDateTime;

public class ReportListItemRow {

    private Long reportId;
    private String reportType;
    private String reportStatus;
    private String reasonText;
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
    private Integer targetDeletedFlag;
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

    public Integer getTargetDeletedFlag() {
        return targetDeletedFlag;
    }

    public void setTargetDeletedFlag(Integer targetDeletedFlag) {
        this.targetDeletedFlag = targetDeletedFlag;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
