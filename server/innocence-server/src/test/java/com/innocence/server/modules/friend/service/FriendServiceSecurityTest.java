package com.innocence.server.modules.friend.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.friend.domain.FriendRequest;
import com.innocence.server.modules.friend.dto.request.RespondFriendRequestRequest;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class FriendServiceSecurityTest {

    private FriendMapper friendMapper;
    private UserMapper userMapper;
    private FriendService friendService;

    @BeforeEach
    void setUp() {
        friendMapper = mock(FriendMapper.class);
        userMapper = mock(UserMapper.class);
        friendService = new FriendService(
                friendMapper,
                userMapper,
                mock(NotificationService.class)
        );
    }

    @Test
    void respondRequestRejectsUserOutsideRequestTenant() {
        Long currentUserId = 7L;
        Long requestId = 31L;

        User currentUser = new User();
        currentUser.setStatus(1);
        when(userMapper.findUserById(currentUserId)).thenReturn(currentUser);

        FriendRequest friendRequest = new FriendRequest();
        friendRequest.setId(requestId);
        friendRequest.setRequesterUserId(8L);
        friendRequest.setTargetUserId(9L);
        friendRequest.setStatus("pending");
        when(friendMapper.findFriendRequestById(requestId)).thenReturn(friendRequest);

        RespondFriendRequestRequest request = new RespondFriendRequestRequest();
        request.setAccept(true);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> friendService.respondRequest(currentUserId, requestId, request)
        );

        assertEquals(ErrorCode.FORBIDDEN, exception.getCode());
        verify(friendMapper, never()).updateFriendRequestStatusById(requestId, "accepted");
    }
}
