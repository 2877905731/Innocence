package com.innocence.server.modules.focus.dto.request;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

public record PomodoroStudyRequest(
        @NotBlank @Size(max = 160) @Pattern(regexp = "[a-zA-Z0-9_-]+/[1-9][0-9]*/[0-9]{4}-[0-9]{2}-[0-9]{2}") String recordKey,
        @NotNull LocalDateTime startTime,
        @NotNull LocalDateTime endTime,
        @NotNull @Min(0) @Max(86400) Integer studySeconds,
        @NotNull @Min(0) @Max(86400) Integer creditedSeconds,
        @NotNull @Min(0) @Max(1) Integer completedRounds
) {}
