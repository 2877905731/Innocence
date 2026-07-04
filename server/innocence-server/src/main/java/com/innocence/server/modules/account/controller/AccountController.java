package com.innocence.server.modules.account.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.account.dto.request.CancelAccountRequest;
import com.innocence.server.modules.account.dto.request.UpdatePrivacyRequest;
import com.innocence.server.modules.account.dto.request.UpdateProfileRequest;
import com.innocence.server.modules.account.dto.response.BlacklistItemResponse;
import com.innocence.server.modules.account.dto.response.CurrentSessionResponse;
import com.innocence.server.modules.account.dto.response.PrivacySettingResponse;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;
import com.innocence.server.modules.account.service.AccountService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/app/v1/account")
public class AccountController {

    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping("/profile")
    public ApiResponse<UserProfileResponse> getProfile() {
        return ApiResponse.success(accountService.getMyProfile(currentUserId()));
    }

    @PutMapping("/profile")
    public ApiResponse<UserProfileResponse> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.success(accountService.updateMyProfile(currentUserId(), request));
    }

    @GetMapping("/privacy")
    public ApiResponse<PrivacySettingResponse> getPrivacy() {
        return ApiResponse.success(accountService.getPrivacySetting(currentUserId()));
    }

    @PutMapping("/privacy")
    public ApiResponse<PrivacySettingResponse> updatePrivacy(@Valid @RequestBody UpdatePrivacyRequest request) {
        return ApiResponse.success(accountService.updatePrivacySetting(currentUserId(), request));
    }

    @GetMapping("/sessions/current")
    public ApiResponse<CurrentSessionResponse> getCurrentSession(
            @RequestHeader(name = "X-Device-Type") String deviceType,
            @RequestHeader(name = "X-Device-Id") String deviceId,
            @RequestHeader(name = "Authorization", defaultValue = "") String authorization
    ) {
        String sessionToken = authorization.replace("Bearer", "").trim();
        return ApiResponse.success(accountService.getCurrentSession(currentUserId(), deviceType, deviceId, sessionToken));
    }

    @PostMapping("/cancel")
    public ApiResponse<Map<String, Object>> cancelAccount(@Valid @RequestBody CancelAccountRequest request) {
        accountService.cancelAccount(currentUserId(), request);
        return ApiResponse.success(Map.of("success", true));
    }

    @GetMapping("/blacklist")
    public ApiResponse<List<BlacklistItemResponse>> getBlacklist() {
        return ApiResponse.success(accountService.getBlacklist(currentUserId()));
    }

    @PostMapping("/blacklist/{targetUserId}")
    public ApiResponse<Map<String, Object>> addBlacklist(@PathVariable Long targetUserId) {
        accountService.addBlacklist(currentUserId(), targetUserId);
        return ApiResponse.success(Map.of("success", true));
    }

    @DeleteMapping("/blacklist/{targetUserId}")
    public ApiResponse<Map<String, Object>> removeBlacklist(@PathVariable Long targetUserId) {
        accountService.removeBlacklist(currentUserId(), targetUserId);
        return ApiResponse.success(Map.of("success", true));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
