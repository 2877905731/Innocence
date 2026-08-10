package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.dto.request.PasswordLoginRequest;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AccountServiceSecurityTest {

    private UserMapper userMapper;
    private AccountService accountService;

    @BeforeEach
    void setUp() {
        userMapper = mock(UserMapper.class);
        accountService = new AccountService(
                userMapper,
                mock(EmailCodeService.class),
                mock(CheckInService.class),
                mock(FriendMapper.class)
        );
    }

    @Test
    void passwordLoginRejectsIncorrectPassword() {
        UserAuth auth = new UserAuth();
        auth.setUserId(7L);
        auth.setPasswordSalt("synthetic-salt");
        auth.setPasswordHash("different-synthetic-hash");
        when(userMapper.findAuthByEmail("redacted@example.test")).thenReturn(auth);

        PasswordLoginRequest request = new PasswordLoginRequest();
        request.setEmail("redacted@example.test");
        request.setPassword("synthetic-password");
        request.setDeviceType("windows");
        request.setDeviceId("synthetic-desktop");

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> accountService.loginByPassword(request)
        );

        assertEquals(ErrorCode.UNAUTHORIZED, exception.getCode());
        verify(userMapper, never()).updateUserLoginTime(7L);
    }

    @Test
    void blacklistRejectsCurrentUserAsTarget() {
        when(userMapper.findUserById(7L)).thenReturn(new User());

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> accountService.addBlacklist(7L, 7L)
        );

        assertEquals(ErrorCode.BAD_REQUEST, exception.getCode());
        assertEquals("不能拉黑自己", exception.getMessage());
        verify(userMapper, never()).insertBlacklist(7L, 7L);
    }
}
