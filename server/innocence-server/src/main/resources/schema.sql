CREATE TABLE IF NOT EXISTS app_user
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_no         VARCHAR(32)  NOT NULL UNIQUE,
    nickname        VARCHAR(64)  NOT NULL,
    avatar_url      VARCHAR(255) NULL,
    status          TINYINT      NOT NULL DEFAULT 1,
    last_login_time DATETIME     NULL,
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_auth
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id       BIGINT       NOT NULL,
    auth_type     VARCHAR(32)  NOT NULL,
    auth_account  VARCHAR(128) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(64)  NOT NULL,
    is_verified   TINYINT      NOT NULL DEFAULT 1,
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_profile
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id     BIGINT      NOT NULL UNIQUE,
    bio         VARCHAR(255) NULL,
    timezone    VARCHAR(64) NOT NULL DEFAULT 'Asia/Shanghai',
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_privacy_setting
(
    id                         BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                    BIGINT  NOT NULL UNIQUE,
    allow_friend_view_profile  TINYINT NOT NULL DEFAULT 1,
    allow_teammate_view_study  TINYINT NOT NULL DEFAULT 1,
    allow_stranger_message     TINYINT NOT NULL DEFAULT 0,
    create_time                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_notification_setting
(
    id                          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                     BIGINT  NOT NULL UNIQUE,
    mobile_push_enabled         TINYINT NOT NULL DEFAULT 1,
    desktop_notice_enabled      TINYINT NOT NULL DEFAULT 1,
    team_remind_enabled         TINYINT NOT NULL DEFAULT 1,
    system_announcement_enabled TINYINT NOT NULL DEFAULT 1,
    create_time                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_widget_setting
(
    id                 BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id            BIGINT  NOT NULL UNIQUE,
    auto_start_flag    TINYINT NOT NULL DEFAULT 0,
    always_on_top_flag TINYINT NOT NULL DEFAULT 0,
    show_plan_flag     TINYINT NOT NULL DEFAULT 1,
    show_timer_flag    TINYINT NOT NULL DEFAULT 1,
    show_memo_flag     TINYINT NOT NULL DEFAULT 1,
    create_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_appearance_setting
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id        BIGINT      NOT NULL UNIQUE,
    theme_mode     VARCHAR(16) NOT NULL DEFAULT 'dark',
    desktop_effect VARCHAR(32) NOT NULL DEFAULT 'immersive_glass',
    create_time    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_blacklist
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT   NOT NULL,
    blocked_user_id BIGINT   NOT NULL,
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_blocked (user_id, blocked_user_id)
);

CREATE TABLE IF NOT EXISTS friend_group
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id     BIGINT      NOT NULL,
    group_name  VARCHAR(32) NOT NULL,
    system_flag TINYINT     NOT NULL DEFAULT 0,
    sort_order  INT         NOT NULL DEFAULT 0,
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_friend_group_user_name (user_id, group_name),
    KEY idx_friend_group_user_sort (user_id, sort_order, id)
);

CREATE TABLE IF NOT EXISTS friend_request
(
    id                BIGINT PRIMARY KEY AUTO_INCREMENT,
    requester_user_id BIGINT       NOT NULL,
    target_user_id    BIGINT       NOT NULL,
    request_message   VARCHAR(120) NOT NULL DEFAULT '',
    status            VARCHAR(16)  NOT NULL DEFAULT 'pending',
    create_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_friend_request_pair (requester_user_id, target_user_id),
    KEY idx_friend_request_target_status (target_user_id, status, create_time),
    KEY idx_friend_request_requester_status (requester_user_id, status, create_time)
);

CREATE TABLE IF NOT EXISTS friend_relation
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id        BIGINT   NOT NULL,
    friend_user_id BIGINT   NOT NULL,
    group_id       BIGINT   NULL,
    create_time    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_friend_relation_user_friend (user_id, friend_user_id),
    KEY idx_friend_relation_user_group (user_id, group_id, create_time)
);

CREATE TABLE IF NOT EXISTS user_session
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id       BIGINT       NOT NULL,
    device_type   VARCHAR(32)  NOT NULL,
    device_slot   VARCHAR(32)  NOT NULL,
    device_id     VARCHAR(128) NOT NULL,
    session_token VARCHAR(64)  NOT NULL,
    status        TINYINT      NOT NULL DEFAULT 1,
    login_time    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    logout_time   DATETIME     NULL,
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_device_slot (user_id, device_slot),
    UNIQUE KEY uk_session_token (session_token)
);

