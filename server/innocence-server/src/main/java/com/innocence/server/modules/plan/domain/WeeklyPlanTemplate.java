package com.innocence.server.modules.plan.domain;

import java.time.LocalDateTime;

public class WeeklyPlanTemplate {

    private Long id;
    private Long userId;
    private String templateName;
    private String sourcePlanName;
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

    public String getTemplateName() {
        return templateName;
    }

    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }

    public String getSourcePlanName() {
        return sourcePlanName;
    }

    public void setSourcePlanName(String sourcePlanName) {
        this.sourcePlanName = sourcePlanName;
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
