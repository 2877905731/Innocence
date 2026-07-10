package com.innocence.server.modules.report.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.report.dto.response.AdminLiftPunishmentResponse;
import com.innocence.server.modules.report.dto.response.AdminUserDetailResponse;
import com.innocence.server.modules.report.dto.response.AdminUserPunishmentItemResponse;
import com.innocence.server.modules.report.dto.response.AdminUserReportItemResponse;
import com.innocence.server.modules.report.dto.response.AdminUserSearchItemResponse;
import com.innocence.server.modules.report.service.ReportService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/v1/users")
public class ReportAdminUserController {

    private final ReportService reportService;

    public ReportAdminUserController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/search")
    public ApiResponse<List<AdminUserSearchItemResponse>> searchUsers(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(reportService.searchUsers(currentUserId(), keyword, limit));
    }

    @GetMapping("/{userId}")
    public ApiResponse<AdminUserDetailResponse> getUserDetail(@PathVariable("userId") Long userId) {
        return ApiResponse.success(reportService.getAdminUserDetail(currentUserId(), userId));
    }

    @GetMapping("/{userId}/reports")
    public ApiResponse<List<AdminUserReportItemResponse>> getUserReports(
            @PathVariable("userId") Long userId,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(reportService.getAdminUserReports(currentUserId(), userId, limit));
    }

    @GetMapping("/{userId}/punishments")
    public ApiResponse<List<AdminUserPunishmentItemResponse>> getUserPunishments(
            @PathVariable("userId") Long userId,
            @RequestParam(name = "status", required = false) String status,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(
                reportService.getAdminUserPunishments(currentUserId(), userId, status, limit)
        );
    }

    @PostMapping("/{userId}/punishments/{punishmentId}/lift")
    public ApiResponse<AdminLiftPunishmentResponse> liftPunishment(
            @PathVariable("userId") Long userId,
            @PathVariable("punishmentId") Long punishmentId
    ) {
        return ApiResponse.success(
                reportService.liftPunishment(currentUserId(), userId, punishmentId)
        );
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
