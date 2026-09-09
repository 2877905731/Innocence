---
schema_version: 1
document_type: checkpoint
sequence: "0047"
created_at: "2026-09-10T03:21:25+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Logo 边界纠正为白色圆角底板并完成真透明抠图"
objective: "按用户纠正移除 Logo 白色圆角底板之外的外围背景，同时完整保留底板和内部品牌内容"
completed:
  - fact: "Logo 的正式边界被明确为白色圆角底板，外围灰白画布不属于 Logo。"
    evidence: "用户明确要求‘背景扣掉，保留圆角白色底板，这个才是logo’。"
  - fact: "生成 1254×1254 ARGB 抠图母版，四角为真实透明，底板内部保持不透明。"
    evidence: "System.Drawing 读取结果为 Format32bppArgb；(0,0) alpha=0，(627,627) alpha=255。"
  - fact: "圆角边缘保留抗锯齿，底板内部没有被重绘。"
    evidence: "左上圆角区域检测到 0、7、15…246、255 等多级 Alpha；7 个不透明位置的 RGB 与源图逐点一致。"
  - fact: "OpenAI ImageGen 背景提取稿未采用。"
    evidence: "工具输出被检测为 Format24bppRgb、角点 alpha=255，透明棋盘格实际被写入像素，因此未复制到项目。"
changed_files:
  - path: "docs/design/logo/innocence-logo-v1-cutout.png"
    change: "保留白色圆角底板和内部品牌内容、外围真透明的正式抠图母版。"
  - path: "docs/design/logo/README.md"
    change: "区分未处理源图与正式抠图母版，并记录透明度、保真证据和弃用稿原因。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新 Logo 边界决策、当前状态和后续 ICO 动作。"
  - path: "progress/INDEX.md"
    change: "追加 0047 纠正检查点。"
evidence:
  - command: "System.Drawing 使用抗锯齿圆角 TextureBrush 蒙版，从 innocence-logo-v1-selected.png 生成 innocence-logo-v1-cutout.png"
    result: "生成成功，文件 SHA-256 为 F5BE185D83A8738EF7FB03FD95D144D8CEC8CBA98310D1D396EFE40E80126A7F。"
  - command: "System.Drawing 检查尺寸、PixelFormat、角点/中心 Alpha、圆角 Alpha 阶梯和内部 RGB 抽样"
    result: "1254×1254、Format32bppArgb；角点 0、中心 255；圆角有多级 Alpha；不透明抽样 RGB 无差异。"
compatibility_and_security:
  contract_impact: "none；未修改程序代码、ICO、托盘逻辑或业务契约。"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "完整字标在 16×16/32×32 托盘尺寸下可能不可辨认，正式接入时仍需制作同源简化小尺寸构图。"
next_actions:
  - id: NEXT-001
    action: "使用抠图母版生成多尺寸 Windows ICO 和托盘小图标，替换正式资源并执行 Release 构建与小尺寸视觉检查。"
    inputs: ["docs/design/logo/innocence-logo-v1-cutout.png", "client/flutter_app/windows/runner/resources/app_icon.ico"]
---

# 检查点说明

- 本检查点只完成 Logo 抠图与视觉边界纠正，尚未替换应用图标、构建或发布。
