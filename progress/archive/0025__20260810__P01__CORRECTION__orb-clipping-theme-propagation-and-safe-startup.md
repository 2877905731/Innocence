---
schema_version: 1
document_type: checkpoint
sequence: "0025"
created_at: "2026-08-10T22:04:13+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Focus Orb 裁切、全局主题传播与安全启动尺寸纠偏"
objective: "修复 Focus Orb 黑色外圈与裁切 Tooltip、设置页切换主题后主界面仍使用旧主题，以及启动恢复过大 Canvas 尺寸的问题。"
completed:
  - fact: "Focus Orb 已移除 Tooltip、外层透明 padding 和外部阴影，主题表面铺满原生 72×72 椭圆窗口区域。"
    evidence: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
  - fact: "HomePage 在每次构建和打开设置时从 ThemeData 的 AppVisualThemeMarker 解析当前主题，不再把路由创建时的旧参数继续传给主界面。"
    evidence: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
  - fact: "Windows 不再跨进程读写 Canvas 的 PageWidth/PageHeight/PageX/PageY，每次启动从居中 920×760 Medium 开始，同一进程内的 Canvas/Orb 恢复仍保留尺寸。"
    evidence: "client/flutter_app/windows/runner/win32_window.cpp；启动实测窗口 920×760"
  - fact: "用户原话与新的启动尺寸/全局主题/Orb 裁切规则已存档并更新相关 Windows 规划。"
    evidence: "docs/planning/Innocence-UI设计规划.md 2.18；Windows 自适应桌面体验.md"
changed_files:
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "删除悬浮 Tooltip 和透明外圈，让圆面铺满原生裁切区域。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "主界面和设置路由改为读取全局当前主题标记。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "Canvas 尺寸改为进程内保留，每次启动使用 920×760 Medium 默认值。"
  - path: "client/flutter_app/test/app/app_visual_theme_test.dart"
    change: "新增全局 ThemeData 随主题控制器重建的回归测试。"
  - path: "docs/03-execution-plan.md; docs/planning/Innocence-UI设计规划.md; docs/planning/Innocence-Windows*.md"
    change: "存档用户纠偏并将跨启动 Canvas 恢复改为安全 Medium 启动。"
evidence:
  - command: "flutter analyze"
    result: "No issues found"
  - command: "flutter test test/app/app_visual_theme_test.dart"
    result: "5 项全部通过，包含全局 ThemeData 传播回归"
  - command: "flutter test"
    result: "22 项全部通过"
  - command: "flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "Start-Process；GetWindowRect + GetDpiForWindow"
    result: "PID 26236，DPI 144，实际窗口 920×760，位置 (393,76)"
compatibility_and_security:
  contract_impact: "none"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "尚需用户在实际桌面上再次视觉确认 Orb 边缘，并从设置页切换四主题后返回主界面确认整体更新。"
next_actions:
  - id: NEXT-001
    action: "在已启动的 Release 中悬停和拖动 Orb，确认无黑色外圈、灰色 Tooltip 或裁切文字。"
    inputs: ["Windows Release"]
  - id: NEXT-002
    action: "从设置页逐一切换四主题并返回主界面，确认主画布和 Orb 同步更新。"
    inputs: ["Windows Release", "可登录测试账号"]
---

# 检查点说明

- 本检查点纠正 0024 后的实机反馈，不修改旧检查点。
