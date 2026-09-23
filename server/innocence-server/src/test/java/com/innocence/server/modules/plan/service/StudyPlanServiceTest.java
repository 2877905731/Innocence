package com.innocence.server.modules.plan.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.plan.domain.AnnualPlanSegment;
import com.innocence.server.modules.plan.domain.AnnualPlanSubtask;
import com.innocence.server.modules.plan.dto.request.ApplyDayTemplateBatchRequest;
import com.innocence.server.modules.plan.dto.request.AnnualPlanSubtaskRequest;
import com.innocence.server.modules.plan.dto.request.SaveAnnualPlanSegmentRequest;
import com.innocence.server.modules.plan.dto.response.AnnualPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.MonthPlanOverviewResponse;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class StudyPlanServiceTest {

    private StudyPlanMapper mapper;
    private StudyPlanService service;

    @BeforeEach
    void setUp() {
        mapper = mock(StudyPlanMapper.class);
        service = new StudyPlanService(mapper, mock(NotificationService.class));
    }

    @Test
    void leapMonthReturnsEveryCalendarDayForCurrentUser() {
        when(mapper.findDailyPlansByUserIdAndDateRange(
                7L,
                LocalDate.of(2028, 2, 1),
                LocalDate.of(2028, 2, 29)
        )).thenReturn(List.of());

        MonthPlanOverviewResponse response = service.getMonthPlanOverview(
                7L,
                YearMonth.of(2028, 2)
        );

        assertEquals("2028-02", response.month());
        assertEquals(29, response.days().size());
        assertEquals("2028-02-01", response.days().get(0).planDate());
        assertEquals("2028-02-29", response.days().get(28).planDate());
        verify(mapper).findDailyPlansByUserIdAndDateRange(
                7L,
                LocalDate.of(2028, 2, 1),
                LocalDate.of(2028, 2, 29)
        );
    }

    @Test
    void annualOverviewAlwaysReturnsTwelveMonths() {
        when(mapper.findDailyPlansByUserIdAndDateRange(
                7L,
                LocalDate.of(2028, 1, 1),
                LocalDate.of(2028, 12, 31)
        )).thenReturn(List.of());
        when(mapper.findAnnualSegmentsByUserIdAndYear(7L, 2028)).thenReturn(List.of());

        AnnualPlanOverviewResponse response = service.getAnnualPlanOverview(7L, 2028);

        assertEquals(12, response.months().size());
        assertEquals(1, response.months().get(0).month());
        assertEquals(12, response.months().get(11).month());
    }

    @Test
    void dayTemplateFromAnotherTenantIsRejectedBeforePlanWrite() {
        ApplyDayTemplateBatchRequest request = new ApplyDayTemplateBatchRequest();
        request.setPlanDates(List.of(LocalDate.of(2028, 2, 1)));
        request.setStrategy("overwrite");
        when(mapper.findWeeklyTemplateByIdAndUserId(99L, 7L)).thenReturn(null);

        assertThrows(
                BusinessException.class,
                () -> service.applyDayTemplateBatch(7L, 99L, request)
        );

        verify(mapper, never()).insertDailyPlan(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void staleAnnualRevisionIsRejectedWithoutUpdate() {
        AnnualPlanSegment existing = new AnnualPlanSegment();
        existing.setId(3L);
        existing.setUserId(7L);
        existing.setRevision(4);
        when(mapper.findAnnualSegmentByIdAndUserId(3L, 7L)).thenReturn(existing);
        SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
        request.setYear(2028);
        request.setTitle("Foundation");
        request.setStartMonth(2);
        request.setEndMonth(5);
        request.setRevision(3);

        assertThrows(
                BusinessException.class,
                () -> service.saveAnnualSegment(7L, 3L, request)
        );

        verify(mapper, never()).updateAnnualPlanSegment(existing);
    }

    @Test
    void annualSubtasksAreWrittenForTheCurrentUserAndReturnedInOverview() {
        AnnualPlanSegment existing = new AnnualPlanSegment();
        existing.setId(3L);
        existing.setUserId(7L);
        existing.setPlanYear(2028);
        existing.setClientEntityId("annual-3");
        existing.setRevision(1);
        existing.setProgressPercent(15);
        when(mapper.findAnnualSegmentByIdAndUserId(3L, 7L)).thenReturn(existing);
        when(mapper.findAnnualSegmentsByUserIdAndYear(7L, 2028)).thenReturn(List.of(existing));

        AnnualPlanSubtaskRequest subtaskRequest = new AnnualPlanSubtaskRequest();
        subtaskRequest.setTitle("Confirm milestone");
        subtaskRequest.setDetail("Check the completed work");
        subtaskRequest.setCompleted(true);
        SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
        request.setYear(2028);
        request.setTitle("Foundation");
        request.setStartMonth(2);
        request.setEndMonth(5);
        request.setProgressPercent(65);
        request.setSubtasks(List.of(subtaskRequest));

        AnnualPlanSubtask storedSubtask = new AnnualPlanSubtask();
        storedSubtask.setId(8L);
        storedSubtask.setSegmentId(3L);
        storedSubtask.setUserId(7L);
        storedSubtask.setTitle("Confirm milestone");
        storedSubtask.setDetail("Check the completed work");
        storedSubtask.setStatus(1);
        storedSubtask.setSortOrder(0);
        when(mapper.findAnnualPlanSubtasksBySegmentId(3L, 7L))
                .thenReturn(List.of(storedSubtask));

        AnnualPlanOverviewResponse response = service.saveAnnualSegment(7L, 3L, request);

        ArgumentCaptor<AnnualPlanSubtask> captor = ArgumentCaptor.forClass(AnnualPlanSubtask.class);
        verify(mapper).deleteAnnualPlanSubtasksBySegmentIdAndUserId(3L, 7L);
        verify(mapper).insertAnnualPlanSubtask(captor.capture());
        assertEquals(7L, captor.getValue().getUserId());
        assertEquals(3L, captor.getValue().getSegmentId());
        assertEquals(1, captor.getValue().getStatus());
        assertEquals(65, existing.getProgressPercent());
        assertEquals(65, response.segments().get(0).progressPercent());
        assertEquals("Confirm milestone", response.segments().get(0).subtasks().get(0).title());
        assertTrue(response.segments().get(0).subtasks().get(0).completed());
    }

    @Test
    void annualSubtaskWithoutTitleIsRejectedBeforeWrite() {
        AnnualPlanSubtaskRequest subtask = new AnnualPlanSubtaskRequest();
        subtask.setTitle(" ");
        SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
        request.setYear(2028);
        request.setTitle("Foundation");
        request.setStartMonth(2);
        request.setEndMonth(5);
        request.setSubtasks(List.of(subtask));

        assertThrows(BusinessException.class, () -> service.saveAnnualSegment(7L, null, request));

        verify(mapper, never()).insertAnnualPlanSegment(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void annualProgressOutsideRangeIsRejectedBeforeWrite() {
        SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
        request.setYear(2028);
        request.setTitle("Foundation");
        request.setStartMonth(2);
        request.setEndMonth(5);
        request.setProgressPercent(101);

        assertThrows(BusinessException.class, () -> service.saveAnnualSegment(7L, null, request));
        verify(mapper, never()).insertAnnualPlanSegment(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void omittedAnnualProgressPreservesExistingValue() {
        AnnualPlanSegment existing = new AnnualPlanSegment();
        existing.setId(9L);
        existing.setUserId(7L);
        existing.setPlanYear(2028);
        existing.setClientEntityId("annual-9");
        existing.setRevision(2);
        existing.setProgressPercent(45);
        when(mapper.findAnnualSegmentByIdAndUserId(9L, 7L)).thenReturn(existing);
        when(mapper.findAnnualSegmentsByUserIdAndYear(7L, 2028)).thenReturn(List.of(existing));

        SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
        request.setYear(2028);
        request.setTitle("Foundation");
        request.setStartMonth(2);
        request.setEndMonth(5);

        AnnualPlanOverviewResponse response = service.saveAnnualSegment(7L, 9L, request);

        assertEquals(45, existing.getProgressPercent());
        assertEquals(45, response.segments().get(0).progressPercent());
        verify(mapper).updateAnnualPlanSegment(existing);
    }

    @Test
    void vividAnnualColorsAreAcceptedButUnknownColorIsRejected() {
        when(mapper.findDailyPlansByUserIdAndDateRange(
                7L, LocalDate.of(2028, 1, 1), LocalDate.of(2028, 12, 31)
        )).thenReturn(List.of());
        when(mapper.findAnnualSegmentsByUserIdAndYear(7L, 2028)).thenReturn(List.of());

        for (String colorKey : List.of("coral", "gold", "cyan")) {
            SaveAnnualPlanSegmentRequest request = new SaveAnnualPlanSegmentRequest();
            request.setYear(2028);
            request.setTitle("Foundation");
            request.setStartMonth(4);
            request.setEndMonth(11);
            request.setColorKey(colorKey);
            service.saveAnnualSegment(7L, null, request);
        }

        ArgumentCaptor<AnnualPlanSegment> captor = ArgumentCaptor.forClass(AnnualPlanSegment.class);
        verify(mapper, times(3)).insertAnnualPlanSegment(captor.capture());
        assertEquals(List.of("coral", "gold", "cyan"),
                captor.getAllValues().stream().map(AnnualPlanSegment::getColorKey).toList());

        SaveAnnualPlanSegmentRequest invalid = new SaveAnnualPlanSegmentRequest();
        invalid.setYear(2028);
        invalid.setTitle("Foundation");
        invalid.setStartMonth(4);
        invalid.setEndMonth(11);
        invalid.setColorKey("unknown");
        assertThrows(BusinessException.class, () -> service.saveAnnualSegment(7L, null, invalid));
        verify(mapper, times(3)).insertAnnualPlanSegment(org.mockito.ArgumentMatchers.any());
    }
}
