package com.innocence.server.modules.team.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.team.dto.request.CreateTeamRequest;
import com.innocence.server.modules.team.dto.request.CreateTeamInvitationRequest;
import com.innocence.server.modules.team.dto.request.JoinTeamRequest;
import com.innocence.server.modules.team.dto.request.RespondTeamInvitationRequest;
import com.innocence.server.modules.team.dto.request.SendTeamChatMessageRequest;
import com.innocence.server.modules.team.dto.response.TeammateReminderResponse;
import com.innocence.server.modules.team.dto.response.TeammateStatsResponse;
import com.innocence.server.modules.team.dto.response.TeamChatOverviewResponse;
import com.innocence.server.modules.team.dto.response.TeamOverviewResponse;
import com.innocence.server.modules.team.service.TeamService;
import com.innocence.server.modules.report.dto.request.CreateChatReportRequest;
import com.innocence.server.modules.report.dto.response.CreateReportResponse;
import com.innocence.server.modules.report.service.ReportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/app/v1/team")
public class TeamController {

    private final TeamService teamService;
    private final ReportService reportService;

    public TeamController(TeamService teamService, ReportService reportService) {
        this.teamService = teamService;
        this.reportService = reportService;
    }

    @GetMapping("/current")
    public ApiResponse<TeamOverviewResponse> getCurrentTeam() {
        return ApiResponse.success(teamService.getCurrentTeam(currentUserId()));
    }

    @PostMapping("/create")
    public ApiResponse<TeamOverviewResponse> createTeam(@Valid @RequestBody CreateTeamRequest request) {
        return ApiResponse.success(teamService.createTeam(currentUserId(), request));
    }

    @PostMapping("/join")
    public ApiResponse<TeamOverviewResponse> joinTeam(@Valid @RequestBody JoinTeamRequest request) {
        return ApiResponse.success(teamService.joinTeam(currentUserId(), request));
    }

    @PostMapping("/invite")
    public ApiResponse<TeamOverviewResponse> inviteMember(
            @Valid @RequestBody CreateTeamInvitationRequest request
    ) {
        return ApiResponse.success(teamService.inviteMember(currentUserId(), request));
    }

    @PostMapping("/invitations/{invitationId}/respond")
    public ApiResponse<TeamOverviewResponse> respondInvitation(
            @org.springframework.web.bind.annotation.PathVariable Long invitationId,
            @RequestBody RespondTeamInvitationRequest request
    ) {
        return ApiResponse.success(teamService.respondInvitation(currentUserId(), invitationId, request));
    }

    @PostMapping("/remove-member")
    public ApiResponse<Boolean> removeMember(@RequestParam("memberUserId") Long memberUserId) {
        return ApiResponse.success(teamService.removeMember(currentUserId(), memberUserId));
    }

    @PostMapping("/dissolve")
    public ApiResponse<Boolean> dissolveTeam() {
        return ApiResponse.success(teamService.dissolveTeam(currentUserId()));
    }

    @GetMapping("/teammates/stats")
    public ApiResponse<List<TeammateStatsResponse>> getTeammateStats() {
        return ApiResponse.success(teamService.getTeammateStats(currentUserId()));
    }

    @PostMapping("/teammates/remind")
    public ApiResponse<TeammateReminderResponse> remindTeammate(
            @RequestParam("teammateUserId") Long teammateUserId
    ) {
        return ApiResponse.success(teamService.remindTeammate(currentUserId(), teammateUserId));
    }

    @GetMapping("/chat")
    public ApiResponse<TeamChatOverviewResponse> getTeamChat(
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(teamService.getTeamChatMessages(currentUserId(), limit));
    }

    @PostMapping("/chat/send")
    public ApiResponse<TeamChatOverviewResponse> sendTeamChat(
            @Valid @RequestBody SendTeamChatMessageRequest request
    ) {
        return ApiResponse.success(teamService.sendTeamChatMessage(currentUserId(), request));
    }

    @PostMapping("/chat/read")
    public ApiResponse<TeamChatOverviewResponse> markTeamChatRead() {
        return ApiResponse.success(teamService.markTeamChatRead(currentUserId()));
    }

    @PostMapping("/chat/{messageId}/report")
    public ApiResponse<CreateReportResponse> reportTeamChatMessage(
            @org.springframework.web.bind.annotation.PathVariable("messageId") Long messageId,
            @Valid @RequestBody CreateChatReportRequest request
    ) {
        return ApiResponse.success(reportService.createTeamChatReport(currentUserId(), messageId, request));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
