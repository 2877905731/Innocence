---
schema_version: 1
document_type: contract_inventory
project_name: "Innocence"
read_before: docs/07-dataflow-and-module-map.md
evidence_policy:
  source_types:
    - controller
    - frontend_call
  source_code_proves_old_behavior_not_runtime_contract: true
  sample_policy:
    redacted: true
    forbidden:
      - token
      - cookie
      - real_name
      - identity_document
      - bank_account
      - real_amount
      - email_address
common_request_context:
  base_url: "http://localhost:8080（本地；生产未定）"
  authentication_method: "Authorization: Bearer {accessToken}"
  user_context_header: "X-User-Id（仅服务端从 token 解析，不作为请求入参）"
endpoints:
  - id: U01
    method: POST
    path: "/api/app/v1/auth/email/register"
    source_behavior: "邮箱注册（接口草案 4.1）"
    evidence_status: pending
    trigger: "P01 认证收尾时以真实请求回放核对"
  - id: U02
    method: POST
    path: "/api/app/v1/auth/login/password"
    source_behavior: "邮箱+密码登录（接口草案 4.1）"
    evidence_status: pending
    trigger: "P01 认证收尾时以真实请求回放核对"
  - id: U03
    method: POST
    path: "/api/app/v1/focus/session/start"
    source_behavior: "开始学习时段（接口草案 4.8）"
    evidence_status: pending
    trigger: "P02 定时收尾时以真实请求回放核对"
  - id: U24
    method: POST
    path: "/api/app/v1/focus/session/pause"
    source_behavior: "暂停当前用户的活动专注；冻结有效学习时长、剩余时间和番茄阶段，不把暂停时段计入学习统计"
    success: "返回 active=true、paused=true 的当前专注快照；服务端保存 pausedAt 与累计暂停秒数"
    failures: "未认证返回 401；没有活动专注或当前已暂停返回 404/400；只允许操作 token 所属用户的数据"
    evidence_status: client_server_implemented_unit_verified_http_pending
    trigger: "2026-09-10 已完成服务端当前用户状态校验、Flutter 在线/离线持久化和 3 项服务单测；真实 HTTP 回放待补"
  - id: U25
    method: POST
    path: "/api/app/v1/focus/session/resume"
    source_behavior: "继续当前用户已暂停的专注；按本次暂停时长顺延计划结束时间，保持剩余专注时长不变"
    success: "返回 active=true、paused=false 的当前专注快照；累计暂停秒数只增不减"
    failures: "未认证返回 401；没有已暂停专注或状态不匹配返回 404/400；只允许操作 token 所属用户的数据"
    evidence_status: client_server_implemented_unit_verified_http_pending
    trigger: "2026-09-10 已完成顺延结束时间、累计暂停秒数、Flutter 在线/离线恢复和服务单测；真实 HTTP 回放待补"
  - id: U04
    method: POST
    path: "/api/app/v1/check-in/submit"
    source_behavior: "手动签到（接口草案 4.9）"
    evidence_status: implementation_matched_sample_pending
    trigger: "P02 签到收尾时以真实请求回放核对"
  - id: U05
    method: GET
    path: "/api/app/v1/stats/trend"
    source_behavior: "趋势图数据 7d/30d（接口草案 4.11）"
    evidence_status: pending
    trigger: "P04 统计完善时以真实请求回放核对"
  - id: U06
    method: GET
    path: "/api/app/v1/home/overview"
    source_behavior: "首页聚合（接口草案 4.14）"
    evidence_status: pending
    trigger: "P02 首页重建时以真实请求回放核对"
  - id: U07
    method: POST
    path: "/api/app/v1/auth/password/reset"
    source_behavior: "邮箱验证码重置密码（接口草案 4.1）"
    evidence_status: implementation_matched_sample_pending
    trigger: "P01 认证收尾时以脱敏请求回放核对"
  - id: U08
    method: POST
    path: "/api/app/v1/auth/password/send-reset-code"
    source_behavior: "发送找回密码验证码（接口草案 4.1）"
    evidence_status: implementation_matched_sample_pending
    trigger: "P01 认证收尾时以脱敏请求回放核对"
  - id: U09
    method: GET
    path: "/api/app/v1/account/blacklist"
    source_behavior: "获取当前用户黑名单（接口草案 4.1）"
    evidence_status: http_replay_verified
    trigger: "2026-08-10 已以合成用户完成空/非空黑名单真实 HTTP 回放"
  - id: U10
    method: DELETE
    path: "/api/app/v1/account/blacklist/{targetUserId}"
    source_behavior: "解除当前用户的黑名单关系（接口草案 4.1）"
    evidence_status: http_replay_verified
    trigger: "2026-08-10 已完成所属用户解除与跨租户身份不匹配拒绝真实 HTTP 回放"
  - id: U11
    method: GET
    path: "/api/app/v1/account/sessions/current"
    source_behavior: "读取当前设备会话状态（接口草案 4.1）"
    evidence_status: http_replay_verified
    trigger: "2026-08-10 已完成手机与电脑并存、同槽桌面替换及旧会话拒绝真实 HTTP 回放"
  - id: U12
    method: POST
    path: "/api/app/v1/account/blacklist/{targetUserId}"
    source_behavior: "将目标用户加入当前用户黑名单（接口草案 4.1）"
    evidence_status: http_replay_verified
    trigger: "2026-08-10 已完成正常、本人、重复拉黑和跨租户身份不匹配真实 HTTP 回放"
  - id: U13
    method: POST
    path: "/api/app/v1/account/avatar/upload"
    source_behavior: "上传当前用户头像；服务端生成文件名并回写 avatarUrl（接口草案 4.1）"
    request: "multipart/form-data，字段 file；image/jpeg 或 image/png；最大 5 MiB"
    success: "HTTP 200，data.avatarUrl 为 public-path 下的相对 URL"
    failures: "缺失/超限/类型不支持/无效图片返回 HTTP 400 + code=1000；会话失效返回 HTTP 401 + code=2000；存储失败返回 HTTP 500 + code=9000"
    evidence_status: server_http_and_client_toolchain_verified_runtime_picker_pending
    trigger: "2026-08-10 已完成服务端正常/负向 HTTP 回放、Flutter pub get/analyze/test 与 Windows Release 构建；真实文件选择和 DPI 实机验收待补"
  - id: U14
    method: POST
    path: "/api/app/v1/sync/import-preview"
    source_behavior: "登录后提交仅含类型、数量、日期范围和修订摘要的本机 manifest，由服务端返回当前账号对比预览；确认前不得上传业务正文"
    request: "localProfileId + pendingOperationCount + dailyPlanDates + 按类型计数；不含 payload 正文"
    success: "返回 token 所属目标账号、待导入数、云端日期冲突数与冲突日期"
    evidence_status: client_server_implemented_unit_verified_http_pending
    trigger: "2026-09-09 已完成客户端 manifest、服务端当前账号解析与冲突预检；Flutter/Maven 全量回归通过，真实 HTTP 回放待补"
  - id: U15
    method: POST
    path: "/api/app/v1/sync/import"
    source_behavior: "用户确认目标账号后，按 operationId/clientEntityId 幂等导入离线实体并逐项返回 accepted/rejected/conflict"
    request: "localProfileId + targetUserNo + conflictStrategy(keep_server|overwrite) + 最多 500 条 typed outbox operation"
    success: "按日模板→日计划→年度区间→专注→备忘录→签到意图顺序逐项事务导入；只有 accepted 在本机标记 synced，原始本地业务数据不删除"
    failures: "目标账号不匹配整体 HTTP 403；单项非法/缺绑定返回 rejected；日期或模板冲突返回 conflict"
    evidence_status: client_server_implemented_unit_verified_http_pending
    trigger: "2026-09-09 已完成幂等结果表、当前用户隔离、冲突策略、本地结果回写与负向单测；真实 HTTP 重放/断线续传待补"
  - id: U16
    method: GET
    path: "/api/app/v1/plans/day-templates"
    source_behavior: "读取可复用的单日日程模板；替代把日模板命名为 weekly template 的新契约"
    evidence_status: client_server_implemented_unit_verified
    trigger: "新日模板路由已实现；旧 /weekly-templates 继续作为兼容接口"
  - id: U17
    method: POST
    path: "/api/app/v1/plans/day-templates"
    source_behavior: "把已保存且仍可编辑的短计划另存为日模板"
    evidence_status: client_server_implemented_unit_verified
    trigger: "短计划保存后继续编辑与另存日模板已实现；字段缺失/重名真实 HTTP 回放待补"
  - id: U18
    method: POST
    path: "/api/app/v1/plans/day-templates/{templateId}/apply-batch"
    source_behavior: "将日模板套用到月历中的一个或多个日期，并显式处理已有计划的覆盖/跳过/取消"
    evidence_status: client_server_implemented_unit_verified
    trigger: "覆盖/跳过显式策略、重复日期去重和跨租户模板拒绝已实现并有服务单测"
  - id: U19
    method: GET
    path: "/api/app/v1/plans/month?month=YYYY-MM"
    source_behavior: "返回完整月份的日期摘要，支撑长计划月历和前后月滑动"
    evidence_status: client_server_implemented_unit_verified
    trigger: "完整月历与横向前后月已实现；闰年 2 月 29 天服务/模型测试通过"
  - id: U20
    method: GET
    path: "/api/app/v1/plans/year?year=YYYY"
    source_behavior: "返回年度 12 个月摘要及年度计划区间，支撑超长计划年历"
    evidence_status: client_server_implemented_unit_verified
    trigger: "12 月摘要、年度区间和重叠展示已实现；空年份 12 月结构测试通过"
  - id: U21
    method: POST
    path: "/api/app/v1/plans/annual-segments"
    source_behavior: "按月为最小单位创建年度计划区间"
    evidence_status: client_server_implemented_unit_verified
    trigger: "按月拖动创建、重叠区间与 1..12 边界校验已实现"
  - id: U22
    method: PUT
    path: "/api/app/v1/plans/annual-segments/{segmentId}"
    source_behavior: "调整年度计划区间的起止月份、标题、颜色键或排序"
    evidence_status: client_server_implemented_unit_verified
    trigger: "编辑与 revision 冲突拒绝已实现并通过单测；真实 HTTP 回放待补"
  - id: U23
    method: DELETE
    path: "/api/app/v1/plans/annual-segments/{segmentId}"
    source_behavior: "删除当前用户的年度计划区间；离线端在 outbox 中保留删除操作作为补传墓碑"
    evidence_status: client_server_implemented_unit_verified
    trigger: "客户端删除墓碑、服务端当前用户限定删除与同步绑定解析已实现；重复删除真实 HTTP 回放待补"
