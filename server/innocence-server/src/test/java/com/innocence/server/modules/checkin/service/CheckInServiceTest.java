package com.innocence.server.modules.checkin.service;

import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.checkin.domain.CheckInFailRecord;
import com.innocence.server.modules.checkin.domain.CheckInSummary;
import com.innocence.server.modules.checkin.dto.response.CheckInFailureRecordResponse;
import com.innocence.server.modules.checkin.dto.response.CheckInSummaryResponse;
import com.innocence.server.modules.checkin.mapper.CheckInMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.any;

class CheckInServiceTest {

    private CheckInMapper checkInMapper;
    private UserMapper userMapper;
    private StudyPlanService studyPlanService;
    private CheckInService checkInService;

    @BeforeEach
    void setUp() {
        checkInMapper = mock(CheckInMapper.class);
        userMapper = mock(UserMapper.class);
        studyPlanService = mock(StudyPlanService.class);
        checkInService = new CheckInService(
                checkInMapper,
                studyPlanService,
                userMapper,
                mock(NotificationService.class)
        );
    }

    @Test
    void summaryUsesCurrentUserSummaryAndStudyDuration() {
        CheckInSummary summary = new CheckInSummary();
        summary.setConsecutiveDays(4);
        summary.setTotalDays(12);
        summary.setLastSuccessDate(LocalDate.now());
        when(checkInMapper.findCheckInSummaryByUserId(7L)).thenReturn(summary);
        when(userMapper.findTotalStudySecondsByUserId(7L)).thenReturn(3660);

        CheckInSummaryResponse response = checkInService.getSummary(7L);

        assertEquals(4, response.getConsecutiveDays());
        assertEquals(12, response.getTotalDays());
        assertEquals(61, response.getTotalStudyDurationMinutes());
        verify(checkInMapper).findCheckInSummaryByUserId(7L);
        verify(userMapper).findTotalStudySecondsByUserId(7L);
    }

    @Test
    void failureRecordsArePaginatedAndMappedWithoutCrossUserLookup() {
        CheckInFailRecord record = new CheckInFailRecord();
        record.setCheckInDate(LocalDate.of(2026, 8, 18));
        record.setAttemptCount(2);
        record.setLatestReason("Finish today's plan first.");
        record.setPlanCompletedCount(1);
        record.setPlanTotalCount(3);
        record.setStudyDurationMinutes(25);
        record.setLastAttemptTime(LocalDateTime.of(2026, 8, 18, 20, 30));
        when(checkInMapper.findCheckInFailRecordsByUserId(7L, 20, 10)).thenReturn(List.of(record));

        List<CheckInFailureRecordResponse> response = checkInService.listFailureRecords(7L, 3, 10);

        assertEquals(1, response.size());
        assertEquals("2026-08-18", response.get(0).getDate());
        assertEquals("8/18", response.get(0).getLabel());
        assertEquals(2, response.get(0).getAttemptCount());
        assertEquals("2026-08-18T20:30", response.get(0).getLastAttemptTime());
        verify(checkInMapper).findCheckInFailRecordsByUserId(eq(7L), eq(20), eq(10));
    }

    @Test
    void historicalOfflineCheckInRevalidatesPlanAndRebuildsSummary() {
        LocalDate importedDate = LocalDate.of(2026, 9, 8);
        TodayPlanResponse plan = new TodayPlanResponse();
        plan.setTotalCount(2);
        plan.setCompletedCount(2);
        when(studyPlanService.getTodayPlan(7L, importedDate)).thenReturn(plan);
        when(checkInMapper.findCheckInDatesByUserId(7L)).thenReturn(List.of(
                LocalDate.of(2026, 9, 9),
                importedDate
        ));

        checkInService.importCheckInIntent(7L, importedDate);

        verify(checkInMapper).insertCheckInRecord(any());
        verify(checkInMapper).insertCheckInSummary(any());
    }
}
