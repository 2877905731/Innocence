package com.innocence.server.modules.setting.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.dto.response.PrivacySettingResponse;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;
import com.innocence.server.modules.account.service.AccountService;
import com.innocence.server.modules.setting.domain.UserAppearanceSetting;
import com.innocence.server.modules.setting.domain.UserNotificationSetting;
import com.innocence.server.modules.setting.domain.UserWidgetSetting;
import com.innocence.server.modules.setting.dto.request.UpdateAppearanceSettingRequest;
import com.innocence.server.modules.setting.dto.request.UpdateNotificationSettingRequest;
import com.innocence.server.modules.setting.dto.request.UpdateWidgetSettingRequest;
import com.innocence.server.modules.setting.dto.response.AppearanceSettingResponse;
import com.innocence.server.modules.setting.dto.response.NotificationSettingResponse;
import com.innocence.server.modules.setting.dto.response.SettingOverviewResponse;
import com.innocence.server.modules.setting.dto.response.WidgetSettingResponse;
import com.innocence.server.modules.setting.mapper.SettingMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
public class SettingService {

    private static final String THEME_DARK = "dark";
    private static final String THEME_LIGHT = "light";
    private static final String EFFECT_IMMERSIVE_GLASS = "immersive_glass";
    private static final String EFFECT_SOFT_GLASS = "soft_glass";
    private static final String EFFECT_FOCUS_GLOW = "focus_glow";

    private final SettingMapper settingMapper;
    private final AccountService accountService;

    public SettingService(
            SettingMapper settingMapper,
            AccountService accountService
    ) {
        this.settingMapper = settingMapper;
        this.accountService = accountService;
    }

    @Transactional
    public SettingOverviewResponse getOverview(Long userId) {
        UserProfileResponse profile = accountService.getMyProfile(userId);
        PrivacySettingResponse privacy = accountService.getPrivacySetting(userId);
        NotificationSettingResponse notification = buildNotificationResponse(
                ensureNotificationSetting(userId)
        );
        WidgetSettingResponse widget = buildWidgetResponse(
                ensureWidgetSetting(userId)
        );
        AppearanceSettingResponse appearance = buildAppearanceResponse(
                ensureAppearanceSetting(userId)
        );

        SettingOverviewResponse response = new SettingOverviewResponse();
        response.setAccountSetting(profile);
        response.setPrivacySetting(privacy);
        response.setNotificationSetting(notification);
        response.setWidgetSetting(widget);
        response.setAppearanceSetting(appearance);
        return response;
    }

    @Transactional
    public NotificationSettingResponse getNotificationSetting(Long userId) {
        return buildNotificationResponse(ensureNotificationSetting(userId));
    }

    @Transactional
    public NotificationSettingResponse updateNotificationSetting(
            Long userId,
            UpdateNotificationSettingRequest request
    ) {
        UserNotificationSetting setting = ensureNotificationSetting(userId);
        setting.setMobilePushEnabled(normalizeFlag(request.getMobilePushEnabled(), "Mobile push"));
        setting.setDesktopNoticeEnabled(normalizeFlag(request.getDesktopNoticeEnabled(), "Desktop notice"));
        setting.setTeamRemindEnabled(normalizeFlag(request.getTeamRemindEnabled(), "Teammate reminder"));
        setting.setSystemAnnouncementEnabled(normalizeFlag(request.getSystemAnnouncementEnabled(), "System announcement"));
        settingMapper.updateNotificationSetting(setting);
        return buildNotificationResponse(setting);
    }

    @Transactional
    public WidgetSettingResponse getWidgetSetting(Long userId) {
        return buildWidgetResponse(ensureWidgetSetting(userId));
    }

    @Transactional
    public WidgetSettingResponse updateWidgetSetting(
            Long userId,
            UpdateWidgetSettingRequest request
    ) {
        UserWidgetSetting setting = ensureWidgetSetting(userId);
        setting.setAutoStartFlag(normalizeFlag(request.getAutoStart(), "Auto-start"));
        setting.setAlwaysOnTopFlag(normalizeFlag(request.getAlwaysOnTop(), "Always-on-top"));
        setting.setShowPlanFlag(normalizeFlag(request.getShowPlan(), "Show plan"));
        setting.setShowTimerFlag(normalizeFlag(request.getShowTimer(), "Show timer"));
        setting.setShowMemoFlag(normalizeFlag(request.getShowMemo(), "Show memo"));
        settingMapper.updateWidgetSetting(setting);
        return buildWidgetResponse(setting);
    }

    @Transactional
    public AppearanceSettingResponse getAppearanceSetting(Long userId) {
        return buildAppearanceResponse(ensureAppearanceSetting(userId));
    }

