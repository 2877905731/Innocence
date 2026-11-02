package com.innocence.server.modules.plan.service;

import com.innocence.server.common.web.*;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.plan.controller.StudyPlanController;
import com.innocence.server.modules.plan.dto.request.SaveAnnualPlanSegmentRequest;
import com.innocence.server.modules.plan.dto.request.AnnualPlanSubtaskRequest;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/** Real controller/service/MySQL mapping. Synthetic rows are rolled back after each case. */
@SpringBootTest(properties = "logging.level.com.innocence.server=INFO")
@Transactional
class AnnualPlanHttpIntegrationTest {
    @Autowired StudyPlanService plans;
    @Autowired JdbcTemplate db;
    @MockBean SessionAuthService auth;
    MockMvc mvc;
    long owner;
    String path = "/api/app/v1/plans/annual-segments";
    String minimal = "{\"year\":2027,\"title\":\"x\",\"startMonth\":1,\"endMonth\":1,\"note\":\"\",\"subtasks\":[]}";
    long owner() {
        String name = "annual-fixture-" + UUID.randomUUID();
        db.update("INSERT INTO app_user(user_no,nickname,status) VALUES(?,?,1)", UUID.randomUUID().toString().replace("-", ""), name);
        return db.queryForObject("SELECT id FROM app_user WHERE nickname=?", Long.class, name);
    }
    @BeforeEach void setup() {
        owner = owner();
        UserSession session = new UserSession(); session.setUserId(owner);
        when(auth.requireActiveSession("harmonyos", "annual-fixture-token")).thenReturn(session);
        mvc = MockMvcBuilders.standaloneSetup(new StudyPlanController(plans)).addFilter(new RequestTraceFilter())
            .addInterceptors(new AuthInterceptor(auth)).setControllerAdvice(new GlobalExceptionHandler()).build();
    }
    @AfterEach void clear() { RequestUserContext.clear(); }
    MockHttpServletRequestBuilder own(MockHttpServletRequestBuilder request) {
        return request.header("Authorization", "Bearer annual-fixture-token").header("X-Device-Type", "harmonyos")
            .header("X-Request-ID", "11111111-1111-4111-8111-111111111111").contentType("application/json");
    }
    SaveAnnualPlanSegmentRequest request(String clientId) {
        var request = new SaveAnnualPlanSegmentRequest(); request.setYear(2026); request.setTitle("Existing");
        request.setStartMonth(1); request.setEndMonth(8); request.setClientEntityId(clientId); request.setProgressPercent(70);
        var child = new AnnualPlanSubtaskRequest(); child.setTitle("Child"); child.setCompleted(true); request.setSubtasks(List.of(child));
        return request;
    }
    @Test void exactMinimalCreateReturnsSuccessAndPersistsDefaultProgressWithoutSubtasks() throws Exception {
        mvc.perform(own(post(path)).content(minimal)).andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value(0)).andExpect(jsonPath("$.requestId").isNotEmpty())
            .andExpect(jsonPath("$.data.year").value(2027)).andExpect(jsonPath("$.data.segments[0].title").value("x"))
            .andExpect(jsonPath("$.data.segments[0].progressPercent").value(0))
            .andExpect(jsonPath("$.data.segments[0].subtasks").isEmpty());
        assertEquals(1, db.queryForObject("SELECT COUNT(*) FROM annual_plan_segment WHERE user_id=?", Integer.class, owner));
    }
    @Test void uuidOnTheNumericUpdateRouteIsA400AndDoesNotCreateAnyTask() throws Exception {
        mvc.perform(own(put(path + "/22222222-2222-4222-8222-222222222222")).content(minimal))
            .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value(1001))
            .andExpect(jsonPath("$.requestId").isNotEmpty());
        assertEquals(0, db.queryForObject("SELECT COUNT(*) FROM annual_plan_segment WHERE user_id=?", Integer.class, owner));
    }
    @Test void existingUpdatePreservesProgressAndChildCompletion() throws Exception {
        var existing = plans.saveAnnualSegment(owner, null, request(UUID.randomUUID().toString())).segments().getFirst();
        String body = "{\"year\":2026,\"title\":\"Revised\",\"startMonth\":2,\"endMonth\":9,\"revision\":" + existing.revision() +
            ",\"subtasks\":[{\"title\":\"Child\",\"detail\":\"\",\"completed\":true}]}";
        mvc.perform(own(put(path + "/" + existing.id())).content(body)).andExpect(status().isOk())
            .andExpect(jsonPath("$.data.segments[0].title").value("Revised"))
            .andExpect(jsonPath("$.data.segments[0].progressPercent").value(70))
            .andExpect(jsonPath("$.data.segments[0].subtasks[0].completed").value(true));
    }
    @Test void authenticatedOwnerRejectsForeignIdsEvenWhenBodyOrHeaderTriesToSelectAnotherUser() throws Exception {
        long other = owner();
        var foreign = plans.saveAnnualSegment(other, null, request(UUID.randomUUID().toString())).segments().getFirst();
        mvc.perform(own(put(path + "/" + foreign.id())).header("X-User-Id", other).content(minimal))
            .andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value(4004));
        assertEquals("Existing", plans.getAnnualPlanOverview(other, 2026).segments().getFirst().title());
    }
    @Test void authenticationAndMissingFieldsNeverWrite() throws Exception {
        mvc.perform(post(path).contentType("application/json").content(minimal)).andExpect(status().isUnauthorized());
        mvc.perform(own(post(path)).content("{}")).andExpect(status().isBadRequest());
        assertEquals(0, db.queryForObject("SELECT COUNT(*) FROM annual_plan_segment WHERE user_id=?", Integer.class, owner));
    }
    @Test void clientEntityIsAnOwnerScopedIdempotencyKeyAndNeedsNoPreRegisteredForeignRow() {
        String id = UUID.randomUUID().toString();
        var first = plans.saveAnnualSegment(owner, null, request(id)).segments().getFirst();
        var retry = plans.saveAnnualSegment(owner, null, request(id)).segments().getFirst();
        assertEquals(first.id(), retry.id());
        assertEquals(1, db.queryForObject("SELECT COUNT(*) FROM annual_plan_segment WHERE user_id=?", Integer.class, owner));
        long other = owner(); plans.saveAnnualSegment(other, null, request(id));
        assertEquals(1, plans.getAnnualPlanOverview(other, 2026).segments().size());
    }
}
