package com.innocence.server.modules.stats.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.stats.domain.StatsCheckInDayValue;
import com.innocence.server.modules.stats.domain.StatsDayValue;
import com.innocence.server.modules.stats.domain.StatsFailureDayValue;
import com.innocence.server.modules.stats.domain.StatsPlanDayValue;
import com.innocence.server.modules.stats.dto.response.StatsFailureRecordResponse;
import com.innocence.server.modules.stats.dto.response.StatsOverviewResponse;
import com.innocence.server.modules.stats.dto.response.StatsTrendPointResponse;
import com.innocence.server.modules.stats.mapper.StatsMapper;
import com.innocence.server.modules.team.dto.response.TeammateStatsResponse;
import com.innocence.server.modules.team.service.TeamService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StatsService {

    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final StatsMapper statsMapper;
    private final TeamService teamService;

    public StatsService(StatsMapper statsMapper, TeamService teamService) {
        this.statsMapper = statsMapper;
        this.teamService = teamService;
    }

    @Transactional(readOnly = true)
    public StatsOverviewResponse getOverview(Long userId, Integer rangeDays) {
        int normalizedRangeDays = normalizeRangeDays(rangeDays);
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(normalizedRangeDays - 1L);

        Map<LocalDate, Integer> studyDurationByDate = toDayValueMap(
                statsMapper.findDailyStudyDuration(userId, startDate, endDate)
        );
        Map<LocalDate, Integer> pomodoroCompletedByDate = toDayValueMap(
                statsMapper.findDailyPomodoroCompleted(userId, startDate, endDate)
        );
        Map<LocalDate, StatsPlanDayValue> planCompletionByDate = toPlanDayMap(
                statsMapper.findDailyPlanCompletion(userId, startDate, endDate)
        );
        Map<LocalDate, StatsCheckInDayValue> checkInStatsByDate = toCheckInDayMap(
                statsMapper.findDailyCheckInStats(userId, startDate, endDate)
        );
        List<StatsFailureRecordResponse> failureRecords = toFailureRecords(
                statsMapper.findFailureRecords(userId, startDate, endDate)
        );
        List<TeammateStatsResponse> teammates = teamService.getTeammateStats(userId);

        List<StatsTrendPointResponse> trend = new ArrayList<>();
        int totalStudyDurationMinutes = 0;
        int totalPomodoroCompleted = 0;
        int totalCheckInDays = 0;
        int totalFailedCheckInAttempts = 0;
        int totalPlanCompletedCount = 0;
        int totalPlanTotalCount = 0;
        int activePlanDays = 0;

        for (int offset = 0; offset < normalizedRangeDays; offset++) {
            LocalDate currentDate = startDate.plusDays(offset);
            int studyDurationMinutes = defaultNumber(studyDurationByDate.get(currentDate));
            int pomodoroCompletedCount = defaultNumber(pomodoroCompletedByDate.get(currentDate));

            StatsPlanDayValue planDayValue = planCompletionByDate.get(currentDate);
            int planCompletedCount = planDayValue == null ? 0 : defaultNumber(planDayValue.getCompletedCount());
            int planTotalCount = planDayValue == null ? 0 : defaultNumber(planDayValue.getTotalCount());
            boolean hasPlan = planTotalCount > 0;
            int planCompletionRate = hasPlan ? percentage(planCompletedCount, planTotalCount) : 0;

            StatsCheckInDayValue checkInDayValue = checkInStatsByDate.get(currentDate);
            int checkInSuccessCount = checkInDayValue == null ? 0 : defaultNumber(checkInDayValue.getSuccessCount());
            int failedCheckInAttempts = checkInDayValue == null ? 0 : defaultNumber(checkInDayValue.getFailedAttempts());
            int checkInSuccessRate = hasPlan ? (checkInSuccessCount > 0 ? 100 : 0) : 0;

            StatsTrendPointResponse point = new StatsTrendPointResponse();
            point.setDate(currentDate.toString());
            point.setLabel(currentDate.getMonthValue() + "/" + currentDate.getDayOfMonth());
            point.setHasPlan(hasPlan);
            point.setStudyDurationMinutes(studyDurationMinutes);
            point.setPomodoroCompletedCount(pomodoroCompletedCount);
            point.setCheckInSuccessCount(checkInSuccessCount);
            point.setFailedCheckInAttempts(failedCheckInAttempts);
            point.setPlanCompletedCount(planCompletedCount);
            point.setPlanTotalCount(planTotalCount);
            point.setPlanCompletionRate(planCompletionRate);
            point.setCheckInSuccessRate(checkInSuccessRate);
            trend.add(point);

            totalStudyDurationMinutes += studyDurationMinutes;
            totalPomodoroCompleted += pomodoroCompletedCount;
            totalCheckInDays += checkInSuccessCount > 0 ? 1 : 0;
            totalFailedCheckInAttempts += failedCheckInAttempts;
            totalPlanCompletedCount += planCompletedCount;
            totalPlanTotalCount += planTotalCount;
            if (hasPlan) {
                activePlanDays++;
            }
        }

        StatsOverviewResponse response = new StatsOverviewResponse();
        response.setRangeDays(normalizedRangeDays);
        response.setActivePlanDays(activePlanDays);
        response.setTotalStudyDurationMinutes(totalStudyDurationMinutes);
        response.setTotalPomodoroCompleted(totalPomodoroCompleted);
        response.setTotalCheckInDays(totalCheckInDays);
        response.setTotalFailedCheckInAttempts(totalFailedCheckInAttempts);
        response.setPlanCompletionRate(percentage(totalPlanCompletedCount, totalPlanTotalCount));
        response.setCheckInSuccessRate(
                percentage(totalCheckInDays, Math.max(activePlanDays, totalCheckInDays))
        );
        response.setTrend(trend);
        response.setFailures(failureRecords);
        response.setTeammates(teammates);
        return response;
    }

    private int normalizeRangeDays(Integer rangeDays) {
        if (rangeDays == null) {
            return 7;
        }
        if (rangeDays == 7 || rangeDays == 30) {
            return rangeDays;
        }
        throw new BusinessException(ErrorCode.BAD_REQUEST, "Stats range supports only 7 or 30 days.");
    }

    private Map<LocalDate, Integer> toDayValueMap(List<StatsDayValue> rows) {
        Map<LocalDate, Integer> result = new HashMap<>();
        for (StatsDayValue row : rows) {
            if (row.getStatsDate() == null) {
                continue;
            }
            result.put(row.getStatsDate(), defaultNumber(row.getValue()));
        }
        return result;
    }

    private Map<LocalDate, StatsPlanDayValue> toPlanDayMap(List<StatsPlanDayValue> rows) {
        Map<LocalDate, StatsPlanDayValue> result = new HashMap<>();
        for (StatsPlanDayValue row : rows) {
            if (row.getStatsDate() == null) {
                continue;
            }
            result.put(row.getStatsDate(), row);
        }
        return result;
    }

    private Map<LocalDate, StatsCheckInDayValue> toCheckInDayMap(List<StatsCheckInDayValue> rows) {
        Map<LocalDate, StatsCheckInDayValue> result = new HashMap<>();
        for (StatsCheckInDayValue row : rows) {
            if (row.getStatsDate() == null) {
                continue;
            }
            result.put(row.getStatsDate(), row);
        }
        return result;
    }

    private List<StatsFailureRecordResponse> toFailureRecords(List<StatsFailureDayValue> rows) {
        List<StatsFailureRecordResponse> result = new ArrayList<>();
        for (StatsFailureDayValue row : rows) {
            if (row.getStatsDate() == null) {
                continue;
            }
            StatsFailureRecordResponse response = new StatsFailureRecordResponse();
            response.setDate(row.getStatsDate().toString());
            response.setLabel(row.getStatsDate().getMonthValue() + "/" + row.getStatsDate().getDayOfMonth());
            response.setAttemptCount(defaultNumber(row.getAttemptCount()));
            response.setLatestReason(defaultText(row.getLatestReason()));
            response.setPlanCompletedCount(defaultNumber(row.getPlanCompletedCount()));
            response.setPlanTotalCount(defaultNumber(row.getPlanTotalCount()));
            response.setStudyDurationMinutes(defaultNumber(row.getStudyDurationMinutes()));
            response.setLastAttemptTime(formatDateTime(row.getLastAttemptTime()));
            result.add(response);
        }
        return result;
    }

    private int percentage(int numerator, int denominator) {
        if (denominator <= 0) {
            return 0;
        }
        return (int) Math.round((numerator * 100.0) / denominator);
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String defaultText(String value) {
        return value == null ? "" : value.trim();
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(DATE_TIME_FORMATTER);
    }
}
