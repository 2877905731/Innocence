package com.innocence.server.modules.focus.mapper;

import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface FocusSessionMapper {

    StudyTimerRecord findCurrentSessionByUserId(@Param("userId") Long userId);

    StudyTimerRecord findSessionByIdAndUserId(@Param("sessionId") Long sessionId, @Param("userId") Long userId);

    void insertStudyTimerRecord(StudyTimerRecord record);

    void insertImportedStudyTimerRecord(StudyTimerRecord record);

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
