package com.innocence.server.modules.focus.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record ConfigurePomodoroRequest(
        @NotNull @Positive Long sessionId,
        @NotNull Boolean bindPomodoro,
        Integer pomodoroStudyMinutes,
        Integer pomodoroBreakMinutes
) {}
