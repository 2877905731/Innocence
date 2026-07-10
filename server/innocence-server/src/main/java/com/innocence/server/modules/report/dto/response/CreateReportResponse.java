package com.innocence.server.modules.report.dto.response;

public class CreateReportResponse {

    private Long reportId;
    private String message;

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
