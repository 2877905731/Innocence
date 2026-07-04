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
        String userIdHeader = request.getHeader("X-User-Id");
        if (userIdHeader == null || userIdHeader.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "缺少用户身份，请重新登录");
        }
        Long userId = Long.valueOf(userIdHeader);
        String deviceType = request.getHeader("X-Device-Type");
        String authorization = request.getHeader("Authorization");
        String sessionToken = authorization == null ? "" : authorization.replace("Bearer", "").trim();

        sessionAuthService.requireActiveSession(userId, deviceType, sessionToken);
        RequestUserContext.setUserId(userId);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        RequestUserContext.clear();
    }
}
