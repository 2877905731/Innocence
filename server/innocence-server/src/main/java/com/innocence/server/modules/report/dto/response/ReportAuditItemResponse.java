package com.innocence.server.modules.report.dto.response;

public class ReportAuditItemResponse {

    private Long auditId;
    private String decision;
    private boolean deleteContent;
    private String punishmentType;
    private int durationDays;
    private String reason;
    private Long adminUserId;
    private String adminDisplayName;
    private String createTime;

    public Long getAuditId() {
        return auditId;
    }

    public void setAuditId(Long auditId) {
        this.auditId = auditId;
    }

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public boolean isDeleteContent() {
        return deleteContent;
    }

    public void setDeleteContent(boolean deleteContent) {
        this.deleteContent = deleteContent;
    }

    public String getPunishmentType() {
        return punishmentType;
    }

    public void setPunishmentType(String punishmentType) {
        this.punishmentType = punishmentType;
    }

    public int getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(int durationDays) {
        this.durationDays = durationDays;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Long getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(Long adminUserId) {
        this.adminUserId = adminUserId;
    }

    public String getAdminDisplayName() {
        return adminDisplayName;
    }

    public void setAdminDisplayName(String adminDisplayName) {
        this.adminDisplayName = adminDisplayName;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }
}
