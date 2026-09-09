---
schema_version: 1
document_type: checkpoint
sequence: "0046"
created_at: "2026-09-10T03:04:15+08:00"
phase: P01
type: DECISION
status: complete
title: "用户指定 Logo 已保留白色底板无损归档"
objective: "记录用户对首版 Windows Logo 的最终视觉方向，并先完成不改变原图的项目内提取归档"
completed:
  - fact: "用户指定银灰字母 I、右上圆点、环线、INNOCENCE 字标与下方短横作为新 Logo，并明确要求保留白色圆角底板。"
    evidence: "用户提供 D:/file_0000000026e081f4afc26c543c5fdd99.png，随后明确回复‘保留白色底板’。"
  - fact: "用户原图已无损复制到项目，未重绘、裁切、调色或透明化。"
    evidence: "来源文件与 docs/design/logo/innocence-logo-v1-selected.png 的 SHA-256 均为 30127536CF367B97841C6CBEAB6EA5E64173B58F2A2C88855A5F00191D026C40。"
  - fact: "此前生成的折页/前进箭头候选稿已降级为历史设计记录，不再作为正式图标来源。"
    evidence: "docs/design/logo/README.md 已将用户选定稿标记为唯一视觉源。"
changed_files:
  - path: "docs/design/logo/innocence-logo-v1-selected.png"
    change: "用户指定 Logo 的 1254×1254 无损归档，保留白色圆角底板、外围留白和阴影。"
  - path: "docs/design/logo/README.md"
    change: "记录用户选定稿、完整性与后续图标适配边界，并将旧候选稿标记为历史记录。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新 Logo 决策、状态、待办与下一步。"
  - path: "progress/INDEX.md"
    change: "追加 0046 决策检查点。"
evidence:
  - command: "Copy-Item 用户原图到 docs/design/logo/innocence-logo-v1-selected.png；Get-FileHash -Algorithm SHA256 对比两文件"
    result: "复制成功；来源与归档 SHA-256 完全一致。"
  - command: "System.Drawing 读取 docs/design/logo/innocence-logo-v1-selected.png"
    result: "1254×1254、Format24bppRgb、PNG。"
compatibility_and_security:
  contract_impact: "none；本检查点只归档视觉资产，未修改 Windows ICO、托盘逻辑、应用代码或数据契约。"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "白色底板和完整字标在 16×16/32×32 托盘尺寸下会丢失细节；正式接入时需制作同源简化构图并进行小尺寸像素检查。"
next_actions:
  - id: NEXT-001
    action: "用户确认无损提取稿后，制作包含 16/20/24/32/40/48/64/128/256 尺寸的 Windows ICO，并为托盘小尺寸生成同源简化版。"
    inputs: ["docs/design/logo/innocence-logo-v1-selected.png", "client/flutter_app/windows/runner/resources/app_icon.ico"]
---

# 检查点说明

- 该检查点只完成用户 Logo 决策与原图归档，没有替换应用资源，也没有触发 Windows 构建或发布。
