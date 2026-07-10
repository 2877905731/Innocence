package com.innocence.server.modules.report.dto.response;

import java.util.ArrayList;
import java.util.List;

public class ReportDetailResponse {

    private Long reportId;
    private String reportType;
    private String status;
    private String reason;
    private String description;
    private Long reportUserId;
    private String reportUserDisplayName;
    private Long targetId;
    private Long targetUserId;
    private String targetUserDisplayName;
    private Long teamId;
    private String teamName;
    private String targetContent;
    private boolean targetMasked;
    private boolean targetDeleted;
    private String targetDeletedReason;
    private Long handledUserId;
    private String handledUserDisplayName;
    private String handledTime;
    private String createTime;
    private List<ReportAuditItemResponse> auditHistory = new ArrayList<>();

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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public String getTargetContent() {
        return targetContent;
    }

    public void setTargetContent(String targetContent) {
        this.targetContent = targetContent;
    }

    public boolean isTargetMasked() {
        return targetMasked;
    }

    public void setTargetMasked(boolean targetMasked) {
        this.targetMasked = targetMasked;
    }

    public boolean isTargetDeleted() {
        return targetDeleted;
    }

    public void setTargetDeleted(boolean targetDeleted) {
        this.targetDeleted = targetDeleted;
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

    public String getHandledUserDisplayName() {
        return handledUserDisplayName;
    }

    public void setHandledUserDisplayName(String handledUserDisplayName) {
        this.handledUserDisplayName = handledUserDisplayName;
    }

    public String getHandledTime() {
        return handledTime;
    }

    public void setHandledTime(String handledTime) {
        this.handledTime = handledTime;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public List<ReportAuditItemResponse> getAuditHistory() {
        return auditHistory;
    }

    public void setAuditHistory(List<ReportAuditItemResponse> auditHistory) {
        this.auditHistory = auditHistory;
    }
}
