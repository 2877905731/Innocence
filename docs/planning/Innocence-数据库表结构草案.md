# Innocence 数据库表结构草案

## 1. 文档说明

- 数据库类型：MySQL 8.x
- 字符集建议：`utf8mb4`
- 排序规则建议：`utf8mb4_0900_ai_ci`
- 设计目标：优先覆盖 `Innocence` 第一版可落地功能，兼顾后续扩展
- 建议命名风格：表名使用小写下划线，主键统一使用 `bigint`

## 2. 设计原则

- 先满足第一版，不为远期微服务过早拆库
- 强业务表保留 `create_time`、`update_time`
- 逻辑删除仅用于需要追溯的数据，纯临时关系可物理删除
- 需要审计的后台与处罚类数据，尽量不物理删除
- 高并发读取的数据以汇总表、状态表辅助，不只依赖明细表

## 3. 核心模块总览

按当前计划书，第一版数据库主要覆盖这些模块：

- 用户与账户基础
- 设备与同步基础
- 好友模块
- 团队模块
- 私信 / 团队交流 / 提醒 / 队友进度可见
- 学习计划
- 定时系统
- 签到系统
- 备忘录
- 统计中心
- 系统通知
- 系统设置
- 后台管理
- 权限与内容安全基础

## 4. 表结构草案

### 4.1 用户与账户基础

#### `user`

用途：用户主表，承载账户主体信息。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 用户主键 |
| user_no | varchar(32) UK | 用户号，对外搜索用 |
| nickname | varchar(64) | 昵称 |
| avatar_url | varchar(255) | 头像地址 |
| status | tinyint | 状态：1正常 2禁言 3封号 4注销 |
| last_login_time | datetime | 最近登录时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_user_no`
- `idx_nickname`
- `idx_status`

#### `user_auth`

用途：账号认证表，支撑邮箱 + 密码 / 邮箱 + 验证码。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| auth_type | varchar(32) | 认证类型，首版固定 `email` |
| auth_account | varchar(128) UK | 邮箱 |
| password_hash | varchar(255) | 密码哈希 |
| password_salt | varchar(64) | 盐值，可选 |
| is_verified | tinyint | 邮箱是否已验证 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_auth_account`
- `idx_user_id`

#### `user_profile`

用途：用户扩展资料。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| bio | varchar(255) | 简介，可先预留 |
| timezone | varchar(64) | 时区 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `user_privacy_setting`

用途：隐私设置。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| allow_friend_view_profile | tinyint | 仅好友可看资料 |
| allow_teammate_view_study | tinyint | 仅队友可见学习数据 |
| allow_stranger_message | tinyint | 陌生人私信开关，首版应为关闭 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `user_blacklist`

用途：黑名单关系。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 拉黑人 |
| blocked_user_id | bigint | 被拉黑人 |
| create_time | datetime | 创建时间 |

索引建议：

- `uk_user_blocked`
- `idx_blocked_user_id`

### 4.2 设备与同步基础

#### `user_device`

