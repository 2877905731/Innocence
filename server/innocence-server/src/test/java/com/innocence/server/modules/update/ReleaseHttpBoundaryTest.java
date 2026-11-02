package com.innocence.server.modules.update;

import com.innocence.server.common.exception.*;
import com.innocence.server.common.web.*;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.junit.jupiter.api.*;
import org.springframework.test.web.servlet.*;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ReleaseHttpBoundaryTest {
    ReleaseService service = mock(ReleaseService.class);
    AdminAccessService admins = mock(AdminAccessService.class);
    SessionAuthService auth = mock(SessionAuthService.class);
    MockMvc mvc;
    @BeforeEach void setup() {
        UserSession owner = new UserSession(); owner.setUserId(7L);
        when(auth.requireActiveSession("android", "qa-token")).thenReturn(owner);
        when(auth.requireActiveSession("android", "invalid")).thenThrow(new BusinessException(ErrorCode.UNAUTHORIZED, "Expired"));
        mvc = MockMvcBuilders.standaloneSetup(new ReleaseController(service, admins)).addInterceptors(new AuthInterceptor(auth)).setControllerAdvice(new GlobalExceptionHandler()).build();
    }
    @AfterEach void clear() { RequestUserContext.clear(); }
    @Test void anonymousAndExpiredSessionsCannotQueryOrDownload() throws Exception {
        mvc.perform(get("/api/app/v1/updates/latest?platform=android&arch=universal&currentBuild=15")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/app/v1/updates/x/download").header("Authorization", "Bearer invalid").header("X-Device-Type", "android")).andExpect(status().isUnauthorized());
        verifyNoInteractions(service);
    }
    @Test void missingFieldsAndUnprivilegedSpoofedOwnerCannotMutate() throws Exception {
        mvc.perform(get("/api/app/v1/updates/latest").header("Authorization", "Bearer qa-token").header("X-Device-Type", "android")).andExpect(status().isBadRequest());
        doThrow(new BusinessException(ErrorCode.FORBIDDEN, "Not an administrator")).when(admins).requireAdmin(7L);
        mvc.perform(post("/api/admin/v1/releases/x/publish").header("Authorization", "Bearer qa-token").header("X-Device-Type", "android").header("X-User-Id", "1")).andExpect(status().isForbidden());
        verify(admins).requireAdmin(7L); verifyNoInteractions(service);
    }
    @Test void noUpdateIsAStableNullAndOwnerIsNotTakenFromQuery() throws Exception {
        mvc.perform(get("/api/app/v1/updates/latest?platform=android&arch=universal&currentBuild=16&userId=1").header("Authorization", "Bearer qa-token").header("X-Device-Type", "android"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.data.update").isEmpty());
        verify(service).latest("android", "android", "universal",16);
    }
}
