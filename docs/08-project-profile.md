---
schema_version: 1
document_type: project_profile
project_name: "Innocence"
project_type: "other（双端自有产品：Flutter 手机端 + 桌面端 + Spring Boot 后端）"
data_owner: "Innocence 自有数据；用户数据归用户，由 Innocence 服务托管"
authorization_boundary: "用户数据以登录用户为边界；陌生人不可私信/看资料；仅队友可见学习数据；后台管理权限仅限内容治理与账号治理"
default_invariants:
  - id: STANDALONE-FIRST
    enabled: disabled
    rationale: "自有产品无宿主系统，不适用"
  - id: UPSTREAM-OWNS-DATA
    enabled: disabled
    rationale: "数据全部自有，无上游系统"
  - id: TENANT-ISOLATION
    enabled: enabled
    rationale: "所有业务查询/写入必须绑定当前登录用户（userId），黑名单/好友/团队关系构成访问边界"
  - id: CONTRACT-BEFORE-CLIENT
    enabled: enabled
    rationale: "接口清单草案已固化统一约定与字段，前端实现以草案为准；UI 重建不回改接口"
  - id: EXACT-OUTPUT
    enabled: disabled
    rationale: "无外部字节级输出要求"
  - id: NO-SECRET-COPY
    enabled: enabled
    rationale: "邮件密码经 INNOCENCE_MAIL_PASSWORD 环境变量注入（application-local-secret.yml 不进仓库）"
  - id: NO-SILENT-NORMALIZATION
    enabled: enabled
    rationale: "业务规则差异（如签到判定口径）必须以 DECISION 记录，禁止静默改规则"
project_specific_rules:
  - id: RULE-001
    enabled: true
    rule: "git commit 消息使用中文"
    verification: "提交历史语言检查"
  - id: RULE-002
    enabled: true
    rule: "前端 UI 推翻重建：页面布局与观感全部重新设计，不沿用旧布局；功能逻辑与数据层保留"
    verification: "页面重建对照 docs/planning/Innocence-UI设计规划.md 验收"
  - id: RULE-003
    enabled: true
    rule: "四个主题并存可切换：主题只注入设计令牌值，不重写页面结构"
    verification: "设置中切换主题即时生效，页面结构不变"
  - id: RULE-004
    enabled: true
    rule: "用户提供的主题提示词必须原文存档到 docs/planning/Innocence-UI设计规划.md，后续生成以存档为准"
    verification: "存档章节存在且含提示词原文"
  - id: RULE-005
    enabled: true
    rule: "1 台手机 + 1 台电脑同时在线；超出时拒绝新设备或替换旧会话"
    verification: "会话策略验收（G01）"
  - id: RULE-006
    enabled: true
    rule: "双端同步冲突采用最后修改覆盖；桌面端断网本地记录、联网补传"
    verification: "同步链路验收（G02）"
  - id: RULE-007
    enabled: true
    rule: "签到成功需同时满足手动点击与当天计划完成；学习时长不足条件仍保留"
    verification: "签到判定验收（G02）"
  - id: RULE-008
    enabled: true
    rule: "本地环境限制：Dart analyze 可能超时、Maven 依赖受限，验证策略以代码级校对 + 接口对齐为主，证据必须真实"
    verification: "检查点证据字段"
  - id: RULE-009
    enabled: true
    rule: "team 上限 5 人、一人一团队、队长专属移除/解散权限、解散后数据全删"
    verification: "团队规则验收（G03）"
  - id: RULE-010
    enabled: true
    rule: "Windows 端采用 Large/Medium/Small 自适应画布 + 用户主动 Focus Orb；默认 920×760，不以小挂件启动；跨尺寸只重排布局，不重建业务状态"
    verification: "窗口尺寸矩阵、DPI、多屏、状态连续性与四主题验收（G05/G06）"
change_policy:
  source_of_truth: this_file
  rule_change_checkpoint: DECISION
  affected_documents_to_sync:
    - docs/03-execution-plan.md
    - docs/02-contract-and-compatibility-rules.md
    - docs/planning/Innocence-Windows自适应桌面体验.md
---

# 项目画像说明

本文为 Innocence 项目特有规则的权威来源。产品细节以 `docs/planning/` 为详稿，治理规则以本文为准。

关键参考文档：
- 产品规划：`docs/planning/Innocence-项目计划书.md`
- MVP 范围：`docs/planning/Innocence-MVP第一版功能范围.md`
- 接口契约：`docs/planning/Innocence-接口清单草案.md`
- 数据库契约：`docs/planning/Innocence-数据库表结构草案.md`
- UI 规划与主题存档：`docs/planning/Innocence-UI设计规划.md`
- Windows 自适应体验：`docs/planning/Innocence-Windows自适应桌面体验.md`
- Windows 信息架构与组件接口：`docs/planning/Innocence-Windows信息架构与组件体系.md`（已确认）
