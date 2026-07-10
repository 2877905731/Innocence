package com.innocence.server.modules.notification.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.notification.dto.request.CreateSystemAnnouncementRequest;
import com.innocence.server.modules.notification.dto.response.AdminAnnouncementActionResponse;
import com.innocence.server.modules.notification.dto.response.AdminAnnouncementItemResponse;
import com.innocence.server.modules.notification.service.AdminAnnouncementService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/v1/announcements")
public class AdminAnnouncementController {

    private final AdminAnnouncementService adminAnnouncementService;

    public AdminAnnouncementController(AdminAnnouncementService adminAnnouncementService) {
        this.adminAnnouncementService = adminAnnouncementService;
    }

    @GetMapping
    public ApiResponse<List<AdminAnnouncementItemResponse>> getRecentAnnouncements(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(
                adminAnnouncementService.getRecentAnnouncements(currentUserId(), limit)
        );
    }

    @PostMapping
    public ApiResponse<AdminAnnouncementActionResponse> createAnnouncement(
            @Valid @RequestBody CreateSystemAnnouncementRequest request
    ) {
        return ApiResponse.success(
                adminAnnouncementService.createAnnouncement(currentUserId(), request)
        );
    }

    @PostMapping("/{announcementId}/delete")
    public ApiResponse<AdminAnnouncementActionResponse> deleteAnnouncement(
            @PathVariable("announcementId") Long announcementId
    ) {
        return ApiResponse.success(
                adminAnnouncementService.deleteAnnouncement(currentUserId(), announcementId)
        );
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