preview_queue:
  - priority: P1
    sample: "待收样本：认证/学习/签到/统计/首页聚合 5 组正常+空+边界请求"
    requirements:
      - preserve_field_structure
      - replace_sensitive_values
compatibility_decisions:
  - id: DEC-001
    difference: "UI 全面推翻重建不影响接口契约；页面重写不改变接口边界"
    decision: "接口清单草案继续作为契约源，UI 重建期间不回改接口"
    checkpoint: "DEC-0004（RESUME 用户决策）"
  - id: DEC-002
    difference: "旧实现把长计划定义为周概览、把日模板命名为 weekly template，并让超长计划复用逐周日计划"
    decision: "自 2026-09-08 起权威语义改为短=日、长=月、超长=年；旧 /week 与 /weekly-templates 仅作迁移兼容，不再指导新 UI 或新数据模型"
    checkpoint: "DEC-0027 / progress 0040"
  - id: DEC-003
    difference: "旧同步默认已登录且全局最后修改覆盖"
    decision: "增加未登录 local profile 和登录后导入确认；按实体类型执行冲突规则，服务端身份始终从 token 解析"
    checkpoint: "DEC-0027 / progress 0040"
undocumented_route_families:
  - family: "/api/admin/v1/**"
    evidence_status: pending
    trigger: "P04 后台完善时核对实现与草案差异"
---

# 契约清单说明

本文件为接口清单草案（`docs/planning/Innocence-接口清单草案.md`）的治理层索引：

- 完整接口清单（前台 14 组 + 后台 6 组 + WebSocket 事件表）以**草案文档为准**
- 本文件登记「实现后回放核对」的核验点，避免草案与代码漂移
- 数据库契约以 `docs/planning/Innocence-数据库表结构草案.md` 为准（第一批 42 表 + 第二批 13 表）
