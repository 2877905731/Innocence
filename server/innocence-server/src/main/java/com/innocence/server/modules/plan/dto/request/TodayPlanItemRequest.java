package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Max;

public class TodayPlanItemRequest {

    @NotBlank(message = "Task title is required")
    private String title;

    @Min(value = 0, message = "Planned minutes must be at least 0")
    private Integer plannedMinutes;

    @Min(value = 0, message = "Actual minutes must be at least 0")
    private Integer actualMinutes;

    @Min(value = 0, message = "Start slot must be at least 0")
    @Max(value = 47, message = "Start slot must be at most 47")
    private Integer startSlot;

    @Min(value = 1, message = "End slot must be at least 1")
    @Max(value = 48, message = "End slot must be at most 48")
    private Integer endSlot;

    private Boolean completed;

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

    public Integer getActualMinutes() {
        return actualMinutes;
    }

    public void setActualMinutes(Integer actualMinutes) {
        this.actualMinutes = actualMinutes;
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

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }
}
