package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class SessionAuthServiceTest {

    private UserMapper userMapper;
    private SessionAuthService sessionAuthService;

    @BeforeEach
    void setUp() {
        userMapper = mock(UserMapper.class);
        sessionAuthService = new SessionAuthService(userMapper);
    }

    @Test
    void rejectsMissingSessionTokenBeforeReadingAccountState() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> sessionAuthService.requireActiveSession(7L, "windows", "")
        );

        assertEquals(ErrorCode.UNAUTHORIZED, exception.getCode());
        verify(userMapper, never()).findSessionByUserIdAndSlot(7L, "desktop");
    }

    @Test
    void rejectsTokenFromAReplacedDesktopSession() {
        UserSession activeSession = activeSession("current-desktop-session");
        when(userMapper.findSessionByUserIdAndSlot(7L, "desktop"))
                .thenReturn(activeSession);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> sessionAuthService.requireActiveSession(
                        7L,
                        "windows",
                        "replaced-desktop-session"
                )
        );

        assertEquals(ErrorCode.UNAUTHORIZED, exception.getCode());
        assertEquals("账号已在同类型新设备登录", exception.getMessage());
    }

    @Test
    void rejectsUnsupportedDeviceType() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> sessionAuthService.requireActiveSession(
                        7L,
                        "unsupported-device",
                        "session-value"
                )
        );

        assertEquals(ErrorCode.UNAUTHORIZED, exception.getCode());
    }

    @Test
    void acceptsTheActiveWindowsSessionFromTheDesktopSlot() {
        UserSession activeSession = activeSession("current-desktop-session");
        when(userMapper.findSessionByUserIdAndSlot(7L, "desktop"))
                .thenReturn(activeSession);

        UserSession result = sessionAuthService.requireActiveSession(
                7L,
                "desktop",
                "current-desktop-session"
        );

        assertSame(activeSession, result);
        verify(userMapper).findSessionByUserIdAndSlot(7L, "desktop");
    }

    private UserSession activeSession(String token) {
        UserSession session = new UserSession();
        session.setStatus(1);
        session.setSessionToken(token);
        return session;
    }
}
