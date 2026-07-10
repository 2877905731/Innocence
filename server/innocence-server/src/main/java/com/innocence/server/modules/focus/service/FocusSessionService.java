package com.innocence.server.modules.focus.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import com.innocence.server.modules.focus.dto.request.FinishFocusSessionRequest;
import com.innocence.server.modules.focus.dto.request.StartFocusSessionRequest;
import com.innocence.server.modules.focus.dto.response.FocusSessionResponse;
import com.innocence.server.modules.focus.mapper.FocusSessionMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;

@Service
public class FocusSessionService {

    private static final int MAX_SESSION_MINUTES = 24 * 60;

    private final FocusSessionMapper focusSessionMapper;
    private final NotificationService notificationService;

    public FocusSessionService(
            FocusSessionMapper focusSessionMapper,
            NotificationService notificationService
    ) {
        this.focusSessionMapper = focusSessionMapper;
        this.notificationService = notificationService;
    }

    @Transactional
    public FocusSessionResponse getCurrentSession(Long userId) {
        StudyTimerRecord activeRecord = focusSessionMapper.findActiveSessionByUserId(userId);
        if (activeRecord == null) {
            return emptyResponse();
        }

        LocalDateTime now = LocalDateTime.now();
        if (!activeRecord.getPlannedEndTime().isAfter(now)) {
            finalizeRecordAndNotify(activeRecord, activeRecord.getPlannedEndTime());
            return buildFinishedResponse(activeRecord);
        }

        return buildActiveResponse(activeRecord, now);
    }

