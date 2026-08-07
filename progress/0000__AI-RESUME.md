---
schema_version: 1
document_type: ai_resume
project_name: "Innocence"
updated_at: "2026-08-07"
latest_checkpoint: "0000"
current_phase: P00
current_gate: G00
state: governance_baseline_initialized
next_sequence: "0001"
current_goal: "P00 治理基线已生成（AGENTS/docs 0~8/progress）。P00.5 UI 设计体系进行中：主题一「侘寂禅意」（wabiSabi 家族）提示词已存档并完成 Tailwind 参考实现，等待主题二、三提示词"
recent_baseline:
  - checkpoint: null
    result: "P00 治理基线初始化完成；暂无历史检查点"
user_decisions:
  - id: DEC-0001
    decision: "模板治理框架全量 9 文档落地；planning 文档并存引用"
  - id: DEC-0002
    decision: "阶段门禁按 MVP 5 阶段映射，已实现部分折入对应阶段基线"
  - id: DEC-0003
    decision: "进度协议启用（检查点 + RESUME + INDEX）"
  - id: DEC-0004
    decision: "前端 UI 全面推翻重建；功能逻辑与数据层保留"
  - id: DEC-0005
    decision: "三个主题并存可切换，主题提示词由用户提供并必须存档"
unfinished:
  - id: TODO-001
    priority: P0
    item: "主题二、主题三提示词待用户提供（收到后先存档到 docs/planning/Innocence-UI设计规划.md）"
    gate: G00.5
  - id: TODO-002
    priority: P1
    item: "P00.5 UI 设计体系：三主题齐备后推进信息架构 → 双端布局 → 视觉令牌 → 组件"
    gate: G00.5
next_actions:
  - id: NEXT-001
    action: "等待用户提供主题二、三提示词；主题一参考实现 docs/design/templates/wabisabi-zen.html 可先用浏览器预览"
    inputs: []
required_reads:
  - AGENTS.md
  - docs/08-project-profile.md
  - docs/03-execution-plan.md
  - docs/07-dataflow-and-module-map.md
  - docs/06-contract-inventory.md
  - progress/INDEX.md
