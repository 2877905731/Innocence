package com.innocence.server.modules.team.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.team.dto.response.AdminTeamActionResponse;
import com.innocence.server.modules.team.dto.response.AdminTeamDetailResponse;
import com.innocence.server.modules.team.dto.response.AdminTeamListItemResponse;
import com.innocence.server.modules.team.service.AdminTeamManagementService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/v1/teams")
public class AdminTeamController {

    private final AdminTeamManagementService adminTeamManagementService;

    public AdminTeamController(AdminTeamManagementService adminTeamManagementService) {
        this.adminTeamManagementService = adminTeamManagementService;
    }

    @GetMapping
    public ApiResponse<List<AdminTeamListItemResponse>> searchTeams(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "status", required = false) Integer status,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return ApiResponse.success(
                adminTeamManagementService.searchTeams(currentUserId(), keyword, status, limit)
        );
    }

    @GetMapping("/{teamId}")
    public ApiResponse<AdminTeamDetailResponse> getTeamDetail(@PathVariable("teamId") Long teamId) {
        return ApiResponse.success(adminTeamManagementService.getTeamDetail(currentUserId(), teamId));
    }

    @PostMapping("/{teamId}/remove-member")
    public ApiResponse<AdminTeamActionResponse> removeMember(
            @PathVariable("teamId") Long teamId,
            @RequestParam("memberUserId") Long memberUserId
    ) {
        return ApiResponse.success(
                adminTeamManagementService.removeMember(currentUserId(), teamId, memberUserId)
        );
    }

    @PostMapping("/{teamId}/dissolve")
    public ApiResponse<AdminTeamActionResponse> dissolveTeam(@PathVariable("teamId") Long teamId) {
        return ApiResponse.success(adminTeamManagementService.dissolveTeam(currentUserId(), teamId));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
