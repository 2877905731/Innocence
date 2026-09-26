package com.innocence.server.modules.report.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.report.mapper.AdminDashboardMapper;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/admin/v1/dashboard")
public class AdminDashboardController {
    private final AdminDashboardMapper dashboardMapper;
    private final AdminAccessService adminAccessService;

    public AdminDashboardController(AdminDashboardMapper dashboardMapper, AdminAccessService adminAccessService) {
        this.dashboardMapper = dashboardMapper;
        this.adminAccessService = adminAccessService;
    }

    @GetMapping("/overview")
    public ApiResponse<Map<String, Long>> overview() {
        adminAccessService.requireAdmin(RequestUserContext.getUserId());
        return ApiResponse.success(Map.of(
                "userCount", dashboardMapper.countUsers(),
                "availableUserCount", dashboardMapper.countAvailableUsers(),
                "teamCount", dashboardMapper.countActiveTeams(),
                "pendingReportCount", dashboardMapper.countPendingReports(),
                "todayStudyMinutes", dashboardMapper.todayStudySeconds() / 60
        ));
    }
}
