---
schema_version: 1
document_type: checkpoint
sequence: "0039"
created_at: "2026-08-20T01:57:53+08:00"
phase: P01
type: CORRECTION
status: complete
title: "顶部常驻三圆环 Canvas 尺寸预设"
objective: "把单按钮尺寸菜单改为顶部直接可见、从左到右逐级缩小并分别对应大中小画布的三圆环控件。"
completed:
  - fact: "删除单个尺寸图标及其弹出菜单，Large/Medium/Small 三个入口在认证页、主 Canvas 和二级页顶部直接常驻。"
    evidence: "client/flutter_app/lib/core/widgets/desktop_close_button.dart 中 DesktopCanvasSizeButton 直接渲染三个 _CanvasSizePresetButton。"
  - fact: "三个入口从左到右使用23/17/11px圆环（Compact为20/15/10px），点击区域保持一致，并分别直接调用 large/medium/small 原生预设。"
    evidence: "canvas-size-large/medium/small 与 canvas-size-glyph-* 部件键。"
  - fact: "圆环颜色、描边、容器和 Hover 发光继续读取当前 ColorScheme；参考图红色手绘框未进入正式视觉。"
    evidence: "_CanvasSizePresetButtonState 与主题语义色。"
  - fact: "UI规划、自适应体验和执行计划已明确删除单按钮弹出菜单方案；0038仅作历史审计。"
    evidence: "UI设计规划2.27、Windows自适应桌面体验3.1、docs/03-execution-plan.md。"
changed_files:
  - path: "client/flutter_app/lib/core/widgets/desktop_close_button.dart"
    change: "将弹出菜单重构为常驻三圆环尺寸选择器。"
  - path: "client/flutter_app/test/core/widgets/desktop_window_controls_test.dart"
    change: "验证三个入口常驻、圆环尺寸递减且均可点击。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "新增2.27覆盖决策。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "将尺寸预设固化为常驻三圆环，不允许菜单折叠。"
  - path: "docs/03-execution-plan.md"
    change: "替换P05尺寸预设执行描述。"
evidence:
  - command: "flutter analyze"
    result: "No issues found。"
  - command: "flutter test test/core/widgets/desktop_window_controls_test.dart"
    result: "2项通过。"
  - command: "flutter test"
    result: "32项全部通过。"
  - command: "flutter build windows --release"
    result: "27.4秒成功生成Release EXE。"
  - command: "git diff --check"
    result: "通过；仅有LF/CRLF提示。"
  - command: "Start-Process release exe；Get-Process"
    result: "PID 5952，MainWindowTitle=Innocence，Responding=True。"
compatibility_and_security:
  contract_impact: "none；仍调用既有setCanvasSizePreset原生通道。"
  tenant_impact: "none。"
  sensitive_data: "none。"
risks_or_blockers:
  - "三圆环在四主题及Small最窄宽度下的最终间距仍需人工视觉确认。"
next_actions:
  - id: NEXT-001
    action: "在当前Release中依次点击三个圆环，确认大中小窗口切换、Hover反馈与顶部间距。"
    inputs: ["Windows Release", "四主题"]
---

# 纠偏说明

本检查点覆盖0038中“三档尺寸菜单”的实现形式。原生三档尺寸和持久化语义保持不变，只有入口改为用户指定的顶部常驻三圆环。
