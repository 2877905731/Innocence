package com.innocence.server.modules.notification.mapper;

import com.innocence.server.modules.notification.domain.AppNotification;
import com.innocence.server.modules.notification.domain.AdminAnnouncementRow;
import com.innocence.server.modules.notification.domain.AppNotificationRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface NotificationMapper {

    List<AppNotificationRow> findRecentNotificationsByUserId(
            @Param("userId") Long userId,
            @Param("sinceTime") LocalDateTime sinceTime,
            @Param("limit") int limit
    );

    Integer countUnreadByUserId(
            @Param("userId") Long userId,
            @Param("sinceTime") LocalDateTime sinceTime
    );

    void insertNotification(AppNotification notification);

    List<AdminAnnouncementRow> findRecentSystemAnnouncements(
            @Param("notificationType") String notificationType,
            @Param("relatedType") String relatedType,
            @Param("limit") int limit
    );

    int deleteSystemAnnouncement(
            @Param("notificationType") String notificationType,
            @Param("relatedType") String relatedType,
            @Param("announcementId") Long announcementId
    );

    int markRead(
            @Param("userId") Long userId,
            @Param("notificationId") Long notificationId
    );

    int markAllRead(
            @Param("userId") Long userId,
            @Param("sinceTime") LocalDateTime sinceTime
    );

    Integer countNotificationsByRecipientAndRelated(
            @Param("userId") Long userId,
            @Param("notificationType") String notificationType,
            @Param("relatedType") String relatedType,
            @Param("relatedId") Long relatedId
    );
}
