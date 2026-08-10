---
schema_version: 1
document_type: checkpoint
sequence: "0029"
created_at: "2026-08-11T00:25:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "玻璃态设置页、可缩放 Canvas 与带版本窗口记忆纠偏"
objective: "修复玻璃态白色遮挡和静态设置页，恢复 Windows 窗口缩放，并将首次尺寸与后续用户尺寸记忆统一为可验证策略。"
completed:
  - fact: "玻璃态品牌标记与统计页操作按钮不再使用白底白字；品牌改为半透明描边，操作按钮改为半透明玻璃按钮。"
    evidence: "adaptive_canvas_shell.dart::_BrandMark；adaptive_desktop_home.dart::_SectionLead"
  - fact: "动态蓝紫粉渐变、漂浮光团、网格和微粒抽为共享 GlassMotionBackdrop，主页与设置页共用；主页和设置面板增加背景模糊、悬停上浮、描边增强与发光。"
    evidence: "glass_motion_backdrop.dart；secondary_page_scaffold.dart；settings_page.dart::_SettingsSurface；adaptive_desktop_home.dart::_HoverSurface"
  - fact: "Windows 非 Orb 窗口恢复 WS_THICKFRAME，同时继续移除 Caption、接管 WM_NCCALCSIZE 并关闭 DWM 非客户区绘制；边缘缩放与无顶层黑边不再互斥。"
    evidence: "win32_window.cpp::UpdateWindowFrame；ApplyDesktopBackdrop；MessageHandler"
  - fact: "首次 Canvas 按工作区约 84%×82% 居中显示；PageStateVersion=2 只迁移一次旧过大历史值，之后保存和恢复用户调整后的尺寸与位置。"
    evidence: "win32_window.cpp::PositionPageWindow；LoadWindowState；SaveWindowState"
  - fact: "进入认证页不再清空已加载的 Canvas 历史边界；从设置页、Orb 与跨启动返回 Canvas 时使用同一份页面边界。"
    evidence: "win32_window.cpp::SetWindowMode"
  - fact: "执行计划与两份 Windows 规划文档删除固定 920×760 / 1240×780 和不跨启动恢复的冲突约束，改为首次工作区比例 + 后续用户尺寸记忆。"
    evidence: "docs/03-execution-plan.md；Innocence-Windows自适应桌面体验.md；Innocence-Windows信息架构与组件体系.md"
changed_files:
  - path: "client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart"
    change: "新增主页与二级页共享的动态玻璃背景。"
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "修复玻璃态品牌白块，补充玻璃材质标记。"
  - path: "client/flutter_app/lib/core/widgets/secondary_page_scaffold.dart"
    change: "玻璃主题二级页接入动态背景。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "修复统计页白色空按钮并为玻璃面板加入真实背景模糊。"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "设置导航与内容面板改为半透明、模糊、Hover 发光的玻璃态。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp; win32_window.h"
    change: "恢复原生缩放能力、调整首次窗口比例并加入版本化 Canvas 边界持久化。"
  - path: "docs/03-execution-plan.md; docs/planning/Innocence-Windows自适应桌面体验.md; docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "覆盖固定 Medium 启动和不记忆尺寸的旧计划约束。"
evidence:
  - command: "flutter analyze"
    result: "No issues found"
  - command: "flutter test"
    result: "24 项全部通过；新增玻璃二级页共享动态背景测试"
  - command: "flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "GetWindowLongPtr + WM_NCHITTEST"
    result: "HasCaption=False；HasThickFrame=True；RightEdgeHit=11(HTRIGHT)"
  - command: "SetWindowPos 1180×700 -> WM_CLOSE -> relaunch"
    result: "PageStateVersion=2 保存 DPI 物理尺寸 1770×1050；重启进入 Canvas 后恢复为 1180×700"
compatibility_and_security:
  contract_impact: "none；仅视觉组件和本机窗口状态策略变化"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "动态模糊和发光已通过源码、测试、构建与窗口行为探针；最终 GPU 帧率和四主题逐页视觉仍需用户实际显示器观察。"
next_actions:
  - id: NEXT-001
    action: "用户运行最新 Release，逐页检查玻璃态设置、统计页白块、Hover 光效和顶部黑边。"
    inputs: ["Windows Release"]
  - id: NEXT-002
    action: "继续执行 100%/125%/150% DPI 与多屏边界矩阵，确认尺寸持久化裁剪策略。"
    inputs: ["Windows DPI 环境"]
---