用途：设备信息表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| device_type | varchar(32) | `mobile` / `desktop` |
| device_no | varchar(128) | 设备唯一标识 |
| device_name | varchar(128) | 设备名称 |
| os_type | varchar(32) | 系统类型 |
| last_active_time | datetime | 最近活跃时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_device_no`
- `idx_user_device_type`

#### `user_device_session`

用途：登录会话，控制 1 台手机 + 1 台电脑。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| device_id | bigint | 设备 ID |
| token_version | varchar(64) | 会话版本或登录态标识 |
| login_time | datetime | 登录时间 |
| expire_time | datetime | 过期时间 |
| status | tinyint | 1在线 2失效 3下线 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `sync_task`

用途：同步任务主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| source_device_id | bigint | 来源设备 |
| biz_type | varchar(32) | 业务类型：plan/memo/notice/state |
| biz_id | bigint | 业务主键 |
| sync_status | tinyint | 1待同步 2成功 3失败 |
| sync_version | bigint | 版本号 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `sync_log`

用途：同步日志明细。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| sync_task_id | bigint | 同步任务 ID |
| target_device_id | bigint | 目标设备 ID |
| result_status | tinyint | 结果状态 |
| error_msg | varchar(255) | 错误信息 |
| create_time | datetime | 创建时间 |

#### `offline_sync_record`

用途：离线补传记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| device_id | bigint | 设备 ID |
| biz_type | varchar(32) | 业务类型 |
| biz_id | bigint | 业务 ID |
| payload_json | json | 待补传内容 |
| sync_status | tinyint | 1待传 2成功 3失败 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 4.3 好友模块

#### `friend_request`

用途：好友申请。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| from_user_id | bigint | 发起人 |
| to_user_id | bigint | 接收人 |
| request_message | varchar(255) | 申请备注 |
| status | tinyint | 1待处理 2已同意 3已拒绝 4已撤回 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `idx_to_user_status`
- `idx_from_user_status`

#### `friend_relation`

用途：好友关系。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| friend_user_id | bigint | 好友 ID |
| source_type | varchar(32) | 来源：search/invite/team |
| create_time | datetime | 创建时间 |

索引建议：

- `uk_user_friend`
- `idx_friend_user_id`

说明：

- 建议双向各存一条，方便直接查好友列表。

#### `friend_group`

用途：好友分组。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 所属用户 |
| group_name | varchar(64) | 分组名称 |
| sort_no | int | 排序 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `friend_group_member`

用途：好友分组映射。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| group_id | bigint | 分组 ID |
| friend_user_id | bigint | 好友用户 ID |
| create_time | datetime | 创建时间 |

### 4.4 团队模块

#### `team`

用途：团队主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_name | varchar(64) | 团队名称 |
| owner_user_id | bigint | 队长 |
| status | tinyint | 1正常 2已解散 |
| dismiss_time | datetime | 解散时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `team_member`

用途：团队成员关系。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| user_id | bigint | 用户 ID |
| role_type | varchar(32) | 角色，首版 `owner` / `member` |
| join_time | datetime | 加入时间 |
| status | tinyint | 1在队 2已移除 3已退出 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_team_user`
- `idx_user_id`

#### `team_invite_code`

用途：团队邀请码。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| invite_code | varchar(32) UK | 邀请码 |
| expire_time | datetime | 过期时间 |
| status | tinyint | 1有效 2失效 |
| create_time | datetime | 创建时间 |

#### `team_invitation`

用途：团队邀请。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| inviter_user_id | bigint | 邀请人 |
| invitee_user_id | bigint | 被邀请人，允许空时配合邀请码场景扩展 |
| status | tinyint | 1待处理 2已接受 3已拒绝 4已失效 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `team_member_remove_record`

用途：移除成员记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| removed_user_id | bigint | 被移除用户 |
| operator_user_id | bigint | 操作人 |
| reason | varchar(255) | 原因 |
| create_time | datetime | 创建时间 |

#### `team_dismiss_record`

用途：团队解散记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| operator_user_id | bigint | 操作人 |
| create_time | datetime | 创建时间 |

### 4.5 私信 / 团队交流 / 提醒

#### `private_chat_session`