CREATE TABLE IF NOT EXISTS study_team
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_name   VARCHAR(64) NOT NULL,
    invite_code VARCHAR(32) NOT NULL UNIQUE,
    owner_user_id BIGINT    NOT NULL,
    status      TINYINT     NOT NULL DEFAULT 1,
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS study_team_member
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id     BIGINT      NOT NULL,
    user_id     BIGINT      NOT NULL UNIQUE,
    role        VARCHAR(16) NOT NULL DEFAULT 'member',
    status      TINYINT     NOT NULL DEFAULT 1,
    joined_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_user (team_id, user_id),
    KEY idx_team_member_team_status (team_id, status),
    KEY idx_team_member_user_status (user_id, status)
);

CREATE TABLE IF NOT EXISTS study_team_invitation
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id         BIGINT      NOT NULL,
    inviter_user_id BIGINT      NOT NULL,
    invitee_user_id BIGINT      NOT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'pending',
    create_time     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_team_invitation_invitee_status (invitee_user_id, status, create_time),
    KEY idx_team_invitation_team_status (team_id, status, create_time)
);

CREATE TABLE IF NOT EXISTS study_team_reminder
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id       BIGINT      NOT NULL,
    from_user_id  BIGINT      NOT NULL,
    to_user_id    BIGINT      NOT NULL,
    reminder_type VARCHAR(32) NOT NULL DEFAULT 'study',
    content       VARCHAR(255) NOT NULL DEFAULT '',
    create_time   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_team_reminder_to_time (to_user_id, create_time),
    KEY idx_team_reminder_from_to_time (from_user_id, to_user_id, create_time)
);

CREATE TABLE IF NOT EXISTS study_team_chat_message
(
    id             BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id        BIGINT       NOT NULL,
    sender_user_id BIGINT       NOT NULL,
    content        VARCHAR(500) NOT NULL,
    masked_flag    TINYINT      NOT NULL DEFAULT 0,
    deleted_flag   TINYINT      NOT NULL DEFAULT 0,
    deleted_reason VARCHAR(255) NULL,
    deleted_time   DATETIME     NULL,
    create_time    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_team_chat_team_time (team_id, create_time, id),
    KEY idx_team_chat_sender_time (sender_user_id, create_time, id)
);

CREATE TABLE IF NOT EXISTS study_team_chat_read_state
(
    id                   BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id              BIGINT   NOT NULL,
    user_id              BIGINT   NOT NULL,
    last_read_message_id BIGINT   NOT NULL DEFAULT 0,
    last_read_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_time          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_chat_read_state_team_user (team_id, user_id),
    KEY idx_team_chat_read_state_user_time (user_id, update_time)
);

SET @team_chat_deleted_flag_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'study_team_chat_message'
              AND COLUMN_NAME = 'deleted_flag'
        ),
        'SELECT 1',
        'ALTER TABLE study_team_chat_message ADD COLUMN deleted_flag TINYINT NOT NULL DEFAULT 0 AFTER masked_flag'
    )
);
PREPARE team_chat_deleted_flag_stmt FROM @team_chat_deleted_flag_sql;
EXECUTE team_chat_deleted_flag_stmt;
DEALLOCATE PREPARE team_chat_deleted_flag_stmt;

SET @team_chat_deleted_reason_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'study_team_chat_message'
              AND COLUMN_NAME = 'deleted_reason'
        ),
        'SELECT 1',
        'ALTER TABLE study_team_chat_message ADD COLUMN deleted_reason VARCHAR(255) NULL AFTER deleted_flag'
    )
);
PREPARE team_chat_deleted_reason_stmt FROM @team_chat_deleted_reason_sql;
EXECUTE team_chat_deleted_reason_stmt;
DEALLOCATE PREPARE team_chat_deleted_reason_stmt;

SET @team_chat_deleted_time_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'study_team_chat_message'
              AND COLUMN_NAME = 'deleted_time'
        ),
        'SELECT 1',
        'ALTER TABLE study_team_chat_message ADD COLUMN deleted_time DATETIME NULL AFTER deleted_reason'
    )
);
PREPARE team_chat_deleted_time_stmt FROM @team_chat_deleted_time_sql;
EXECUTE team_chat_deleted_time_stmt;
DEALLOCATE PREPARE team_chat_deleted_time_stmt;

