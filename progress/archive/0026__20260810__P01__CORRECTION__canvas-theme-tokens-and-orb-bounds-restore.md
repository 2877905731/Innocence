---
schema_version: 1
document_type: checkpoint
sequence: "0026"
created_at: "2026-08-10T23:10:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Canvas 四主题令牌与 Focus Orb 原窗口边界恢复纠偏"
objective: "修复设置切换主题后主界面视觉不变化，以及从 Focus Orb 返回时未恢复进入前 Canvas 尺寸的问题。"
completed:
  - fact: "Canvas Shell 与首页内容调色板不再把纯白和中世纪主题合并为同一硬编码分支，四主题均直接消费 AppVisualTokens。"
    evidence: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart；adaptive_desktop_home.dart"
  - fact: "进入 Focus Orb 前，Win32 原生层从 WINDOWPLACEMENT.rcNormalPosition 快照 Canvas 的正常窗口位置与尺寸；恢复时先退出特殊展示状态，再应用该快照。"
    evidence: "client/flutter_app/windows/runner/win32_window.cpp"
  - fact: "新增 Canvas Shell 四主题背景令牌回归测试。"
    evidence: "client/flutter_app/test/core/widgets/adaptive_canvas_theme_test.dart"
changed_files:
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "Shell 导航、背景、表面、文字和强调色统一映射当前 AppVisualTokens。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "首页业务卡片调色板统一映射当前 AppVisualTokens。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "Canvas→Orb 切换边界捕获正常窗口尺寸，Orb→Canvas 使用捕获值恢复。"
  - path: "client/flutter_app/test/core/widgets/adaptive_canvas_theme_test.dart"
    change: "覆盖四主题 Canvas 背景令牌。"
evidence:
  - command: "flutter analyze"
    result: "No issues found"
  - command: "flutter test"
    result: "23 项全部通过"
  - command: "flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "git diff --check"
    result: "退出码 0；仅显示工作区既有 LF/CRLF 提示"
compatibility_and_security:
  contract_impact: "none"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "自动化已覆盖主题令牌和 Windows 编译；四主题完整视觉差异及自由调整窗口后往返 Orb 的精确尺寸仍需实机人工确认。"
next_actions:
  - id: NEXT-001
    action: "在 Windows Release 中依次切换四主题并返回首页，确认 Shell、首页卡片和 Orb 均同步变化。"
    inputs: ["Windows Release"]
  - id: NEXT-002
    action: "将 Canvas 调整为非默认尺寸和位置，进入 Orb 后恢复，确认位置与宽高一致。"
    inputs: ["Windows Release"]
---

# 检查点说明

- 本检查点纠正 0025 中仅验证全局 ThemeData、未覆盖 Canvas 私有硬编码调色板和 Orb 真实恢复边界的不足。
