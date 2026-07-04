package com.innocence.server.modules.account.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.modules.account.dto.request.CodeLoginRequest;
import com.innocence.server.modules.account.dto.request.EmailCodeRequest;
import com.innocence.server.modules.account.dto.request.EmailRegisterRequest;
import com.innocence.server.modules.account.dto.request.PasswordLoginRequest;
import com.innocence.server.modules.account.dto.request.ResetPasswordRequest;
import com.innocence.server.modules.account.dto.response.AuthTokenResponse;
import com.innocence.server.modules.account.service.AccountService;
import com.innocence.server.modules.account.service.EmailCodeService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/app/v1/auth")
public class AuthController {

    private final AccountService accountService;
    private final EmailCodeService emailCodeService;

    public AuthController(AccountService accountService, EmailCodeService emailCodeService) {
        this.accountService = accountService;
        this.emailCodeService = emailCodeService;
    }

    @PostMapping("/email/send-register-code")
    public ApiResponse<Map<String, Object>> sendRegisterCode(@Valid @RequestBody EmailCodeRequest request) {
        return ApiResponse.success(emailCodeService.sendRegisterCode(request.getEmail()));
    }

    @PostMapping("/email/send-login-code")
    public ApiResponse<Map<String, Object>> sendLoginCode(@Valid @RequestBody EmailCodeRequest request) {
        return ApiResponse.success(emailCodeService.sendLoginCode(request.getEmail()));
    }

    @PostMapping("/password/send-reset-code")
    public ApiResponse<Map<String, Object>> sendResetCode(@Valid @RequestBody EmailCodeRequest request) {
        return ApiResponse.success(emailCodeService.sendResetCode(request.getEmail()));
    }

    @PostMapping("/email/register")
    public ApiResponse<AuthTokenResponse> register(@Valid @RequestBody EmailRegisterRequest request) {
        return ApiResponse.success(accountService.registerByEmail(request));
    }

    @PostMapping("/login/password")
    public ApiResponse<AuthTokenResponse> loginByPassword(@Valid @RequestBody PasswordLoginRequest request) {
        return ApiResponse.success(accountService.loginByPassword(request));
    }

    @PostMapping("/login/code")
    public ApiResponse<AuthTokenResponse> loginByCode(@Valid @RequestBody CodeLoginRequest request) {
        return ApiResponse.success(accountService.loginByCode(request));
    }

    @PostMapping("/password/reset")
    public ApiResponse<Map<String, Object>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        accountService.resetPassword(request);
        return ApiResponse.success(Map.of("success", true));
    }
}
