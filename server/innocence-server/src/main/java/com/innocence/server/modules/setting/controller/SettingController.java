package com.innocence.server.modules.setting.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.setting.dto.request.UpdateAppearanceSettingRequest;
import com.innocence.server.modules.setting.dto.request.UpdateNotificationSettingRequest;
import com.innocence.server.modules.setting.dto.request.UpdateWidgetSettingRequest;
import com.innocence.server.modules.setting.dto.response.AppearanceSettingResponse;
import com.innocence.server.modules.setting.dto.response.NotificationSettingResponse;
import com.innocence.server.modules.setting.dto.response.SettingOverviewResponse;
import com.innocence.server.modules.setting.dto.response.WidgetSettingResponse;
import com.innocence.server.modules.setting.service.SettingService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/app/v1/settings")
public class SettingController {

    private final SettingService settingService;

    public SettingController(SettingService settingService) {
        this.settingService = settingService;
    }

    @GetMapping("/profile")
    public ApiResponse<SettingOverviewResponse> getOverview() {
        return ApiResponse.success(settingService.getOverview(currentUserId()));
    }

    @GetMapping("/notifications")
    public ApiResponse<NotificationSettingResponse> getNotifications() {
        return ApiResponse.success(settingService.getNotificationSetting(currentUserId()));
    }

    @PutMapping("/notifications")
    public ApiResponse<NotificationSettingResponse> updateNotifications(
            @Valid @RequestBody UpdateNotificationSettingRequest request
    ) {
        return ApiResponse.success(settingService.updateNotificationSetting(currentUserId(), request));
    }

    @GetMapping("/appearance")
    public ApiResponse<AppearanceSettingResponse> getAppearance() {
        return ApiResponse.success(settingService.getAppearanceSetting(currentUserId()));
    }

    @PutMapping("/appearance")
    public ApiResponse<AppearanceSettingResponse> updateAppearance(
            @Valid @RequestBody UpdateAppearanceSettingRequest request
    ) {
        return ApiResponse.success(settingService.updateAppearanceSetting(currentUserId(), request));
    }

    @GetMapping("/widget")
    public ApiResponse<WidgetSettingResponse> getWidget() {
        return ApiResponse.success(settingService.getWidgetSetting(currentUserId()));
    }

    @PutMapping("/widget")
    public ApiResponse<WidgetSettingResponse> updateWidget(
            @Valid @RequestBody UpdateWidgetSettingRequest request
    ) {
        return ApiResponse.success(settingService.updateWidgetSetting(currentUserId(), request));
    }

    @PostMapping("/cache/clear")
    public ApiResponse<Map<String, Object>> clearCache() {
        settingService.clearCache(currentUserId());
        return ApiResponse.success(Map.of("success", true));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
