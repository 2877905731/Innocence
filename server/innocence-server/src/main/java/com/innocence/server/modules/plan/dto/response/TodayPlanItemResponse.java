package com.innocence.server.modules.plan.dto.response;

public class TodayPlanItemResponse {

    private Long id;
    private String title;
    private int completed;
    private int plannedMinutes;
    private int actualMinutes;
    private Integer startSlot;
    private Integer endSlot;
    private int sortOrder;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getCompleted() {
        return completed;
    }

    public void setCompleted(int completed) {
        this.completed = completed;
    }

    public int getPlannedMinutes() {
        return plannedMinutes;
    }

    public void setPlannedMinutes(int plannedMinutes) {
        this.plannedMinutes = plannedMinutes;
    }

    public int getActualMinutes() {
        return actualMinutes;
    }

    public void setActualMinutes(int actualMinutes) {
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

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
}
