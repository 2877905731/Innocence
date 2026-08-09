---
schema_version: 1
document_type: execution_plan
project_name: "Innocence"
project_profile_path: docs/08-project-profile.md
baseline:
  project_root: "D:\\project\\Innocence"
  runtime: "Flutter + Java 21 + Spring Boot 3.3.2 + MyBatis + MySQL 8 + Redis"
  current_phase: P00
  current_gate: G00
  evidence: "docs 0~8 + AGENTS + progress 已生成（2026-08-07）"
invariants:
  - id: INV-001-TRUTHFUL-SCOPE
    enabled: true
    rule: 占位、mock-only、未验证输出不计完成；证据字段必须真实
  - id: INV-002-TENANT-ISOLATION
    enabled: true
    rule: 业务数据必须绑定当前登录用户上下文，越权访问有负向测试
  - id: INV-003-CONTRACT-FIRST
    enabled: true
    rule: 接口契约与字段语义固化后再实现前端调用
  - id: INV-004-NO-SECRETS
    enabled: true
    rule: 邮件密码等凭据走环境变量（INNOCENCE_MAIL_PASSWORD），不进仓库
  - id: INV-005-UI-REWRITE
    enabled: true
    rule: 前端页面按新设计推翻重建，不沿用旧布局；功能逻辑与数据层保留
  - id: INV-006-THEME-PROMPTS-ARCHIVED
    enabled: true
    rule: 用户提供的主题提示词必须存档于 docs/planning/Innocence-UI设计规划.md
phases:
  - id: P00
    name: baseline_and_governance
    deliverables:
      - AGENTS.md
      - progress/0000__AI-RESUME.md
      - progress/INDEX.md
      - docs/00-current-state-audit.md
      - docs/01-product-scope.md
      - docs/02-contract-and-compatibility-rules.md
      - docs/03-execution-plan.md
      - docs/04-future-integration.md
      - docs/05-git-version-control-policy.md
      - docs/06-contract-inventory.md
      - docs/07-dataflow-and-module-map.md
      - docs/08-project-profile.md
    gate:
      id: G00
      criteria:
        - documents_consistent（docs 间互相引用无断链）
        - baseline_evidence_reproducible（git log 可复现）
        - planning_docs_unchanged（并存引用，不迁移）
  - id: P00.5
    name: ui_design_system
    deliverables:
      - docs/planning/Innocence-UI设计规划.md（信息架构 + 双端布局 + 视觉令牌 + 组件）
      - 四个主题设计（并存可切换，提示词由用户提供并先存档）
      - 页面清单与导航地图（登录 → 主框架 → 首页 → 二级页）
    actions:
      - 四个主题提示词已存档，继续完成信息架构与组件体系
      - 按「信息架构 → 双端布局 → 视觉令牌 → 主题 → 组件」顺序产出
      - 生成 Flutter 前端时优先将 `docs/design/templates/` 中对应 HTML 作为构图、信息层级和视觉令牌参考；若 AI 参考 HTML 不便或 HTML 到 Flutter 的转换效率较低，可忽略 HTML 代码，仅依据提示词、设计令牌和页面结构实现
    gate:
      id: G00.5
      criteria:
        - theme_prompts_archived（提示词原文存档）
        - four_themes_designed（色彩/质感/动效可落地）
        - page_inventory_approved（页面清单与导航地图用户确认）
  - id: P01
    name: account_and_basics
    actions:
      - 认证/会话/权限/设置模块收尾（已实现部分验收）
      - 按新 UI 重建：登录、注册、找回密码、资料、隐私、设置页面
    gate:
      id: G01
      criteria:
        - auth_flow_ui_redesigned
        - session_policy_verified（1 手机 + 1 电脑）
        - negative_tests_passed（拉黑/越权访问）
  - id: P02
    name: learning_core_loop
    actions:
      - 计划/定时/签到/备忘录/首页收尾（已实现部分验收）
      - 按新 UI 重建：首页聚合、计划（短/长/超长）、定时与番茄、签到、备忘录页面
    gate:
      id: G02
      criteria:
        - personal_loop_closed（计划→学习→记录→签到→统计）
        - today_plan_editor_redesigned
        - focus_timer_redesigned
  - id: P03
    name: social_skeleton
    actions:
      - 好友、团队、私信、团队群聊、提醒、队友进度可见（主要剩余开发量）
      - 按新 UI 重建：好友、团队、会话、通知页面
      - WebSocket 实时通道落地
    gate:
      id: G03
      criteria:
        - team_loop_closed（建队→看进度→提醒→完成通知→群聊）
        - ws_realtime_working
        - privacy_boundary_verified（陌生人不可私信、仅队友可见学习数据）
  - id: P04
    name: results_and_governance
    actions:
      - 统计中心完善、举报处理、敏感词管理、公告与定向通知、后台管理
      - 按新 UI 重建：统计中心、后台页面
    gate:
      id: G04
      criteria:
        - stats_complete（趋势图 7/30 天、双完成率、失败摘要、队友摘要）
        - admin_governance_working（举报→审核→处罚留痕）
        - admin_audit_trail_present
  - id: P05
    name: desktop_experience
    actions:
      - 桌面主窗口与挂件落地、双端视觉统一、桌面通知联动
    gate:
      id: G05
      criteria:
        - widget_renders_core_summary（当前学习/今日计划/摘要）
        - cross_device_notify_working
        - visual_consistent（四主题双端一致）
  - id: P06
    name: mvp_acceptance
    actions:
      - 对照 MVP 完成标准 9 条逐条验收
      - 四主题可切换验收 + 双端观感一致验收
    gate:
      id: G06
      criteria:
        - mvp_9_criteria_all_passed
        - four_themes_switchable
        - release_candidate_confirmed
next_actions:
  - id: NEXT-001
    action: "主题三 Mid-Century Modern 与主题四 Glassmorphism Windows 参考实现均已独立；等待用户确认四主题视觉方向 → 推进 P00.5 信息架构与双端布局"
    inputs: []
---
