package com.innocence.server.modules.plan.mapper;

import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.DailyPlanItem;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplate;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplateItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface StudyPlanMapper {

    DailyPlan findDailyPlanByUserIdAndDate(@Param("userId") Long userId, @Param("planDate") LocalDate planDate);

    List<DailyPlanItem> findDailyPlanItemsByPlanId(@Param("planId") Long planId);

    List<DailyPlan> findDailyPlansByUserIdAndDateRange(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    List<DailyPlanItem> findDailyPlanItemsByPlanIds(@Param("planIds") List<Long> planIds);

    void insertDailyPlan(DailyPlan dailyPlan);

    void updateDailyPlan(DailyPlan dailyPlan);

    void deleteDailyPlanById(@Param("planId") Long planId);

    void deleteDailyPlanItemsByPlanId(@Param("planId") Long planId);

    void insertDailyPlanItem(DailyPlanItem item);

    List<WeeklyPlanTemplate> findWeeklyTemplatesByUserId(@Param("userId") Long userId);

    WeeklyPlanTemplate findWeeklyTemplateByUserIdAndName(@Param("userId") Long userId, @Param("templateName") String templateName);

    WeeklyPlanTemplate findWeeklyTemplateByIdAndUserId(@Param("templateId") Long templateId, @Param("userId") Long userId);

    List<WeeklyPlanTemplateItem> findWeeklyTemplateItemsByTemplateId(@Param("templateId") Long templateId);

    void insertWeeklyPlanTemplate(WeeklyPlanTemplate template);

    void updateWeeklyPlanTemplate(WeeklyPlanTemplate template);

    void deleteWeeklyPlanTemplateItemsByTemplateId(@Param("templateId") Long templateId);

    void deleteWeeklyPlanTemplateByIdAndUserId(@Param("templateId") Long templateId, @Param("userId") Long userId);

    void insertWeeklyPlanTemplateItem(WeeklyPlanTemplateItem item);
}
