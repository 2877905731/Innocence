package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.domain.UserProfile;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.dto.request.PasswordLoginRequest;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

class AdminWebSessionTest {
    private UserMapper mapper;
    private AdminAccessService access;
    private AccountService account;

    @BeforeEach
    void setUp() {
        mapper = mock(UserMapper.class);
        access = mock(AdminAccessService.class);
        account = new AccountService(mapper, mock(EmailCodeService.class), mock(CheckInService.class), mock(FriendMapper.class));
    }

    @Test
    void adminLoginUsesIndependentSlot() throws Exception {
        UserAuth auth = auth();
        when(mapper.findAuthByEmail("admin@example.test")).thenReturn(auth);
        User user = new User(); user.setId(7L); user.setNickname("管理员"); user.setUserNo("U7");
        UserProfile profile = new UserProfile(); profile.setUserId(7L);
        when(mapper.findUserById(7L)).thenReturn(user);
        when(mapper.findProfileByUserId(7L)).thenReturn(profile);

        var result = account.loginAdminByPassword("admin@example.test", "synthetic-password", "browser-tab", access);

        ArgumentCaptor<UserSession> session = ArgumentCaptor.forClass(UserSession.class);
        verify(mapper).upsertSession(session.capture());
        assertEquals("admin_web", session.getValue().getDeviceSlot());
        assertEquals("admin_web", result.getDeviceType());
        assertEquals("browser-tab", result.getDeviceId());
        verify(access).requireAdmin(7L);
    }

    @Test
    void nonAdminCannotCreateWebSession() throws Exception {
        when(mapper.findAuthByEmail("admin@example.test")).thenReturn(auth());
        doThrow(new BusinessException(ErrorCode.FORBIDDEN, "forbidden")).when(access).requireAdmin(7L);

        BusinessException error = assertThrows(BusinessException.class,
                () -> account.loginAdminByPassword("admin@example.test", "synthetic-password", "browser-tab", access));

        assertEquals(ErrorCode.FORBIDDEN, error.getCode());
        verify(mapper, never()).upsertSession(any());
        verify(mapper, never()).updateUserLoginTime(anyLong());
    }

    @Test
    void normalLoginCannotRequestAdminSlot() throws Exception {
        when(mapper.findAuthByEmail("admin@example.test")).thenReturn(auth());
        User user = new User(); user.setId(7L);
        UserProfile profile = new UserProfile(); profile.setUserId(7L);
        when(mapper.findUserById(7L)).thenReturn(user);
        when(mapper.findProfileByUserId(7L)).thenReturn(profile);
        PasswordLoginRequest request = new PasswordLoginRequest();
        request.setEmail("admin@example.test"); request.setPassword("synthetic-password");
        request.setDeviceType("admin_web"); request.setDeviceId("browser-tab");

        BusinessException error = assertThrows(BusinessException.class, () -> account.loginByPassword(request));
        assertEquals(ErrorCode.BAD_REQUEST, error.getCode());
        verify(mapper, never()).upsertSession(any());
    }

    @Test
    void webTokenCannotUseDesktopSlot() {
        SessionAuthService sessions = new SessionAuthService(mapper);
        UserSession web = new UserSession(); web.setUserId(7L);
        when(mapper.findActiveSessionByTokenAndSlot("synthetic-token", "admin_web")).thenReturn(web);
        assertEquals(7L, sessions.requireActiveSession("admin_web", "synthetic-token").getUserId());
        assertThrows(BusinessException.class, () -> sessions.requireActiveSession("windows", "synthetic-token"));
        verify(mapper).findActiveSessionByTokenAndSlot("synthetic-token", "desktop");
    }

    private UserAuth auth() throws Exception {
        UserAuth auth = new UserAuth();
        auth.setUserId(7L); auth.setAuthAccount("admin@example.test"); auth.setPasswordSalt("salt");
        byte[] hash = MessageDigest.getInstance("SHA-256").digest("synthetic-passwordsalt".getBytes(StandardCharsets.UTF_8));
        auth.setPasswordHash(HexFormat.of().formatHex(hash));
        return auth;
    }
}
