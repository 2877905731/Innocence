package com.innocence.server.modules.friend.mapper;

import com.innocence.server.modules.friend.domain.FriendGroup;
import com.innocence.server.modules.friend.domain.FriendGroupRow;
import com.innocence.server.modules.friend.domain.FriendItemRow;
import com.innocence.server.modules.friend.domain.FriendRelation;
import com.innocence.server.modules.friend.domain.FriendRequest;
import com.innocence.server.modules.friend.domain.FriendRequestRow;
import com.innocence.server.modules.friend.domain.FriendSearchRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface FriendMapper {

    FriendGroup findDefaultGroupByUserId(@Param("userId") Long userId);

    FriendGroup findFriendGroupByIdAndUserId(
            @Param("groupId") Long groupId,
            @Param("userId") Long userId
    );

    List<FriendGroupRow> findFriendGroupRowsByUserId(@Param("userId") Long userId);

    Integer countCustomGroupsByUserId(@Param("userId") Long userId);

    Integer findMaxGroupSortOrder(@Param("userId") Long userId);

    void insertFriendGroup(FriendGroup group);

    Integer countFriendCount(@Param("userId") Long userId);

    FriendRelation findFriendRelation(
            @Param("userId") Long userId,
            @Param("friendUserId") Long friendUserId
    );

    List<FriendItemRow> findFriendItemRowsByUserId(@Param("userId") Long userId);

    void insertFriendRelation(FriendRelation relation);

    int updateFriendGroup(
            @Param("userId") Long userId,
            @Param("friendUserId") Long friendUserId,
            @Param("groupId") Long groupId
    );

    int deleteFriendRelation(
            @Param("userId") Long userId,
            @Param("friendUserId") Long friendUserId
    );

    FriendRequest findFriendRequestById(@Param("requestId") Long requestId);

    FriendRequest findFriendRequestByRequesterAndTarget(
            @Param("requesterUserId") Long requesterUserId,
            @Param("targetUserId") Long targetUserId
    );

    List<FriendRequestRow> findIncomingPendingRequestRowsByUserId(@Param("userId") Long userId);

    List<FriendRequestRow> findOutgoingPendingRequestRowsByUserId(@Param("userId") Long userId);

    void insertFriendRequest(FriendRequest friendRequest);

    int updateFriendRequestForResend(FriendRequest friendRequest);

    int updateFriendRequestStatusById(
            @Param("requestId") Long requestId,
            @Param("status") String status
    );

    int updateFriendRequestStatusByUsers(
            @Param("requesterUserId") Long requesterUserId,
            @Param("targetUserId") Long targetUserId,
            @Param("status") String status
    );

    int deleteFriendRequestsBetweenUsers(
            @Param("userId") Long userId,
            @Param("otherUserId") Long otherUserId
    );

    Integer countBlacklistRelation(
            @Param("userId") Long userId,
            @Param("blockedUserId") Long blockedUserId
    );

    List<FriendSearchRow> searchFriendCandidates(
            @Param("userId") Long userId,
            @Param("keywordLike") String keywordLike,
            @Param("exactKeyword") String exactKeyword,
            @Param("searchTime") LocalDateTime searchTime
    );
}
