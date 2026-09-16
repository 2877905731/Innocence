---
schema_version: 1
document_type: checkpoint
sequence: "0048"
created_at: "2026-09-17T01:08:17+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Logo 抠图右侧残留画布清理"
objective: "修正正式抠图母版右边界偏外的问题，清除右侧残留背景并保持白色圆角底板完整"
completed:
  - fact: "定位到上一版蒙版右边界偏外，将 x=1166–1199 的原始外围画布误收入 Logo。"
    evidence: "源图 y=600 在 x=1166 出现从底板亮色到外部阴影的 7 级亮度突变；用户同时指出右边没有扣干净。"
  - fact: "蒙版修正为左右对称边界，白色底板有效像素为 x=89..1165。"
    evidence: "修正后 y=600 的 x=89 与 x=1165 alpha=255，x=88、x=1166 和 x=1199 alpha=0。"
  - fact: "上下边界与圆角抗锯齿保持有效。"
    evidence: "中心列 y=61/62/1151/1152 的 alpha 分别为 0/255/255/0；圆角区域仍包含 0、7、15…246、255 多级 Alpha。"
changed_files:
  - path: "docs/design/logo/innocence-logo-v1-cutout.png"
    change: "收紧右侧和整体圆角轮廓，删除右边残留外围画布。"
  - path: "docs/design/logo/README.md"
    change: "更新有效像素边界、透明度证据和成品 SHA-256。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录右边界纠正后的当前状态。"
  - path: "progress/INDEX.md"
    change: "追加 0048 纠正检查点。"
evidence:
  - command: "System.Drawing 重新以 x=89..1165、y=62..1151、圆角半径 235 的抗锯齿 TextureBrush 蒙版生成抠图母版"
    result: "生成成功；1254×1254、Format32bppArgb，SHA-256 为 1DB3D73496A8A396A9C8CD7D08F09AEAB3A7B1393D958B4067A436FE6F3988DD。"
  - command: "System.Drawing 检查左右/上下边界 Alpha 与圆角 Alpha 阶梯"
    result: "左右外侧和上下外侧 alpha=0，底板内侧 alpha=255，圆角包含多级抗锯齿 Alpha。"
compatibility_and_security:
  contract_impact: "none；未修改程序代码、ICO、托盘逻辑或业务契约。"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "尚未生成或替换多尺寸 Windows ICO。"
next_actions:
  - id: NEXT-001
    action: "使用修正后的抠图母版生成多尺寸 Windows ICO 和托盘小图标，并执行 Release 构建与小尺寸视觉检查。"
    inputs: ["docs/design/logo/innocence-logo-v1-cutout.png", "client/flutter_app/windows/runner/resources/app_icon.ico"]
---

# 检查点说明

- 本检查点仅修正抠图边界，未修改应用资源、构建或发布。
