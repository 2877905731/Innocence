package com.innocence.server.modules.report.domain;

import java.time.LocalDateTime;

public class ReportAuditRecord {

    private Long id;
    private Long reportId;
    private Long adminUserId;
    private String decision;
    private Integer deleteContentFlag;
    private String punishmentType;
    private Integer durationDays;
    private String reasonText;
    private LocalDateTime createTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public Long getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(Long adminUserId) {
        this.adminUserId = adminUserId;
    }

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public Integer getDeleteContentFlag() {
        return deleteContentFlag;
    }

    public void setDeleteContentFlag(Integer deleteContentFlag) {
        this.deleteContentFlag = deleteContentFlag;
    }

    public String getPunishmentType() {
        return punishmentType;
    }

    public void setPunishmentType(String punishmentType) {
        this.punishmentType = punishmentType;
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

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
