package com.innocence.server.modules.report.dto.response;

public class ReportListItemResponse {

    private Long reportId;
    private String reportType;
    private String status;
    private String reason;
    private Long reportUserId;
    private String reportUserDisplayName;
    private Long targetId;
    private Long targetUserId;
    private String targetUserDisplayName;
    private Long teamId;
    private String teamName;
    private String contentPreview;
    private boolean targetDeleted;
    private String createTime;

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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Long getReportUserId() {
        return reportUserId;
    }

    public void setReportUserId(Long reportUserId) {
        this.reportUserId = reportUserId;
    }

    public String getReportUserDisplayName() {
        return reportUserDisplayName;
    }

    public void setReportUserDisplayName(String reportUserDisplayName) {
        this.reportUserDisplayName = reportUserDisplayName;
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

    public String getTargetUserDisplayName() {
        return targetUserDisplayName;
    }

    public void setTargetUserDisplayName(String targetUserDisplayName) {
        this.targetUserDisplayName = targetUserDisplayName;
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

    public String getContentPreview() {
        return contentPreview;
    }

    public void setContentPreview(String contentPreview) {
        this.contentPreview = contentPreview;
    }

    public boolean isTargetDeleted() {
        return targetDeleted;
    }

    public void setTargetDeleted(boolean targetDeleted) {
        this.targetDeleted = targetDeleted;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }
}
