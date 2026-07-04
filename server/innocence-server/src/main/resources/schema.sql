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

CREATE TABLE IF NOT EXISTS user_blacklist
(
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         BIGINT   NOT NULL,
    blocked_user_id BIGINT   NOT NULL,
    create_time     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_blocked (user_id, blocked_user_id)
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
    sort_order      INT          NOT NULL DEFAULT 0,
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_plan_item_plan_id (plan_id),
    KEY idx_plan_item_user_date (user_id, sort_order)
);
