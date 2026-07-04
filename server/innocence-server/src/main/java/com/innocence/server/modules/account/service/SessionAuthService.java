package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.springframework.stereotype.Service;

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
        String deviceSlot = "windows".equals(normalizedDeviceType) ? "desktop" : "mobile";
        UserSession session = userMapper.findSessionByUserIdAndSlot(userId, deviceSlot);
        if (session == null || session.getStatus() == null || session.getStatus() != 1) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "登录已失效，请重新登录");
        }
        if (!sessionToken.equals(session.getSessionToken())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "账号已在同类型新设备登录");
        }
        return session;
    }

    private String normalizeDeviceType(String deviceType) {
        String normalized = deviceType.trim().toLowerCase();
        return switch (normalized) {
            case "android", "ios", "mobile", "phone" -> "android";
            case "windows", "desktop", "pc" -> "windows";
            default -> throw new BusinessException(ErrorCode.UNAUTHORIZED, "不支持的设备类型");
        };
    }
}
