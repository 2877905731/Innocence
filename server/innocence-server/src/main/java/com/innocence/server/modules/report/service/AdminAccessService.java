package com.innocence.server.modules.report.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.report.config.AdminAccessProperties;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

@Service
public class AdminAccessService {

    private final UserMapper userMapper;
    private final Set<String> adminEmails = new HashSet<>();

    public AdminAccessService(UserMapper userMapper, AdminAccessProperties adminAccessProperties) {
        this.userMapper = userMapper;
        if (adminAccessProperties != null && adminAccessProperties.getEmails() != null) {
            for (String email : adminAccessProperties.getEmails()) {
                if (email != null && !email.isBlank()) {
                    adminEmails.add(email.trim().toLowerCase(Locale.ROOT));
                }
            }
        }
    }

    public void requireAdmin(Long userId) {
        if (userId == null) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "Administrator login is required.");
        }
        UserAuth userAuth = userMapper.findAuthByUserId(userId);
        String email = userAuth == null ? "" : defaultText(userAuth.getAuthAccount()).toLowerCase(Locale.ROOT);
        if (!adminEmails.contains(email)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "You do not have administrator permission.");
        }
    }

    private String defaultText(String value) {
        return value == null ? "" : value.trim();
    }
}
