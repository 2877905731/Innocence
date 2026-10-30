package com.innocence.server.modules.account.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.account.service.AdminAccountService;
import com.fasterxml.jackson.databind.JsonNode;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/v1")
public class AdminAccountController {
    public record RegistrationUpdate(@NotNull(message="请选择是否接受注册") JsonNode enabled) { }
    private final AdminAccountService service;
    public AdminAccountController(AdminAccountService service) { this.service=service; }

    @GetMapping("/settings/registration")
    public ApiResponse<AdminAccountService.RegistrationPolicy> getRegistration() {
        return ApiResponse.success(service.getRegistration(RequestUserContext.getUserId()));
    }
    @PutMapping("/settings/registration")
    public ApiResponse<AdminAccountService.RegistrationPolicy> setRegistration(@Valid @RequestBody RegistrationUpdate request) {
        if (!request.enabled().isBoolean()) throw new BusinessException(ErrorCode.VALIDATION_ERROR, "接受注册必须为布尔值");
        return ApiResponse.success(service.setRegistration(RequestUserContext.getUserId(), request.enabled().booleanValue()));
    }
    @GetMapping("/users/{userId}/deletion-preview")
    public ApiResponse<AdminAccountService.DeletionPreview> preview(@PathVariable Long userId) {
        return ApiResponse.success(service.previewDeletion(RequestUserContext.getUserId(), userId));
    }
    @DeleteMapping("/users/{userId}")
    public ApiResponse<AdminAccountService.DeletionResult> delete(@PathVariable Long userId) {
        return ApiResponse.success(service.deleteUser(RequestUserContext.getUserId(), userId));
    }
}