    @Transactional
    public AppearanceSettingResponse updateAppearanceSetting(
            Long userId,
            UpdateAppearanceSettingRequest request
    ) {
        UserAppearanceSetting setting = ensureAppearanceSetting(userId);
        setting.setThemeMode(normalizeThemeMode(request.getThemeMode()));
        setting.setDesktopEffect(normalizeDesktopEffect(request.getDesktopEffect()));
        settingMapper.updateAppearanceSetting(setting);
        return buildAppearanceResponse(setting);
    }

    @Transactional(readOnly = true)
    public void clearCache(Long userId) {
        accountService.getMyProfile(userId);
    }

    private UserNotificationSetting ensureNotificationSetting(Long userId) {
        UserNotificationSetting setting = settingMapper.findNotificationSettingByUserId(userId);
        if (setting != null) {
            return setting;
        }

        UserNotificationSetting created = new UserNotificationSetting();
        created.setUserId(userId);
        created.setMobilePushEnabled(1);
        created.setDesktopNoticeEnabled(1);
        created.setTeamRemindEnabled(1);
        created.setSystemAnnouncementEnabled(1);
        settingMapper.insertNotificationSetting(created);
        return created;
    }

    private UserWidgetSetting ensureWidgetSetting(Long userId) {
        UserWidgetSetting setting = settingMapper.findWidgetSettingByUserId(userId);
        if (setting != null) {
            return setting;
        }

        UserWidgetSetting created = new UserWidgetSetting();
        created.setUserId(userId);
        created.setAutoStartFlag(0);
        created.setAlwaysOnTopFlag(0);
        created.setShowPlanFlag(1);
        created.setShowTimerFlag(1);
        created.setShowMemoFlag(1);
        settingMapper.insertWidgetSetting(created);
        return created;
    }

    private UserAppearanceSetting ensureAppearanceSetting(Long userId) {
        UserAppearanceSetting setting = settingMapper.findAppearanceSettingByUserId(userId);
        if (setting != null) {
            return setting;
        }

        UserAppearanceSetting created = new UserAppearanceSetting();
        created.setUserId(userId);
        created.setThemeMode(THEME_DARK);
        created.setDesktopEffect(EFFECT_IMMERSIVE_GLASS);
        settingMapper.insertAppearanceSetting(created);
        return created;
    }

    private NotificationSettingResponse buildNotificationResponse(UserNotificationSetting setting) {
        NotificationSettingResponse response = new NotificationSettingResponse();
        response.setMobilePushEnabled(defaultFlag(setting.getMobilePushEnabled()));
        response.setDesktopNoticeEnabled(defaultFlag(setting.getDesktopNoticeEnabled()));
        response.setTeamRemindEnabled(defaultFlag(setting.getTeamRemindEnabled()));
        response.setSystemAnnouncementEnabled(defaultFlag(setting.getSystemAnnouncementEnabled()));
        return response;
    }

    private WidgetSettingResponse buildWidgetResponse(UserWidgetSetting setting) {
        WidgetSettingResponse response = new WidgetSettingResponse();
        response.setAutoStart(defaultFlag(setting.getAutoStartFlag()));
        response.setAlwaysOnTop(defaultFlag(setting.getAlwaysOnTopFlag()));
        response.setShowPlan(defaultFlag(setting.getShowPlanFlag()));
        response.setShowTimer(defaultFlag(setting.getShowTimerFlag()));
        response.setShowMemo(defaultFlag(setting.getShowMemoFlag()));
        return response;
    }

    private AppearanceSettingResponse buildAppearanceResponse(UserAppearanceSetting setting) {
        AppearanceSettingResponse response = new AppearanceSettingResponse();
        response.setThemeMode(normalizeThemeMode(setting.getThemeMode()));
        response.setDesktopEffect(normalizeDesktopEffect(setting.getDesktopEffect()));
        return response;
    }

    private Integer normalizeFlag(Integer value, String fieldName) {
        if (value == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, fieldName + " setting is required.");
        }
        return value == 0 ? 0 : 1;
    }

    private Integer defaultFlag(Integer value) {
        return value != null && value == 0 ? 0 : 1;
    }

    private String normalizeThemeMode(String value) {
        String normalized = value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case THEME_DARK, THEME_LIGHT -> normalized;
            default -> throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Theme mode supports only dark or light."
            );
        };
    }

    private String normalizeDesktopEffect(String value) {
        String normalized = value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case EFFECT_IMMERSIVE_GLASS, EFFECT_SOFT_GLASS, EFFECT_FOCUS_GLOW -> normalized;
            default -> throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Desktop effect is invalid."
            );
        };
    }
}
