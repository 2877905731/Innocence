package com.innocence.server.modules.team.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.report.service.AdminAccessService;
import com.innocence.server.modules.team.domain.AdminTeamSearchRow;
import com.innocence.server.modules.team.domain.StudyTeam;
import com.innocence.server.modules.team.domain.StudyTeamChatMessageRow;
import com.innocence.server.modules.team.domain.StudyTeamMember;
import com.innocence.server.modules.team.domain.TeammateStatsRow;
import com.innocence.server.modules.team.dto.response.AdminTeamActionResponse;
import com.innocence.server.modules.team.dto.response.AdminTeamDetailResponse;
import com.innocence.server.modules.team.dto.response.AdminTeamListItemResponse;
import com.innocence.server.modules.team.dto.response.TeamMemberResponse;
import com.innocence.server.modules.team.mapper.TeamMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class AdminTeamManagementService {

    private static final int MEMBER_LIMIT = 5;
    private static final int ACTIVE_STATUS = 1;
    private static final int INACTIVE_STATUS = 0;
    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 200;
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final TeamMapper teamMapper;
    private final AdminAccessService adminAccessService;

    public AdminTeamManagementService(
            TeamMapper teamMapper,
            AdminAccessService adminAccessService
    ) {
        this.teamMapper = teamMapper;
        this.adminAccessService = adminAccessService;
    }

    @Transactional(readOnly = true)
    public List<AdminTeamListItemResponse> searchTeams(
            Long adminUserId,
            String keyword,
            Integer status,
            Integer limit
    ) {
        adminAccessService.requireAdmin(adminUserId);
        Integer normalizedStatus = normalizeOptionalStatus(status);
        int normalizedLimit = normalizeLimit(limit);
        List<AdminTeamSearchRow> rows = teamMapper.searchTeams(
                defaultText(keyword),
                normalizedStatus,
                normalizedLimit
        );
        List<AdminTeamListItemResponse> responses = new ArrayList<>();
        for (AdminTeamSearchRow row : rows) {
            responses.add(toListItemResponse(row));
        }
        return responses;
    }

    @Transactional(readOnly = true)
    public AdminTeamDetailResponse getTeamDetail(Long adminUserId, Long teamId) {
        adminAccessService.requireAdmin(adminUserId);
        StudyTeam team = requireTeam(teamId);

        LocalDate today = LocalDate.now();
        LocalDateTime rangeStart = today.atStartOfDay();
        LocalDateTime rangeEnd = rangeStart.plusDays(1);

        List<TeammateStatsRow> rows = teamMapper.findActiveTeamMemberStats(
                team.getId(),
                team.getOwnerUserId(),
                today,
                rangeStart,
                rangeEnd
        );

        AdminTeamDetailResponse response = new AdminTeamDetailResponse();
        response.setTeamId(team.getId());
        response.setTeamName(defaultText(team.getTeamName()));
        response.setInviteCode(defaultText(team.getInviteCode()));
        response.setOwnerUserId(team.getOwnerUserId());
        response.setOwnerDisplayName(resolveDisplayName(
                findOwnerNo(rows, team.getOwnerUserId()),
                findOwnerNickname(rows, team.getOwnerUserId())
        ));
        response.setStatusCode(defaultNumber(team.getStatus()));
        response.setStatusLabel(resolveStatusLabel(team.getStatus()));
        response.setMemberLimit(MEMBER_LIMIT);
        response.setMemberCount(rows.size());
        response.setLatestChatPreview(loadLatestChatPreview(team.getId()));
        response.setCreateTime(formatDateTime(team.getCreateTime()));

        List<TeamMemberResponse> members = new ArrayList<>();
        for (TeammateStatsRow row : rows) {
            members.add(toTeamMemberResponse(row, team.getOwnerUserId()));
        }
        response.setMembers(members);
        return response;
    }

    @Transactional
    public AdminTeamActionResponse removeMember(
            Long adminUserId,
            Long teamId,
            Long memberUserId
    ) {
        adminAccessService.requireAdmin(adminUserId);
        StudyTeam team = requireTeam(teamId);
        if (memberUserId == null || memberUserId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Member user id is required.");
        }
        if (team.getOwnerUserId() != null && team.getOwnerUserId().equals(memberUserId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "The team owner cannot be removed directly.");
        }
        StudyTeamMember member = teamMapper.findActiveMemberByTeamIdAndUserId(teamId, memberUserId);
        if (member == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected member is not in this team.");
        }

        boolean removed = teamMapper.updateTeamMemberStatus(teamId, memberUserId, INACTIVE_STATUS) > 0;
        AdminTeamActionResponse response = new AdminTeamActionResponse();
        response.setTeamId(teamId);
        response.setSuccess(removed);
        response.setMessage(removed ? "Team member removed." : "No team member was removed.");
        return response;
    }

    @Transactional
    public AdminTeamActionResponse dissolveTeam(Long adminUserId, Long teamId) {
        adminAccessService.requireAdmin(adminUserId);
        requireTeam(teamId);
        int updatedTeamCount = teamMapper.updateTeamStatus(teamId, INACTIVE_STATUS);
        if (updatedTeamCount > 0) {
            teamMapper.updateTeamMembersStatusByTeamId(teamId, INACTIVE_STATUS);
        }

        AdminTeamActionResponse response = new AdminTeamActionResponse();
        response.setTeamId(teamId);
        response.setSuccess(updatedTeamCount > 0);
        response.setMessage(updatedTeamCount > 0 ? "Team dissolved." : "The team was not dissolved.");
        return response;
    }

    private StudyTeam requireTeam(Long teamId) {
        if (teamId == null || teamId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Team id is required.");
        }
        StudyTeam team = teamMapper.findTeamById(teamId);
        if (team == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The team was not found.");
        }
        return team;
    }

    private AdminTeamListItemResponse toListItemResponse(AdminTeamSearchRow row) {
        AdminTeamListItemResponse response = new AdminTeamListItemResponse();
        response.setTeamId(row.getTeamId());
        response.setTeamName(defaultText(row.getTeamName()));
        response.setInviteCode(defaultText(row.getInviteCode()));
        response.setOwnerUserId(row.getOwnerUserId());
        response.setOwnerDisplayName(resolveDisplayName(row.getOwnerUserNo(), row.getOwnerNickname()));
        response.setStatusCode(defaultNumber(row.getStatus()));
        response.setStatusLabel(resolveStatusLabel(row.getStatus()));
        response.setMemberCount(defaultNumber(row.getMemberCount()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        return response;
    }

    private TeamMemberResponse toTeamMemberResponse(TeammateStatsRow row, Long ownerUserId) {
        TeamMemberResponse response = new TeamMemberResponse();
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setRole(row.getUserId() != null && row.getUserId().equals(ownerUserId) ? "owner" : "member");
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

    private String loadLatestChatPreview(Long teamId) {
        List<StudyTeamChatMessageRow> latestMessages = teamMapper.findRecentTeamChatMessages(
                teamId,
                LocalDateTime.now().minusDays(30),
                1
        );
        if (latestMessages.isEmpty()) {
            return "";
        }
        StudyTeamChatMessageRow row = latestMessages.get(0);
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

    private Integer normalizeOptionalStatus(Integer status) {
        if (status == null) {
            return null;
        }
        if (status != ACTIVE_STATUS && status != INACTIVE_STATUS) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported team status filter.");
        }
        return status;
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

    private String resolveDisplayName(String userNo, String nickname) {
        String normalizedNickname = defaultText(nickname);
        if (!normalizedNickname.isEmpty()) {
            return normalizedNickname;
        }
        String normalizedUserNo = defaultText(userNo);
        if (!normalizedUserNo.isEmpty()) {
            return normalizedUserNo;
        }
        return "Owner";
    }

    private String findOwnerNo(List<TeammateStatsRow> rows, Long ownerUserId) {
        for (TeammateStatsRow row : rows) {
            if (row.getUserId() != null && row.getUserId().equals(ownerUserId)) {
                return row.getUserNo();
            }
        }
        return "";
    }

    private String findOwnerNickname(List<TeammateStatsRow> rows, Long ownerUserId) {
        for (TeammateStatsRow row : rows) {
            if (row.getUserId() != null && row.getUserId().equals(ownerUserId)) {
                return row.getNickname();
            }
        }
        return "";
    }

    private String resolveStatusLabel(Integer status) {
        return defaultNumber(status) == ACTIVE_STATUS ? "active" : "dissolved";
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
