CREATE TABLE IF NOT EXISTS app_registration_policy (
    id TINYINT PRIMARY KEY,
    enabled TINYINT NOT NULL DEFAULT 1,
    updated_by BIGINT NULL,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT IGNORE INTO app_registration_policy (id, enabled) VALUES (1, 1);

CREATE TABLE IF NOT EXISTS admin_account_action (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    operator_user_id BIGINT NOT NULL,
    target_user_id BIGINT NULL,
    action_code VARCHAR(32) NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_admin_account_action_time (create_time)
);
