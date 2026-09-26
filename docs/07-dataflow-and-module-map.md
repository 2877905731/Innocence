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
    - id: admin_web
      name: "独立管理员网站（浏览器静态资源，经同域反向代理访问服务端）"
      owner: "Innocence"
    - id: backend
      name: "Spring Boot 后端（innocence-server）"
      owner: "Innocence"
    - id: desktop_local_store
      name: "Windows 本地业务库 + sync_outbox（按 ownerScope 隔离）"
      owner: "当前设备上的用户"
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
    - from: admin_web
      to: backend
      call: "REST /api/admin/v1（同域 /api 反向代理）"
      auth: "独立 admin_web 会话槽位 + Bearer token + 服务端管理员白名单"
    - from: flutter_desktop
      to: desktop_local_store
      call: "local profile、账户缓存、日/月/年计划、专注、备忘录与待同步操作的事务读写"
      auth: "无需 Bearer token；以 local:profileUuid 或 account:userId 作为 ownerScope"
    - from: desktop_local_store
      to: backend
      call: "仅在认证成功并确认目标账号后执行幂等导入/补传；未登录离线资料禁止直连受保护接口"
      auth: "Bearer token + 服务端解析的当前用户；clientEntityId/operationId 仅用于幂等，不代表身份"
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
        source_or_endpoint: "创建今日计划（/plans/today）→ 开始学习（/focus/session/start）→ 完成任务 → 签到（/check-in/submit）→ 统计（/stats/*）"
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
  - id: FLOW-003
    steps:
      - sequence: 1
        source_or_endpoint: "认证页 → 离线使用"
        data_fields: [localProfileUuid, ownerScope]
        note: "只创建本机离线身份，不伪造服务端 userId"
      - sequence: 2
        source_or_endpoint: "计划/专注/备忘录 → 本地事务 → sync_outbox"
        data_fields: [clientEntityId, operationId, revision, syncState]
        note: "先本地成功再更新 UI；社交、通知处理和账号安全不可离线执行"
      - sequence: 3
        source_or_endpoint: "登录成功 → 导入预览 → 用户确认目标账号"
        data_fields: [entityCount, dateRange, conflictCount, targetAccount]
        note: "确认前不上传未绑定离线资料"
      - sequence: 4
        source_or_endpoint: "幂等补传 → 服务端按实体返回 accepted/rejected/conflict"
        data_fields: [operationId, clientEntityId, serverId, serverRevision, result]
        note: "本地原始数据保留到逐项确认；签到意图由服务端重新校验"
data_mappings:
  - from_shape: 接口草案 DTO
    to_shape: 后端模块 domain/service 内部模型
    transform: "controller → service 转换层（禁止 Map/JSONNode 透传）"
  - from_shape: 后端响应
    to_shape: Flutter feature 模型
    transform: "Dart 模型 fromJson（字段结构与草案一致）"
  - from_shape: Flutter 本地实体/同步操作
    to_shape: 后端同步与计划 DTO
    transform: "LocalRepository → SyncMapper/OutboxAdapter；必须显式映射 ownerScope、clientEntityId、revision 和墓碑，禁止本地表结构直接透传"
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
  - id: DIFF-004
    category: offline_identity
    description: "local profile 不是服务端账号；未登录阶段不得调用需要 Bearer token 的接口，登录后也必须确认目标账号才允许绑定导入"
    contract_test_required: true
  - id: DIFF-005
    category: plan_horizon
    description: "短/长/超长分别为日计划、带任务存档架的月历、独立年度任务板；年度任务含用户编辑的月份跨度、七选一 colorKey、独立 progressPercent 与多子任务，不自动关联日/月计划。吸顶月份刻度与唯一脉冲充能框共用 12 列坐标，完整外框表示跨度、内部从左到右填充表示 progressPercent；+10/−10、+5/−5、+1/−1 与直接完成复用原保存接口，双向钳制 0–100，子任务仍独立。今日页本月分页复用年度任务查询与同一充能组件；离线日任务变更后同步重算统计完成率。旧 week 与 weekly-template 路由仅作兼容"
    contract_test_required: true
  - id: DIFF-006
    category: conflict_strategy
    description: "计划、备忘录、专注事件、年度区间与签到意图使用不同冲突规则，禁止全局套用最后修改覆盖"
    contract_test_required: true
code_locations:
  backend: "server/innocence-server/src/main/java/com/innocence/server/modules/（account/checkin/focus/friend/home/memo/notification/plan/report/setting/stats/system/team）"
  frontend: "client/flutter_app/lib/features/（account/admin/auth/checkin/focus/friends/home/memos/notifications/plans/settings/stats/team）+ core/（network/config/theme/platform/layout/widgets）"
  admin_frontend: "client/admin_web/src/（独立管理员网站；登录、概览、举报、用户、团队、公告）"
  database: "server/innocence-server/src/main/resources/schema.sql + infra/docker/docker-compose.dev.yml"
project_boundary:
  read:
    - "docs/planning/*（产品层详稿；通常引用，用户决策发生时同步维护）"
  write:
    - "docs/00~08、docs/planning/、progress/、AGENTS.md（治理与产品计划；按用户决策维护）"
  do_not_copy:
    - "planning 文档内容不复制进 docs 0~8，只做指针引用"
  model_layers:
    - 接口草案 DTO
    - 后端 domain 模型
    - Dart feature 模型
fixtures:
  - path: "暂无（契约样本未收，P01 起回放收样）"
    contract: "U01-U13"
---
