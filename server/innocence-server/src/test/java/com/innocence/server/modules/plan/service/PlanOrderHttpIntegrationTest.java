package com.innocence.server.modules.plan.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.web.*;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.service.SessionAuthService;
import com.innocence.server.modules.plan.controller.PlanOrderController;
import com.innocence.server.modules.plan.dto.request.*;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import java.time.LocalDate;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(properties = "logging.level.com.innocence.server=INFO")
@Transactional
class PlanOrderHttpIntegrationTest {
    @Autowired StudyPlanService plans;
    @Autowired PlanOrderService ordering;
    @Autowired JdbcTemplate db;
    @Autowired ObjectMapper json;
    @MockBean SessionAuthService auth;
    MockMvc mvc;
    long owner;
    final String path = "/api/app/v1/plans/reorder";
    long owner() {
        String name = "order-fixture-" + UUID.randomUUID();
        db.update("INSERT INTO app_user(user_no,nickname,status) VALUES(?,?,1)", UUID.randomUUID().toString().replace("-", ""), name);
        return db.queryForObject("SELECT id FROM app_user WHERE nickname=?", Long.class, name);
    }
    @BeforeEach void setup() {
        owner = owner();
        var session = new UserSession(); session.setUserId(owner);
        when(auth.requireActiveSession("windows", "order-fixture-token")).thenReturn(session);
        mvc = MockMvcBuilders.standaloneSetup(new PlanOrderController(ordering))
            .addInterceptors(new AuthInterceptor(auth)).setControllerAdvice(new GlobalExceptionHandler()).build();
    }
    @AfterEach void clear() { RequestUserContext.clear(); }
    MockHttpServletRequestBuilder own(Object body) throws Exception {
        return put(path).header("Authorization", "Bearer order-fixture-token").header("X-Device-Type", "windows")
            .contentType("application/json").content(json.writeValueAsString(body));
    }
    void annual(long user, String title) throws Exception {
        plans.saveAnnualSegment(user, null, json.readValue("{\"year\":2027,\"title\":\""+title+
            "\",\"startMonth\":2,\"endMonth\":11,\"progressPercent\":37,\"subtasks\":[{\"title\":\"a\",\"completed\":true},{\"title\":\"b\"}]}", SaveAnnualPlanSegmentRequest.class));
    }
    List<Map<String,Object>> items(List<?> ids) { return ids.stream().map(id -> Map.<String,Object>of("id",id)).toList(); }