用途：私信会话。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_a_id | bigint | 用户 A |
| user_b_id | bigint | 用户 B |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_user_pair`

#### `private_chat_message`

用途：私信消息，仅文字。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| session_id | bigint | 会话 ID |
| from_user_id | bigint | 发送人 |
| content_text | text | 文本内容 |
| read_status | tinyint | 1未读 2已读 |
| create_time | datetime | 创建时间 |

#### `team_chat_message`

用途：团队群聊消息。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| from_user_id | bigint | 发送人 |
| content_text | text | 文本内容 |
| message_status | tinyint | 1正常 2删除 3屏蔽 |
| create_time | datetime | 创建时间 |

索引建议：

- `idx_team_create_time`

#### `remind_record`

用途：提醒记录，支持提醒全队或单人。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| team_id | bigint | 团队 ID |
| from_user_id | bigint | 发起人 |
| target_user_id | bigint | 被提醒人，提醒全队时可为空 |
| remind_scope | varchar(32) | `team_all` / `single_user` |
| remind_text | varchar(255) | 提醒文案 |
| create_time | datetime | 创建时间 |

#### `unread_state`

用途：未读状态汇总。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| biz_type | varchar(32) | `private_chat` / `team_chat` / `notification` |
| biz_id | bigint | 业务 ID |
| unread_count | int | 未读数 |
| update_time | datetime | 更新时间 |

### 4.6 学习计划

#### `study_plan`

用途：学习计划主表，统一短计划 / 长计划 / 超长计划。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| plan_type | varchar(32) | `short_day` / `long_week` / `ultra_day_range` |
| plan_name | varchar(128) | 计划名称 |
| start_date | date | 开始日期 |
| end_date | date | 结束日期 |
| status | tinyint | 1进行中 2完成 3失败 4废弃 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `idx_user_plan_type`
- `idx_start_date`

#### `study_plan_block`

用途：短计划时间块、长计划按天套用块。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| plan_id | bigint | 计划 ID |
| block_name | varchar(128) | 时段名称 |
| block_date | date | 所属日期 |
| start_time | datetime | 开始时间 |
| end_time | datetime | 结束时间 |
| duration_minutes | int | 时长分钟 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `study_plan_template`

用途：日计划模板。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| template_name | varchar(128) | 模板名 |
| source_plan_id | bigint | 来源短计划 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `study_plan_progress`

用途：计划清单项。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| plan_id | bigint | 计划 ID |
| item_name | varchar(128) | 清单项名称 |
| item_level | varchar(32) | short/long/ultra |
| sort_no | int | 排序 |
| status | tinyint | 1待完成 2已完成 3失败 |
| complete_time | datetime | 完成时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `study_plan_fail_record`

用途：计划失败记录区。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| plan_id | bigint | 计划 ID |
| progress_id | bigint | 清单项 ID，可空 |
| fail_type | varchar(32) | `plan_unfinished` / `check_in_failed` |
| fail_date | date | 失败日期 |
| remark | varchar(255) | 备注 |
| create_time | datetime | 创建时间 |

说明：

- 该表同时承接学习计划失败记录与签到失败记录区，符合当前已确认规则。

### 4.7 定时系统

#### `study_timer_record`

用途：学习时长记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| plan_id | bigint | 关联计划，可空 |
| start_time | datetime | 开始时间 |
| expected_end_time | datetime | 预计结束时间 |
| actual_end_time | datetime | 实际结束时间 |
| duration_minutes | int | 累计时长 |
| status | tinyint | 1进行中 2正常结束 3手动结束 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `pomodoro_config`

用途：番茄配置。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| study_minutes | int | 学习分钟数 |
| break_minutes | int | 休息分钟数 |
| bind_timer_flag | tinyint | 是否关联学习时长 |
| cycle_count | int | 循环次数，不关联时可用 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `pomodoro_cycle_record`

用途：番茄循环记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| timer_record_id | bigint | 学习时长记录 ID |
| cycle_no | int | 第几轮 |
| cycle_type | varchar(32) | `study` / `break` |
| start_time | datetime | 开始时间 |
| end_time | datetime | 结束时间 |
| status | tinyint | 1完成 2中断 |
| create_time | datetime | 创建时间 |

#### `study_timer_state`

用途：当前计时状态缓存表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| timer_record_id | bigint | 当前计时记录 |
| current_status | varchar(32) | `idle` / `timing` / `break` |
| update_time | datetime | 更新时间 |

### 4.8 签到系统

#### `check_in_record`

用途：每日签到记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| check_in_date | date | 签到日期 |
| success_flag | tinyint | 是否成功 |
| click_time | datetime | 点击时间 |
| plan_completed_flag | tinyint | 当天计划是否完成 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

索引建议：

- `uk_user_check_in_date`

#### `check_in_summary`

用途：签到汇总，便于快速读首页。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| consecutive_days | int | 连续坚持天数 |
| total_days | int | 累计坚持天数 |
| total_minutes | int | 累计坚持时长 |
| update_time | datetime | 更新时间 |

#### `check_in_fail_record`

用途：签到失败明细，可选单独留表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| check_in_date | date | 日期 |
| reason | varchar(255) | 失败原因 |
| create_time | datetime | 创建时间 |

说明：

- 虽然展示层与学习计划失败记录共用失败记录区，但数据层建议仍保留独立表，便于统计和追溯。

### 4.9 备忘录

#### `memo_record`

用途：备忘录主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 用户 ID |
| title | varchar(128) | 标题，可空 |
| content_text | text | 文本内容 |
| sort_no | int | 排序 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `memo_check_item`

用途：备忘录清单项。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| memo_id | bigint | 备忘录 ID |
| item_text | varchar(255) | 清单项内容 |
| checked_flag | tinyint | 是否勾选 |
| sort_no | int | 排序 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 4.10 通知系统

#### `notification_record`

用途：通知主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 接收用户 |
| notification_type | varchar(32) | `friend_apply` / `team_invite` / `team_remind` / `team_done` / `check_in_result` / `system_announcement` |
| title | varchar(128) | 标题 |
| content_text | varchar(255) | 内容 |
| biz_id | bigint | 关联业务 ID |
| action_type | varchar(32) | 是否可操作 |
| read_flag | tinyint | 已读状态 |
| expire_time | datetime | 过期时间，默认 30 天 |
| create_time | datetime | 创建时间 |

索引建议：

- `idx_user_read_flag`
- `idx_expire_time`

#### `notification_read_state`

用途：通知读状态扩展表，可按需保留。

#### `notification_delivery_record`

用途：通知投递明细。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| notification_id | bigint | 通知 ID |
| delivery_channel | varchar(32) | `in_app` / `mobile_push` / `desktop_system` |
| delivery_status | tinyint | 1成功 2失败 |
| fail_reason | varchar(255) | 失败原因 |
| create_time | datetime | 创建时间 |

#### `system_announcement`

用途：系统公告。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| title | varchar(128) | 标题 |
| content_text | text | 内容 |
| publish_status | tinyint | 1草稿 2已发布 3下线 |
| publish_time | datetime | 发布时间 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 4.11 系统设置

#### `user_setting`

用途：用户设置主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| theme_mode | varchar(32) | `light` / `dark` / `follow_system` |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `user_notification_setting`

用途：通知设置。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| mobile_push_flag | tinyint | 手机推送开关 |
| desktop_notify_flag | tinyint | 桌面通知开关 |
| teammate_remind_flag | tinyint | 队友提醒开关 |
| system_announcement_flag | tinyint | 系统公告开关 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `user_widget_setting`

用途：桌面挂件设置。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| auto_start_flag | tinyint | 开机自启 |
| always_on_top_flag | tinyint | 是否置顶 |
| show_plan_flag | tinyint | 显示计划 |
| show_timer_flag | tinyint | 显示倒计时 |
| show_memo_flag | tinyint | 显示备忘录 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `user_appearance_setting`

用途：外观设置。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint UK | 用户 ID |
| desktop_glass_flag | tinyint | 毛玻璃效果开关，可默认开 |
| transparency_level | tinyint | 透明度等级 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

### 4.12 权限与内容安全 / 后台

#### `report_record`

用途：举报主表。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| report_user_id | bigint | 举报人 |
| report_type | varchar(32) | 当前首版为 `team_chat` |
| target_id | bigint | 被举报内容 ID |
| reason_text | varchar(255) | 举报原因 |
| status | tinyint | 1待处理 2已处理 3已驳回 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `report_target`

用途：举报对象冗余表，可按需保留。

#### `report_audit_record`

用途：举报处理记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| report_id | bigint | 举报 ID |
| admin_user_id | bigint | 管理员 |
| action_type | varchar(32) | delete/warn/mute/ban/reject |
| action_result | varchar(255) | 结果说明 |
| create_time | datetime | 创建时间 |

#### `punishment_record`

用途：处罚记录。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| user_id | bigint | 被处罚用户 |
| punishment_type | varchar(32) | warn/mute/ban |
| start_time | datetime | 开始时间 |
| end_time | datetime | 结束时间 |
| reason_text | varchar(255) | 原因 |
| operator_admin_id | bigint | 操作管理员 |
| create_time | datetime | 创建时间 |

#### `sensitive_word`

用途：敏感词库。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| word_text | varchar(128) | 敏感词 |
| handle_type | varchar(32) | replace/block |
| replacement_text | varchar(128) | 替换内容 |
| status | tinyint | 启用状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `content_security_log`

用途：内容安全处理日志。

#### `admin_user`

用途：管理员账号。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| username | varchar(64) UK | 管理员账号 |
| password_hash | varchar(255) | 密码哈希 |
| status | tinyint | 状态 |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### `admin_operation_log`

用途：后台操作日志。

建议字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint PK | 主键 |
| admin_user_id | bigint | 管理员 |
| operation_type | varchar(64) | 操作类型 |
| target_type | varchar(64) | 目标类型 |
| target_id | bigint | 目标 ID |
| detail_json | json | 操作详情 |
| create_time | datetime | 创建时间 |

#### `admin_notification_task`

用途：后台定向通知任务。

#### `report_review_record`

用途：举报复查记录。

## 5. 表关系建议

### 5.1 账户关系主线

- `user` 1:1 `user_auth`
- `user` 1:1 `user_profile`
- `user` 1:1 `user_privacy_setting`
- `user` 1:N `user_device`
- `user` 1:N `user_blacklist`

### 5.2 社交关系主线

- `user` 1:N `friend_request`
- `user` N:N `friend_relation`
- `user` 1:N `friend_group`
- `friend_group` 1:N `friend_group_member`

### 5.3 团队关系主线

- `team` 1:N `team_member`
- `team` 1:N `team_invitation`
- `team` 1:N `team_chat_message`
- `team` 1:N `remind_record`

### 5.4 学习执行主线

- `study_plan` 1:N `study_plan_block`
- `study_plan` 1:N `study_plan_progress`
- `study_plan` 1:N `study_timer_record`
- `study_timer_record` 1:N `pomodoro_cycle_record`
- `study_plan` / `check_in_record` -> `study_plan_fail_record`

## 6. 第一版必须优先落地的表

以下表建议作为 MVP 第一批必须实现：

- `user`
- `user_auth`
- `user_profile`
- `user_privacy_setting`
- `user_blacklist`
- `user_device`
- `user_device_session`
- `friend_request`
- `friend_relation`
- `friend_group`
- `friend_group_member`
- `team`
- `team_member`
- `team_invite_code`
- `team_invitation`
- `team_chat_message`
- `remind_record`
- `notification_record`
- `notification_delivery_record`
- `study_plan`
- `study_plan_block`
- `study_plan_template`
- `study_plan_progress`
- `study_plan_fail_record`
- `study_timer_record`
- `pomodoro_config`
- `pomodoro_cycle_record`
- `study_timer_state`
- `check_in_record`
- `check_in_summary`
- `memo_record`
- `memo_check_item`
- `user_setting`
- `user_notification_setting`
- `user_widget_setting`
- `user_appearance_setting`
- `report_record`
- `report_audit_record`
- `punishment_record`
- `admin_user`
- `admin_operation_log`

## 7. 第二批可延后实现的表

可在第一版跑通后补充：

- `sync_task`
- `sync_log`
- `offline_sync_record`
- `unread_state`
- `check_in_fail_record`
- `stats_summary`
- `stats_trend`
- `completion_rate_stats`
- `failure_stats`
- `system_announcement`
- `report_review_record`
- `content_security_log`
- `admin_notification_task`

## 8. 索引与性能建议

- 所有外键关联字段建立普通索引
- 高频列表页按 `user_id + create_time` 或 `team_id + create_time` 建联合索引
- 通知、私信、团队群聊这类按时间倒序读取的表，优先索引时间字段
- 统计图和首页摘要尽量走汇总表，不要直接扫大明细表
- 团队人数上限仅 5 人，团队统计可先用轻量聚合

## 9. 建议的枚举统一

建议在 Java 后端中统一维护以下枚举：

- 用户状态枚举
- 设备类型枚举
- 好友申请状态枚举
- 团队邀请状态枚举
- 团队角色枚举
- 计划类型枚举
- 计划状态枚举
- 计时状态枚举
- 番茄周期类型枚举
- 通知类型枚举
- 处罚类型枚举
- 举报状态枚举

## 10. 下一步建议

基于这份数据库草案，最自然的下一步有两个：

1. 输出 `前后端接口清单`
2. 输出 `MVP 第一版功能范围`

如果你愿意，我下一条就可以继续接着把 `接口清单` 写出来，并且按你现有栈直接贴近 `Spring Boot + MyBatis` 的实现方式。 
