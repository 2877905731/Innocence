package com.innocence.server.modules.stats.mapper;

import com.innocence.server.modules.stats.domain.StatsCheckInDayValue;
import com.innocence.server.modules.stats.domain.StatsDayValue;
import com.innocence.server.modules.stats.domain.StatsFailureDayValue;
import com.innocence.server.modules.stats.domain.StatsPlanDayValue;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface StatsMapper {

    List<StatsDayValue> findDailyStudyDuration(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    List<StatsDayValue> findDailyPomodoroCompleted(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    List<StatsPlanDayValue> findDailyPlanCompletion(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    List<StatsCheckInDayValue> findDailyCheckInStats(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    List<StatsFailureDayValue> findFailureRecords(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
