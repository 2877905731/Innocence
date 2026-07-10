package com.innocence.server.modules.notification.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.focus.domain.StudyTimerRecord;
import com.innocence.server.modules.focus.mapper.FocusSessionMapper;
import com.innocence.server.modules.friend.domain.FriendRequest;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.notification.domain.AppNotification;
import com.innocence.server.modules.notification.domain.AppNotificationRow;
import com.innocence.server.modules.notification.dto.response.NotificationItemResponse;
import com.innocence.server.modules.notification.dto.response.NotificationOverviewResponse;
import com.innocence.server.modules.notification.mapper.NotificationMapper;
import com.innocence.server.modules.team.domain.StudyTeam;
import com.innocence.server.modules.team.domain.StudyTeamInvitation;
import com.innocence.server.modules.team.domain.StudyTeamMember;
import com.innocence.server.modules.team.mapper.TeamMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class NotificationService {

    private static final int RECENT_DAYS = 30;
    private static final int DEFAULT_LIMIT = 40;
    private static final int MAX_LIMIT = 100;
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final NotificationMapper notificationMapper;
    private final UserMapper userMapper;
    private final FriendMapper friendMapper;
    private final TeamMapper teamMapper;
    private final FocusSessionMapper focusSessionMapper;

    public NotificationService(
            NotificationMapper notificationMapper,
            UserMapper userMapper,
            FriendMapper friendMapper,
            TeamMapper teamMapper,
            FocusSessionMapper focusSessionMapper
    ) {
        this.notificationMapper = notificationMapper;
        this.userMapper = userMapper;
        this.friendMapper = friendMapper;
        this.teamMapper = teamMapper;
        this.focusSessionMapper = focusSessionMapper;
    }

    @Transactional(readOnly = true)
    public NotificationOverviewResponse getOverview(Long userId, Integer limit) {
        return buildOverview(userId, normalizeLimit(limit));
    }

    @Transactional
    public NotificationOverviewResponse markRead(Long userId, Long notificationId) {
        if (notificationId == null || notificationId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Notification id is required.");
        }
        notificationMapper.markRead(userId, notificationId);
        return buildOverview(userId, DEFAULT_LIMIT);
    }

    @Transactional
    public NotificationOverviewResponse markAllRead(Long userId) {
        notificationMapper.markAllRead(userId, recentSinceTime());
        return buildOverview(userId, DEFAULT_LIMIT);
    }

    @Transactional
    public void createTeamReminderNotification(Long fromUserId, Long toUserId) {
        if (fromUserId == null || toUserId == null || fromUserId.equals(toUserId)) {
            return;
        }

        String senderName = resolveUserDisplayName(fromUserId, "Teammate");
        insertNotification(
                toUserId,
                fromUserId,
                "team_reminder",
                "Teammate reminder",
                senderName + " sent you a study reminder.",
                "team",
                fromUserId
        );
    }

    @Transactional
    public void createFriendRequestNotification(Long fromUserId, Long toUserId, Long requestId) {
        if (fromUserId == null || toUserId == null || fromUserId.equals(toUserId)) {
            return;
        }

        String senderName = resolveUserDisplayName(fromUserId, "Friend");
        insertNotification(
                toUserId,
                fromUserId,
                "friend_request",
                "Friend request",
                senderName + " wants to add you as a friend.",
                "friend_request",
                requestId
        );
    }

    @Transactional
    public void createTeamInvitationNotification(
            Long fromUserId,
            Long toUserId,
            Long invitationId,
            String teamName
    ) {
        if (fromUserId == null || toUserId == null || fromUserId.equals(toUserId)) {
            return;
        }

        String senderName = resolveUserDisplayName(fromUserId, "Captain");
        String resolvedTeamName = defaultText(teamName);
        if (resolvedTeamName.isEmpty()) {
            resolvedTeamName = "study team";
        }
        insertNotification(
                toUserId,
                fromUserId,
                "team_invitation",
                "Team invitation",
                senderName + " invited you to join " + resolvedTeamName + ".",
                "team_invitation",
                invitationId
        );
    }

    @Transactional
    public void createTeamChatNotification(
            Long fromUserId,
            Long toUserId,
            Long messageId,
            String content
    ) {
        if (fromUserId == null || toUserId == null || fromUserId.equals(toUserId)) {
            return;
        }

        String senderName = resolveUserDisplayName(fromUserId, "Teammate");
        String preview = defaultText(content);
        if (preview.length() > 80) {
            preview = preview.substring(0, 80) + "...";
        }
        insertNotification(
                toUserId,
                fromUserId,
                "team_chat",
                "Team chat update",
                senderName + ": " + preview,
                "team_chat",
                messageId
        );
    }

    @Transactional
    public void createCheckInResultNotification(Long userId, boolean success, String message) {
        if (userId == null) {
            return;
        }

        insertNotification(
                userId,
                null,
                success ? "check_in_success" : "check_in_failure",
                success ? "Check-in completed" : "Check-in pending",
                defaultText(message),
                "checkin",
                null
        );
    }

    @Transactional
    public void createReportReviewNotification(
            Long userId,
            String decision,
            String punishmentType,
            String reason,
            boolean deleteContent
    ) {
        if (userId == null) {
            return;
        }

        String normalizedDecision = defaultText(decision);
        String normalizedPunishmentType = defaultText(punishmentType);
        String normalizedReason = defaultText(reason);

        String title;
        String content;
        if ("reject".equalsIgnoreCase(normalizedDecision)) {
            title = "Report review result";
            content = "A report involving your content was reviewed and no violation was confirmed.";
        } else {
            title = "Content violation handled";
            StringBuilder builder = new StringBuilder("A report involving your content was confirmed.");
            if (deleteContent) {
                builder.append(" The content was removed.");
            }
            if (!normalizedPunishmentType.isEmpty() && !"none".equalsIgnoreCase(normalizedPunishmentType)) {
                builder.append(" Penalty: ").append(normalizedPunishmentType).append('.');
            }
            if (!normalizedReason.isEmpty()) {
                builder.append(" Reason: ").append(normalizedReason);
            }
            content = builder.toString();
        }

        insertNotification(
                userId,
                null,
                "report_review",
                title,
                content,
                "report",
                null
        );
    }

    @Transactional
    public void createPunishmentLiftedNotification(
            Long userId,
            String punishmentType,
            String reason
    ) {
        if (userId == null) {
            return;
        }

        String normalizedType = defaultText(punishmentType);
        String normalizedReason = defaultText(reason);
        StringBuilder content = new StringBuilder("Your ");
        content.append(normalizedType.isEmpty() ? "restriction" : normalizedType);
        content.append(" was lifted by an administrator.");
        if (!normalizedReason.isEmpty()) {
            content.append(" Note: ").append(normalizedReason);
        }

        insertNotification(
                userId,
                null,
                "punishment_lifted",
                "Restriction lifted",
                content.toString(),
                "report",
                null
        );
    }

    @Transactional
    public void createFocusCompletionNotifications(Long userId, StudyTimerRecord record) {
        if (userId == null || record == null || record.getId() == null) {
            return;
        }
        if (defaultNumber(record.getCompletionNotifiedFlag()) == 1) {
            return;
        }

        int updated = focusSessionMapper.markCompletionNotificationSent(record.getId());
        if (updated <= 0) {
            record.setCompletionNotifiedFlag(1);
            return;
        }
        record.setCompletionNotifiedFlag(1);

        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember == null || currentMember.getTeamId() == null) {
            return;
        }

        List<StudyTeamMember> members = teamMapper.findActiveMembersByTeamId(currentMember.getTeamId());
        if (members == null || members.isEmpty()) {
            return;
        }

        String senderName = resolveUserDisplayName(userId, "Teammate");
        String taskName = resolveTaskName(record.getTaskName());
        String durationLabel = formatMinutes(resolveDurationMinutes(record));
        String content = senderName + " finished " + taskName + " after " + durationLabel + ".";

        for (StudyTeamMember member : members) {
            if (member == null || member.getUserId() == null || member.getUserId().equals(userId)) {
                continue;
            }
            if (defaultNumber(member.getStatus()) != 1) {
                continue;
            }

            insertNotification(
                    member.getUserId(),
                    userId,
                    "teammate_completion",
                    "Teammate finished studying",
                    content,
                    "focus",
                    record.getId()
            );
        }
    }

    @Transactional
    public void createPlanCompletionNotifications(
            Long userId,
            String planDate,
            String planName,
            int completedCount,
            int totalCount
    ) {
        if (userId == null || totalCount <= 0 || completedCount < totalCount) {
            return;
        }

        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember == null || currentMember.getTeamId() == null) {
            return;
        }

        List<StudyTeamMember> members = teamMapper.findActiveMembersByTeamId(currentMember.getTeamId());
        if (members == null || members.isEmpty()) {
            return;
        }

        String senderName = resolveUserDisplayName(userId, "Teammate");
        String resolvedPlanName = resolvePlanName(planName);
        String safePlanDate = defaultText(planDate);
        String content = senderName
                + " completed today's plan: "
                + resolvedPlanName
                + " ("
                + completedCount
                + "/"
                + totalCount
                + ").";

        Long dedupeId = buildPlanCompletionRelatedId(userId, safePlanDate);
        for (StudyTeamMember member : members) {
            if (member == null || member.getUserId() == null || member.getUserId().equals(userId)) {
                continue;
            }
            if (defaultNumber(member.getStatus()) != 1) {
                continue;
            }
            Integer existingCount = notificationMapper.countNotificationsByRecipientAndRelated(
                    member.getUserId(),
                    "plan_completion",
                    "plan",
                    dedupeId
            );
            if (defaultNumber(existingCount) > 0) {
                continue;
            }

            insertNotification(
                    member.getUserId(),
                    userId,
                    "plan_completion",
                    safePlanDate.isEmpty()
                            ? "Teammate completed today's plan"
                            : "Teammate completed the " + safePlanDate + " plan",
                    content,
                    "plan",
                    dedupeId
            );
        }
    }

    private NotificationOverviewResponse buildOverview(Long userId, int limit) {
        LocalDateTime sinceTime = recentSinceTime();
        List<AppNotificationRow> rows = notificationMapper.findRecentNotificationsByUserId(
                userId,
                sinceTime,
                limit
        );
        Integer unreadCount = notificationMapper.countUnreadByUserId(userId, sinceTime);

        NotificationOverviewResponse response = new NotificationOverviewResponse();
        response.setUnreadCount(defaultNumber(unreadCount));

        List<NotificationItemResponse> items = new ArrayList<>();
        for (AppNotificationRow row : rows) {
            items.add(toItemResponse(userId, row));
        }
        response.setItems(items);
        return response;
    }

    private NotificationItemResponse toItemResponse(Long userId, AppNotificationRow row) {
        NotificationItemResponse response = new NotificationItemResponse();
        response.setId(row.getId());
        response.setNotificationType(defaultText(row.getNotificationType()));
        response.setTitle(defaultText(row.getTitle()));
        response.setContent(defaultText(row.getContent()));
        response.setRelatedType(defaultText(row.getRelatedType()));
        response.setRelatedId(row.getRelatedId());
        response.setActionable(isActionable(userId, row));
        response.setRead(defaultNumber(row.getReadFlag()) == 1);
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        response.setSenderUserId(row.getSenderUserId());
        response.setSenderUserNo(defaultText(row.getSenderUserNo()));
        response.setSenderNickname(defaultText(row.getSenderNickname()));
        response.setSenderAvatarUrl(defaultText(row.getSenderAvatarUrl()));
        return response;
    }

    private boolean isActionable(Long userId, AppNotificationRow row) {
        String notificationType = defaultText(row.getNotificationType());
        Long relatedId = row.getRelatedId();
        if (userId == null || relatedId == null || relatedId <= 0) {
            return false;
        }

        if ("friend_request".equalsIgnoreCase(notificationType)) {
            FriendRequest friendRequest = friendMapper.findFriendRequestById(relatedId);
            return friendRequest != null
                    && userId.equals(friendRequest.getTargetUserId())
                    && "pending".equalsIgnoreCase(defaultText(friendRequest.getStatus()));
        }

        if ("team_invitation".equalsIgnoreCase(notificationType)) {
            StudyTeamInvitation invitation = teamMapper.findTeamInvitationById(relatedId);
            if (invitation == null
                    || !userId.equals(invitation.getInviteeUserId())
                    || !"pending".equalsIgnoreCase(defaultText(invitation.getStatus()))) {
                return false;
            }
            if (teamMapper.findActiveMemberByUserId(userId) != null) {
                return false;
            }
            StudyTeam team = teamMapper.findActiveTeamById(invitation.getTeamId());
            return team != null;
        }

        return false;
    }

    private void insertNotification(
            Long userId,
            Long senderUserId,
            String notificationType,
            String title,
            String content,
            String relatedType,
            Long relatedId
    ) {
        AppNotification notification = new AppNotification();
        notification.setUserId(userId);
        notification.setSenderUserId(senderUserId);
        notification.setNotificationType(notificationType);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setRelatedType(relatedType);
        notification.setRelatedId(relatedId);
        notification.setReadFlag(0);
        notification.setCreateTime(LocalDateTime.now());
        notificationMapper.insertNotification(notification);
    }

    private int normalizeLimit(Integer limit) {
        if (limit == null) {
            return DEFAULT_LIMIT;
        }
        if (limit < 1 || limit > MAX_LIMIT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Notification limit must be between 1 and 100."
            );
        }
        return limit;
    }

    private LocalDateTime recentSinceTime() {
        return LocalDateTime.now().minusDays(RECENT_DAYS);
    }

    private String resolveUserDisplayName(Long userId, String fallback) {
        User user = userMapper.findUserById(userId);
        if (user == null) {
            return fallback;
        }
        String nickname = defaultText(user.getNickname());
        if (!nickname.isEmpty()) {
            return nickname;
        }
        String userNo = defaultText(user.getUserNo());
        if (!userNo.isEmpty()) {
            return userNo;
        }
        return fallback;
    }

    private String resolveTaskName(String taskName) {
        String normalized = defaultText(taskName);
        return normalized.isEmpty() ? "a focus session" : normalized;
    }

    private String resolvePlanName(String planName) {
        String normalized = defaultText(planName);
        return normalized.isEmpty() ? "Today" : normalized;
    }

    private Long buildPlanCompletionRelatedId(Long userId, String planDate) {
        String normalizedDate = defaultText(planDate);
        int dateHash = normalizedDate.isEmpty() ? 0 : normalizedDate.hashCode();
        long positiveHash = Integer.toUnsignedLong(dateHash);
        return userId * 100000000L + (positiveHash % 100000000L);
    }

    private int resolveDurationMinutes(StudyTimerRecord record) {
        int durationSeconds = defaultNumber(record.getDurationSeconds());
        if (durationSeconds <= 0) {
            return Math.max(defaultNumber(record.getPlannedMinutes()), 1);
        }
        return Math.max((durationSeconds + 59) / 60, 1);
    }

    private String formatMinutes(int minutes) {
        int normalized = Math.max(minutes, 0);
        int hours = normalized / 60;
        int remainingMinutes = normalized % 60;
        if (hours <= 0) {
            return normalized + " min";
        }
        if (remainingMinutes == 0) {
            return hours + " h";
        }
        return hours + " h " + remainingMinutes + " min";
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