CREATE TABLE IF NOT EXISTS report_record
(
    id               BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_user_id   BIGINT       NOT NULL,
    report_type      VARCHAR(32)  NOT NULL,
    target_id        BIGINT       NOT NULL,
    target_user_id   BIGINT       NOT NULL,
    team_id          BIGINT       NULL,
    reason_text      VARCHAR(120) NOT NULL,
    description_text VARCHAR(255) NOT NULL DEFAULT '',
    status           VARCHAR(32)  NOT NULL DEFAULT 'pending',
    handled_user_id  BIGINT       NULL,
    handled_time     DATETIME     NULL,
    create_time      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_report_unique_user_target (report_user_id, report_type, target_id),
    KEY idx_report_status_time (status, create_time, id),
    KEY idx_report_target (report_type, target_id, create_time),
    KEY idx_report_target_user (target_user_id, create_time)
);

CREATE TABLE IF NOT EXISTS report_audit_record
(
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_id           BIGINT       NOT NULL,
    admin_user_id       BIGINT       NOT NULL,
    decision            VARCHAR(32)  NOT NULL,
    delete_content_flag TINYINT      NOT NULL DEFAULT 0,
    punishment_type     VARCHAR(32)  NOT NULL DEFAULT 'none',
    duration_days       INT          NOT NULL DEFAULT 0,
    reason_text         VARCHAR(255) NOT NULL DEFAULT '',
    create_time         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_report_audit_report_time (report_id, create_time, id)
);

CREATE TABLE IF NOT EXISTS punishment_record
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT       NOT NULL,
    report_id       BIGINT       NULL,
    punishment_type VARCHAR(32)  NOT NULL,
    status          VARCHAR(16)  NOT NULL DEFAULT 'active',
    duration_days   INT          NOT NULL DEFAULT 0,
    reason_text     VARCHAR(255) NOT NULL DEFAULT '',
    operator_user_id BIGINT      NULL,
    start_time      DATETIME     NOT NULL,
    end_time        DATETIME     NULL,
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_punishment_user_type_status (user_id, punishment_type, status, end_time),
    KEY idx_punishment_report (report_id)
);

CREATE TABLE IF NOT EXISTS daily_plan
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id     BIGINT      NOT NULL,
    plan_date   DATE        NOT NULL,
    plan_name   VARCHAR(64) NOT NULL DEFAULT 'Today',
    plan_type   VARCHAR(32) NOT NULL DEFAULT 'manual',
    create_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_plan_date (user_id, plan_date)
);

CREATE TABLE IF NOT EXISTS daily_plan_item
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    plan_id         BIGINT       NOT NULL,
    user_id         BIGINT       NOT NULL,
    title           VARCHAR(128) NOT NULL,
    status          TINYINT      NOT NULL DEFAULT 0,
    planned_minutes INT          NOT NULL DEFAULT 0,
    actual_minutes  INT          NOT NULL DEFAULT 0,
    start_slot      INT          NULL,
    end_slot        INT          NULL,
    sort_order      INT          NOT NULL DEFAULT 0,
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_plan_item_plan_id (plan_id),
    KEY idx_plan_item_user_date (user_id, sort_order)
);

SET @daily_plan_start_slot_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'daily_plan_item'
              AND COLUMN_NAME = 'start_slot'
        ),
        'SELECT 1',
        'ALTER TABLE daily_plan_item ADD COLUMN start_slot INT NULL AFTER actual_minutes'
    )
);
PREPARE daily_plan_start_slot_stmt FROM @daily_plan_start_slot_sql;
EXECUTE daily_plan_start_slot_stmt;
DEALLOCATE PREPARE daily_plan_start_slot_stmt;

SET @daily_plan_end_slot_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'daily_plan_item'
              AND COLUMN_NAME = 'end_slot'
        ),
        'SELECT 1',
        'ALTER TABLE daily_plan_item ADD COLUMN end_slot INT NULL AFTER start_slot'
    )
);
PREPARE daily_plan_end_slot_stmt FROM @daily_plan_end_slot_sql;
EXECUTE daily_plan_end_slot_stmt;
DEALLOCATE PREPARE daily_plan_end_slot_stmt;

CREATE TABLE IF NOT EXISTS weekly_plan_template
(
    id               BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id          BIGINT      NOT NULL,
    template_name    VARCHAR(64) NOT NULL,
    source_plan_name VARCHAR(64) NOT NULL DEFAULT 'Today',
    create_time      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_week_template_name (user_id, template_name)
);

CREATE TABLE IF NOT EXISTS weekly_plan_template_item
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    template_id     BIGINT       NOT NULL,
    user_id         BIGINT       NOT NULL,
    title           VARCHAR(128) NOT NULL,
    planned_minutes INT          NOT NULL DEFAULT 0,
    start_slot      INT          NULL,
    end_slot        INT          NULL,
    sort_order      INT          NOT NULL DEFAULT 0,
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_week_template_item_template_id (template_id),
    KEY idx_week_template_item_user_id (user_id)
);

