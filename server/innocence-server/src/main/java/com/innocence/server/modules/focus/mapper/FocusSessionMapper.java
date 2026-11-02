package com.innocence.server.modules.focus.mapper;

import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;

@Mapper
public interface FocusSessionMapper {
    @Insert("""
        INSERT INTO study_timer_record(user_id,client_pomodoro_key,task_name,planned_end_time,actual_end_time,
          planned_minutes,duration_seconds,status,completed_pomodoro_count,completion_notified_flag,create_time)
        VALUES(#{userId},#{record.recordKey},'Pomodoro study',#{record.endTime},#{record.endTime},
          CEIL(#{record.creditedSeconds}/60.0),#{record.creditedSeconds},'finished',#{record.completedRounds},1,#{record.startTime})
        ON DUPLICATE KEY UPDATE duration_seconds=GREATEST(duration_seconds,#{record.creditedSeconds}),
          completed_pomodoro_count=GREATEST(completed_pomodoro_count,#{record.completedRounds}),
          actual_end_time=GREATEST(actual_end_time,#{record.endTime}),
          planned_end_time=GREATEST(planned_end_time,#{record.endTime})
        """)
    void upsertPomodoroStudy(@Param("userId") Long userId,
        @Param("record") com.innocence.server.modules.focus.dto.request.PomodoroStudyRequest record);

    @Update("UPDATE assistant_document SET payload_json=JSON_SET(payload_json,'$.execution.undoEligibility',JSON_EXTRACT('false','$')) WHERE user_id=#{userId} AND kind='execution' AND JSON_EXTRACT(payload_json,'$.execution.undoEligibility')=true")
    void invalidateAssistantUndo(@Param("userId") Long userId);
    @Select("SELECT id FROM app_user WHERE id=#{userId} FOR UPDATE")
    Long lockPlanningOwner(@Param("userId") Long userId);
    @Insert("INSERT IGNORE INTO daily_plan_revision(user_id,plan_date,revision) VALUES(#{userId},#{date},0)")
    void ensureDayRevision(@Param("userId") Long userId, @Param("date") java.time.LocalDate date);
    @Update("UPDATE daily_plan_revision SET revision=revision+1 WHERE user_id=#{userId} AND plan_date=#{date}")
    void advanceDayRevision(@Param("userId") Long userId, @Param("date") java.time.LocalDate date);

    StudyTimerRecord findCurrentSessionByUserId(@Param("userId") Long userId);

    StudyTimerRecord findSessionByIdAndUserId(@Param("sessionId") Long sessionId, @Param("userId") Long userId);

    void insertStudyTimerRecord(StudyTimerRecord record);

    void insertImportedStudyTimerRecord(StudyTimerRecord record);
    int configurePomodoro(StudyTimerRecord record);

    void finishStudyTimerRecord(
            @Param("sessionId") Long sessionId,
            @Param("actualEndTime") LocalDateTime actualEndTime,
            @Param("durationSeconds") int durationSeconds,
            @Param("completedPomodoroCount") int completedPomodoroCount,
            @Param("status") String status
    );

    void finishImportedStudyTimerRecord(
            @Param("sessionId") Long sessionId,
            @Param("userId") Long userId,
            @Param("actualEndTime") LocalDateTime actualEndTime,
            @Param("durationSeconds") int durationSeconds,
            @Param("completedPomodoroCount") int completedPomodoroCount
    );

    int pauseStudyTimerRecord(
            @Param("sessionId") Long sessionId,
            @Param("userId") Long userId,
            @Param("pausedAt") LocalDateTime pausedAt
    );

    int resumeStudyTimerRecord(
            @Param("sessionId") Long sessionId,
            @Param("userId") Long userId,
            @Param("plannedEndTime") LocalDateTime plannedEndTime,
            @Param("pausedDurationSeconds") int pausedDurationSeconds
    );

    int markCompletionNotificationSent(@Param("sessionId") Long sessionId);
}
