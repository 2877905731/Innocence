package com.innocence.server.modules.report.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.report.domain.ActivePunishmentRow;
import com.innocence.server.modules.report.domain.AdminUserDetailRow;
import com.innocence.server.modules.report.domain.AdminUserPunishmentRow;
import com.innocence.server.modules.report.domain.AdminUserReportRow;
import com.innocence.server.modules.report.domain.AdminUserSearchRow;
import com.innocence.server.modules.report.domain.PunishmentRecord;
import com.innocence.server.modules.report.domain.ReportAuditRecord;
import com.innocence.server.modules.report.domain.ReportDetailRow;
import com.innocence.server.modules.report.domain.ReportListItemRow;
import com.innocence.server.modules.report.domain.ReportRecord;
import com.innocence.server.modules.report.dto.response.AdminLiftPunishmentResponse;
import com.innocence.server.modules.report.dto.response.AdminUserDetailResponse;
import com.innocence.server.modules.report.dto.response.AdminUserPunishmentItemResponse;
import com.innocence.server.modules.report.dto.response.AdminUserReportItemResponse;
import com.innocence.server.modules.report.dto.response.AdminUserSearchItemResponse;
import com.innocence.server.modules.report.dto.request.CreateChatReportRequest;
import com.innocence.server.modules.report.dto.request.ReviewReportRequest;
import com.innocence.server.modules.report.dto.response.CreateReportResponse;
import com.innocence.server.modules.report.dto.response.ReportAuditItemResponse;
import com.innocence.server.modules.report.dto.response.ReportDetailResponse;
import com.innocence.server.modules.report.dto.response.ReportListItemResponse;
import com.innocence.server.modules.report.dto.response.ReportReviewResponse;
import com.innocence.server.modules.report.mapper.ReportMapper;
import com.innocence.server.modules.team.domain.StudyTeam;
import com.innocence.server.modules.team.domain.StudyTeamChatMessageRow;
import com.innocence.server.modules.team.domain.StudyTeamMember;
import com.innocence.server.modules.team.mapper.TeamMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class ReportService {

    public static final String REPORT_TYPE_TEAM_CHAT = "team_chat";
    public static final String REPORT_STATUS_PENDING = "pending";
    public static final String REPORT_STATUS_REJECTED = "rejected";
    public static final String REPORT_STATUS_RESOLVED = "resolved";
    public static final String PUNISHMENT_STATUS_ACTIVE = "active";
    public static final String PUNISHMENT_STATUS_LIFTED = "lifted";
    public static final String PUNISHMENT_NONE = "none";
    public static final String PUNISHMENT_WARN = "warn";
    public static final String PUNISHMENT_MUTE = "mute";
    public static final String PUNISHMENT_BAN = "ban";
    public static final String DECISION_REJECT = "reject";
    public static final String DECISION_VIOLATION = "violation";
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final ReportMapper reportMapper;
    private final TeamMapper teamMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;
    private final AdminAccessService adminAccessService;

    public ReportService(
            ReportMapper reportMapper,
            TeamMapper teamMapper,
            UserMapper userMapper,
            NotificationService notificationService,
            AdminAccessService adminAccessService
    ) {
        this.reportMapper = reportMapper;
        this.teamMapper = teamMapper;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
        this.adminAccessService = adminAccessService;
    }

    @Transactional
    public CreateReportResponse createTeamChatReport(
            Long userId,
            Long messageId,
            CreateChatReportRequest request
    ) {
        if (messageId == null || messageId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Message id is required.");
        }
        StudyTeamMember member = requireActiveMember(userId);
        StudyTeamChatMessageRow message = requireTeamChatMessage(messageId);
        if (message.getTeamId() == null || !message.getTeamId().equals(member.getTeamId())) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "You can report only messages from your own team.");
        }
        if (message.getSenderUserId() != null && message.getSenderUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You cannot report your own message.");
        }

        ReportRecord existing = reportMapper.findReportByUserAndTarget(
                userId,
                REPORT_TYPE_TEAM_CHAT,
                messageId
        );
        if (existing != null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You already reported this message.");
        }

        ReportRecord record = new ReportRecord();
        record.setReportUserId(userId);
        record.setReportType(REPORT_TYPE_TEAM_CHAT);
        record.setTargetId(messageId);
        record.setTargetUserId(message.getSenderUserId());
        record.setTeamId(member.getTeamId());
        record.setReasonText(normalizeReason(request == null ? null : request.getReason()));
        record.setDescriptionText(normalizeDescription(request == null ? null : request.getDescription()));
        record.setStatus(REPORT_STATUS_PENDING);
        try {
            reportMapper.insertReportRecord(record);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You already reported this message.");
        }

        CreateReportResponse response = new CreateReportResponse();
        response.setReportId(record.getId());
        response.setMessage("Report submitted.");
        return response;
    }

    @Transactional(readOnly = true)
    public List<ReportListItemResponse> getReports(
            Long adminUserId,
            String status,
            String reportType,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        String normalizedStatus = normalizeOptionalStatus(status);
        String normalizedType = normalizeOptionalType(reportType);
        int normalizedLimit = normalizeLimit(limit);
        List<ReportListItemRow> rows = reportMapper.findReports(
                normalizedStatus,
                normalizedType,
                normalizedLimit
        );
        List<ReportListItemResponse> responses = new ArrayList<>();
        for (ReportListItemRow row : rows) {
            responses.add(toListItemResponse(row));
        }
        return responses;
    }

    @Transactional(readOnly = true)
    public ReportDetailResponse getReportDetail(Long adminUserId, Long reportId) {
        adminAccessService.requireAdmin(adminUserId);
        if (reportId == null || reportId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Report id is required.");
        }

        ReportDetailRow detail = reportMapper.findReportDetail(reportId);
        if (detail == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The report was not found.");
        }

        ReportDetailResponse response = toDetailResponse(detail);
        List<ReportAuditRecord> audits = reportMapper.findAuditHistory(reportId);
        List<ReportAuditItemResponse> auditItems = new ArrayList<>();
        for (ReportAuditRecord audit : audits) {
            auditItems.add(toAuditItemResponse(audit));
        }
        response.setAuditHistory(auditItems);
        return response;
    }

    @Transactional
    public ReportReviewResponse reviewReport(
            Long adminUserId,
            Long reportId,
            ReviewReportRequest request
    ) {
        adminAccessService.requireAdmin(adminUserId);
        if (reportId == null || reportId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Report id is required.");
        }

        ReportRecord report = reportMapper.findReportById(reportId);
        if (report == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The report was not found.");
        }
        if (!REPORT_STATUS_PENDING.equalsIgnoreCase(defaultText(report.getStatus()))) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This report has already been handled.");
        }

        String decision = normalizeDecision(request == null ? null : request.getDecision());
        String punishmentType = normalizePunishmentType(request == null ? null : request.getPunishmentType());
        boolean deleteContent = request != null && Boolean.TRUE.equals(request.getDeleteContent());
        int durationDays = normalizeDurationDays(punishmentType, request == null ? null : request.getDurationDays());
        String reviewReason = normalizeDescription(request == null ? null : request.getReason());

        if (DECISION_REJECT.equals(decision)) {
            deleteContent = false;
            punishmentType = PUNISHMENT_NONE;
            durationDays = 0;
        } else if (PUNISHMENT_NONE.equals(punishmentType) && !deleteContent) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "A violation review must either delete the content or apply a punishment."
            );
        }

        LocalDateTime now = LocalDateTime.now();
        int updated = reportMapper.updateReportHandled(
                reportId,
                DECISION_REJECT.equals(decision) ? REPORT_STATUS_REJECTED : REPORT_STATUS_RESOLVED,
                adminUserId,
                now
        );
        if (updated <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This report has already been handled.");
        }

        if (deleteContent) {
            String deleteReason = reviewReason.isEmpty() ? "Removed after report review." : reviewReason;
            teamMapper.softDeleteTeamChatMessage(report.getTargetId(), deleteReason, now);
        }

        if (!PUNISHMENT_NONE.equals(punishmentType)) {
            PunishmentRecord punishmentRecord = new PunishmentRecord();
            punishmentRecord.setUserId(report.getTargetUserId());
            punishmentRecord.setReportId(reportId);
            punishmentRecord.setPunishmentType(punishmentType);
            punishmentRecord.setStatus("active");
            punishmentRecord.setDurationDays(durationDays);
            punishmentRecord.setReasonText(reviewReason);
            punishmentRecord.setOperatorUserId(adminUserId);
            punishmentRecord.setStartTime(now);
            punishmentRecord.setEndTime(resolvePunishmentEndTime(durationDays, punishmentType, now));
            reportMapper.insertPunishmentRecord(punishmentRecord);
        }

        ReportAuditRecord auditRecord = new ReportAuditRecord();
        auditRecord.setReportId(reportId);
        auditRecord.setAdminUserId(adminUserId);
        auditRecord.setDecision(decision);
        auditRecord.setDeleteContentFlag(deleteContent ? 1 : 0);
        auditRecord.setPunishmentType(punishmentType);
        auditRecord.setDurationDays(durationDays);
        auditRecord.setReasonText(reviewReason);
        reportMapper.insertAuditRecord(auditRecord);

        if (report.getTargetUserId() != null) {
            notificationService.createReportReviewNotification(
                    report.getTargetUserId(),
                    decision,
                    punishmentType,
                    reviewReason,
                    deleteContent
            );
        }

        ReportReviewResponse response = new ReportReviewResponse();
        response.setReportId(reportId);
        response.setStatus(DECISION_REJECT.equals(decision) ? REPORT_STATUS_REJECTED : REPORT_STATUS_RESOLVED);
        response.setDecision(decision);
        response.setMessage(DECISION_REJECT.equals(decision) ? "Report rejected." : "Report handled.");
        return response;
    }

    @Transactional(readOnly = true)
    public List<AdminUserSearchItemResponse> searchUsers(
            Long adminUserId,
            String keyword,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        int normalizedLimit = normalizeLimit(limit);
        List<AdminUserSearchRow> rows = reportMapper.searchUsers(
                defaultText(keyword),
                normalizedLimit
        );
        List<AdminUserSearchItemResponse> responses = new ArrayList<>();
        for (AdminUserSearchRow row : rows) {
            responses.add(toAdminUserSearchItemResponse(row));
        }
        return responses;
    }

    @Transactional(readOnly = true)
    public AdminUserDetailResponse getAdminUserDetail(Long adminUserId, Long userId) {
        adminAccessService.requireAdmin(adminUserId);
        Long normalizedUserId = normalizeUserId(userId);
        AdminUserDetailRow row = reportMapper.findAdminUserDetail(normalizedUserId);
        if (row == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The user was not found.");
        }
        return toAdminUserDetailResponse(row);
    }

    @Transactional(readOnly = true)
    public List<AdminUserReportItemResponse> getAdminUserReports(
            Long adminUserId,
            Long userId,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        Long normalizedUserId = normalizeUserId(userId);
        ensureUserExists(normalizedUserId);
        int normalizedLimit = normalizeLimit(limit);
        List<AdminUserReportRow> rows = reportMapper.findReportsByTargetUserId(
                normalizedUserId,
                normalizedLimit
        );
        List<AdminUserReportItemResponse> responses = new ArrayList<>();
        for (AdminUserReportRow row : rows) {
            responses.add(toAdminUserReportItemResponse(row));
        }
        return responses;
    }

    @Transactional(readOnly = true)
    public List<AdminUserPunishmentItemResponse> getAdminUserPunishments(
            Long adminUserId,
            Long userId,
            String status,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        Long normalizedUserId = normalizeUserId(userId);
        ensureUserExists(normalizedUserId);
        String normalizedStatus = normalizePunishmentHistoryStatus(status);
        int normalizedLimit = normalizeLimit(limit);
        List<AdminUserPunishmentRow> rows = reportMapper.findPunishmentsByUserId(
                normalizedUserId,
                normalizedStatus,
                LocalDateTime.now(),
                normalizedLimit
        );
        List<AdminUserPunishmentItemResponse> responses = new ArrayList<>();
        for (AdminUserPunishmentRow row : rows) {
            responses.add(toAdminUserPunishmentItemResponse(row));
        }
        return responses;
    }

    @Transactional
    public AdminLiftPunishmentResponse liftPunishment(
            Long adminUserId,
            Long userId,
            Long punishmentId
    ) {
        adminAccessService.requireAdmin(adminUserId);
        Long normalizedUserId = normalizeUserId(userId);
        if (punishmentId == null || punishmentId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Punishment id is required.");
        }

        AdminUserPunishmentRow punishment = reportMapper.findPunishmentById(punishmentId);
        if (punishment == null || punishment.getUserId() == null || !punishment.getUserId().equals(normalizedUserId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The punishment was not found.");
        }
        if (defaultNumber(punishment.getActiveFlag()) != 1) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This punishment is no longer active.");
        }

        LocalDateTime now = LocalDateTime.now();
        int updated = reportMapper.liftPunishment(punishmentId, now);
        if (updated <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This punishment is no longer active.");
        }

        notificationService.createPunishmentLiftedNotification(
                punishment.getUserId(),
                punishment.getPunishmentType(),
                punishment.getReasonText()
        );

        AdminLiftPunishmentResponse response = new AdminLiftPunishmentResponse();
        response.setPunishmentId(punishmentId);
        response.setStatus(PUNISHMENT_STATUS_LIFTED);
        response.setMessage("Punishment lifted.");
        return response;
    }

    @Transactional(readOnly = true)
    public void ensureNotMutedForTeamChat(Long userId) {
        if (userId == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        ActivePunishmentRow mute = reportMapper.findActivePunishment(userId, PUNISHMENT_MUTE, now);
        if (mute != null) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    buildMuteMessage(mute)
            );
        }
        ActivePunishmentRow ban = reportMapper.findActivePunishment(userId, PUNISHMENT_BAN, now);
        if (ban != null) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    buildBanMessage(ban)
            );
        }
        User user = userMapper.findUserById(userId);
        if (user != null && defaultNumber(user.getStatus()) == 3) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "This account has been banned.");
        }
    }

    private StudyTeamMember requireActiveMember(Long userId) {
        StudyTeamMember member = teamMapper.findActiveMemberByUserId(userId);
        if (member == null || member.getTeamId() == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Join a team first.");
        }
        StudyTeam team = teamMapper.findActiveTeamById(member.getTeamId());
        if (team == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Join a team first.");
        }
        return member;
    }

    private StudyTeamChatMessageRow requireTeamChatMessage(Long messageId) {
        StudyTeamChatMessageRow row = teamMapper.findTeamChatMessageById(messageId);
        if (row == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected team chat message was not found.");
        }
        return row;
    }

    private ReportListItemResponse toListItemResponse(ReportListItemRow row) {
        ReportListItemResponse response = new ReportListItemResponse();
        response.setReportId(row.getReportId());
        response.setReportType(defaultText(row.getReportType()));
        response.setStatus(defaultText(row.getReportStatus()));
        response.setReason(defaultText(row.getReasonText()));
        response.setReportUserId(row.getReportUserId());
        response.setReportUserDisplayName(resolveDisplayName(row.getReportUserNickname(), row.getReportUserNo(), "Reporter"));
        response.setTargetId(row.getTargetId());
        response.setTargetUserId(row.getTargetUserId());
        response.setTargetUserDisplayName(resolveDisplayName(row.getTargetUserNickname(), row.getTargetUserNo(), "Member"));
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setContentPreview(buildContentPreview(row.getTargetContent()));
        response.setTargetDeleted(defaultNumber(row.getTargetDeletedFlag()) == 1);
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private ReportDetailResponse toDetailResponse(ReportDetailRow row) {
        ReportDetailResponse response = new ReportDetailResponse();
        response.setReportId(row.getReportId());
        response.setReportType(defaultText(row.getReportType()));
        response.setStatus(defaultText(row.getReportStatus()));
        response.setReason(defaultText(row.getReasonText()));
        response.setDescription(defaultText(row.getDescriptionText()));
        response.setReportUserId(row.getReportUserId());
        response.setReportUserDisplayName(resolveDisplayName(row.getReportUserNickname(), row.getReportUserNo(), "Reporter"));
        response.setTargetId(row.getTargetId());
        response.setTargetUserId(row.getTargetUserId());
        response.setTargetUserDisplayName(resolveDisplayName(row.getTargetUserNickname(), row.getTargetUserNo(), "Member"));
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setTargetContent(defaultText(row.getTargetContent()));
        response.setTargetMasked(defaultNumber(row.getTargetMaskedFlag()) == 1);
        response.setTargetDeleted(defaultNumber(row.getTargetDeletedFlag()) == 1);
        response.setTargetDeletedReason(defaultText(row.getTargetDeletedReason()));
        response.setHandledUserId(row.getHandledUserId());
        response.setHandledUserDisplayName(resolveDisplayName(row.getHandledUserNickname(), row.getHandledUserNo(), ""));
        response.setHandledTime(formatDateTime(row.getHandledTime()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private ReportAuditItemResponse toAuditItemResponse(ReportAuditRecord audit) {
        ReportAuditItemResponse response = new ReportAuditItemResponse();
        response.setAuditId(audit.getId());
        response.setDecision(defaultText(audit.getDecision()));
        response.setDeleteContent(defaultNumber(audit.getDeleteContentFlag()) == 1);
        response.setPunishmentType(defaultText(audit.getPunishmentType()));
        response.setDurationDays(defaultNumber(audit.getDurationDays()));
        response.setReason(defaultText(audit.getReasonText()));
        response.setAdminUserId(audit.getAdminUserId());
        User admin = audit.getAdminUserId() == null ? null : userMapper.findUserById(audit.getAdminUserId());
        response.setAdminDisplayName(admin == null
                ? "Admin"
                : resolveDisplayName(admin.getNickname(), admin.getUserNo(), "Admin"));
        response.setCreateTime(formatDateTime(audit.getCreateTime()));
        return response;
    }

    private AdminUserSearchItemResponse toAdminUserSearchItemResponse(AdminUserSearchRow row) {
        AdminUserSearchItemResponse response = new AdminUserSearchItemResponse();
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setDisplayName(resolveDisplayName(row.getNickname(), row.getUserNo(), "User"));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setStatusCode(defaultNumber(row.getStatus()));
        response.setStatusLabel(resolveUserStatusLabel(row.getStatus()));
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setLastLoginTime(formatDateTime(row.getLastLoginTime()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private AdminUserDetailResponse toAdminUserDetailResponse(AdminUserDetailRow row) {
        AdminUserDetailResponse response = new AdminUserDetailResponse();
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setDisplayName(resolveDisplayName(row.getNickname(), row.getUserNo(), "User"));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setEmail(defaultText(row.getEmail()));
        response.setStatusCode(defaultNumber(row.getStatus()));
        response.setStatusLabel(resolveUserStatusLabel(row.getStatus()));
        response.setBio(defaultText(row.getBio()));
        response.setTimezone(defaultText(row.getTimezone()));
        response.setAllowFriendViewProfile(defaultNumber(row.getAllowFriendViewProfile()) == 1);
        response.setAllowTeammateViewStudy(defaultNumber(row.getAllowTeammateViewStudy()) == 1);
        response.setAllowStrangerMessage(defaultNumber(row.getAllowStrangerMessage()) == 1);
        response.setTotalStudyMinutes(Math.max(defaultNumber(row.getTotalStudySeconds()) / 60, 0));
        response.setTotalCheckInDays(defaultNumber(row.getTotalCheckInDays()));
        response.setConsecutiveCheckInDays(defaultNumber(row.getConsecutiveCheckInDays()));
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setTeamInviteCode(defaultText(row.getTeamInviteCode()));
        response.setTeamRole(defaultText(row.getTeamRole()));
        response.setTeamJoinedTime(formatDateTime(row.getTeamJoinedTime()));
        response.setLastLoginTime(formatDateTime(row.getLastLoginTime()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private AdminUserReportItemResponse toAdminUserReportItemResponse(AdminUserReportRow row) {
        AdminUserReportItemResponse response = new AdminUserReportItemResponse();
        response.setReportId(row.getReportId());
        response.setReportType(defaultText(row.getReportType()));
        response.setStatus(defaultText(row.getReportStatus()));
        response.setReason(defaultText(row.getReasonText()));
        response.setDescription(defaultText(row.getDescriptionText()));
        response.setReportUserId(row.getReportUserId());
        response.setReportUserDisplayName(
                resolveDisplayName(row.getReportUserNickname(), row.getReportUserNo(), "Reporter")
        );
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setContentPreview(buildContentPreview(row.getTargetContent()));
        response.setTargetDeleted(defaultNumber(row.getTargetDeletedFlag()) == 1);
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private AdminUserPunishmentItemResponse toAdminUserPunishmentItemResponse(AdminUserPunishmentRow row) {
        AdminUserPunishmentItemResponse response = new AdminUserPunishmentItemResponse();
        response.setPunishmentId(row.getPunishmentId());
        response.setReportId(row.getReportId());
        response.setPunishmentType(defaultText(row.getPunishmentType()));
        response.setStatus(defaultText(row.getStatus()));
        response.setActive(defaultNumber(row.getActiveFlag()) == 1);
        response.setLiftable(defaultNumber(row.getActiveFlag()) == 1);
        response.setDurationDays(defaultNumber(row.getDurationDays()));
        response.setReason(defaultText(row.getReasonText()));
        response.setOperatorUserId(row.getOperatorUserId());
        response.setOperatorDisplayName(
                resolveDisplayName(row.getOperatorUserNickname(), row.getOperatorUserNo(), "Admin")
        );
        response.setStartTime(formatDateTime(row.getStartTime()));
        response.setEndTime(formatDateTime(row.getEndTime()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private String normalizeReason(String value) {
        String normalized = defaultText(value);
        if (normalized.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Report reason is required.");
        }
        if (normalized.length() > 120) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Report reason must be 120 characters or fewer.");
        }
        return normalized;
    }

    private String normalizeDescription(String value) {
        String normalized = defaultText(value);
        if (normalized.length() > 255) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Text must be 255 characters or fewer.");
        }
        return normalized;
    }

    private String normalizeDecision(String value) {
        String normalized = defaultText(value).toLowerCase(Locale.ROOT);
        if (!DECISION_REJECT.equals(normalized) && !DECISION_VIOLATION.equals(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Decision must be reject or violation.");
        }
        return normalized;
    }

    private String normalizePunishmentType(String value) {
        String normalized = defaultText(value).toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            normalized = PUNISHMENT_NONE;
        }
        if (!PUNISHMENT_NONE.equals(normalized)
                && !PUNISHMENT_WARN.equals(normalized)
                && !PUNISHMENT_MUTE.equals(normalized)
                && !PUNISHMENT_BAN.equals(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported punishment type.");
        }
        return normalized;
    }

    private int normalizeDurationDays(String punishmentType, Integer durationDays) {
        if (PUNISHMENT_MUTE.equals(punishmentType) || PUNISHMENT_BAN.equals(punishmentType)) {
            int normalized = durationDays == null ? 0 : Math.max(durationDays, 0);
            if (normalized <= 0) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "Mute or ban must have a positive duration in days."
                );
            }
            return normalized;
        }
        return 0;
    }

    private int normalizeLimit(Integer limit) {
        if (limit == null) {
            return 50;
        }
        if (limit < 1 || limit > 200) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Limit must be between 1 and 200.");
        }
        return limit;
    }

    private String normalizeOptionalStatus(String status) {
        String normalized = defaultText(status).toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            return "";
        }
        if (!REPORT_STATUS_PENDING.equals(normalized)
                && !REPORT_STATUS_REJECTED.equals(normalized)
                && !REPORT_STATUS_RESOLVED.equals(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported report status.");
        }
        return normalized;
    }

    private String normalizePunishmentHistoryStatus(String status) {
        String normalized = defaultText(status).toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            return "";
        }
        if (!PUNISHMENT_STATUS_ACTIVE.equals(normalized) && !"history".equals(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported punishment status filter.");
        }
        return normalized;
    }

    private Long normalizeUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "User id is required.");
        }
        return userId;
    }

    private void ensureUserExists(Long userId) {
        User user = userMapper.findUserById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The user was not found.");
        }
    }

    private String normalizeOptionalType(String reportType) {
        String normalized = defaultText(reportType).toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            return "";
        }
        if (!REPORT_TYPE_TEAM_CHAT.equals(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported report type.");
        }
        return normalized;
    }

    private LocalDateTime resolvePunishmentEndTime(int durationDays, String punishmentType, LocalDateTime startTime) {
        if (PUNISHMENT_WARN.equals(punishmentType) || PUNISHMENT_NONE.equals(punishmentType)) {
            return startTime;
        }
        if (durationDays <= 0) {
            return null;
        }
        return startTime.plusDays(durationDays);
    }

    private String resolveDisplayName(String nickname, String userNo, String fallback) {
        String normalizedNickname = defaultText(nickname);
        if (!normalizedNickname.isEmpty()) {
            return normalizedNickname;
        }
        String normalizedUserNo = defaultText(userNo);
        if (!normalizedUserNo.isEmpty()) {
            return normalizedUserNo;
        }
        return fallback;
    }

    private String buildContentPreview(String value) {
        String content = defaultText(value);
        if (content.length() > 60) {
            return content.substring(0, 60) + "...";
        }
        return content;
    }

    private String buildMuteMessage(ActivePunishmentRow mute) {
        if (mute.getEndTime() == null) {
            return "You are muted and cannot send team chat messages right now.";
        }
        return "You are muted until " + formatDateTime(mute.getEndTime()) + ".";
    }

    private String buildBanMessage(ActivePunishmentRow ban) {
        if (ban.getEndTime() == null) {
            return "This account has been banned.";
        }
        return "This account is banned until " + formatDateTime(ban.getEndTime()) + ".";
    }

    private String resolveUserStatusLabel(Integer status) {
        int normalizedStatus = defaultNumber(status);
        if (normalizedStatus == 1) {
            return "active";
        }
        if (normalizedStatus == 3) {
            return "banned";
        }
        if (normalizedStatus == 4) {
            return "cancelled";
        }
        return "inactive";
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
