package com.innocence.server.modules.focus.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.focus.dto.request.FinishFocusSessionRequest;
import com.innocence.server.modules.focus.dto.request.StartFocusSessionRequest;
import com.innocence.server.modules.focus.dto.response.FocusSessionResponse;
import com.innocence.server.modules.focus.service.FocusSessionService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app/v1/focus/session")
public class FocusSessionController {

    private final FocusSessionService focusSessionService;

    public FocusSessionController(FocusSessionService focusSessionService) {
        this.focusSessionService = focusSessionService;
    }

    @PostMapping("/start")
    public ApiResponse<FocusSessionResponse> startSession(@Valid @RequestBody StartFocusSessionRequest request) {
        return ApiResponse.success(focusSessionService.startSession(currentUserId(), request));
    }

    @GetMapping("/current")
    public ApiResponse<FocusSessionResponse> getCurrentSession() {
        return ApiResponse.success(focusSessionService.getCurrentSession(currentUserId()));
    }

    @PostMapping("/finish")
    public ApiResponse<FocusSessionResponse> finishSession(
            @RequestBody(required = false) FinishFocusSessionRequest request
    ) {
        return ApiResponse.success(focusSessionService.finishSession(currentUserId(), request));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
