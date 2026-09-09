package com.innocence.server.modules.plan.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class SaveAnnualPlanSegmentRequest {

    @Size(max = 64)
    private String clientEntityId;

    @NotNull
    @Min(1)
    @Max(9999)
    private Integer year;

    @NotBlank
    @Size(max = 96)
    private String title;

    @NotNull
    @Min(1)
    @Max(12)
    private Integer startMonth;

    @NotNull
    @Min(1)
    @Max(12)
    private Integer endMonth;

    @Size(max = 24)
    private String colorKey;

    private Integer sortOrder;

    @Size(max = 500)
    private String note;

    private Integer revision;

    public String getClientEntityId() { return clientEntityId; }
    public void setClientEntityId(String clientEntityId) { this.clientEntityId = clientEntityId; }
    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
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
}
