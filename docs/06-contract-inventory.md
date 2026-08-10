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
  - id: U04
    method: POST
    path: "/api/app/v1/check-in/submit"
    source_behavior: "手动签到（接口草案 4.9）"
    evidence_status: pending
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
