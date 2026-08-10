---
schema_version: 1
document_type: checkpoint
sequence: "0030"
created_at: "2026-08-11T00:35:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "UI 规划与原生缩放能力位对齐"
objective: "清除 UI 设计规划中仍会诱导删除 WS_THICKFRAME 和固定启动尺寸的残余约束。"
completed:
  - fact: "2.20 改为保留 WS_THICKFRAME 能力位、移除可见非客户区；新增 2.21 覆盖固定 920×760 / 1240×780，并固化动态玻璃设置页与版本化尺寸记忆。"
    evidence: "docs/planning/Innocence-UI设计规划.md 2.20-2.21"
changed_files:
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "对齐当前原生窗口实现与用户最新默认尺寸、设置页玻璃态要求。"
evidence:
  - command: "rg -n 'WS_THICKFRAME|84%|2.21' docs/planning/Innocence-UI设计规划.md"
    result: "当前执行条款明确保留缩放能力位，首次按工作区比例，旧 2.18 由 2.21 覆盖。"
compatibility_and_security:
  contract_impact: "none"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "none"
next_actions:
  - id: NEXT-001
    action: "继续四主题逐页视觉和 DPI 矩阵验收。"
    inputs: ["Windows Release"]
---
