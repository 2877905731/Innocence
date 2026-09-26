package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class SessionAuthService {

    private final UserMapper userMapper;

    public SessionAuthService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public UserSession requireActiveSession(Long userId, String deviceType, String sessionToken) {
        if (sessionToken == null || sessionToken.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录已失效，请重新登录");
        }
        if (deviceType == null || deviceType.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "缺少设备类型");
        }

        String normalizedDeviceType = normalizeDeviceType(deviceType);
        String deviceSlot = resolveDeviceSlot(normalizedDeviceType);
        UserSession session = userMapper.findSessionByUserIdAndSlot(userId, deviceSlot);
        if (session == null || session.getStatus() == null || session.getStatus() != 1) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录已失效，请重新登录");
        }
        if (!sessionToken.equals(session.getSessionToken())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "账号已在同类型新设备登录");
        }
        return session;
    }

    /**
     * Resolves the authenticated user from the bearer session itself.
     * The caller must not provide a user id that is trusted as identity input.
     */
    public UserSession requireActiveSession(String deviceType, String sessionToken) {
        if (sessionToken == null || sessionToken.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录已失效，请重新登录");
        }
        String deviceSlot = resolveDeviceSlot(deviceType);
        UserSession session = userMapper.findActiveSessionByTokenAndSlot(sessionToken, deviceSlot);
        if (session == null || session.getUserId() == null) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录已失效，请重新登录");
        }
        return session;
    }

    public void logoutActiveSession(String deviceType, String sessionToken) {
        UserSession session = requireActiveSession(deviceType, sessionToken);
        userMapper.logoutSessionById(session.getId(), LocalDateTime.now());
    }

    private String normalizeDeviceType(String deviceType) {
        if (deviceType == null || deviceType.isBlank()) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "缺少设备类型");
        }
        String normalized = deviceType.trim().toLowerCase();
        return switch (normalized) {
            case "android", "ios", "mobile", "phone" -> "android";
            case "windows", "desktop", "pc" -> "windows";
            case "admin_web" -> "admin_web";
            default -> throw new BusinessException(ErrorCode.UNAUTHORIZED, "不支持的设备类型");
        };
    }

    private String resolveDeviceSlot(String deviceType) {
        return switch (normalizeDeviceType(deviceType)) {
            case "windows" -> "desktop";
            case "admin_web" -> "admin_web";
            default -> "mobile";
        };
    }
}
