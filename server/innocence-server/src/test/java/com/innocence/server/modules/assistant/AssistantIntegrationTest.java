package com.innocence.server.modules.assistant;

import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.assistant.service.*;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.plan.dto.request.*;
import com.innocence.server.modules.focus.service.FocusSessionService;
import com.innocence.server.modules.focus.dto.request.*;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/** Real MySQL mapper/transaction checks. Each fixture and business write rolls back. */
@SpringBootTest(properties={"logging.level.com.innocence.server=INFO"})
@Transactional
class AssistantIntegrationTest {
    @Autowired AssistantService assistant;
    @Autowired StudyPlanService plans;
    @Autowired FocusSessionService focus;
    @Autowired JdbcTemplate db;
    @MockBean ModelProviderAdapter provider;
    long owner;
    String date;
    @BeforeEach void setup() {
        String marker="assistant-fixture-"+UUID.randomUUID();
        db.update("INSERT INTO app_user(user_no,nickname,status) VALUES(?,?,1)",UUID.randomUUID().toString().substring(0,32),marker);
        owner=db.queryForObject("SELECT id FROM app_user WHERE nickname=?",Long.class,marker);
        date=LocalDate.now(ZoneId.of("Asia/Shanghai")).toString();
        when(provider.generate(any(),any())).thenReturn(output("练习",22,24));
    }
    ProviderPlan output(String title,int from,int until) {
        return new ProviderPlan("ready",List.of(),List.of("仅新增"),List.of("conservative","balanced","compact").stream()
                .map(mode->new ProviderCandidate(mode,List.of(new ProviderTask(title,from,until)),"保留原任务")).toList());
    }
    GenerateRequest request(String instruction,String mode) { return new GenerateRequest(UUID.randomUUID().toString(),instruction,date,"Asia/Shanghai","model",mode); }
    Proposal generate() {return assistant.generate(owner,request("安排练习","suggest")).proposal();}
    ExecuteRequest executable(Proposal p,String auth) {
        var c=p.candidates().getFirst(); var v=assistant.validate(owner,p.proposalId(),new ValidateRequest(p.proposalRevision(),c.candidateId(),null));
        return new ExecuteRequest(UUID.randomUUID().toString(),v.proposalRevision(),c.candidateId(),v.validationId(),auth);
    }
    @Test void addPreservesExistingIdsStateAndMinutesAndUndoIsIdempotent() {
        var item=new TodayPlanItemRequest();item.setTitle("原任务");item.setStartSlot(18);item.setEndSlot(20);item.setCompleted(true);item.setActualMinutes(55);
        var save=new SaveTodayPlanRequest();save.setPlanDate(LocalDate.parse(date));save.setPlanName("我的计划");save.setItems(List.of(item));
        var original=plans.saveTodayPlan(owner,save).getItems().getFirst();
        var p=generate();var input=executable(p,"preview_apply");var e=assistant.execute(owner,p.proposalId(),input);
        assertEquals("committed",e.status());assertEquals(2,e.afterRevision());
        var saved=plans.getTodayPlan(owner,LocalDate.parse(date));
        assertEquals(2,saved.getItems().size());assertEquals(original.getId(),saved.getItems().getFirst().getId());
        assertEquals(1,saved.getItems().getFirst().getCompleted());assertEquals(55,saved.getItems().getFirst().getActualMinutes());
        assertEquals(e,assistant.execute(owner,p.proposalId(),input));assertEquals(2,plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().size());
        var undo=new UndoRequest(UUID.randomUUID().toString(),e.afterRevision());
        var undone=assistant.undo(owner,e.executionId(),undo);assertEquals(3,undone.afterRevision());
        assertEquals(undone,assistant.undo(owner,e.executionId(),undo));
        assertEquals(original.getId(),plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().getFirst().getId());
        var altered=new ExecuteRequest(input.operationId(),input.proposalRevision(),input.candidateId(),input.validationId(),"direct_add");
        assertEquals("IDEMPOTENCY_CONFLICT",assertThrows(AssistantException.class,()->assistant.execute(owner,p.proposalId(),altered)).reason());
    }
    @Test void tenantCannotReadOrApplyAnotherOwnersProposal() {
        var p=generate();var execute=executable(p,"preview_apply");
        String marker="assistant-fixture-"+UUID.randomUUID();
        db.update("INSERT INTO app_user(user_no,nickname,status) VALUES(?,?,1)",UUID.randomUUID().toString().substring(0,32),marker);
        long other=db.queryForObject("SELECT id FROM app_user WHERE nickname=?",Long.class,marker);
        assertEquals(404,assertThrows(AssistantException.class,()->assistant.validate(other,p.proposalId(),new ValidateRequest(1,p.candidates().getFirst().candidateId(),null))).status());
        assertEquals(404,assertThrows(AssistantException.class,()->assistant.execute(other,p.proposalId(),execute)).status());
        assertEquals(0,plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().size());
    }
    @Test void staleDayRejectsExecutionAndPersistsRejectedResult() {
        var p=generate();var input=executable(p,"preview_apply");
        var save=new SaveTodayPlanRequest();save.setPlanDate(LocalDate.parse(date));save.setPlanName("用户手动安排");plans.saveTodayPlan(owner,save);
        assertEquals("STALE_DAY",assertThrows(AssistantException.class,()->assistant.execute(owner,p.proposalId(),input)).reason());
        assertEquals("rejected",assistant.execution(owner,input.operationId()).status());
        assertEquals(0,plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().size());
    }
    @Test void directAuthorizationIsDeterministicAndRejectsDifferentTask() {
        var p=assistant.generate(owner,request("直接新增 "+date+" 11:00-12:00 练习，保留已有任务","direct_add")).proposal();
        assertEquals("committed",assistant.execute(owner,p.proposalId(),executable(p,"direct_add")).status());
        when(provider.generate(any(),any())).thenReturn(output("练习",26,28));
        var p2=assistant.generate(owner,request("直接新增 "+date+" 13:00-14:00 数学，保留已有任务","direct_add")).proposal();
        // Provider fails to respect the second command; it cannot expand authorization.
        assertEquals(403,assertThrows(AssistantException.class,()->assistant.execute(owner,p2.proposalId(),executable(p2,"direct_add"))).status());
    }
    @Test void generationFailureIsQueryableAndNeverWritesPlan() {
        when(provider.generate(any(),any())).thenReturn(new ProviderPlan("ready",List.of(),List.of(),List.of()));
        var r=request("安排任务","suggest");
        assertEquals("INVALID_MODEL_OUTPUT",assertThrows(AssistantException.class,()->assistant.generate(owner,r)).reason());
        assertEquals("failed",assistant.request(owner,r.clientRequestId()).requestStatus());
        assertEquals(0,plans.getTodayPlan(owner,LocalDate.parse(date)).getDayRevision());
    }
    @Test void startingThenFinishingFocusStillPreventsUndo() {
        var p=generate();var e=assistant.execute(owner,p.proposalId(),executable(p,"preview_apply"));
        var start=new StartFocusSessionRequest();start.setEndTime(LocalDateTime.now().plusMinutes(10));start.setTaskName("练习");
        var active=focus.startSession(owner,start);var finish=new FinishFocusSessionRequest();finish.setSessionId(active.getSessionId());focus.finishSession(owner,finish);
        assertEquals("UNDO_CONFLICT",assertThrows(AssistantException.class,()->assistant.undo(owner,e.executionId(),new UndoRequest(UUID.randomUUID().toString(),e.afterRevision()))).reason());
        assertEquals(1,plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().size());
    }
    @Test void emptyAdditionDoesNotCreatePlanOrAdvanceRevision() {
        when(provider.generate(any(),any())).thenReturn(new ProviderPlan("ready",List.of(),List.of(),List.of("conservative","balanced","compact").stream()
            .map(mode->new ProviderCandidate(mode,List.of(),"无新增")).toList()));
        var p=generate();var e=assistant.execute(owner,p.proposalId(),executable(p,"preview_apply"));
        assertTrue(e.actualChanges().isEmpty());assertEquals(0,e.afterRevision());
        assertEquals(0,db.queryForObject("SELECT COUNT(*) FROM daily_plan WHERE user_id=?",Integer.class,owner));
    }
    @Test void permissionDeniedBeforeCallingProvider() {
        db.update("UPDATE app_user SET status=4 WHERE id=?",owner);
        assertEquals(403,assertThrows(AssistantException.class,()->generate()).status());verifyNoInteractions(provider);
    }
    @Test void explicit45MinutesIsClarifiedBeforeCallingTheModel() {
        var result=assistant.generate(owner,request("英语45分钟","suggest"));
        assertEquals("needs_input",result.proposal().status());assertTrue(result.proposal().candidates().isEmpty());
        verifyNoInteractions(provider);assertEquals(0,plans.getTodayPlan(owner,LocalDate.parse(date)).getDayRevision());
    }
    @Test void clearingAnEmptyDayInvalidatesTheOldPreview() {
        var p=generate();var input=executable(p,"preview_apply");
        var clear=new SaveTodayPlanRequest();clear.setPlanDate(LocalDate.parse(date));plans.saveTodayPlan(owner,clear);
        assertEquals(1,plans.getTodayPlan(owner,LocalDate.parse(date)).getDayRevision());
        assertEquals(0,db.queryForObject("SELECT COUNT(*) FROM daily_plan WHERE user_id=?",Integer.class,owner));
        assertEquals("STALE_DAY",assertThrows(AssistantException.class,()->assistant.execute(owner,p.proposalId(),input)).reason());
    }
    @Test void expiredOperationIdsCannotBeReusedAfterThirtyDays() {
        var p=generate();var input=executable(p,"preview_apply");assistant.execute(owner,p.proposalId(),input);
        db.update("UPDATE assistant_document SET create_time=DATE_SUB(NOW(),INTERVAL 31 DAY) WHERE user_id=? AND kind='execution' AND document_id=?",owner,input.operationId());
        assertEquals(410,assertThrows(AssistantException.class,()->assistant.execution(owner,input.operationId())).status());
        assertEquals(410,assertThrows(AssistantException.class,()->assistant.execute(owner,p.proposalId(),input)).status());
        assertEquals(1,plans.getTodayPlan(owner,LocalDate.parse(date)).getItems().size());
    }
    @Test void generationRequestRetriesDoNotCallProviderTwice() {
        var request=request("安排任务","suggest");var first=assistant.generate(owner,request);
        assertEquals(first,assistant.generate(owner,request));verify(provider,times(1)).generate(any(),any());
        var different=new GenerateRequest(request.clientRequestId(),"另一条指令",date,"Asia/Shanghai","model","suggest");
        assertEquals("IDEMPOTENCY_CONFLICT",assertThrows(AssistantException.class,()->assistant.generate(owner,different)).reason());
    }
    @Test void clientProposalUsesNoServerModelAndPreservesStableDataThroughApplyUndo() {
        var save = new SaveTodayPlanRequest(); save.setPlanDate(LocalDate.parse(date)); save.setPlanName("原安排");
        var item = new TodayPlanItemRequest(); item.setTitle("原任务"); item.setStartSlot(10); item.setEndSlot(12);
        save.setItems(List.of(item)); var original = plans.saveTodayPlan(owner, save);
        long originalId = original.getItems().getFirst().getId();
        var request = new ClientProposalRequest(UUID.randomUUID().toString(), date, "Asia/Shanghai", original.getDayRevision(),
                List.of(new Task(UUID.randomUUID().toString(), "聊天新增", 20, 22)));
        var result = assistant.clientProposal(owner, request); assertEquals(result, assistant.clientProposal(owner, request));
        verifyNoInteractions(provider); assertEquals(1, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().size());
        var execution = assistant.execute(owner, result.proposal().proposalId(), executable(result.proposal(), "preview_apply"));
        assertEquals("committed", execution.status()); assertEquals(originalId, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().getFirst().getId());
        assistant.undo(owner, execution.executionId(), new UndoRequest(UUID.randomUUID().toString(), execution.afterRevision()));
        assertEquals(originalId, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().getFirst().getId());
        assertEquals(1, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().size());
    }
    @Test void clientProposalRejectsStaleMissingConflictAndDifferentPayload() {
        var id = UUID.randomUUID().toString(); var tasks = List.of(new Task(UUID.randomUUID().toString(), "聊天任务", 20, 22));
        var request = new ClientProposalRequest(id, date, "Asia/Shanghai", 0L, tasks);
        assistant.clientProposal(owner, request);
        assertEquals(409, assertThrows(AssistantException.class, () -> assistant.clientProposal(owner,
                new ClientProposalRequest(id, date, "Asia/Shanghai", 0L, List.of()))).status());
        assertThrows(AssistantException.class, () -> assistant.clientProposal(owner,
                new ClientProposalRequest(UUID.randomUUID().toString(), date, "Asia/Shanghai", null, tasks)));
        var clear = new SaveTodayPlanRequest(); clear.setPlanDate(LocalDate.parse(date)); plans.saveTodayPlan(owner, clear);
        assertEquals("STALE_PROPOSAL", assertThrows(AssistantException.class, () -> assistant.clientProposal(owner,
                new ClientProposalRequest(UUID.randomUUID().toString(), date, "Asia/Shanghai", 0L, tasks))).reason());
        assertEquals(0, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().size());
    }
    @Test void clientProposalCannotAuthorizeDirectWriteOrReadAnotherOwner() {
        var request = new ClientProposalRequest(UUID.randomUUID().toString(), date, "Asia/Shanghai", 0L,
                List.of(new Task(UUID.randomUUID().toString(), "聊天任务", 20, 22)));
        var p = assistant.clientProposal(owner, request).proposal();
        assertEquals(403, assertThrows(AssistantException.class, () -> assistant.execute(owner, p.proposalId(), executable(p, "direct_add"))).status());
        assertEquals(404, assertThrows(AssistantException.class, () -> assistant.request(owner + 9876543, request.clientRequestId())).status());
        assertEquals(0, plans.getTodayPlan(owner, LocalDate.parse(date)).getItems().size());
    }
}
