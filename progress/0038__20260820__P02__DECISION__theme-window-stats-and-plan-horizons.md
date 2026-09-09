---
schema_version: 1
document_type: checkpoint
sequence: "0038"
created_at: "2026-08-20T01:49:13+08:00"
phase: P02
type: DECISION
status: complete
title: "主题化窗口控件、统计固定工具栏与可操作计划层级"
objective: "统一认证与主界面的窗口控件，补齐大中小尺寸预设和边缘缩放光标，修复统计中心主题/滚动问题，并让长计划与超长计划成为真实可操作视图。"
completed:
  - fact: "认证页、主 Canvas 和二级页使用统一的主题化尺寸、最小化与关闭控件；玻璃态具备半透明表面、圆角、描边和 Hover 反馈。"
    evidence: "client/flutter_app/lib/core/widgets/desktop_close_button.dart；AdaptiveCanvasShell 与 SecondaryPageScaffold 接入 DesktopWindowControls。"
  - fact: "右上角新增 Large/Medium/Small 三档尺寸菜单，并通过 MethodChannel 调用原生窗口层；预设逻辑尺寸为 1320×820、920×720、460×680，应用后居中且进入窗口记忆。"
    evidence: "DesktopWidgetBridge.setCanvasSizePreset；FlutterWindow setCanvasSizePreset handler；Win32Window::SetCanvasSizePreset。"
  - fact: "无框 Canvas 的四边/四角缩放命中带扩为14逻辑像素，并通过 WM_SETCURSOR 显示横向、纵向和对角缩放光标。"
    evidence: "client/flutter_app/windows/runner/win32_window.cpp 的 WM_NCHITTEST 与 WM_SETCURSOR。"
  - fact: "统计中心固定顶部返回/刷新/窗口操作区，正文独立滚动；内层概览、趋势、胶囊和空状态改用当前 ColorScheme，不再在玻璃态显示固定白卡。"
    evidence: "SecondaryPageScaffold.pinHeader；StatsPage pinHeader=true 及主题语义色替换。"
  - fact: "计划页新增短计划、长计划、超长计划切换；长计划展示真实周数据、日期编辑和模板套用，超长计划支持逐周浏览并将未来任务保存到具体日期。"
    evidence: "adaptive_desktop_home.dart 中 _PlanHorizonSwitcher、_WeekPlanBoard、_LongTermRoadmap；HomePage 传入周数据与日期/模板回调。"
  - fact: "现行规划已用按日期计划复用方案替换未落地的 planType=ultra 数据孤岛，并覆盖静态计划层级、仅手动缩放和二级页标题随正文滚动的冲突要求。"
    evidence: "UI设计规划2.26、Windows自适应桌面体验3.1、Windows信息架构与组件体系5.2、docs/03-execution-plan.md。"
changed_files:
  - path: "client/flutter_app/lib/core/widgets/desktop_close_button.dart"
    change: "重建主题化窗口控件并加入三档尺寸菜单。"
  - path: "client/flutter_app/lib/core/platform/desktop_widget_bridge.dart"
    change: "新增 Canvas 尺寸预设 MethodChannel 调用。"
  - path: "client/flutter_app/windows/runner/flutter_window.cpp"
    change: "接收 setCanvasSizePreset 原生调用。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "实现三档窗口尺寸、尺寸记忆、14px边缘命中与方向缩放光标。"
  - path: "client/flutter_app/windows/runner/win32_window.h"
    change: "公开 SetCanvasSizePreset。"
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "主命令栏和Small顶部接入统一窗口控件。"
  - path: "client/flutter_app/lib/core/widgets/secondary_page_scaffold.dart"
    change: "新增固定标题工具栏模式并接入统一窗口控件。"
  - path: "client/flutter_app/lib/features/stats/presentation/pages/stats_page.dart"
    change: "启用固定工具栏并移除内层固定浅色 SurfacePalette。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "实现短/长/超长计划切换、周看板和长期日期路线。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "向自适应计划页传入真实周数据、周导航、日期编辑和模板套用回调。"
  - path: "client/flutter_app/test/core/widgets/desktop_window_controls_test.dart"
    change: "验证三档尺寸菜单与滚动时固定返回工具栏。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "新增2.26覆盖决策。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "固化尺寸预设、缩放光标与固定二级工具栏。"
  - path: "docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "将长计划和超长计划改为当前真实接口与日期持久化方案。"
  - path: "docs/03-execution-plan.md"
    change: "新增P02/P04/P05动作和门禁。"
evidence:
  - command: "flutter analyze"
    result: "No issues found。"
  - command: "flutter test test/core/widgets/desktop_window_controls_test.dart"
    result: "2项通过：尺寸菜单与固定工具栏。"
  - command: "flutter test"
    result: "32项全部通过。"
  - command: "git diff --check"
    result: "通过；仅有LF/CRLF转换提示，无空白错误。"
  - command: "flutter build windows --release"
    result: "最终增量构建25.5秒成功生成 build/windows/x64/runner/Release/innocence_flutter.exe；前一轮完整原生构建39.2秒通过。"
  - command: "Start-Process release exe；Get-Process"
    result: "PID 4052，MainWindowTitle=Innocence，Responding=True。"
compatibility_and_security:
  contract_impact: "none；长/超长计划复用现有按日期计划和周概览契约，未新增伪接口。"
  tenant_impact: "none；日期计划仍由现有登录用户上下文隔离。"
  sensitive_data: "none；未记录截图中的邮箱、密码或会话数据。"
risks_or_blockers:
  - "三档尺寸在100%/125%/150% DPI与多屏工作区的实际像素效果仍需人工矩阵验收。"
  - "长期日程当前是MVP日期路线；若未来需要跨日目标树、依赖关系或独立进度，必须先新增契约与迁移。"
next_actions:
  - id: NEXT-001
    action: "在当前Windows Release中切换四主题，检查认证窗口按钮、统计滚动固定区、三档尺寸和边缘光标。"
    inputs: ["Windows Release", "四主题"]
  - id: NEXT-002
    action: "使用合成登录会话在长计划/超长计划中编辑未来日期并套用模板，确认保存后周概览回显。"
    inputs: ["Windows Release", "合成登录会话"]
---

# 检查点说明

本决策覆盖静态计划层级、未落地 `planType=ultra`、仅依赖手动拖拽尺寸以及统计标题随正文滚动的旧执行方案。历史检查点依不可变规则保留，但冲突内容不再指导当前实现。