CREATE TABLE IF NOT EXISTS study_timer_record
(
    id                       BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                  BIGINT       NOT NULL,
    task_name                VARCHAR(128) NOT NULL DEFAULT 'Focus session',
    planned_end_time         DATETIME     NOT NULL,
    actual_end_time          DATETIME     NULL,
    planned_minutes          INT          NOT NULL DEFAULT 0,
    duration_seconds         INT          NOT NULL DEFAULT 0,
    status                   VARCHAR(32)  NOT NULL DEFAULT 'active',
    bind_pomodoro_flag       TINYINT      NOT NULL DEFAULT 0,
    pomodoro_study_minutes   INT          NOT NULL DEFAULT 0,
    pomodoro_break_minutes   INT          NOT NULL DEFAULT 0,
    completed_pomodoro_count INT          NOT NULL DEFAULT 0,
    completion_notified_flag TINYINT      NOT NULL DEFAULT 0,
    create_time              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_study_timer_user_status (user_id, status),
    KEY idx_study_timer_create_time (create_time)
);

SET @study_timer_completion_notified_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'study_timer_record'
              AND COLUMN_NAME = 'completion_notified_flag'
        ),
        'SELECT 1',
        'ALTER TABLE study_timer_record ADD COLUMN completion_notified_flag TINYINT NOT NULL DEFAULT 0 AFTER completed_pomodoro_count'
    )
);
PREPARE study_timer_completion_notified_stmt FROM @study_timer_completion_notified_sql;
EXECUTE study_timer_completion_notified_stmt;
DEALLOCATE PREPARE study_timer_completion_notified_stmt;

CREATE TABLE IF NOT EXISTS memo_record
(
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id      BIGINT       NOT NULL,
    title        VARCHAR(128) NOT NULL DEFAULT '',
    content_text TEXT         NULL,
    sort_no      INT          NOT NULL DEFAULT 0,
    create_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_memo_record_user_time (user_id, update_time, id)
);

CREATE TABLE IF NOT EXISTS memo_check_item
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    memo_id     BIGINT       NOT NULL,
    item_text   VARCHAR(255) NOT NULL,
    checked_flag TINYINT     NOT NULL DEFAULT 0,
    sort_no     INT          NOT NULL DEFAULT 0,
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_memo_check_item_memo_sort (memo_id, sort_no, id)
);

CREATE TABLE IF NOT EXISTS app_notification
(
    id                BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id           BIGINT       NOT NULL,
    sender_user_id    BIGINT       NULL,
    notification_type VARCHAR(32)  NOT NULL,
    title             VARCHAR(64)  NOT NULL DEFAULT '',
    content           VARCHAR(255) NOT NULL DEFAULT '',
    related_type      VARCHAR(32)  NOT NULL DEFAULT '',
    related_id        BIGINT       NULL,
    read_flag         TINYINT      NOT NULL DEFAULT 0,
    create_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_notification_user_time (user_id, create_time),
    KEY idx_notification_user_read_time (user_id, read_flag, create_time)
);

CREATE TABLE IF NOT EXISTS check_in_record
(
    id                     BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                BIGINT   NOT NULL,
    check_in_date          DATE     NOT NULL,
    plan_completed_count   INT      NOT NULL DEFAULT 0,
    plan_total_count       INT      NOT NULL DEFAULT 0,
    study_duration_minutes INT      NOT NULL DEFAULT 0,
    create_time            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_check_in_date (user_id, check_in_date),
    KEY idx_check_in_user_date (user_id, check_in_date)
);

CREATE TABLE IF NOT EXISTS check_in_summary
(
    id                BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id           BIGINT   NOT NULL UNIQUE,
    consecutive_days  INT      NOT NULL DEFAULT 0,
    total_days        INT      NOT NULL DEFAULT 0,
    last_success_date DATE     NULL,
    create_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS check_in_fail_record
(
    id                     BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id                BIGINT       NOT NULL,
    check_in_date          DATE         NOT NULL,
    attempt_count          INT          NOT NULL DEFAULT 1,
    latest_reason          VARCHAR(255) NOT NULL,
    plan_completed_count   INT          NOT NULL DEFAULT 0,
    plan_total_count       INT          NOT NULL DEFAULT 0,
    study_duration_minutes INT          NOT NULL DEFAULT 0,
    last_attempt_time      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_time            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_check_in_fail_date (user_id, check_in_date),
    KEY idx_check_in_fail_user_date (user_id, check_in_date)
);
