package com.innocence.server.modules.plan.domain;

import java.time.LocalDateTime;

public class WeeklyPlanTemplateItem {

    private Long id;
    private Long templateId;
    private Long userId;
    private String title;
    private Integer plannedMinutes;
    private Integer startSlot;
    private Integer endSlot;
    private Integer sortOrder;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getTemplateId() {
        return templateId;
    }

    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Integer getPlannedMinutes() {
        return plannedMinutes;
    }

    public void setPlannedMinutes(Integer plannedMinutes) {
        this.plannedMinutes = plannedMinutes;
    }

    public Integer getStartSlot() {
        return startSlot;
    }

    public void setStartSlot(Integer startSlot) {
        this.startSlot = startSlot;
    }

    public Integer getEndSlot() {
        return endSlot;
    }

    public void setEndSlot(Integer endSlot) {
        this.endSlot = endSlot;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
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