    @Transactional
    public FocusSessionResponse startSession(Long userId, StartFocusSessionRequest request) {
        StudyTimerRecord currentRecord = focusSessionMapper.findActiveSessionByUserId(userId);
        if (currentRecord != null) {
            LocalDateTime now = LocalDateTime.now();
            if (currentRecord.getPlannedEndTime().isAfter(now)) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "An active study session is already running."
                );
            }
            finalizeRecordAndNotify(currentRecord, currentRecord.getPlannedEndTime());
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime endTime = request.getEndTime();
        if (endTime == null || !endTime.isAfter(now)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "End time must be later than now.");
        }

        long plannedSeconds = Duration.between(now, endTime).getSeconds();
        if (plannedSeconds < 60) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Study duration must be at least 1 minute.");
        }
        if (plannedSeconds > MAX_SESSION_MINUTES * 60L) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Study duration cannot exceed 24 hours.");
        }

        boolean bindPomodoro = Boolean.TRUE.equals(request.getBindPomodoro());
        int pomodoroStudyMinutes = 0;
        int pomodoroBreakMinutes = 0;
        if (bindPomodoro) {
            pomodoroStudyMinutes = requirePositiveMinutes(
                    request.getPomodoroStudyMinutes(),
                    "Pomodoro study minutes must be greater than 0."
            );
            pomodoroBreakMinutes = requireNonNegativeMinutes(
                    request.getPomodoroBreakMinutes(),
                    "Pomodoro break minutes cannot be negative."
            );
        }

        StudyTimerRecord record = new StudyTimerRecord();
        record.setUserId(userId);
        record.setTaskName(normalizeTaskName(request.getTaskName()));
        record.setPlannedEndTime(endTime);
        record.setActualEndTime(null);
        record.setPlannedMinutes((int) ((plannedSeconds + 59) / 60));
        record.setDurationSeconds(0);
        record.setStatus("active");
        record.setBindPomodoroFlag(bindPomodoro ? 1 : 0);
        record.setPomodoroStudyMinutes(pomodoroStudyMinutes);
        record.setPomodoroBreakMinutes(pomodoroBreakMinutes);
        record.setCompletedPomodoroCount(0);
        record.setCompletionNotifiedFlag(0);
        record.setCreateTime(now);
        focusSessionMapper.insertStudyTimerRecord(record);

        return buildActiveResponse(record, now);
    }

    @Transactional
    public FocusSessionResponse finishSession(Long userId, FinishFocusSessionRequest request) {
        StudyTimerRecord record;
        if (request != null && request.getSessionId() != null) {
            record = focusSessionMapper.findSessionByIdAndUserId(request.getSessionId(), userId);
        } else {
            record = focusSessionMapper.findActiveSessionByUserId(userId);
        }

        if (record == null || !"active".equalsIgnoreCase(record.getStatus())) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "No active study session was found.");
        }

        finalizeRecordAndNotify(record, LocalDateTime.now());
        return buildFinishedResponse(record);
    }

    private void finalizeRecordAndNotify(StudyTimerRecord record, LocalDateTime finishTime) {
        finalizeRecord(record, finishTime);
        notificationService.createFocusCompletionNotifications(record.getUserId(), record);
    }

    private void finalizeRecord(StudyTimerRecord record, LocalDateTime finishTime) {
        LocalDateTime effectiveEndTime = finishTime;
        if (record.getPlannedEndTime() != null && record.getPlannedEndTime().isBefore(effectiveEndTime)) {
            effectiveEndTime = record.getPlannedEndTime();
        }

        int durationSeconds = calculateElapsedSeconds(record.getCreateTime(), effectiveEndTime);
        int completedPomodoroCount = calculateCompletedPomodoroCount(record, durationSeconds);

        focusSessionMapper.finishStudyTimerRecord(
                record.getId(),
                effectiveEndTime,
                durationSeconds,
                completedPomodoroCount,
                "finished"
        );

        record.setActualEndTime(effectiveEndTime);
        record.setDurationSeconds(durationSeconds);
        record.setCompletedPomodoroCount(completedPomodoroCount);
        record.setStatus("finished");
    }

    private FocusSessionResponse buildActiveResponse(StudyTimerRecord record, LocalDateTime now) {
        int elapsedSeconds = calculateElapsedSeconds(record.getCreateTime(), now);
        int remainingSeconds = calculateRemainingSeconds(now, record.getPlannedEndTime());
        PomodoroState pomodoroState = resolvePomodoroState(record, elapsedSeconds, remainingSeconds);

        FocusSessionResponse response = new FocusSessionResponse();
        response.setSessionId(record.getId());
        response.setActive(true);
        response.setTaskName(normalizeTaskName(record.getTaskName()));
        response.setStageName(pomodoroState.stageName());
        response.setStartTime(formatDateTime(record.getCreateTime()));
        response.setPlannedEndTime(formatDateTime(record.getPlannedEndTime()));
        response.setActualEndTime("");
        response.setPlannedMinutes(defaultNumber(record.getPlannedMinutes()));
        response.setElapsedSeconds(elapsedSeconds);
        response.setRemainingSeconds(remainingSeconds);
        response.setBindPomodoro(isPomodoroBound(record));
        response.setPomodoroStudyMinutes(defaultNumber(record.getPomodoroStudyMinutes()));
        response.setPomodoroBreakMinutes(defaultNumber(record.getPomodoroBreakMinutes()));
        response.setCurrentCycleNo(pomodoroState.currentCycleNo());
        response.setCompletedPomodoroCount(pomodoroState.completedPomodoroCount());
        response.setStageRemainingSeconds(pomodoroState.stageRemainingSeconds());
        return response;
    }

    private FocusSessionResponse buildFinishedResponse(StudyTimerRecord record) {
        FocusSessionResponse response = new FocusSessionResponse();
        response.setSessionId(record.getId());
        response.setActive(false);
        response.setTaskName(normalizeTaskName(record.getTaskName()));
        response.setStageName("finished");
        response.setStartTime(formatDateTime(record.getCreateTime()));
        response.setPlannedEndTime(formatDateTime(record.getPlannedEndTime()));
        response.setActualEndTime(formatDateTime(record.getActualEndTime()));
        response.setPlannedMinutes(defaultNumber(record.getPlannedMinutes()));
        response.setElapsedSeconds(defaultNumber(record.getDurationSeconds()));
        response.setRemainingSeconds(0);
        response.setBindPomodoro(isPomodoroBound(record));
        response.setPomodoroStudyMinutes(defaultNumber(record.getPomodoroStudyMinutes()));
        response.setPomodoroBreakMinutes(defaultNumber(record.getPomodoroBreakMinutes()));
        response.setCurrentCycleNo(resolveFinishedCycleNo(record, defaultNumber(record.getDurationSeconds())));
        response.setCompletedPomodoroCount(defaultNumber(record.getCompletedPomodoroCount()));
        response.setStageRemainingSeconds(0);
        return response;
    }

    private FocusSessionResponse emptyResponse() {
        FocusSessionResponse response = new FocusSessionResponse();
        response.setSessionId(0L);
        response.setActive(false);
        response.setTaskName("");
        response.setStageName("idle");
        response.setStartTime("");
        response.setPlannedEndTime("");
        response.setActualEndTime("");
        response.setPlannedMinutes(0);
        response.setElapsedSeconds(0);
        response.setRemainingSeconds(0);
        response.setBindPomodoro(false);
        response.setPomodoroStudyMinutes(0);
        response.setPomodoroBreakMinutes(0);
        response.setCurrentCycleNo(0);
        response.setCompletedPomodoroCount(0);
        response.setStageRemainingSeconds(0);
        return response;
    }

    private PomodoroState resolvePomodoroState(
            StudyTimerRecord record,
            int elapsedSeconds,
            int remainingSeconds
    ) {
        if (!isPomodoroBound(record) || defaultNumber(record.getPomodoroStudyMinutes()) <= 0) {
            return new PomodoroState("study", 1, 0, remainingSeconds);
        }

        int studySeconds = defaultNumber(record.getPomodoroStudyMinutes()) * 60;
        int breakSeconds = defaultNumber(record.getPomodoroBreakMinutes()) * 60;
        if (breakSeconds <= 0) {
            int completedCount = elapsedSeconds / studySeconds;
            int currentCycleNo = completedCount + 1;
            int slotOffset = elapsedSeconds % studySeconds;
            int stageRemainingSeconds = slotOffset == 0 ? studySeconds : studySeconds - slotOffset;
            return new PomodoroState(
                    "study",
                    currentCycleNo,
                    completedCount,
                    Math.min(stageRemainingSeconds, remainingSeconds)
            );
        }

        int cycleSeconds = studySeconds + breakSeconds;
        int cycleIndex = elapsedSeconds / cycleSeconds;
        int cyclePosition = elapsedSeconds % cycleSeconds;
        if (cyclePosition < studySeconds) {
            return new PomodoroState(
                    "study",
                    cycleIndex + 1,
                    cycleIndex,
                    Math.min(studySeconds - cyclePosition, remainingSeconds)
            );
        }

        return new PomodoroState(
                "break",
                cycleIndex + 1,
                cycleIndex + 1,
                Math.min(cycleSeconds - cyclePosition, remainingSeconds)
        );
    }

    private int calculateCompletedPomodoroCount(StudyTimerRecord record, int elapsedSeconds) {
        if (!isPomodoroBound(record) || defaultNumber(record.getPomodoroStudyMinutes()) <= 0) {
            return 0;
        }

        int studySeconds = defaultNumber(record.getPomodoroStudyMinutes()) * 60;
        int breakSeconds = defaultNumber(record.getPomodoroBreakMinutes()) * 60;
        if (breakSeconds <= 0) {
            return elapsedSeconds / studySeconds;
        }
        if (elapsedSeconds < studySeconds) {
            return 0;
        }

        int cycleSeconds = studySeconds + breakSeconds;
        return 1 + ((elapsedSeconds - studySeconds) / cycleSeconds);
    }

    private int resolveFinishedCycleNo(StudyTimerRecord record, int elapsedSeconds) {
        if (!isPomodoroBound(record) || defaultNumber(record.getPomodoroStudyMinutes()) <= 0) {
            return 1;
        }

        int studySeconds = defaultNumber(record.getPomodoroStudyMinutes()) * 60;
        int breakSeconds = defaultNumber(record.getPomodoroBreakMinutes()) * 60;
        if (breakSeconds <= 0) {
            return (elapsedSeconds / studySeconds) + 1;
        }

        int cycleSeconds = studySeconds + breakSeconds;
        return (elapsedSeconds / cycleSeconds) + 1;
    }

    private int calculateElapsedSeconds(LocalDateTime startTime, LocalDateTime currentTime) {
        if (startTime == null || currentTime == null || currentTime.isBefore(startTime)) {
            return 0;
        }
        long seconds = Duration.between(startTime, currentTime).getSeconds();
        return (int) Math.max(seconds, 0);
    }

    private int calculateRemainingSeconds(LocalDateTime currentTime, LocalDateTime endTime) {
        if (currentTime == null || endTime == null || !endTime.isAfter(currentTime)) {
            return 0;
        }
        long seconds = Duration.between(currentTime, endTime).getSeconds();
        return (int) Math.max(seconds, 0);
    }

    private int requirePositiveMinutes(Integer value, String message) {
        if (value == null || value <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, message);
        }
        return value;
    }

    private int requireNonNegativeMinutes(Integer value, String message) {
        if (value == null) {
            return 0;
        }
        if (value < 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, message);
        }
        return value;
    }

    private boolean isPomodoroBound(StudyTimerRecord record) {
        return record != null && defaultNumber(record.getBindPomodoroFlag()) == 1;
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String normalizeTaskName(String taskName) {
        if (taskName == null || taskName.isBlank()) {
            return "Focus session";
        }
        return taskName.trim();
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "" : value.toString();
    }

    private record PomodoroState(
            String stageName,
            int currentCycleNo,
            int completedPomodoroCount,
            int stageRemainingSeconds
    ) {
    }
}
