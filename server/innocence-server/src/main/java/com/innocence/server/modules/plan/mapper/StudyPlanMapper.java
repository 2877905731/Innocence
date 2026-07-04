package com.innocence.server.modules.plan.mapper;

import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.DailyPlanItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface StudyPlanMapper {

    DailyPlan findDailyPlanByUserIdAndDate(@Param("userId") Long userId, @Param("planDate") LocalDate planDate);

    List<DailyPlanItem> findDailyPlanItemsByPlanId(@Param("planId") Long planId);

    void insertDailyPlan(DailyPlan dailyPlan);

    void updateDailyPlan(DailyPlan dailyPlan);

    void deleteDailyPlanById(@Param("planId") Long planId);

    void deleteDailyPlanItemsByPlanId(@Param("planId") Long planId);

    void insertDailyPlanItem(DailyPlanItem item);
}