    @Test void dailyOrderPreservesIdentityTimesCompletionAndAdvancesRevision() throws Exception {
        var date = LocalDate.of(2027,2,3);
        var before = plans.saveTodayPlan(owner, json.readValue("{\"planDate\":\"2027-02-03\",\"items\":[{\"title\":\"early\",\"startSlot\":10,\"endSlot\":12,\"completed\":true,\"actualMinutes\":17},{\"title\":\"flexible\",\"plannedMinutes\":20}]}", SaveTodayPlanRequest.class));
        var first = before.getItems().get(0); var second = before.getItems().get(1);
        var body = Map.of("scope","today","planDate","2027-02-03","baseRevision",before.getDayRevision(),"items",items(List.of(second.getId(), first.getId())));
        mvc.perform(own(body)).andExpect(status().isOk()).andExpect(jsonPath("$.data").value(true));
        var after = plans.getTodayPlan(owner,date);
        assertEquals(List.of(second.getId(),first.getId()), after.getItems().stream().map(i->i.getId()).toList());
        assertEquals(10,after.getItems().get(1).getStartSlot());
        assertEquals(17,after.getItems().get(1).getActualMinutes());
        assertEquals(1, after.getItems().get(1).getCompleted());
        assertEquals(before.getDayRevision()+1,after.getDayRevision());
        mvc.perform(own(body)).andExpect(status().isBadRequest());
        assertEquals(after.getDayRevision(),plans.getTodayPlan(owner,date).getDayRevision());
    }
    @Test void annualAndChildOrderPreserveAllBusinessValuesAndIds() throws Exception {
        annual(owner,"first"); annual(owner,"second");
        var before = plans.getAnnualPlanOverview(owner,2027).segments();
        var a=before.get(0); var b=before.get(1);
        var ordered = List.of(Map.of("id",b.id(),"revision",b.revision()),Map.of("id",a.id(),"revision",a.revision()));
        mvc.perform(own(Map.of("scope","annual","year",2027,"items",ordered))).andExpect(status().isOk());
        var after = plans.getAnnualPlanOverview(owner,2027).segments();
        assertEquals(List.of(b.id(),a.id()),after.stream().map(i->i.id()).toList());
        var parent=after.get(1);
        assertEquals(37,parent.progressPercent()); assertEquals(2,parent.startMonth()); assertEquals(11,parent.endMonth());
        assertEquals(a.subtasks(),parent.subtasks());
        var ids=parent.subtasks().stream().map(i->i.id()).toList();
        mvc.perform(own(Map.of("scope","subtasks","segmentId",parent.id(),"baseRevision",parent.revision(),"items",items(List.of(ids.get(1),ids.get(0)))))).andExpect(status().isOk());
        var result=plans.getAnnualPlanOverview(owner,2027).segments().get(1);
        assertEquals(List.of(ids.get(1),ids.get(0)),result.subtasks().stream().map(i->i.id()).toList());
        assertTrue(result.subtasks().get(1).completed()); assertEquals(37,result.progressPercent());
        assertEquals(parent.revision()+1,result.revision());
    }
    @Test void incompleteDuplicateForeignAndStaleRequestsDoNotPartiallyWrite() throws Exception {
        annual(owner,"first"); annual(owner,"second");
        var before=plans.getAnnualPlanOverview(owner,2027);
        var a=before.segments().get(0);var b=before.segments().get(1);
        for (var entries: List.of(
                List.of(Map.of("id",a.id(),"revision",a.revision())),
                List.of(Map.of("id",a.id(),"revision",a.revision()),Map.of("id",a.id(),"revision",a.revision())),
                List.of(Map.of("id",b.id(),"revision",b.revision()),Map.of("id",a.id(),"revision",a.revision()+9)),
                List.of(Map.of("id",b.id(),"revision",b.revision()),Map.of("id",Long.MAX_VALUE,"revision",1)))) {
            mvc.perform(own(Map.of("scope","annual","year",2027,"items",entries))).andExpect(status().isBadRequest());
            assertEquals(before,plans.getAnnualPlanOverview(owner,2027));
        }
        long other=owner(); annual(other,"foreign");
        var foreign=plans.getAnnualPlanOverview(other,2027).segments().getFirst();
        mvc.perform(own(Map.of("scope","subtasks","segmentId",foreign.id(),"baseRevision",foreign.revision(),"items",items(foreign.subtasks().stream().map(i->i.id()).toList()))).header("X-User-Id",other))
            .andExpect(status().isNotFound());
        assertEquals(foreign,plans.getAnnualPlanOverview(other,2027).segments().getFirst());
    }
    @Test void authenticationPermissionAndMissingFieldsRejectWithoutWriting() throws Exception {
        mvc.perform(put(path).contentType("application/json").content("{}")).andExpect(status().isUnauthorized());
        mvc.perform(own(Map.of())).andExpect(status().isBadRequest());
        mvc.perform(own(Map.of("scope","annual","items",List.of()))).andExpect(status().isBadRequest());
        mvc.perform(own(Map.of("scope","today","items",List.of()))).andExpect(status().isBadRequest());
        mvc.perform(own(Map.of("scope","subtasks","items",List.of()))).andExpect(status().isBadRequest());
        mvc.perform(own(Map.of("scope","annual","year",2027,"items",Arrays.asList((Object)null)))).andExpect(status().isBadRequest());
        when(auth.requireActiveSession("windows", "order-fixture-token"))
            .thenThrow(new com.innocence.server.common.exception.BusinessException(com.innocence.server.common.exception.ErrorCode.FORBIDDEN,"Permission denied."));
        mvc.perform(own(Map.of("scope","annual","year",2027,"items",List.of()))).andExpect(status().isForbidden());
    }
}
