package com.innocence.server.modules.focus.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.common.web.AuthInterceptor;
import com.innocence.server.common.web.GlobalExceptionHandler;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.focus.controller.FocusSessionController;
import com.innocence.server.modules.focus.dto.request.ConfigurePomodoroRequest;
import com.innocence.server.modules.focus.dto.response.FocusSessionResponse;
import org.junit.jupiter.api.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class FocusPomodoroBoundaryTest {
    FocusSessionService focus = mock(FocusSessionService.class);
    SessionAuthService auth = mock(SessionAuthService.class);
    MockMvc mvc;
    final String path = "/api/app/v1/focus/session/pomodoro";
    final String body = "{\"sessionId\":42,\"bindPomodoro\":true,\"pomodoroStudyMinutes\":25,\"pomodoroBreakMinutes\":5}";
    @BeforeEach void setup() {
        UserSession session = new UserSession(); session.setUserId(7L);
        when(auth.requireActiveSession("android", "qa-token")).thenReturn(session);
        mvc = MockMvcBuilders.standaloneSetup(new FocusSessionController(focus))
                .addInterceptors(new AuthInterceptor(auth)).setControllerAdvice(new GlobalExceptionHandler()).build();
    }
    @AfterEach void clear() { RequestUserContext.clear(); }
    @Test void authenticationAndRequiredFieldsCannotReachMutation() throws Exception {
        mvc.perform(post(path).contentType("application/json").content(body)).andExpect(status().isUnauthorized());
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
                .contentType("application/json").content("{}")).andExpect(status().isBadRequest());
        verifyNoInteractions(focus);
    }
    @Test void tokenOwnerControlsMutationAndStaleSessionIs404() throws Exception {
        when(focus.configurePomodoro(eq(7L), any())).thenReturn(new FocusSessionResponse());
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
                .contentType("application/json").content(body)).andExpect(status().isOk());
        verify(focus).configurePomodoro(7L, new ConfigurePomodoroRequest(42L, true, 25, 5));
        when(focus.configurePomodoro(eq(7L), any())).thenThrow(new BusinessException(ErrorCode.NOT_FOUND, "No matching session"));
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
                .contentType("application/json").content(body)).andExpect(status().isNotFound());
    }
}
