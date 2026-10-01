---
schema_version: 1
document_type: checkpoint
sequence: "0028"
created_at: "2026-08-10T23:59:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "玻璃态动态表现、彻底无框缩放与本地主题切换纠偏"
objective: "恢复玻璃态参考页的动态美学，删除顶层 Win32 可缩放边框，并消除主题切换触发旧 desktopEffect 校验错误。"
completed:
  - fact: "玻璃态背景改为蓝紫粉空间渐变，叠加三组 20 秒循环光团、渐隐网格、18 个动态微粒，并在减少动画设置下静止。"
    evidence: "adaptive_desktop_home.dart::_AnimatedGlassBackdrop；_GlassMotionPainter"
  - fact: "玻璃面板与指标卡增加 300ms Hover 上浮、透明层增强、白色边缘高光和蓝紫柔光；Hero 去除暗色容器并使用高对比白色大标题。"
    evidence: "adaptive_desktop_home.dart::_HoverSurface；_HomePalette.panelDecoration；_HeroStatement"
  - fact: "玻璃 Shell 导航与侧栏使用同一空间渐变和半透明表面，不再保持不协调的深海军蓝实色。"
    evidence: "adaptive_canvas_shell.dart"
  - fact: "Windows Canvas 移除全部非客户区和 WS_THICKFRAME，使用 WM_NCHITTEST 保留四边/四角缩放；实机样式探针确认 HasCaption=False、HasThickFrame=False。"
    evidence: "win32_window.cpp；GetWindowLongPtr 样式 0x140B0000"
  - fact: "主题切换仅更新 AppVisualThemeController 与 SharedPreferences，不再调用 /settings/appearance，旧服务端 desktopEffect 必填错误不再进入切换链路。"
    evidence: "settings_page.dart::_changeVisualTheme"
  - fact: "规划已覆盖玻璃态禁用循环运动、持续发光和 Large 材质降级等冲突项。"
    evidence: "Innocence-UI设计规划.md 2.20；Windows 自适应桌面体验.md；Windows 信息架构与组件体系.md"
changed_files:
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "动态玻璃背景、Hover 光效、透明分层和高对比 Hero。"
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "玻璃态 Shell 全域渐变和透明导航表面。"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "主题切换与服务端外观保存解耦。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "移除非客户区/WS_THICKFRAME，并用 WM_NCHITTEST 手动缩放。"
  - path: "docs/planning/Innocence-UI设计规划.md; Innocence-Windows*.md"
    change: "覆盖玻璃态动效克制与材质降级冲突。"
evidence:
  - command: "flutter analyze"
    result: "No issues found"
  - command: "flutter test"
    result: "23 项全部通过"
  - command: "flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "GetWindowLongPtr(GWL_STYLE)"
    result: "Style=0x140B0000；HasCaption=False；HasThickFrame=False"
  - command: "git diff --check"
    result: "退出码 0；仅有工作区既有 LF/CRLF 提示"
compatibility_and_security:
  contract_impact: "视觉主题不再同步服务端 themeMode；四主题继续由本地偏好持久化。服务端接口保留供未来明确的跨设备明暗偏好使用。"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "动态背景与 Hover 已通过源码、测试和构建验证，最终帧率和视觉强度仍需在用户实际 DPI/GPU 下确认。"
next_actions:
  - id: NEXT-001
    action: "用户运行最新 Release，验证玻璃态背景运动、卡片 Hover 光效和顶边完全消失。"
    inputs: ["Windows Release"]
  - id: NEXT-002
    action: "在设置页连续切换四主题，确认不再出现 desktopEffect 错误横幅。"
    inputs: ["Windows Release", "当前或历史服务端"]
---
