package com.innocence.server.modules.focus.mapper;

import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface FocusSessionMapper {

    StudyTimerRecord findActiveSessionByUserId(@Param("userId") Long userId);

    StudyTimerRecord findSessionByIdAndUserId(@Param("sessionId") Long sessionId, @Param("userId") Long userId);

    void insertStudyTimerRecord(StudyTimerRecord record);

    void finishStudyTimerRecord(
            @Param("sessionId") Long sessionId,
            @Param("actualEndTime") LocalDateTime actualEndTime,
            @Param("durationSeconds") int durationSeconds,
            @Param("completedPomodoroCount") int completedPomodoroCount,
            @Param("status") String status
    );

    int markCompletionNotificationSent(@Param("sessionId") Long sessionId);
}
