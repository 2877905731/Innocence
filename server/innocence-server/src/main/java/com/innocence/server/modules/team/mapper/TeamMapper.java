package com.innocence.server.modules.team.mapper;

import com.innocence.server.modules.team.domain.StudyTeam;
import com.innocence.server.modules.team.domain.AdminTeamSearchRow;
import com.innocence.server.modules.team.domain.StudyTeamChatMessage;
import com.innocence.server.modules.team.domain.StudyTeamChatMessageRow;
import com.innocence.server.modules.team.domain.StudyTeamInvitation;
import com.innocence.server.modules.team.domain.StudyTeamMember;
import com.innocence.server.modules.team.domain.StudyTeamReminder;
import com.innocence.server.modules.team.domain.TeammateStatsRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface TeamMapper {

    StudyTeam findActiveTeamById(@Param("teamId") Long teamId);

    StudyTeam findTeamById(@Param("teamId") Long teamId);

    StudyTeam findTeamByInviteCode(@Param("inviteCode") String inviteCode);

    StudyTeam findActiveTeamByInviteCode(@Param("inviteCode") String inviteCode);

    StudyTeamMember findActiveMemberByUserId(@Param("userId") Long userId);

    List<StudyTeamMember> findActiveMembersByTeamId(@Param("teamId") Long teamId);

    List<StudyTeamMember> findMembersByTeamId(@Param("teamId") Long teamId);

    List<AdminTeamSearchRow> searchTeams(
            @Param("keyword") String keyword,
            @Param("status") Integer status,
            @Param("limit") Integer limit
    );

    List<TeammateStatsRow> findActiveTeamMemberStats(
            @Param("teamId") Long teamId,
            @Param("currentUserId") Long currentUserId,
            @Param("planDate") LocalDate planDate,
            @Param("rangeStart") LocalDateTime rangeStart,
            @Param("rangeEnd") LocalDateTime rangeEnd
    );

    List<TeammateStatsRow> findActiveTeammateStats(
            @Param("teamId") Long teamId,
            @Param("currentUserId") Long currentUserId,
            @Param("planDate") LocalDate planDate,
            @Param("rangeStart") LocalDateTime rangeStart,
            @Param("rangeEnd") LocalDateTime rangeEnd
    );

    StudyTeamMember findActiveMemberByTeamIdAndUserId(
            @Param("teamId") Long teamId,
            @Param("userId") Long userId
    );

    StudyTeamInvitation findTeamInvitationById(@Param("invitationId") Long invitationId);

    StudyTeamInvitation findPendingInvitationByTeamIdAndInviteeUserId(
            @Param("teamId") Long teamId,
            @Param("inviteeUserId") Long inviteeUserId
    );

    Integer countRemindersSentToday(
            @Param("teamId") Long teamId,
            @Param("fromUserId") Long fromUserId,
            @Param("toUserId") Long toUserId,
            @Param("rangeStart") LocalDateTime rangeStart,
            @Param("rangeEnd") LocalDateTime rangeEnd
    );

    List<StudyTeamChatMessageRow> findRecentTeamChatMessages(
            @Param("teamId") Long teamId,
            @Param("sinceTime") LocalDateTime sinceTime,
            @Param("limit") Integer limit
    );

    StudyTeamChatMessageRow findTeamChatMessageById(@Param("messageId") Long messageId);

    Integer countUnreadTeamChatMessages(
            @Param("teamId") Long teamId,
            @Param("userId") Long userId,
            @Param("sinceTime") LocalDateTime sinceTime
    );

    Long findLastReadChatMessageId(
            @Param("teamId") Long teamId,
            @Param("userId") Long userId
    );

    void insertTeam(StudyTeam team);

    void insertTeamMember(StudyTeamMember member);

    void insertTeamInvitation(StudyTeamInvitation invitation);

    void insertTeamChatMessage(StudyTeamChatMessage message);

    int softDeleteTeamChatMessage(
            @Param("messageId") Long messageId,
            @Param("deletedReason") String deletedReason,
            @Param("deletedTime") LocalDateTime deletedTime
    );

    int upsertTeamChatReadState(
            @Param("teamId") Long teamId,
            @Param("userId") Long userId,
            @Param("lastReadMessageId") Long lastReadMessageId
    );

    int updateTeamStatus(
            @Param("teamId") Long teamId,
            @Param("status") Integer status
    );

    int updateTeamMembersStatusByTeamId(
            @Param("teamId") Long teamId,
            @Param("status") Integer status
    );

    int updateTeamMemberStatus(
            @Param("teamId") Long teamId,
            @Param("userId") Long userId,
            @Param("status") Integer status
    );

    int updateTeamInvitationStatusById(
            @Param("invitationId") Long invitationId,
            @Param("status") String status
    );

    void insertReminder(StudyTeamReminder reminder);
}
