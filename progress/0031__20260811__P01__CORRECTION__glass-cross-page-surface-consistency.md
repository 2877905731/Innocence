---
schema_version: 1
document_type: checkpoint
sequence: "0031"
created_at: "2026-08-11T00:21:21+08:00"
phase: P01
type: CORRECTION
status: complete
title: "玻璃态跨页表面与空状态一致性纠偏"
objective: "根据主页、计划、陪伴、收件箱和备忘录实机截图，移除玻璃态中的固定白卡、近黑空状态与旧浅色固定色，提高跨页主题一致性"
completed:
  - fact: "GlassPanel 改为由 AppVisualThemeMarker 驱动的四主题共享表面；lightStyle 在玻璃态下不再强制生成白色 SurfacePalette 卡片"
    evidence: "client/flutter_app/lib/core/widgets/glass_panel.dart；新增组件测试验证玻璃主题颜色为 0x3D101D3B 而非白色"
  - fact: "玻璃态主页卡片、导航、设置页、空状态和 Tooltip 统一为深色半透明蓝紫表面、浅色描边、背景模糊与 Hover 发光"
    evidence: "client/flutter_app/lib/app/app_visual_theme.dart、client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart、client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart、client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
  - fact: "备忘录标题、说明、清单、标签与编辑器子项改用 ColorScheme 语义色，移除旧 SurfacePalette、固定白色和固定薄荷绿依赖"
    evidence: "client/flutter_app/lib/features/memos/presentation/pages/memo_page.dart"
  - fact: "用户反馈已归档为玻璃态跨页表面一致性规则"
    evidence: "docs/planning/Innocence-UI设计规划.md 2.22"
changed_files:
  - path: "client/flutter_app/lib/app/app_visual_theme.dart"
    change: "收敛玻璃态表面、文字、描边和 Tooltip 主题令牌"
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "导航与 Shell 玻璃表面改为深色半透明层"
  - path: "client/flutter_app/lib/core/widgets/glass_panel.dart"
    change: "共享面板改为四主题感知并补齐玻璃 Hover、模糊和发光"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "主页卡片、Hero 标签和嵌套空状态统一玻璃主题"
  - path: "client/flutter_app/lib/features/memos/presentation/pages/memo_page.dart"
    change: "备忘录内部组件全面改用主题语义色"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "玻璃设置页表面去除浅白覆盖"
  - path: "client/flutter_app/test/core/widgets/adaptive_canvas_theme_test.dart"
    change: "新增 lightStyle 面板仍服从玻璃主题的回归测试"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "新增 2.22 玻璃态跨页一致性约束"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前状态、最近基线与 DEC-0021"
  - path: "progress/INDEX.md"
    change: "登记 0031 检查点"
evidence:
  - command: "dart format lib/app/app_visual_theme.dart lib/core/widgets/adaptive_canvas_shell.dart lib/core/widgets/glass_panel.dart lib/features/home/presentation/pages/adaptive_desktop_home.dart lib/features/memos/presentation/pages/memo_page.dart lib/features/settings/presentation/pages/settings_page.dart test/core/widgets/adaptive_canvas_theme_test.dart"
    result: "退出码 0；7 个文件完成格式化，其中 5 个发生格式变化"
  - command: "flutter analyze"
    result: "退出码 0；No issues found"
  - command: "flutter test"
    result: "退出码 0；25 项测试全部通过"
  - command: "flutter build windows --release"
    result: "退出码 0；生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "git diff --check"
    result: "退出码 0；无空白错误"
compatibility_and_security:
  contract_impact: "none；仅调整前端视觉令牌、共享组件与主题测试"
  tenant_impact: "none；未改变业务数据访问"
  sensitive_data: "none；未记录真实凭据或个人身份信息"
risks_or_blockers:
  - "玻璃态动态背景在不同 GPU、DPI 与窗口尺寸下仍需人工视觉验收；本检查点仅完成源码、自动化测试与 Release 构建证据"
next_actions:
  - id: NEXT-001
    action: "在 Windows Release 中逐页打开主页、计划、陪伴、收件箱、备忘录、统计和设置，核对透明度、对比度、Hover 与滚动状态"
    inputs: ["Windows Release", "玻璃态本地偏好"]
---

# 检查点说明

- 本检查点纠正共享 lightStyle 白卡与 palette.background 空状态造成的跨页主题割裂。
- 四主题仍共用业务结构；视觉表面由当前主题标记统一解析。
