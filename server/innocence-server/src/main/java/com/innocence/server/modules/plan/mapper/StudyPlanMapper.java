package com.innocence.server.modules.plan.mapper;

import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.DailyPlanItem;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplate;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplateItem;
import com.innocence.server.modules.plan.domain.AnnualPlanSegment;
import com.innocence.server.modules.plan.domain.AnnualPlanSubtask;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Delete;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface StudyPlanMapper {
    @Select("SELECT id FROM app_user WHERE id=#{userId} FOR UPDATE")
    Long lockPlanningOwner(@Param("userId") Long userId);

    @Insert("INSERT IGNORE INTO daily_plan_revision(user_id,plan_date,revision) VALUES(#{userId},#{planDate},0)")
    void ensureDayRevision(@Param("userId") Long userId, @Param("planDate") LocalDate date);

    @Select("SELECT revision FROM daily_plan_revision WHERE user_id=#{userId} AND plan_date=#{planDate} FOR UPDATE")
    Long lockDayRevision(@Param("userId") Long userId, @Param("planDate") LocalDate date);

    @Select("SELECT revision FROM daily_plan_revision WHERE user_id=#{userId} AND plan_date=#{planDate}")
    Long findDayRevision(@Param("userId") Long userId, @Param("planDate") LocalDate date);

    @Update("UPDATE daily_plan_revision SET revision=revision+1 WHERE user_id=#{userId} AND plan_date=#{planDate}")
    void advanceDayRevision(@Param("userId") Long userId, @Param("planDate") LocalDate date);

    @Delete("DELETE FROM daily_plan_item WHERE id=#{itemId} AND plan_id=#{planId} AND user_id=#{userId}")
    int deleteAssistantItem(@Param("userId") Long userId, @Param("planId") Long planId, @Param("itemId") Long itemId);

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

    List<AnnualPlanSegment> findAnnualSegmentsByUserIdAndYear(
            @Param("userId") Long userId,
            @Param("planYear") Integer planYear
    );

    AnnualPlanSegment findAnnualSegmentByIdAndUserId(
            @Param("segmentId") Long segmentId,
            @Param("userId") Long userId
    );

    AnnualPlanSegment findAnnualSegmentByClientEntityIdAndUserId(
            @Param("clientEntityId") String clientEntityId,
            @Param("userId") Long userId
    );

    void insertAnnualPlanSegment(AnnualPlanSegment segment);

    void updateAnnualPlanSegment(AnnualPlanSegment segment);

    void deleteAnnualPlanSegmentByIdAndUserId(
            @Param("segmentId") Long segmentId,
            @Param("userId") Long userId
    );

    List<AnnualPlanSubtask> findAnnualPlanSubtasksBySegmentId(
            @Param("segmentId") Long segmentId,
            @Param("userId") Long userId
    );

    void insertAnnualPlanSubtask(AnnualPlanSubtask subtask);

    void deleteAnnualPlanSubtasksBySegmentIdAndUserId(
            @Param("segmentId") Long segmentId,
            @Param("userId") Long userId
    );
}
