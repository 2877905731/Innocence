package com.innocence.server.modules.notification.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.notification.domain.AdminAnnouncementRow;
import com.innocence.server.modules.notification.domain.AppNotification;
import com.innocence.server.modules.notification.dto.request.CreateSystemAnnouncementRequest;
import com.innocence.server.modules.notification.dto.response.AdminAnnouncementActionResponse;
import com.innocence.server.modules.notification.dto.response.AdminAnnouncementItemResponse;
import com.innocence.server.modules.notification.mapper.NotificationMapper;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class AdminAnnouncementService {

    private static final int ACTIVE_STATUS = 1;
    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 200;
    private static final String SYSTEM_ANNOUNCEMENT_TYPE = "system_announcement";
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final AdminAccessService adminAccessService;
    private final NotificationMapper notificationMapper;
    private final UserMapper userMapper;

    public AdminAnnouncementService(
            AdminAccessService adminAccessService,
            NotificationMapper notificationMapper,
            UserMapper userMapper
    ) {
        this.adminAccessService = adminAccessService;
        this.notificationMapper = notificationMapper;
        this.userMapper = userMapper;
    }

    @Transactional(readOnly = true)
    public List<AdminAnnouncementItemResponse> getRecentAnnouncements(
            Long adminUserId,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        List<AdminAnnouncementRow> rows = notificationMapper.findRecentSystemAnnouncements(
                SYSTEM_ANNOUNCEMENT_TYPE,
                SYSTEM_ANNOUNCEMENT_TYPE,
                normalizeLimit(limit)
        );
        List<AdminAnnouncementItemResponse> responses = new ArrayList<>();
        for (AdminAnnouncementRow row : rows) {
            responses.add(toItemResponse(row));
        }
        return responses;
    }

    @Transactional
    public AdminAnnouncementActionResponse createAnnouncement(
            Long adminUserId,
            CreateSystemAnnouncementRequest request
    ) {
        adminAccessService.requireAdmin(adminUserId);
        if (request == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Announcement content is required.");
        }

        List<Long> recipientUserIds = userMapper.findSystemAnnouncementRecipientUserIds();
        if (recipientUserIds == null || recipientUserIds.isEmpty()) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "No active users are currently eligible to receive system announcements."
            );
        }

        String title = defaultText(request.getTitle());
        String content = defaultText(request.getContent());
        Long announcementId = System.currentTimeMillis();
        LocalDateTime publishTime = LocalDateTime.now();
        int recipientCount = 0;

        for (Long userId : recipientUserIds) {
            if (userId == null || userId <= 0) {
                continue;
            }

            AppNotification notification = new AppNotification();
            notification.setUserId(userId);
            notification.setSenderUserId(null);
            notification.setNotificationType(SYSTEM_ANNOUNCEMENT_TYPE);
            notification.setTitle(title);
            notification.setContent(content);
            notification.setRelatedType(SYSTEM_ANNOUNCEMENT_TYPE);
            notification.setRelatedId(announcementId);
            notification.setReadFlag(0);
            notification.setCreateTime(publishTime);
            notificationMapper.insertNotification(notification);
            recipientCount++;
        }

        if (recipientCount <= 0) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "No active users are currently eligible to receive system announcements."
            );
        }

        AdminAnnouncementActionResponse response = new AdminAnnouncementActionResponse();
        response.setAnnouncementId(announcementId);
        response.setSuccess(true);
        response.setRecipientCount(recipientCount);
        response.setMessage("Announcement sent to " + recipientCount + " users.");
        return response;
    }

    @Transactional
    public AdminAnnouncementActionResponse deleteAnnouncement(Long adminUserId, Long announcementId) {
        adminAccessService.requireAdmin(adminUserId);
        if (announcementId == null || announcementId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Announcement id is required.");
        }

        int deletedCount = notificationMapper.deleteSystemAnnouncement(
                SYSTEM_ANNOUNCEMENT_TYPE,
                SYSTEM_ANNOUNCEMENT_TYPE,
                announcementId
        );
        if (deletedCount <= 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected announcement was not found.");
        }

        AdminAnnouncementActionResponse response = new AdminAnnouncementActionResponse();
        response.setAnnouncementId(announcementId);
        response.setSuccess(true);
        response.setRecipientCount(deletedCount);
        response.setMessage("Announcement deleted.");
        return response;
    }

    private AdminAnnouncementItemResponse toItemResponse(AdminAnnouncementRow row) {
        AdminAnnouncementItemResponse response = new AdminAnnouncementItemResponse();
        response.setAnnouncementId(row.getAnnouncementId());
        response.setTitle(defaultText(row.getTitle()));
        response.setContent(defaultText(row.getContent()));
        response.setRecipientCount(defaultNumber(row.getRecipientCount()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private int normalizeLimit(Integer limit) {
        if (limit == null) {
            return DEFAULT_LIMIT;
        }
        if (limit < 1 || limit > MAX_LIMIT) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Limit must be between 1 and 200.");
        }
        return limit;
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(DATE_TIME_FORMATTER);
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String defaultText(String value) {
        return value == null ? "" : value.trim();
    }
}
