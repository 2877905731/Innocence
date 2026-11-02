package com.innocence.server.modules.focus.service;

import com.innocence.server.common.web.*;
import com.innocence.server.common.exception.*;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.focus.controller.FocusSessionController;
import org.junit.jupiter.api.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class PomodoroStudyBoundaryTest {
    FocusSessionService focus = mock(FocusSessionService.class);
    SessionAuthService auth = mock(SessionAuthService.class);
    MockMvc mvc;
    String path = "/api/app/v1/focus/session/pomodoro-study";
    String body = """
        {"recordKey":"qa/1/2026-11-01","startTime":"2026-11-01T09:00:00",
        "endTime":"2026-11-01T09:01:00","studySeconds":60,"creditedSeconds":60,"completedRounds":0,"userId":999}
        """;
    @BeforeEach void setup() {
        var session = new UserSession(); session.setUserId(7L);
        when(auth.requireActiveSession("android", "qa-token")).thenReturn(session);
        mvc = MockMvcBuilders.standaloneSetup(new FocusSessionController(focus))
            .addInterceptors(new AuthInterceptor(auth)).setControllerAdvice(new GlobalExceptionHandler()).build();
    }
    @AfterEach void clear() { RequestUserContext.clear(); }
    @Test void authenticationAndMissingFieldsNeverReachMutation() throws Exception {
        mvc.perform(post(path).contentType("application/json").content(body)).andExpect(status().isUnauthorized());
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
            .contentType("application/json").content("{}")).andExpect(status().isBadRequest());
        verifyNoInteractions(focus);
    }
    @Test void tokenOwnerWinsOverBodyAndPermissionFailurePropagates() throws Exception {
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
            .contentType("application/json").content(body)).andExpect(status().isOk());
        verify(focus).recordPomodoroStudy(eq(7L), any());
        doThrow(new BusinessException(ErrorCode.FORBIDDEN, "Permission denied"))
            .when(focus).recordPomodoroStudy(eq(7L), any());
        mvc.perform(post(path).header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")
            .contentType("application/json").content(body)).andExpect(status().isForbidden());
    }
}
