package com.innocence.server.modules.friend.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.friend.dto.request.CreateFriendGroupRequest;
import com.innocence.server.modules.friend.dto.request.CreateFriendRequestRequest;
import com.innocence.server.modules.friend.dto.request.MoveFriendGroupRequest;
import com.innocence.server.modules.friend.dto.request.RespondFriendRequestRequest;
import com.innocence.server.modules.friend.dto.response.FriendOverviewResponse;
import com.innocence.server.modules.friend.dto.response.FriendSearchItemResponse;
import com.innocence.server.modules.friend.service.FriendService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/app/v1/friends")
public class FriendController {

    private final FriendService friendService;

    public FriendController(FriendService friendService) {
        this.friendService = friendService;
    }

    @GetMapping("/overview")
    public ApiResponse<FriendOverviewResponse> getOverview() {
        return ApiResponse.success(friendService.getOverview(currentUserId()));
    }

    @GetMapping("/search")
    public ApiResponse<List<FriendSearchItemResponse>> search(
            @RequestParam("keyword") String keyword
    ) {
        return ApiResponse.success(friendService.searchCandidates(currentUserId(), keyword));
    }

    @PostMapping("/requests")
    public ApiResponse<FriendOverviewResponse> createRequest(
            @RequestBody CreateFriendRequestRequest request
    ) {
        return ApiResponse.success(friendService.createRequest(currentUserId(), request));
    }

    @PostMapping("/requests/{requestId}/respond")
    public ApiResponse<FriendOverviewResponse> respondRequest(
            @PathVariable Long requestId,
            @RequestBody RespondFriendRequestRequest request
    ) {
        return ApiResponse.success(friendService.respondRequest(currentUserId(), requestId, request));
    }

    @PostMapping("/groups")
    public ApiResponse<FriendOverviewResponse> createGroup(
            @RequestBody CreateFriendGroupRequest request
    ) {
        return ApiResponse.success(friendService.createGroup(currentUserId(), request));
    }

    @PutMapping("/{friendUserId}/group")
    public ApiResponse<FriendOverviewResponse> moveFriendToGroup(
            @PathVariable Long friendUserId,
            @RequestBody MoveFriendGroupRequest request
    ) {
        return ApiResponse.success(friendService.moveFriendToGroup(currentUserId(), friendUserId, request));
    }

    @DeleteMapping("/{friendUserId}")
    public ApiResponse<FriendOverviewResponse> deleteFriend(@PathVariable Long friendUserId) {
        return ApiResponse.success(friendService.deleteFriend(currentUserId(), friendUserId));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
