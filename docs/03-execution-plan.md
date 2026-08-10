---
schema_version: 1
document_type: execution_plan
project_name: "Innocence"
project_profile_path: docs/08-project-profile.md
baseline:
  project_root: "D:\\project\\Innocence"
  runtime: "Flutter + Java 21 + Spring Boot 3.3.2 + MyBatis + MySQL 8 + Redis"
  current_phase: P00.5
  current_gate: G00.5
  evidence: "四主题参考、Windows 自适应桌面体验及信息架构/组件接口草案已生成（2026-08-10）"
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
      - docs/planning/Innocence-Windows自适应桌面体验.md（Large / Medium / Small / Focus Orb）
      - docs/planning/Innocence-Windows信息架构与组件体系.md（页面清单 + 导航地图 + 跨尺寸优先级 + Flutter 呈现接口）
      - 四个主题设计（并存可切换，提示词由用户提供并先存档）
      - 页面清单与导航地图（登录 → 主框架 → 首页 → 二级页）
    actions:
      - 四个主题提示词已存档；Windows 信息架构与组件接口已获用户确认
      - 按「信息架构 → 双端布局 → 视觉令牌 → 主题 → 组件」顺序产出
      - 生成 Flutter 前端时优先将 `docs/design/templates/` 中对应 HTML 作为构图、信息层级和视觉令牌参考；若 AI 参考 HTML 不便或 HTML 到 Flutter 的转换效率较低，可忽略 HTML 代码，仅依据提示词、设计令牌和页面结构实现
      - Windows 页面按 Large / Medium / Small 三档自适应重排，Focus Orb 作为用户主动进入的最小状态；不得等比缩放完整页面
    gate:
      id: G00.5
      status: passed
      passed_at: "2026-08-10T09:22:16+08:00"
      criteria:
        - theme_prompts_archived（提示词原文存档）
        - four_themes_designed（色彩/质感/动效可落地）
        - desktop_adaptive_canvas_approved（四形态信息优先级、断点与状态连续性固化）
        - page_inventory_approved（页面清单与导航地图用户确认）
  - id: P01
    name: account_and_basics
    actions:
      - 认证/会话/权限/设置模块收尾；会话槽位、黑名单、租户边界与头像上传服务端真实 HTTP 回放已完成
      - 按新 UI 重建：登录、注册、找回密码、资料、隐私、设置页面
      - DesktopPresentationTier、自适应 6+2 主 Shell、88×88 Focus Orb、认证入口与设置资料链路已通过 Flutter analyze、16 项测试和 Windows Release 构建；DPI 与真实文件选择待实机验收
    gate:
      id: G01
      status: in_progress
      criteria:
        - auth_flow_ui_redesigned（源码、部件测试与 Windows Release 构建已通过；DPI 实机待验收）
        - session_policy_verified（1 手机 + 1 电脑；真实 HTTP 回放已通过）
        - negative_tests_passed（拉黑/越权访问；服务层与真实 HTTP 回放已通过）
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
    name: adaptive_desktop_experience
    actions:
      - 落地 canvas / orb 原生 Windows shell；canvas 内由 Flutter 响应 Large / Medium / Small
      - 完成窗口边缘吸附、置顶、托盘、DPI、多屏和窗口状态持久化
      - 页面不在 P05 末尾补做响应式；P01-P04 重建页面时同步实现三档布局
      - 完成四主题跨尺寸视觉统一与桌面通知联动
    gate:
      id: G05
      criteria:
        - large_canvas_supports_full_workspace（完整工作台与并列上下文）
        - medium_canvas_is_default_and_complete（默认 920×760，日常主流程完整）
        - small_canvas_supports_core_actions（专注、计划、消息、通知核心操作）
        - focus_orb_restores_context（主动收纳、状态可见、恢复不丢上下文）
        - resize_state_continuity_verified（拖拽跨断点不丢页面、草稿、滚动与计时状态）
        - cross_device_notify_working
        - visual_consistent（四主题双端一致）
  - id: P06
    name: mvp_acceptance
    actions:
      - 对照 MVP 完成标准 9 条逐条验收
      - 四主题可切换验收 + 双端观感一致验收
      - Windows Large / Medium / Small / Focus Orb 在 100% / 125% / 150% DPI 与多屏场景验收
    gate:
      id: G06
      criteria:
        - mvp_9_criteria_all_passed
        - four_themes_switchable
        - release_candidate_confirmed
next_actions:
  - id: NEXT-001
    action: "继续 P01：按新 UI 重建资料、隐私与设置页面，并补会话冲突、权限拒绝和 Flutter 工具链验收"
    inputs: []
---
