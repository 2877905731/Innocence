package com.innocence.server.modules.plan.domain;

import java.time.LocalDateTime;

public class AnnualPlanSegment {

    private Long id;
    private Long userId;
    private String clientEntityId;
    private Integer planYear;
    private String title;
    private Integer startMonth;
    private Integer endMonth;
    private String colorKey;
    private Integer sortOrder;
    private String note;
    private Integer revision;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getClientEntityId() { return clientEntityId; }
    public void setClientEntityId(String clientEntityId) { this.clientEntityId = clientEntityId; }
    public Integer getPlanYear() { return planYear; }
    public void setPlanYear(Integer planYear) { this.planYear = planYear; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getStartMonth() { return startMonth; }
    public void setStartMonth(Integer startMonth) { this.startMonth = startMonth; }
    public Integer getEndMonth() { return endMonth; }
    public void setEndMonth(Integer endMonth) { this.endMonth = endMonth; }
    public String getColorKey() { return colorKey; }
    public void setColorKey(String colorKey) { this.colorKey = colorKey; }
    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public Integer getRevision() { return revision; }
    public void setRevision(Integer revision) { this.revision = revision; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
}
