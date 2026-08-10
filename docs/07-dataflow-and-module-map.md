---
schema_version: 1
document_type: dataflow_and_module_map
project_name: "Innocence"
contract_inventory_path: docs/06-contract-inventory.md
topology:
  nodes:
    - id: flutter_mobile
      name: "Flutter 手机端 App（Android）"
      owner: "Innocence"
    - id: flutter_desktop
      name: "Flutter 桌面端（Windows 自适应 Canvas + Focus Orb）"
      owner: "Innocence"
    - id: backend
      name: "Spring Boot 后端（innocence-server）"
      owner: "Innocence"
    - id: db
      name: "MySQL 8 + Redis"
      owner: "Innocence"
  edges:
    - from: flutter_mobile
      to: backend
      call: "REST /api/app/v1 + WebSocket /ws/app"
      auth: "Bearer token（X-Device-Id / X-Device-Type 附带）"
    - from: flutter_desktop
      to: backend
      call: "REST /api/app/v1 + WebSocket /ws/app（Small/Orb 状态摘要可复用 /home/widget 轻量接口）"
      auth: "Bearer token"
    - from: backend
      to: db
      call: "MyBatis（MySQL）+ Redis（会话/在线状态/实时分发）"
      auth: "本地配置连接"
business_flows:
  - id: FLOW-001
    steps:
      - sequence: 1
        source_or_endpoint: "手机端/桌面端登录"
        data_fields: [email, password_or_code, deviceId, deviceType]
        note: "会话按 1 手机 + 1 电脑策略管理"
      - sequence: 2
        source_or_endpoint: "认证 → /sync/bootstrap 拉取初始摘要"
        data_fields: [lastSyncVersion, currentStudyState, unreadSummary]
        note: "双端状态同步入口"
      - sequence: 3
        source_or_endpoint: "创建今日计划（/study/plans）→ 开始学习（/focus/session/start）→ 完成任务 → 签到（/check-in/submit）→ 统计（/stats/*）"
        data_fields: [planBlockList, timerRecord, checkInResult, statsTrend]
        note: "个人闭环主链路"
      - sequence: 4
        source_or_endpoint: "团队交互（/teams/* → /reminders/* → WebSocket chat/remind/progress 事件）"
        data_fields: [teamInfo, remindRecord, progressUpdate]
        note: "社交闭环：建队→看进度→提醒→完成通知→群聊"
  - id: FLOW-002
    steps:
      - sequence: 1
        source_or_endpoint: "举报（/chat/messages/{id}/report）→ 后台（/api/admin/v1/reports/*）"
        data_fields: [reportRecord, auditRecord, punishmentRecord]
        note: "内容治理链路：先发后审"
data_mappings:
  - from_shape: 接口草案 DTO
    to_shape: 后端模块 domain/service 内部模型
    transform: "controller → service 转换层（禁止 Map/JSONNode 透传）"
  - from_shape: 后端响应
    to_shape: Flutter feature 模型
    transform: "Dart 模型 fromJson（字段结构与草案一致）"
pitfalls:
  - id: DIFF-001
    category: time_format
    description: "前后端时间统一 ISO 8601；双端显示需按用户时区转换，存储用 UTC 或带时区"
    contract_test_required: true
  - id: DIFF-002
    category: dynamic_field
    description: "趋势图接口 rangeType=7d/30d 数据形状一致，前端禁止为不同范围写两套解析"
    contract_test_required: true
  - id: DIFF-003
    category: dual_semantics
    description: "签到失败与计划失败共用展示区，但数据层分表（check_in_fail_record / study_plan_fail_record），禁止混用字段"
    contract_test_required: true
code_locations:
  backend: "server/innocence-server/src/main/java/com/innocence/server/modules/（account/checkin/focus/friend/home/memo/notification/plan/report/setting/stats/system/team）"
  frontend: "client/flutter_app/lib/features/（account/admin/auth/checkin/focus/friends/home/memos/notifications/plans/settings/stats/team）+ core/（network/config/theme/platform/layout/widgets）"
  database: "server/innocence-server/src/main/resources/schema.sql + infra/docker/docker-compose.dev.yml"
project_boundary:
  read:
    - "docs/planning/*（产品层详稿，只读引用）"
  write:
    - "docs/00~08、progress/、AGENTS.md（治理层，本项目维护）"
  do_not_copy:
    - "planning 文档内容不复制进 docs 0~8，只做指针引用"
  model_layers:
    - 接口草案 DTO
    - 后端 domain 模型
    - Dart feature 模型
fixtures:
  - path: "暂无（契约样本未收，P01 起回放收样）"
    contract: "U01-U11"
---
