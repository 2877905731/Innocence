package com.innocence.server.modules.report.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.report.dto.request.ReviewReportRequest;
import com.innocence.server.modules.report.dto.response.ReportDetailResponse;
import com.innocence.server.modules.report.dto.response.ReportListItemResponse;
import com.innocence.server.modules.report.dto.response.ReportReviewResponse;
import com.innocence.server.modules.report.service.ReportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/v1/reports")
public class ReportAdminController {

    private final ReportService reportService;

    public ReportAdminController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping
    public ApiResponse<List<ReportListItemResponse>> getReports(
            @RequestParam(name = "status", required = false) String status,
            @RequestParam(name = "reportType", required = false) String reportType,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(
                reportService.getReports(currentUserId(), status, reportType, limit)
        );
    }

    @GetMapping("/{reportId}")
    public ApiResponse<ReportDetailResponse> getReportDetail(@PathVariable("reportId") Long reportId) {
        return ApiResponse.success(reportService.getReportDetail(currentUserId(), reportId));
    }

    @PostMapping("/{reportId}/review")
    public ApiResponse<ReportReviewResponse> reviewReport(
            @PathVariable("reportId") Long reportId,
            @Valid @RequestBody ReviewReportRequest request
    ) {
        return ApiResponse.success(reportService.reviewReport(currentUserId(), reportId, request));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
