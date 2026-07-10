package com.innocence.server.modules.friend.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.friend.domain.FriendGroup;
import com.innocence.server.modules.friend.domain.FriendGroupRow;
import com.innocence.server.modules.friend.domain.FriendItemRow;
import com.innocence.server.modules.friend.domain.FriendRelation;
import com.innocence.server.modules.friend.domain.FriendRequest;
import com.innocence.server.modules.friend.domain.FriendRequestRow;
import com.innocence.server.modules.friend.domain.FriendSearchRow;
import com.innocence.server.modules.friend.dto.request.CreateFriendGroupRequest;
import com.innocence.server.modules.friend.dto.request.CreateFriendRequestRequest;
import com.innocence.server.modules.friend.dto.request.MoveFriendGroupRequest;
import com.innocence.server.modules.friend.dto.request.RespondFriendRequestRequest;
import com.innocence.server.modules.friend.dto.response.FriendGroupResponse;
import com.innocence.server.modules.friend.dto.response.FriendItemResponse;
import com.innocence.server.modules.friend.dto.response.FriendOverviewResponse;
import com.innocence.server.modules.friend.dto.response.FriendRequestResponse;
import com.innocence.server.modules.friend.dto.response.FriendSearchItemResponse;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class FriendService {

    private static final int MAX_FRIEND_COUNT = 200;
    private static final int MAX_CUSTOM_GROUP_COUNT = 20;
    private static final int SEARCH_LIMIT_HINT = 20;
    private static final String DEFAULT_GROUP_NAME = "Default";
    private static final String STATUS_PENDING = "pending";
    private static final String STATUS_ACCEPTED = "accepted";
    private static final String STATUS_REJECTED = "rejected";
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final FriendMapper friendMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    public FriendService(
            FriendMapper friendMapper,
            UserMapper userMapper,
            NotificationService notificationService
    ) {
        this.friendMapper = friendMapper;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
    }

    @Transactional
    public FriendOverviewResponse getOverview(Long userId) {
        requireUser(userId);
        FriendGroup defaultGroup = ensureDefaultGroup(userId);
        return buildOverview(userId, defaultGroup.getId());
    }

    @Transactional(readOnly = true)
    public List<FriendSearchItemResponse> searchCandidates(Long userId, String keyword) {
        requireUser(userId);
        String normalizedKeyword = normalizeKeyword(keyword);
        List<FriendSearchRow> rows = friendMapper.searchFriendCandidates(
                userId,
                "%" + normalizedKeyword + "%",
                normalizedKeyword,
                LocalDateTime.now()
        );

        List<FriendSearchItemResponse> responses = new ArrayList<>();
        int count = 0;
        for (FriendSearchRow row : rows) {
            responses.add(toSearchResponse(row));
            count++;
            if (count >= SEARCH_LIMIT_HINT) {
                break;
            }
        }
        return responses;
    }

    @Transactional
    public FriendOverviewResponse createRequest(Long userId, CreateFriendRequestRequest request) {
        requireUser(userId);

        Long targetUserId = request == null ? null : request.getTargetUserId();
        if (targetUserId == null || targetUserId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Target user is required.");
        }
        if (userId.equals(targetUserId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You cannot add yourself as a friend.");
        }

        requireUser(targetUserId);
        ensureNotBlockedEitherWay(userId, targetUserId);
        ensureNotAlreadyFriends(userId, targetUserId);

        FriendRequest reverseRequest = friendMapper.findFriendRequestByRequesterAndTarget(targetUserId, userId);
        if (reverseRequest != null && STATUS_PENDING.equalsIgnoreCase(defaultText(reverseRequest.getStatus()))) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This user already sent you a friend request. Accept it from the incoming requests list."
            );
        }

        String message = normalizeRequestMessage(request == null ? null : request.getMessage());
        LocalDateTime now = LocalDateTime.now();

        FriendRequest existingRequest = friendMapper.findFriendRequestByRequesterAndTarget(userId, targetUserId);
        if (existingRequest == null) {
            FriendRequest friendRequest = new FriendRequest();
            friendRequest.setRequesterUserId(userId);
            friendRequest.setTargetUserId(targetUserId);
            friendRequest.setRequestMessage(message);
            friendRequest.setStatus(STATUS_PENDING);
            friendRequest.setCreateTime(now);
            try {
                friendMapper.insertFriendRequest(friendRequest);
                existingRequest = friendRequest;
            } catch (DuplicateKeyException exception) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "A friend request is already waiting for this user."
                );
            }
        } else if (STATUS_PENDING.equalsIgnoreCase(defaultText(existingRequest.getStatus()))) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "A friend request is already waiting for this user."
            );
        } else {
            existingRequest.setRequestMessage(message);
            existingRequest.setStatus(STATUS_PENDING);
            existingRequest.setCreateTime(now);
            friendMapper.updateFriendRequestForResend(existingRequest);
        }

        notificationService.createFriendRequestNotification(userId, targetUserId, existingRequest.getId());
        return buildOverview(userId, ensureDefaultGroup(userId).getId());
    }

    @Transactional
    public FriendOverviewResponse respondRequest(
            Long userId,
            Long requestId,
            RespondFriendRequestRequest request
    ) {
        requireUser(userId);
        if (requestId == null || requestId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Friend request id is required.");
        }
        boolean accept = request != null && Boolean.TRUE.equals(request.getAccept());

        FriendRequest friendRequest = friendMapper.findFriendRequestById(requestId);
        if (friendRequest == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The friend request was not found.");
        }
        if (!userId.equals(friendRequest.getTargetUserId())) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "You can respond only to your own incoming requests.");
        }
        if (!STATUS_PENDING.equalsIgnoreCase(defaultText(friendRequest.getStatus()))) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This friend request has already been handled.");
        }

        Long requesterUserId = friendRequest.getRequesterUserId();
        ensureNotBlockedEitherWay(userId, requesterUserId);

        if (accept) {
            ensureNotAlreadyFriends(userId, requesterUserId);
            ensureFriendCapacity(userId);
            ensureFriendCapacity(requesterUserId);

            FriendGroup currentUserDefaultGroup = ensureDefaultGroup(userId);
            FriendGroup requesterDefaultGroup = ensureDefaultGroup(requesterUserId);
            createFriendRelationPair(userId, requesterUserId, currentUserDefaultGroup.getId(), requesterDefaultGroup.getId());
            friendMapper.updateFriendRequestStatusById(requestId, STATUS_ACCEPTED);
            friendMapper.updateFriendRequestStatusByUsers(userId, requesterUserId, STATUS_ACCEPTED);
        } else {
            friendMapper.updateFriendRequestStatusById(requestId, STATUS_REJECTED);
        }

        return buildOverview(userId, ensureDefaultGroup(userId).getId());
    }

    @Transactional
    public FriendOverviewResponse createGroup(Long userId, CreateFriendGroupRequest request) {
        requireUser(userId);
        ensureDefaultGroup(userId);

        int customGroupCount = defaultNumber(friendMapper.countCustomGroupsByUserId(userId));
        if (customGroupCount >= MAX_CUSTOM_GROUP_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "You can create up to 20 custom friend groups."
            );
        }

        FriendGroup group = new FriendGroup();
        group.setUserId(userId);
        group.setGroupName(normalizeGroupName(request == null ? null : request.getGroupName()));
        group.setSystemFlag(0);
        group.setSortOrder(defaultNumber(friendMapper.findMaxGroupSortOrder(userId)) + 1);
        try {
            friendMapper.insertFriendGroup(group);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "This friend group name already exists.");
        }

        return buildOverview(userId, ensureDefaultGroup(userId).getId());
    }

    @Transactional
    public FriendOverviewResponse moveFriendToGroup(
            Long userId,
            Long friendUserId,
            MoveFriendGroupRequest request
    ) {
        requireUser(userId);
        if (friendUserId == null || friendUserId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Friend user id is required.");
        }
        FriendRelation relation = requireFriendRelation(userId, friendUserId);

        Long groupId = request == null ? null : request.getGroupId();
        if (groupId == null || groupId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Friend group id is required.");
        }

        FriendGroup group = friendMapper.findFriendGroupByIdAndUserId(groupId, userId);
        if (group == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected friend group does not exist.");
        }

        if (relation.getGroupId() == null || !relation.getGroupId().equals(groupId)) {
            friendMapper.updateFriendGroup(userId, friendUserId, groupId);
        }
        return buildOverview(userId, ensureDefaultGroup(userId).getId());
    }

    @Transactional
    public FriendOverviewResponse deleteFriend(Long userId, Long friendUserId) {
        requireUser(userId);
        if (friendUserId == null || friendUserId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Friend user id is required.");
        }

        requireFriendRelation(userId, friendUserId);
        friendMapper.deleteFriendRelation(userId, friendUserId);
        friendMapper.deleteFriendRelation(friendUserId, userId);
        friendMapper.deleteFriendRequestsBetweenUsers(userId, friendUserId);
        return buildOverview(userId, ensureDefaultGroup(userId).getId());
    }

    private FriendOverviewResponse buildOverview(Long userId, Long defaultGroupId) {
        List<FriendGroupRow> groupRows = friendMapper.findFriendGroupRowsByUserId(userId);
        List<FriendItemRow> friendRows = friendMapper.findFriendItemRowsByUserId(userId);
        List<FriendRequestRow> incomingRows = friendMapper.findIncomingPendingRequestRowsByUserId(userId);
        List<FriendRequestRow> outgoingRows = friendMapper.findOutgoingPendingRequestRowsByUserId(userId);

        FriendOverviewResponse response = new FriendOverviewResponse();
        response.setFriendCount(friendRows.size());
        response.setMaxFriendCount(MAX_FRIEND_COUNT);
        response.setDefaultGroupId(defaultGroupId);

        List<FriendGroupResponse> groups = new ArrayList<>();
        for (FriendGroupRow row : groupRows) {
            groups.add(toGroupResponse(row));
        }
        response.setGroups(groups);

        List<FriendItemResponse> friends = new ArrayList<>();
        for (FriendItemRow row : friendRows) {
            friends.add(toFriendItemResponse(row));
        }
        response.setFriends(friends);

        List<FriendRequestResponse> incoming = new ArrayList<>();
        for (FriendRequestRow row : incomingRows) {
            incoming.add(toFriendRequestResponse(row, true));
        }
        response.setIncomingRequests(incoming);

        List<FriendRequestResponse> outgoing = new ArrayList<>();
        for (FriendRequestRow row : outgoingRows) {
            outgoing.add(toFriendRequestResponse(row, false));
        }
        response.setOutgoingRequests(outgoing);

        return response;
    }

    private FriendGroup ensureDefaultGroup(Long userId) {
        FriendGroup defaultGroup = friendMapper.findDefaultGroupByUserId(userId);
        if (defaultGroup != null) {
            return defaultGroup;
        }

        FriendGroup created = new FriendGroup();
        created.setUserId(userId);
        created.setGroupName(DEFAULT_GROUP_NAME);
        created.setSystemFlag(1);
        created.setSortOrder(0);
        try {
            friendMapper.insertFriendGroup(created);
            return created;
        } catch (DuplicateKeyException exception) {
            FriendGroup loaded = friendMapper.findDefaultGroupByUserId(userId);
            if (loaded != null) {
                return loaded;
            }
            throw exception;
        }
    }

    private void createFriendRelationPair(
            Long userId,
            Long friendUserId,
            Long userGroupId,
            Long friendGroupId
    ) {
        FriendRelation currentRelation = new FriendRelation();
        currentRelation.setUserId(userId);
        currentRelation.setFriendUserId(friendUserId);
        currentRelation.setGroupId(userGroupId);
        friendMapper.insertFriendRelation(currentRelation);

        FriendRelation reverseRelation = new FriendRelation();
        reverseRelation.setUserId(friendUserId);
        reverseRelation.setFriendUserId(userId);
        reverseRelation.setGroupId(friendGroupId);
        friendMapper.insertFriendRelation(reverseRelation);
    }

    private void ensureNotAlreadyFriends(Long userId, Long otherUserId) {
        FriendRelation relation = friendMapper.findFriendRelation(userId, otherUserId);
        if (relation != null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "You are already friends with this user.");
        }
    }

    private void ensureFriendCapacity(Long userId) {
        int friendCount = defaultNumber(friendMapper.countFriendCount(userId));
        if (friendCount >= MAX_FRIEND_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This account already reached the 200-friend limit."
            );
        }
    }

    private void ensureNotBlockedEitherWay(Long userId, Long otherUserId) {
        if (defaultNumber(friendMapper.countBlacklistRelation(userId, otherUserId)) > 0) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Remove this user from your blacklist before sending a friend request."
            );
        }
        if (defaultNumber(friendMapper.countBlacklistRelation(otherUserId, userId)) > 0) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This user is not available for friend requests."
            );
        }
    }

    private FriendRelation requireFriendRelation(Long userId, Long friendUserId) {
        FriendRelation relation = friendMapper.findFriendRelation(userId, friendUserId);
        if (relation == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "This user is not in your friend list.");
        }
        return relation;
    }

    private User requireUser(Long userId) {
        User user = userMapper.findUserById(userId);
        if (user == null || defaultNumber(user.getStatus()) != 1) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected user was not found.");
        }
        return user;
    }

    private FriendGroupResponse toGroupResponse(FriendGroupRow row) {
        FriendGroupResponse response = new FriendGroupResponse();
        response.setGroupId(row.getId());
        response.setGroupName(defaultText(row.getGroupName()));
        response.setSystem(defaultNumber(row.getSystemFlag()) == 1);
        response.setFriendCount(defaultNumber(row.getFriendCount()));
        return response;
    }

    private FriendItemResponse toFriendItemResponse(FriendItemRow row) {
        FriendItemResponse response = new FriendItemResponse();
        response.setUserId(row.getFriendUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setProfileVisible(defaultNumber(row.getAllowFriendViewProfile()) == 1);
        response.setBio(response.isProfileVisible() ? defaultText(row.getBio()) : "");
        response.setGroupId(row.getGroupId());
        response.setGroupName(defaultText(row.getGroupName()));
        response.setSameTeam(defaultNumber(row.getSameTeamFlag()) == 1);
        return response;
    }

    private FriendRequestResponse toFriendRequestResponse(FriendRequestRow row, boolean incoming) {
        FriendRequestResponse response = new FriendRequestResponse();
        response.setRequestId(row.getId());
        response.setUserId(row.getCounterpartUserId());
        response.setUserNo(defaultText(row.getCounterpartUserNo()));
        response.setNickname(defaultText(row.getCounterpartNickname()));
        response.setAvatarUrl(defaultText(row.getCounterpartAvatarUrl()));
        response.setRequestMessage(defaultText(row.getRequestMessage()));
        response.setCreateTime(formatDateTime(row.getCreateTime()));
        response.setIncoming(incoming);
        response.setSameTeam(defaultNumber(row.getSameTeamFlag()) == 1);
        return response;
    }

    private FriendSearchItemResponse toSearchResponse(FriendSearchRow row) {
        FriendSearchItemResponse response = new FriendSearchItemResponse();
        response.setUserId(row.getUserId());
        response.setUserNo(defaultText(row.getUserNo()));
        response.setNickname(defaultText(row.getNickname()));
        response.setAvatarUrl(defaultText(row.getAvatarUrl()));
        response.setAlreadyFriend(defaultNumber(row.getAlreadyFriendFlag()) == 1);
        response.setOutgoingPending(defaultNumber(row.getOutgoingPendingFlag()) == 1);
        response.setIncomingPending(defaultNumber(row.getIncomingPendingFlag()) == 1);
        response.setBlockedByMe(defaultNumber(row.getBlockedByMeFlag()) == 1);
        response.setBlockedMe(defaultNumber(row.getBlockedMeFlag()) == 1);
        response.setSameTeam(defaultNumber(row.getSameTeamFlag()) == 1);
        return response;
    }

    private String normalizeKeyword(String keyword) {
        String normalized = defaultText(keyword);
        if (normalized.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Search keyword is required.");
        }
        return normalized;
    }

    private String normalizeRequestMessage(String message) {
        String normalized = defaultText(message);
        if (normalized.length() > 120) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Friend request message cannot exceed 120 characters."
            );
        }
        return normalized;
    }

    private String normalizeGroupName(String groupName) {
        String normalized = defaultText(groupName);
        if (normalized.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Friend group name is required.");
        }
        if (normalized.length() > 32) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Friend group name cannot exceed 32 characters."
            );
        }
        if (DEFAULT_GROUP_NAME.equalsIgnoreCase(normalized)) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "This friend group name is reserved."
            );
        }
        return normalized;
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String defaultText(String value) {
        return value == null ? "" : value.trim();
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(DATE_TIME_FORMATTER);
    }
}
