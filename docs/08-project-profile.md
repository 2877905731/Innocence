---
schema_version: 1
document_type: project_profile
project_name: "Innocence"
project_type: "other（双端自有产品：Flutter 手机端 + 桌面端 + Spring Boot 后端）"
data_owner: "Innocence 自有数据；用户数据归用户，由 Innocence 服务托管"
authorization_boundary: "服务端用户数据以登录用户为边界；未登录离线数据以本机 ownerScope 为边界，未经用户确认不得绑定或上传；陌生人不可私信/看资料；仅队友可见学习数据；后台管理权限仅限内容治理与账号治理"
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
    rule: "桌面端支持未登录离线资料与已登录断网缓存两个隔离数据域；业务数据先写本地，登录后先预览目标账号并由用户确认导入；冲突按实体类型处理，禁止用统一最后修改覆盖所有数据"
    verification: "离线入口、本地持久化、ownerScope 隔离、幂等补传、导入确认与冲突矩阵验收（G01/G02）"
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
    rule: "Windows 端采用 Large/Medium/Small 自适应画布 + 用户主动 Focus Orb；首次按工作区约 84%×82% 居中进入适中 Large，之后恢复用户边界，不以小挂件启动；跨尺寸只重排布局，不重建业务状态"
    verification: "窗口尺寸矩阵、DPI、多屏、状态连续性与四主题验收（G05/G06）"
  - id: RULE-011
    enabled: true
    rule: "计划层级固定为短计划按日、长计划按月、超长计划按年；周视图仅作兼容辅助，日计划模板可批量套用到月历日期"
    verification: "日/月/年视图、模板批量套用、年度月区间拖动与跨月/跨年边界验收（G02）"
  - id: RULE-012
    enabled: true
    rule: "首页 Hero 按主题与本地日期稳定轮换；四主题分别使用符合自身气质的文案和艺术字构图，侘寂主题允许英文主标题"
    verification: "四主题、双语、同日稳定、跨午夜切换与 Small Canvas 溢出验收（G02/G05）"
  - id: RULE-013
    enabled: true
    rule: "Windows 无框窗口缩放采用 Flutter 八方向透明命中层触发原生 sizing loop，并保留顶层 WM_NCHITTEST 作为补充；必须真实拖动后尺寸发生变化才算通过"
    verification: "Windows Release 在 100%/125%/150% DPI 下完成四边四角真实拖动、最大化与 Focus Orb 负向验收（G05/G06）"
change_policy:
  source_of_truth: this_file
  rule_change_checkpoint: DECISION
  affected_documents_to_sync:
    - docs/01-product-scope.md
    - docs/03-execution-plan.md
    - docs/02-contract-and-compatibility-rules.md
    - docs/06-contract-inventory.md
    - docs/07-dataflow-and-module-map.md
    - docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md
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
- 离线模式、主题标语、年月计划与窗口缩放：`docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md`（已确认，代码未开始）
