package com.innocence.server.modules.account.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class AdminAccountStore {
    private final JdbcTemplate jdbc;
    // Static schema allowlist; neither table names nor SQL predicates come from requests.
    private static final List<String> OWNED_TABLES = List.of(
            "user_session", "sync_import_operation", "assistant_document", "daily_plan_revision",
            "annual_plan_segment_subtask", "annual_plan_segment", "weekly_plan_template_item",
            "weekly_plan_template", "daily_plan_item", "daily_plan", "study_timer_record",
            "memo_record", "check_in_record", "check_in_summary", "check_in_fail_record",
            "user_notification_setting", "user_widget_setting", "user_appearance_setting",
            "user_privacy_setting", "user_profile", "friend_group", "user_auth");

    public AdminAccountStore(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public boolean registrationEnabled(boolean lock) {
        Boolean enabled = jdbc.queryForObject("SELECT enabled FROM app_registration_policy WHERE id=1" +
                (lock ? " FOR SHARE" : ""), Boolean.class);
        return Boolean.TRUE.equals(enabled);
    }

    public boolean lockRegistrationForChange() {
        return Boolean.TRUE.equals(jdbc.queryForObject(
                "SELECT enabled FROM app_registration_policy WHERE id=1 FOR UPDATE", Boolean.class));
    }

    public void setRegistrationEnabled(boolean enabled, Long actor) {
        if (jdbc.update("UPDATE app_registration_policy SET enabled=?, updated_by=? WHERE id=1", enabled, actor) != 1) {
            throw new IllegalStateException("Missing registration policy row");
        }
    }

    public void audit(Long actor, Long target, String action) {
        jdbc.update("INSERT INTO admin_account_action(operator_user_id,target_user_id,action_code) VALUES (?,?,?)", actor, target, action);
    }

    public int ownedTeamCount(Long userId) {
        return jdbc.queryForObject("SELECT COUNT(*) FROM study_team WHERE owner_user_id=?", Integer.class, userId);
    }

    public int deleteUserGraph(Long userId) {
        List<Long> ownedTeams = jdbc.queryForList("SELECT id FROM study_team WHERE owner_user_id=? FOR UPDATE", Long.class, userId);
        for (Long teamId : ownedTeams) {
            deleteReports("team_id=?", teamId);
            jdbc.update("DELETE FROM app_notification WHERE (related_type='team' AND related_id=?) OR " +
                    "(related_type='team_invitation' AND related_id IN (SELECT id FROM study_team_invitation WHERE team_id=?)) OR " +
                    "(related_type='team_chat' AND related_id IN (SELECT id FROM study_team_chat_message WHERE team_id=?))", teamId, teamId, teamId);
            for (String table : List.of("study_team_chat_read_state", "study_team_chat_message", "study_team_reminder", "study_team_invitation", "study_team_member")) {
                jdbc.update("DELETE FROM " + table + " WHERE team_id=?", teamId);
            }
            jdbc.update("DELETE FROM study_team WHERE id=?", teamId);
        }
        deleteReports("report_user_id=? OR target_user_id=?", userId, userId);
        jdbc.update("DELETE FROM app_notification WHERE " +
                "(related_type='friend_request' AND related_id IN (SELECT id FROM friend_request WHERE requester_user_id=? OR target_user_id=?)) OR " +
                "(related_type='team_invitation' AND related_id IN (SELECT id FROM study_team_invitation WHERE inviter_user_id=? OR invitee_user_id=?)) OR " +
                "(related_type='team_chat' AND related_id IN (SELECT id FROM study_team_chat_message WHERE sender_user_id=?))", userId,userId,userId,userId,userId);
        jdbc.update("DELETE FROM memo_check_item WHERE memo_id IN (SELECT id FROM memo_record WHERE user_id=?)", userId);
        jdbc.update("DELETE FROM friend_relation WHERE user_id=? OR friend_user_id=?", userId, userId);
        jdbc.update("DELETE FROM friend_request WHERE requester_user_id=? OR target_user_id=?", userId, userId);
        jdbc.update("DELETE FROM user_blacklist WHERE user_id=? OR blocked_user_id=?", userId, userId);
        jdbc.update("DELETE FROM study_team_invitation WHERE inviter_user_id=? OR invitee_user_id=?", userId, userId);
        jdbc.update("DELETE FROM study_team_reminder WHERE from_user_id=? OR to_user_id=?", userId, userId);
        jdbc.update("DELETE FROM study_team_chat_message WHERE sender_user_id=?", userId);
        jdbc.update("DELETE FROM study_team_chat_read_state WHERE user_id=?", userId);
        jdbc.update("DELETE FROM study_team_member WHERE user_id=?", userId);
        jdbc.update("DELETE FROM app_notification WHERE user_id=? OR sender_user_id=?", userId, userId);
        jdbc.update("DELETE FROM punishment_record WHERE user_id=?", userId);
        for (String table : OWNED_TABLES) jdbc.update("DELETE FROM " + table + " WHERE user_id=?", userId);
        if (jdbc.update("DELETE FROM app_user WHERE id=?", userId) != 1) throw new IllegalStateException("Account deletion changed concurrently");
        return ownedTeams.size();
    }

    private void deleteReports(String predicate, Object... args) {
        String ids = "SELECT id FROM report_record WHERE " + predicate;
        jdbc.update("DELETE FROM report_audit_record WHERE report_id IN (" + ids + ")", args);
        jdbc.update("DELETE FROM punishment_record WHERE report_id IN (" + ids + ")", args);
        jdbc.update("DELETE FROM app_notification WHERE related_type='report' AND related_id IN (" + ids + ")", args);
        jdbc.update("DELETE FROM report_record WHERE " + predicate, args);
    }
}
