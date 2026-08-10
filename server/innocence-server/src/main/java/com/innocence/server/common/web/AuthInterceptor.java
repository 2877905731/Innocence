package com.innocence.server.common.web;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.service.SessionAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final SessionAuthService sessionAuthService;

    public AuthInterceptor(SessionAuthService sessionAuthService) {
        this.sessionAuthService = sessionAuthService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String deviceType = request.getHeader("X-Device-Type");
        String sessionToken = extractBearerToken(request.getHeader("Authorization"));

        Long userId = sessionAuthService.requireActiveSession(deviceType, sessionToken).getUserId();
        RequestUserContext.setUserId(userId);
        return true;
    }

    private String extractBearerToken(String authorization) {
        if (authorization == null || authorization.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "缺少登录凭据，请重新登录");
        }
        String prefix = "Bearer ";
        if (!authorization.regionMatches(true, 0, prefix, 0, prefix.length())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录凭据格式不正确");
        }
        String token = authorization.substring(prefix.length()).trim();
        if (token.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "缺少登录凭据，请重新登录");
        }
        return token;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        RequestUserContext.clear();
    }
}
