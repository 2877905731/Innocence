package com.innocence.server.modules.team.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.report.service.ReportService;
import com.innocence.server.modules.team.domain.StudyTeam;
import com.innocence.server.modules.team.domain.StudyTeamChatMessage;
import com.innocence.server.modules.team.domain.StudyTeamChatMessageRow;
import com.innocence.server.modules.team.domain.StudyTeamInvitation;
import com.innocence.server.modules.team.domain.StudyTeamMember;
import com.innocence.server.modules.team.domain.StudyTeamReminder;
import com.innocence.server.modules.team.domain.TeammateStatsRow;
import com.innocence.server.modules.team.dto.request.CreateTeamInvitationRequest;
import com.innocence.server.modules.team.dto.request.SendTeamChatMessageRequest;
import com.innocence.server.modules.team.dto.request.RespondTeamInvitationRequest;
import com.innocence.server.modules.team.dto.response.TeammateReminderResponse;
import com.innocence.server.modules.team.dto.response.TeamChatMessageResponse;
import com.innocence.server.modules.team.dto.response.TeamChatOverviewResponse;
import com.innocence.server.modules.team.dto.response.TeammateStatsResponse;
import com.innocence.server.modules.team.dto.request.CreateTeamRequest;
import com.innocence.server.modules.team.dto.request.JoinTeamRequest;
import com.innocence.server.modules.team.dto.response.TeamMemberResponse;
import com.innocence.server.modules.team.dto.response.TeamOverviewResponse;
import com.innocence.server.modules.team.mapper.TeamMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class TeamService {

    private static final int MAX_REMINDERS_PER_DAY = 5;
    private static final int MAX_TEAM_MEMBER_COUNT = 5;
    private static final int INVITE_CODE_LENGTH = 8;
    private static final int TEAM_CHAT_DAYS = 30;
    private static final int TEAM_CHAT_DEFAULT_LIMIT = 50;
    private static final int TEAM_CHAT_MAX_LIMIT = 100;
    private static final String OWNER_ROLE = "owner";
    private static final String MEMBER_ROLE = "member";
    private static final String INVITATION_STATUS_PENDING = "pending";
    private static final String INVITATION_STATUS_ACCEPTED = "accepted";
    private static final String INVITATION_STATUS_REJECTED = "rejected";
    private static final String REMINDER_TYPE_STUDY = "study";
    private static final String REMINDER_CONTENT = "Your teammate sent a study reminder.";
    private static final int ACTIVE_STATUS = 1;
    private static final int INACTIVE_STATUS = 0;
    private static final String INVITE_CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final String MASK_TOKEN = "***";
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final List<String> BLOCKED_CHAT_WORDS = List.of(
            "fuck",
            "shit",
            "sb",
            "傻逼",
            "妈的",
            "操",
            "滚"
    );
    private static final List<String> REPLACE_ONLY_WORDS = List.of(
            "加微信",
            "vx",
            "v信"
    );

    private final TeamMapper teamMapper;
    private final UserMapper userMapper;
    private final FriendMapper friendMapper;
    private final NotificationService notificationService;
    private final ReportService reportService;

    public TeamService(
            TeamMapper teamMapper,
            UserMapper userMapper,
            FriendMapper friendMapper,
            NotificationService notificationService,
            ReportService reportService
    ) {
        this.teamMapper = teamMapper;
        this.userMapper = userMapper;
        this.friendMapper = friendMapper;
        this.notificationService = notificationService;
        this.reportService = reportService;
    }

    @Transactional(readOnly = true)
    public TeamOverviewResponse getCurrentTeam(Long userId) {
        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember == null || currentMember.getTeamId() == null) {
            return emptyTeamOverview();
        }

        StudyTeam team = teamMapper.findActiveTeamById(currentMember.getTeamId());
        if (team == null) {
            return emptyTeamOverview();
        }

        return buildTeamOverview(userId, team);
    }

    @Transactional(readOnly = true)
    public List<TeammateStatsResponse> getTeammateStats(Long userId) {
        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember == null || currentMember.getTeamId() == null) {
            return List.of();
        }
        StudyTeam team = teamMapper.findActiveTeamById(currentMember.getTeamId());
        if (team == null) {
            return List.of();
        }

        LocalDate today = LocalDate.now();
        LocalDateTime rangeStart = today.atStartOfDay();
        LocalDateTime rangeEnd = rangeStart.plusDays(1);

        List<TeammateStatsRow> rows = teamMapper.findActiveTeammateStats(
                currentMember.getTeamId(),
                userId,
                today,
                rangeStart,
                rangeEnd
        );

        List<TeammateStatsResponse> responses = new ArrayList<>();
        for (TeammateStatsRow row : rows) {
            responses.add(toTeammateResponse(row));
        }
        return responses;
    }

    @Transactional
    public TeamOverviewResponse createTeam(Long userId, CreateTeamRequest request) {
        ensureNotInActiveTeam(userId);

        String teamName = normalizeTeamName(request == null ? null : request.getTeamName());

        StudyTeam team = new StudyTeam();
        team.setTeamName(teamName);
        team.setInviteCode(generateInviteCode());
        team.setOwnerUserId(userId);
        team.setStatus(ACTIVE_STATUS);
        teamMapper.insertTeam(team);

        StudyTeamMember ownerMember = new StudyTeamMember();
        ownerMember.setTeamId(team.getId());
        ownerMember.setUserId(userId);
        ownerMember.setRole(OWNER_ROLE);
        ownerMember.setStatus(ACTIVE_STATUS);
        teamMapper.insertTeamMember(ownerMember);

        return buildTeamOverview(userId, team);
    }

    @Transactional
    public TeamOverviewResponse joinTeam(Long userId, JoinTeamRequest request) {
        ensureNotInActiveTeam(userId);

        String inviteCode = normalizeInviteCode(request == null ? null : request.getInviteCode());
        StudyTeam team = teamMapper.findActiveTeamByInviteCode(inviteCode);
        if (team == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The invite code is invalid or expired.");
        }

        List<StudyTeamMember> activeMembers = teamMapper.findActiveMembersByTeamId(team.getId());
        if (activeMembers.size() >= MAX_TEAM_MEMBER_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This team already has 5 members. Try another invite code."
            );
        }

        StudyTeamMember member = new StudyTeamMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setRole(MEMBER_ROLE);
        member.setStatus(ACTIVE_STATUS);
        teamMapper.insertTeamMember(member);

        return buildTeamOverview(userId, team);
    }

    @Transactional
    public TeamOverviewResponse inviteMember(Long userId, CreateTeamInvitationRequest request) {
        Long targetUserId = request == null ? null : request.getTargetUserId();
        if (targetUserId == null || targetUserId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Target user is required.");
        }
        if (targetUserId.equals(userId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You cannot invite yourself.");
        }

        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());
        ensureOwner(userId, team);
        requireActiveUser(targetUserId);

        if (teamMapper.findActiveMemberByUserId(targetUserId) != null) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This user is already in a team and cannot be invited right now."
            );
        }
        if (teamMapper.findActiveMemberByTeamIdAndUserId(team.getId(), targetUserId) != null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This user is already in your team.");
        }

        List<StudyTeamMember> activeMembers = teamMapper.findActiveMembersByTeamId(team.getId());
        if (activeMembers.size() >= MAX_TEAM_MEMBER_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This team already has 5 members. Remove someone before inviting more."
            );
        }

        if (defaultNumber(friendMapper.countBlacklistRelation(userId, targetUserId)) > 0
                || defaultNumber(friendMapper.countBlacklistRelation(targetUserId, userId)) > 0) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This user is not available for team invitations."
            );
        }

        StudyTeamInvitation existingInvitation = teamMapper.findPendingInvitationByTeamIdAndInviteeUserId(
                team.getId(),
                targetUserId
        );
        if (existingInvitation != null) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "A team invitation is already waiting for this user."
            );
        }

        StudyTeamInvitation invitation = new StudyTeamInvitation();
        invitation.setTeamId(team.getId());
        invitation.setInviterUserId(userId);
        invitation.setInviteeUserId(targetUserId);
        invitation.setStatus(INVITATION_STATUS_PENDING);
        invitation.setCreateTime(LocalDateTime.now());
        teamMapper.insertTeamInvitation(invitation);

        notificationService.createTeamInvitationNotification(
                userId,
                targetUserId,
                invitation.getId(),
                team.getTeamName()
        );

        return buildTeamOverview(userId, team);
    }

    @Transactional
    public TeamOverviewResponse respondInvitation(
            Long userId,
            Long invitationId,
            RespondTeamInvitationRequest request
    ) {
        if (invitationId == null || invitationId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Team invitation id is required.");
        }

        StudyTeamInvitation invitation = teamMapper.findTeamInvitationById(invitationId);
        if (invitation == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The team invitation was not found.");
        }
        if (!userId.equals(invitation.getInviteeUserId())) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "You can respond only to your own team invitations.");
        }
        if (!INVITATION_STATUS_PENDING.equalsIgnoreCase(defaultText(invitation.getStatus()))) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This team invitation has already been handled.");
        }

        boolean accept = request != null && Boolean.TRUE.equals(request.getAccept());
        if (!accept) {
            teamMapper.updateTeamInvitationStatusById(invitationId, INVITATION_STATUS_REJECTED);
            return getCurrentTeam(userId);
        }

        ensureNotInActiveTeam(userId);
        StudyTeam team = requireActiveTeam(invitation.getTeamId());
        List<StudyTeamMember> activeMembers = teamMapper.findActiveMembersByTeamId(team.getId());
        if (activeMembers.size() >= MAX_TEAM_MEMBER_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This team is already full. Ask the captain to free a spot first."
            );
        }

        StudyTeamMember member = new StudyTeamMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setRole(MEMBER_ROLE);
        member.setStatus(ACTIVE_STATUS);
        teamMapper.insertTeamMember(member);
        teamMapper.updateTeamInvitationStatusById(invitationId, INVITATION_STATUS_ACCEPTED);
        return buildTeamOverview(userId, team);
    }

    @Transactional
    public boolean removeMember(Long userId, Long memberUserId) {
        if (memberUserId == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Member user id is required.");
        }
        if (memberUserId.equals(userId)) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Use team dissolve instead of removing yourself as the captain."
            );
        }

        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());
        ensureOwner(userId, team);

        StudyTeamMember targetMember = teamMapper.findActiveMemberByTeamIdAndUserId(team.getId(), memberUserId);
        if (targetMember == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected member is not in your team.");
        }
        if (OWNER_ROLE.equalsIgnoreCase(defaultText(targetMember.getRole()))) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "The team captain cannot be removed.");
        }

        return teamMapper.updateTeamMemberStatus(team.getId(), memberUserId, INACTIVE_STATUS) > 0;
    }

    @Transactional
    public boolean dissolveTeam(Long userId) {
        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());
        ensureOwner(userId, team);

        int updatedTeamCount = teamMapper.updateTeamStatus(team.getId(), INACTIVE_STATUS);
        teamMapper.updateTeamMembersStatusByTeamId(team.getId(), INACTIVE_STATUS);
        return updatedTeamCount > 0;
    }

    @Transactional
    public TeammateReminderResponse remindTeammate(Long userId, Long teammateUserId) {
        if (teammateUserId == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Teammate user id is required.");
        }
        if (teammateUserId.equals(userId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You cannot remind yourself.");
        }

        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember == null || currentMember.getTeamId() == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Join a team first before sending reminders.");
        }
        StudyTeam team = teamMapper.findActiveTeamById(currentMember.getTeamId());
        if (team == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Join a team first before sending reminders.");
        }

        StudyTeamMember teammateMember = teamMapper.findActiveMemberByTeamIdAndUserId(
                currentMember.getTeamId(),
                teammateUserId
        );
        if (teammateMember == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The teammate was not found in your current team.");
        }

        LocalDate today = LocalDate.now();
        LocalDateTime rangeStart = today.atStartOfDay();
        LocalDateTime rangeEnd = rangeStart.plusDays(1);
        int reminderCountToday = defaultNumber(
                teamMapper.countRemindersSentToday(
                        currentMember.getTeamId(),
                        userId,
                        teammateUserId,
                        rangeStart,
                        rangeEnd
                )
        );
        if (reminderCountToday >= MAX_REMINDERS_PER_DAY) {
            throw new BusinessException(
                    ErrorCode.TOO_MANY_REQUESTS,
                    "You have already reminded this teammate 5 times today."
            );
        }

        StudyTeamReminder reminder = new StudyTeamReminder();
        reminder.setTeamId(currentMember.getTeamId());
        reminder.setFromUserId(userId);
        reminder.setToUserId(teammateUserId);
        reminder.setReminderType(REMINDER_TYPE_STUDY);
        reminder.setContent(REMINDER_CONTENT);
        reminder.setCreateTime(LocalDateTime.now());
        teamMapper.insertReminder(reminder);
        notificationService.createTeamReminderNotification(userId, teammateUserId);

        TeammateReminderResponse response = new TeammateReminderResponse();
        response.setSuccess(true);
        response.setMessage("Reminder sent.");
        response.setReminderCountToday(reminderCountToday + 1);
        return response;
    }

    @Transactional(readOnly = true)
    public TeamChatOverviewResponse getTeamChatMessages(Long userId, Integer limit) {
        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());

        int normalizedLimit = normalizeChatLimit(limit);
        LocalDateTime sinceTime = LocalDateTime.now().minusDays(TEAM_CHAT_DAYS);
        List<StudyTeamChatMessageRow> rows = teamMapper.findRecentTeamChatMessages(
                team.getId(),
                sinceTime,
                normalizedLimit
        );

        TeamChatOverviewResponse response = new TeamChatOverviewResponse();
        response.setTeamId(team.getId());
        response.setTeamName(defaultText(team.getTeamName()));
        response.setUnreadCount(defaultNumber(
                teamMapper.countUnreadTeamChatMessages(team.getId(), userId, sinceTime)
        ));

        List<TeamChatMessageResponse> items = new ArrayList<>();
        for (StudyTeamChatMessageRow row : rows) {
            items.add(toTeamChatMessageResponse(row, userId));
        }
        Collections.reverse(items);
        response.setMessages(items);
        return response;
    }

    @Transactional
    public TeamChatOverviewResponse sendTeamChatMessage(
            Long userId,
            SendTeamChatMessageRequest request
    ) {
        reportService.ensureNotMutedForTeamChat(userId);
        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());

        ChatContentResult chatContent = normalizeChatContent(
                request == null ? null : request.getContent()
        );

        StudyTeamChatMessage message = new StudyTeamChatMessage();
        message.setTeamId(team.getId());
        message.setSenderUserId(userId);
        message.setContent(chatContent.content());
        message.setMaskedFlag(chatContent.masked() ? 1 : 0);
        message.setDeletedFlag(0);
        message.setCreateTime(LocalDateTime.now());
        teamMapper.insertTeamChatMessage(message);
        teamMapper.upsertTeamChatReadState(team.getId(), userId, message.getId());

        List<StudyTeamMember> members = teamMapper.findActiveMembersByTeamId(team.getId());
        for (StudyTeamMember member : members) {
            if (member == null || member.getUserId() == null || member.getUserId().equals(userId)) {
                continue;
            }
            if (defaultNumber(member.getStatus()) != ACTIVE_STATUS) {
                continue;
            }
            notificationService.createTeamChatNotification(
                    userId,
                    member.getUserId(),
                    message.getId(),
                    chatContent.content()
            );
        }

        return getTeamChatMessages(userId, TEAM_CHAT_DEFAULT_LIMIT);
    }

    @Transactional
    public TeamChatOverviewResponse markTeamChatRead(Long userId) {
        StudyTeamMember currentMember = requireActiveMember(userId);
        StudyTeam team = requireActiveTeam(currentMember.getTeamId());

        LocalDateTime sinceTime = LocalDateTime.now().minusDays(TEAM_CHAT_DAYS);
        List<StudyTeamChatMessageRow> rows = teamMapper.findRecentTeamChatMessages(
                team.getId(),
                sinceTime,
                1
        );
        if (!rows.isEmpty()) {
            teamMapper.upsertTeamChatReadState(team.getId(), userId, rows.get(0).getId());
        }
        return getTeamChatMessages(userId, TEAM_CHAT_DEFAULT_LIMIT);
    }

    private TeamOverviewResponse buildTeamOverview(Long currentUserId, StudyTeam team) {
        LocalDate today = LocalDate.now();
        LocalDateTime rangeStart = today.atStartOfDay();
        LocalDateTime rangeEnd = rangeStart.plusDays(1);
        LocalDateTime chatSinceTime = LocalDateTime.now().minusDays(TEAM_CHAT_DAYS);

        List<TeammateStatsRow> rows = teamMapper.findActiveTeamMemberStats(
                team.getId(),
                currentUserId,
                today,
                rangeStart,
                rangeEnd
        );

        TeamOverviewResponse response = new TeamOverviewResponse();
        response.setInTeam(true);
        response.setTeamId(team.getId());
        response.setTeamName(defaultText(team.getTeamName()));
        response.setInviteCode(defaultText(team.getInviteCode()));
        response.setOwnerUserId(team.getOwnerUserId());
        response.setOwner(team.getOwnerUserId() != null && team.getOwnerUserId().equals(currentUserId));
        response.setMemberLimit(MAX_TEAM_MEMBER_COUNT);
        response.setUnreadChatCount(defaultNumber(
                teamMapper.countUnreadTeamChatMessages(team.getId(), currentUserId, chatSinceTime)
        ));

        List<StudyTeamChatMessageRow> latestMessages = teamMapper.findRecentTeamChatMessages(
                team.getId(),
                chatSinceTime,
                1
        );
        if (!latestMessages.isEmpty()) {
            response.setLatestChatPreview(buildLatestChatPreview(latestMessages.get(0)));
        } else {
            response.setLatestChatPreview("");
        }

        List<TeamMemberResponse> members = new ArrayList<>();
        for (TeammateStatsRow row : rows) {
            members.add(toTeamMemberResponse(row, team.getOwnerUserId()));
        }
        response.setMembers(members);
        return response;
    }

    private TeamChatMessageResponse toTeamChatMessageResponse(
            StudyTeamChatMessageRow row,
            Long currentUserId
    ) {
        TeamChatMessageResponse response = new TeamChatMessageResponse();
        response.setMessageId(row.getId());
        response.setSenderUserId(row.getSenderUserId());
        response.setSenderUserNo(defaultText(row.getSenderUserNo()));
        response.setSenderNickname(defaultText(row.getSenderNickname()));
        response.setSenderAvatarUrl(defaultText(row.getSenderAvatarUrl()));
        boolean deleted = defaultNumber(row.getDeletedFlag()) == 1;
        response.setContent(deleted ? "This message was removed by an administrator." : defaultText(row.getContent()));
        response.setMasked(defaultNumber(row.getMaskedFlag()) == 1);
        response.setDeleted(deleted);
        response.setDeletedReason(defaultText(row.getDeletedReason()));
        response.setOwnMessage(
                currentUserId != null
                        && row.getSenderUserId() != null
                        && row.getSenderUserId().equals(currentUserId)
        );
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private TeammateStatsResponse toTeammateResponse(TeammateStatsRow row) {
        TeammateStatsResponse response = new TeammateStatsResponse();
        response.setTeamId(row.getTeamId());
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setAllowStudyView(defaultNumber(row.getAllowTeammateViewStudy()) != 0);
        response.setTotalStudyDurationMinutes(defaultNumber(row.getStudyDurationTotalMinutes()));
        response.setTotalCheckInDays(defaultNumber(row.getCheckInDaysTotal()));
        response.setTodayCompletedCount(defaultNumber(row.getTodayCompletedCount()));
        response.setTodayTotalCount(defaultNumber(row.getTodayTotalCount()));
        response.setTodayStudyDurationMinutes(defaultNumber(row.getTodayStudyDurationMinutes()));
        response.setActiveStudy(defaultNumber(row.getActiveStudyFlag()) != 0);
        response.setActiveTaskName(defaultText(row.getActiveTaskName()));
        response.setActiveStageName(defaultText(row.getActiveStageName()));
        response.setReminderCountToday(defaultNumber(row.getReminderCountToday()));
        response.setRemindable(defaultNumber(row.getReminderCountToday()) < MAX_REMINDERS_PER_DAY);
        return response;
    }

    private TeamMemberResponse toTeamMemberResponse(TeammateStatsRow row, Long ownerUserId) {
        TeamMemberResponse response = new TeamMemberResponse();
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setRole(row.getUserId() != null && row.getUserId().equals(ownerUserId) ? OWNER_ROLE : MEMBER_ROLE);
        response.setAllowStudyView(defaultNumber(row.getAllowTeammateViewStudy()) != 0);
        response.setTotalStudyDurationMinutes(defaultNumber(row.getStudyDurationTotalMinutes()));
        response.setTotalCheckInDays(defaultNumber(row.getCheckInDaysTotal()));
        response.setTodayCompletedCount(defaultNumber(row.getTodayCompletedCount()));
        response.setTodayTotalCount(defaultNumber(row.getTodayTotalCount()));
        response.setTodayStudyDurationMinutes(defaultNumber(row.getTodayStudyDurationMinutes()));
        response.setActiveStudy(defaultNumber(row.getActiveStudyFlag()) != 0);
        response.setActiveTaskName(defaultText(row.getActiveTaskName()));
        response.setActiveStageName(defaultText(row.getActiveStageName()));
        response.setOwner(row.getUserId() != null && row.getUserId().equals(ownerUserId));
        return response;
    }

    private void ensureNotInActiveTeam(Long userId) {
        StudyTeamMember currentMember = teamMapper.findActiveMemberByUserId(userId);
        if (currentMember != null && currentMember.getTeamId() != null) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "You can join only one team at a time. Leave the current team first."
            );
        }
    }

    private StudyTeamMember requireActiveMember(Long userId) {
        StudyTeamMember member = teamMapper.findActiveMemberByUserId(userId);
        if (member == null || member.getTeamId() == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Join a team first.");
        }
        return member;
    }

    private StudyTeam requireActiveTeam(Long teamId) {
        StudyTeam team = teamMapper.findActiveTeamById(teamId);
        if (team == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The current team was not found.");
        }
        return team;
    }

    private void ensureOwner(Long userId, StudyTeam team) {
        if (team.getOwnerUserId() == null || !team.getOwnerUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "Only the team captain can do this.");
        }
    }

    private User requireActiveUser(Long userId) {
        User user = userMapper.findUserById(userId);
        if (user == null || defaultNumber(user.getStatus()) != ACTIVE_STATUS) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected user was not found.");
        }
        return user;
    }

    private String generateInviteCode() {
        for (int attempt = 0; attempt < 20; attempt++) {
            String inviteCode = randomInviteCode();
            if (teamMapper.findTeamByInviteCode(inviteCode) == null) {
                return inviteCode;
            }
        }
        throw new BusinessException(ErrorCode.INTERNAL_ERROR, "Failed to generate a team invite code.");
    }

    private String randomInviteCode() {
        StringBuilder builder = new StringBuilder(INVITE_CODE_LENGTH);
        ThreadLocalRandom random = ThreadLocalRandom.current();
        for (int index = 0; index < INVITE_CODE_LENGTH; index++) {
            int next = random.nextInt(INVITE_CODE_CHARS.length());
            builder.append(INVITE_CODE_CHARS.charAt(next));
        }
        return builder.toString();
    }

    private String normalizeTeamName(String value) {
        String teamName = defaultText(value);
        if (teamName.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Team name is required.");
        }
        return teamName;
    }

    private String normalizeInviteCode(String value) {
        String inviteCode = defaultText(value).toUpperCase(Locale.ROOT);
        if (inviteCode.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Invite code is required.");
        }
        return inviteCode;
    }

    private TeamOverviewResponse emptyTeamOverview() {
        TeamOverviewResponse response = new TeamOverviewResponse();
        response.setInTeam(false);
        response.setMemberLimit(MAX_TEAM_MEMBER_COUNT);
        response.setUnreadChatCount(0);
        response.setLatestChatPreview("");
        return response;
    }

    private int normalizeChatLimit(Integer value) {
        if (value == null) {
            return TEAM_CHAT_DEFAULT_LIMIT;
        }
        if (value < 1 || value > TEAM_CHAT_MAX_LIMIT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Chat limit must be between 1 and 100."
            );
        }
        return value;
    }

    private ChatContentResult normalizeChatContent(String value) {
        String normalized = defaultText(value);
        if (normalized.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Message content is required.");
        }
        if (normalized.length() > 500) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Message content must be 500 characters or fewer."
            );
        }

        String lowerCase = normalized.toLowerCase(Locale.ROOT);
        for (String word : BLOCKED_CHAT_WORDS) {
            if (word.isBlank()) {
                continue;
            }
            if (lowerCase.contains(word.toLowerCase(Locale.ROOT))) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "This message contains blocked content and cannot be sent."
                );
            }
        }

        boolean masked = false;
        String maskedContent = normalized;
        for (String word : REPLACE_ONLY_WORDS) {
            if (word.isBlank()) {
                continue;
            }
            if (maskedContent.toLowerCase(Locale.ROOT).contains(word.toLowerCase(Locale.ROOT))) {
                masked = true;
                maskedContent = replaceIgnoreCase(maskedContent, word, MASK_TOKEN);
            }
        }

        return new ChatContentResult(maskedContent, masked);
    }

    private String replaceIgnoreCase(String source, String target, String replacement) {
        if (source.isEmpty() || target.isEmpty()) {
            return source;
        }
        String working = source;
        String lowerSource = working.toLowerCase(Locale.ROOT);
        String lowerTarget = target.toLowerCase(Locale.ROOT);
        int index = lowerSource.indexOf(lowerTarget);
        while (index >= 0) {
            working = working.substring(0, index)
                    + replacement
                    + working.substring(index + target.length());
            lowerSource = working.toLowerCase(Locale.ROOT);
            index = lowerSource.indexOf(lowerTarget, index + replacement.length());
        }
        return working;
    }

    private String buildLatestChatPreview(StudyTeamChatMessageRow row) {
        String sender = defaultText(row.getSenderNickname());
        if (sender.isEmpty()) {
            sender = defaultText(row.getSenderUserNo());
        }
        if (sender.isEmpty()) {
            sender = "Teammate";
        }
        String content = defaultText(row.getContent());
        if (content.length() > 40) {
            content = content.substring(0, 40) + "...";
        }
        return sender + ": " + content;
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

    private record ChatContentResult(String content, boolean masked) {
    }
}
