---
schema_version: 1
document_type: contract_and_compatibility_rules
project_name: "Innocence"
upstream_contract:
  required_before_client: true
  endpoint_record_fields:
    - environment_and_base_url_without_secrets
    - method
    - path
    - query
    - request_headers
    - request_body
    - authentication_method
    - user_context_source
    - success_status_and_content_type
    - pagination_and_ordering
    - field_names_types_null_empty_defaults
    - date_timezone_format
    - error_statuses_401_403_404_409_429_5xx
    - timeout_idempotency_retry_rate_limit_cache
  required_samples:
    - normal
    - empty
    - boundary
    - redacted_error
  url_and_single_success_json_is_sufficient: false
dto_layers:
  - upstream_dto
  - canonical_model
  - downstream_request
upstream_to_downstream_map_passthrough: forbidden
api:
  public_paths_versioned: true
  errors_include:
    - code
    - message
    - request_id
    - field_details
  errors_must_not_expose:
    - token
    - internal_url
    - stack_trace
    - cross_user_data
  side_effecting_requests_require_idempotency_key: conditional
  idempotency_required_for:
    - offline_replayable_write
    - batch_template_apply
    - annual_segment_write
authentication_and_tenancy:
  local_test_identity_allowed: true
  production_profile_in_local_tests: forbidden
  cross_user_negative_tests_before_cutover: true
  unauthenticated_offline_profile_is_server_identity: false
  offline_owner_scope_isolation_required: true
sensitive_data:
  logs_allow:
    - internal_business_id
    - count
    - result
    - duration
    - request_id
  samples_must_be_redacted_or_synthetic: true
  secrets_storage: env_or_untracked_local_config
  sync_logs_forbid:
    - token
    - email_address
    - verification_code
    - full_request
    - business_content
compatibility:
  text_output: exact_bytes
  structured_output: structure_and_business_values
  behavior_change_requires: DECISION_or_new_version
  external_calls:
    timeout_explicit: true
    safe_idempotent_retries_only: true
  contract_tests: recorded_replay_or_stub
---

# 契约与兼容性规则

本文提炼自 `docs/planning/Innocence-接口清单草案.md`（统一约定章节）与 `docs/planning/Innocence-数据库表结构草案.md`，作为后端实现与前端调用的硬性约定。接口全量清单以 `docs/06-contract-inventory.md` 为索引。

## 统一接口约定（已确认）

- 前台接口前缀：`/api/app/v1`；后台：`/api/admin/v1`；实时通道：`/ws/app`
- 鉴权：登录返回 `accessToken`，请求头 `Authorization: Bearer {token}`；设备信息 `X-Device-Id`、`X-Device-Type`（`mobile` / `desktop`）
- 独立管理员网页使用保留的 `X-Device-Type: admin_web` 与 `user_session.device_slot=admin_web`；仅 `/api/admin/v1/auth/login` 可在管理员白名单校验后签发该会话，普通用户登录路由不能申请此类型。当前后台 Controller 仍支持已有 Flutter 管理入口；网页请求以同域 `/api` 转发。
- 统一返回结构：`{ code, message, data, requestId, serverTime }`，`code=0` 成功，非 0 为可读业务错误码（不裸抛 HTTP 500）
- 分页结构：`{ pageNo, pageSize, total, list }`
- 时间统一 ISO 8601；需同步的写接口返回 `syncVersion` / `revision` + `updateTime`；客户端提交带 `clientTime` / `clientVersion` / `deviceId`，离线可重放写操作还必须带稳定的 `clientEntityId`、`operationId` 和 `baseRevision`
- 头像上传走 `multipart/form-data`，本地映射目录存储，后续切对象存储
- 头像上传固定使用 `POST /api/app/v1/account/avatar/upload`：字段名为 `file`，仅接受 `image/jpeg` 与 `image/png`，单文件上限 5 MiB；服务端不信任原始文件名，生成 UUID 文件名并写入 `innocence.avatar.storage-dir`
- 上传成功返回 `{ avatarUrl }`，URL 为 `innocence.avatar.public-path/{uuid}.{jpg|png}`，并同步更新当前登录用户的 `app_user.avatar_url`
- 缺失文件、超限、类型不支持、图片内容无效返回 `1000`；未登录仍由会话拦截返回 `401/2000`；存储失败返回 `9000`，错误响应不得暴露本地路径

## 通道划分（已确认）

| 通道 | 内容 |
|---|---|
| REST | 注册登录、资料、好友/团队/计划/备忘录 CRUD、统计拉取、通知列表、历史消息 |
| WebSocket | 私信/群聊实时收发、提醒、完成通知、未读变化、当前学习状态同步 |
| 系统推送 | 手机推送、桌面系统通知、公告触达（应用不在前台时） |

## 关键兼容性约束

1. 业务失败不得只返回 HTTP 500，必须带可读错误码
2. 聊天消息、提醒、通知统一抽象未读状态，禁止各模块单独算红点
3. 首页与 Windows 自适应桌面摘要走聚合接口（`/home/overview`、`/home/widget`），禁止前端一次拉十几个接口
4. `/home/widget` 保留为 Small Canvas / Focus Orb 的轻量摘要投影接口，支持高频刷新；接口命名不约束客户端必须实现为固定挂件
5. WebSocket 断开时前端回退「接口拉取 + 系统通知」模式，不允许数据丢失
6. 跨用户数据访问必须有负向测试（非好友看资料、非队友看学习摘要必须被拒绝）
7. 未登录 local profile 只读写本机数据库，不调用受保护接口，也不使用固定/伪造 userId；登录后先展示导入预览和目标账号，确认前不得上传业务正文
8. 离线资料、账号缓存和服务端租户按 `ownerScope` 隔离；服务端数据归属只从 Bearer token 解析，`clientEntityId`/`operationId` 仅用于幂等
9. 日计划、备忘录、专注事件、年度区间和签到意图按各自规则解决冲突，禁止全局静默套用“最后修改覆盖”
10. 计划权威语义为短=日、长=月、超长=年；旧 `/study/plans/week` 与 `/study/plans/weekly-templates` 仅作迁移兼容
