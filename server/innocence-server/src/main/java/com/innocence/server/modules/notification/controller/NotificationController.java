package com.innocence.server.modules.notification.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.notification.dto.response.NotificationOverviewResponse;
import com.innocence.server.modules.notification.service.NotificationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/overview")
    public ApiResponse<NotificationOverviewResponse> getOverview(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(notificationService.getOverview(currentUserId(), limit));
    }

    @PostMapping("/read")
    public ApiResponse<NotificationOverviewResponse> markRead(
            @RequestParam("notificationId") Long notificationId
    ) {
        return ApiResponse.success(notificationService.markRead(currentUserId(), notificationId));
    }

    @PostMapping("/read-all")
    public ApiResponse<NotificationOverviewResponse> markAllRead() {
        return ApiResponse.success(notificationService.markAllRead(currentUserId()));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
