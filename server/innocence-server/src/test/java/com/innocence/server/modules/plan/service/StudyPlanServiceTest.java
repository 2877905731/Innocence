package com.innocence.server.modules.plan.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.plan.domain.AnnualPlanSegment;
import com.innocence.server.modules.plan.dto.request.ApplyDayTemplateBatchRequest;
import com.innocence.server.modules.plan.dto.request.SaveAnnualPlanSegmentRequest;
import com.innocence.server.modules.plan.dto.response.AnnualPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.MonthPlanOverviewResponse;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
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
}
