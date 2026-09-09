package com.innocence.server.modules.focus.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import com.innocence.server.modules.focus.dto.response.FocusSessionResponse;
import com.innocence.server.modules.focus.mapper.FocusSessionMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class FocusSessionServiceTest {

    private FocusSessionMapper focusSessionMapper;
    private FocusSessionService focusSessionService;

    @BeforeEach
    void setUp() {
        focusSessionMapper = mock(FocusSessionMapper.class);
        focusSessionService = new FocusSessionService(
                focusSessionMapper,
                mock(NotificationService.class)
        );
    }

    @Test
    void pauseFreezesCurrentProgressForTokenOwnedUser() {
        StudyTimerRecord record = activeRecord();
        when(focusSessionMapper.findCurrentSessionByUserId(7L)).thenReturn(record);
        when(focusSessionMapper.pauseStudyTimerRecord(eq(42L), eq(7L), any()))
                .thenReturn(1);

        FocusSessionResponse response = focusSessionService.pauseSession(7L);

        assertTrue(response.isActive());
        assertTrue(response.isPaused());
        assertEquals("paused", response.getStageName());
        assertTrue(response.getElapsedSeconds() >= 299);
        verify(focusSessionMapper).pauseStudyTimerRecord(eq(42L), eq(7L), any());
    }

    @Test
    void resumeExtendsEndTimeAndAccumulatesPausedSeconds() {
        StudyTimerRecord record = activeRecord();
        LocalDateTime originalEnd = record.getPlannedEndTime();
        record.setStatus("paused");
        record.setPausedAt(LocalDateTime.now().minusSeconds(120));
        record.setPausedDurationSeconds(30);
        when(focusSessionMapper.findCurrentSessionByUserId(7L)).thenReturn(record);
        when(focusSessionMapper.resumeStudyTimerRecord(eq(42L), eq(7L), any(), any(Integer.class)))
                .thenReturn(1);

        FocusSessionResponse response = focusSessionService.resumeSession(7L);

        assertTrue(response.isActive());
        assertFalse(response.isPaused());
        ArgumentCaptor<LocalDateTime> endCaptor = ArgumentCaptor.forClass(LocalDateTime.class);
        ArgumentCaptor<Integer> pauseCaptor = ArgumentCaptor.forClass(Integer.class);
        verify(focusSessionMapper).resumeStudyTimerRecord(
                eq(42L), eq(7L), endCaptor.capture(), pauseCaptor.capture()
        );
        assertTrue(endCaptor.getValue().isAfter(originalEnd.plusSeconds(118)));
        assertTrue(pauseCaptor.getValue() >= 149);
    }

    @Test
    void pauseRejectsMissingCurrentSession() {
        when(focusSessionMapper.findCurrentSessionByUserId(7L)).thenReturn(null);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> focusSessionService.pauseSession(7L)
        );

        assertEquals(ErrorCode.NOT_FOUND, exception.getCode());
    }

    private StudyTimerRecord activeRecord() {
        LocalDateTime now = LocalDateTime.now();
        StudyTimerRecord record = new StudyTimerRecord();
        record.setId(42L);
        record.setUserId(7L);
        record.setTaskName("Read chapter 4");
        record.setCreateTime(now.minusMinutes(5));
        record.setPlannedEndTime(now.plusMinutes(25));
        record.setPlannedMinutes(30);
        record.setDurationSeconds(0);
        record.setStatus("active");
        record.setPausedDurationSeconds(0);
        record.setBindPomodoroFlag(0);
        record.setPomodoroStudyMinutes(0);
        record.setPomodoroBreakMinutes(0);
        record.setCompletedPomodoroCount(0);
        return record;
    }
}
