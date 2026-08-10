package com.innocence.server.modules.stats.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.modules.stats.dto.response.StatsTrendResponse;
import com.innocence.server.modules.stats.mapper.StatsMapper;
import com.innocence.server.modules.team.service.TeamService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class StatsServiceTest {

    private StatsMapper statsMapper;
    private TeamService teamService;
    private StatsService statsService;

    @BeforeEach
    void setUp() {
        statsMapper = mock(StatsMapper.class);
        teamService = mock(TeamService.class);
        when(statsMapper.findDailyStudyDuration(org.mockito.ArgumentMatchers.anyLong(), org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.any()))
                .thenReturn(java.util.List.of());
        when(statsMapper.findDailyPomodoroCompleted(org.mockito.ArgumentMatchers.anyLong(), org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.any()))
                .thenReturn(java.util.List.of());
        when(statsMapper.findDailyPlanCompletion(org.mockito.ArgumentMatchers.anyLong(), org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.any()))
                .thenReturn(java.util.List.of());
        when(statsMapper.findDailyCheckInStats(org.mockito.ArgumentMatchers.anyLong(), org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.any()))
                .thenReturn(java.util.List.of());
        when(statsMapper.findFailureRecords(org.mockito.ArgumentMatchers.anyLong(), org.mockito.ArgumentMatchers.any(), org.mockito.ArgumentMatchers.any()))
                .thenReturn(java.util.List.of());
        when(teamService.getTeammateStats(org.mockito.ArgumentMatchers.anyLong())).thenReturn(java.util.List.of());
        statsService = new StatsService(statsMapper, teamService);
    }

    @Test
    void returnsSevenDayXAxisAndSeriesByDefault() {
        StatsTrendResponse response = statsService.getTrend(7L, null);

        assertEquals(7, response.getXAxis().size());
        assertEquals(4, response.getSeries().size());
        assertEquals(7, response.getSeries().get(0).getData().size());
    }

    @Test
    void acceptsThirtyDayRangeType() {
        StatsTrendResponse response = statsService.getTrend(7L, "30D");

        assertEquals(30, response.getXAxis().size());
    }

    @Test
    void rejectsUnsupportedRangeType() {
        assertThrows(BusinessException.class, () -> statsService.getTrend(7L, "90d"));
    }
}
