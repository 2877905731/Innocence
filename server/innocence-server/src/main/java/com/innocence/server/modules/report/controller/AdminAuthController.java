package com.innocence.server.modules.report.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.account.dto.response.AuthTokenResponse;
import com.innocence.server.modules.account.service.AccountService;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.report.dto.request.AdminLoginRequest;
import com.innocence.server.modules.report.service.AdminAccessService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/admin/v1/auth")
public class AdminAuthController {
    private final AccountService accountService;
    private final AdminAccessService adminAccessService;
    private final SessionAuthService sessionAuthService;

    public AdminAuthController(AccountService accountService, AdminAccessService adminAccessService,
                               SessionAuthService sessionAuthService) {
        this.accountService = accountService;
        this.adminAccessService = adminAccessService;
        this.sessionAuthService = sessionAuthService;
    }

    @PostMapping("/login")
    public ApiResponse<AuthTokenResponse> login(@Valid @RequestBody AdminLoginRequest request) {
        return ApiResponse.success(accountService.loginAdminByPassword(
                request.getEmail(), request.getPassword(), request.getDeviceId(), adminAccessService));
    }

    @GetMapping("/me")
    public ApiResponse<Map<String, Object>> me(@RequestHeader("X-Device-Type") String deviceType) {
        requireAdminWeb(deviceType);
        Long userId = RequestUserContext.getUserId();
        adminAccessService.requireAdmin(userId);
        return ApiResponse.success(Map.of("userId", userId));
    }

    @PostMapping("/logout")
    public ApiResponse<Map<String, Boolean>> logout(@RequestHeader("X-Device-Type") String deviceType,
                                                     @RequestHeader("Authorization") String authorization) {
        requireAdminWeb(deviceType);
        Long userId = RequestUserContext.getUserId();
        adminAccessService.requireAdmin(userId);
        sessionAuthService.logoutActiveSession("admin_web", authorization.substring("Bearer ".length()).trim());
        return ApiResponse.success(Map.of("success", true));
    }

    private void requireAdminWeb(String deviceType) {
        if (!"admin_web".equalsIgnoreCase(deviceType)) {
            throw new com.innocence.server.common.exception.BusinessException(
                    com.innocence.server.common.exception.ErrorCode.FORBIDDEN, "Administrator web session required.");
        }
    }
}
