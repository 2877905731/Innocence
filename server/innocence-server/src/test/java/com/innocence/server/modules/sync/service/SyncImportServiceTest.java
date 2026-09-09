package com.innocence.server.modules.sync.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;
import com.innocence.server.modules.account.service.AccountService;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.focus.service.FocusSessionService;
import com.innocence.server.modules.memo.service.MemoService;
import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.sync.dto.request.SyncImportPreviewRequest;
import com.innocence.server.modules.sync.dto.request.SyncImportOperationRequest;
import com.innocence.server.modules.sync.dto.request.SyncImportRequest;
import com.innocence.server.modules.sync.dto.response.SyncImportPreviewResponse;
import com.innocence.server.modules.sync.mapper.SyncImportMapper;
import com.innocence.server.modules.sync.domain.SyncImportOperationRecord;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import org.mockito.ArgumentCaptor;

class SyncImportServiceTest {

    private AccountService accountService;
    private StudyPlanMapper studyPlanMapper;
    private StudyPlanService studyPlanService;
    private SyncImportMapper syncImportMapper;
    private SyncImportService service;

    @BeforeEach
    void setUp() {
        accountService = mock(AccountService.class);
        studyPlanMapper = mock(StudyPlanMapper.class);
        studyPlanService = mock(StudyPlanService.class);
        syncImportMapper = mock(SyncImportMapper.class);
        PlatformTransactionManager transactionManager = mock(PlatformTransactionManager.class);
        when(transactionManager.getTransaction(any(TransactionDefinition.class)))
                .thenReturn(mock(TransactionStatus.class));
        service = new SyncImportService(
                accountService,
                studyPlanService,
                studyPlanMapper,
                mock(MemoService.class),
                mock(FocusSessionService.class),
                mock(CheckInService.class),
                syncImportMapper,
                new ObjectMapper().findAndRegisterModules(),
                transactionManager
        );
    }

    @Test
    void previewUsesAuthenticatedUserAndOnlyChecksManifestDates() {
        UserProfileResponse profile = profile(7L, "U7", "June");
        LocalDate conflictDate = LocalDate.of(2026, 9, 8);
        when(accountService.getMyProfile(7L)).thenReturn(profile);
        when(studyPlanMapper.findDailyPlanByUserIdAndDate(7L, conflictDate))
                .thenReturn(new DailyPlan());

        SyncImportPreviewResponse response = service.preview(
                7L,
                new SyncImportPreviewRequest(
                        "local-profile",
                        3,
                        List.of(conflictDate, LocalDate.of(2026, 9, 9)),
                        List.of(),
                        1
                )
        );

        assertEquals("U7", response.targetUserNo());
        assertEquals(1, response.conflictCount());
        assertEquals(List.of("2026-09-08"), response.dailyPlanConflictDates());
        verify(studyPlanMapper).findDailyPlanByUserIdAndDate(7L, conflictDate);
    }

    @Test
    void importRejectsMismatchedConfirmedAccountBeforeAnyWrite() {
        when(accountService.getMyProfile(7L)).thenReturn(profile(7L, "U7", "June"));

        assertThrows(
                BusinessException.class,
                () -> service.importData(
                        7L,
                        new SyncImportRequest("local-profile", "U8", "keep_server", List.of())
                )
        );

        verify(studyPlanService, never()).saveTodayPlan(
                org.mockito.ArgumentMatchers.anyLong(),
                org.mockito.ArgumentMatchers.any()
        );
    }

    @Test
    void dailyPlanImportWritesAcceptedIdempotencyRecord() {
        when(accountService.getMyProfile(7L)).thenReturn(profile(7L, "U7", "June"));
        SyncImportOperationRequest operation = dailyPlanOperation();

        var response = service.importData(
                7L,
                new SyncImportRequest(
                        "local-profile",
                        "U7",
                        "overwrite",
                        List.of(operation)
                )
        );

        assertEquals(1, response.acceptedCount());
        assertEquals("2026-09-09", response.items().get(0).serverAggregateId());
        verify(studyPlanService).saveTodayPlan(eq(7L), any());
        ArgumentCaptor<SyncImportOperationRecord> captor =
                ArgumentCaptor.forClass(SyncImportOperationRecord.class);
        verify(syncImportMapper).upsertOperation(captor.capture());
        assertEquals("accepted", captor.getValue().getStatus());
    }

    @Test
    void acceptedOperationReplayDoesNotWriteBusinessDataAgain() {
        when(accountService.getMyProfile(7L)).thenReturn(profile(7L, "U7", "June"));
        SyncImportOperationRequest operation = dailyPlanOperation();
        SyncImportOperationRecord accepted = new SyncImportOperationRecord();
        accepted.setOperationId(operation.operationId());
        accepted.setAggregateType(operation.aggregateType());
        accepted.setAggregateId(operation.aggregateId());
        accepted.setOperationType(operation.operationType());
        accepted.setStatus("accepted");
        accepted.setMessage("Imported.");
        accepted.setServerAggregateId("2026-09-09");
        when(syncImportMapper.findByUserIdAndOperationId(7L, operation.operationId()))
                .thenReturn(accepted);

        var response = service.importData(
                7L,
                new SyncImportRequest(
                        "local-profile",
                        "U7",
                        "overwrite",
                        List.of(operation)
                )
        );

        assertEquals(1, response.acceptedCount());
        verify(studyPlanService, never()).saveTodayPlan(anyLong(), any());
        verify(syncImportMapper, never()).upsertOperation(any());
    }

    private SyncImportOperationRequest dailyPlanOperation() {
        String operationId = "6f96bf5e-a2bc-46d6-9df1-20f143506a00";
        return new SyncImportOperationRequest(
                operationId,
                "daily_plan",
                "2026-09-09",
                "upsert",
                Map.of(
                        "planDate", "2026-09-09",
                        "planName", "Offline day",
                        "items", List.of(Map.of(
                                "title", "Read",
                                "completed", true,
                                "plannedMinutes", 20,
                                "actualMinutes", 20
                        ))
                ),
                1,
                operationId,
                "2026-09-09T00:00:00Z"
        );
    }

    private UserProfileResponse profile(Long userId, String userNo, String nickname) {
        UserProfileResponse profile = new UserProfileResponse();
        profile.setUserId(userId);
        profile.setUserNo(userNo);
        profile.setNickname(nickname);
        return profile;
    }
}
