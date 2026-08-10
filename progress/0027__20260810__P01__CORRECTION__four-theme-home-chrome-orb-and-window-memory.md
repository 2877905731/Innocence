---
schema_version: 1
document_type: checkpoint
sequence: "0027"
created_at: "2026-08-10T23:48:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "四主题独立首页、无黑边 Shell、纯圆 Orb 与窗口记忆纠偏"
objective: "按实机截图重做四主题首页表达，删除 DWM 黑边与 Orb 方角，并将窗口策略改为首次适中 Large、后续恢复用户尺寸位置。"
completed:
  - fact: "四主题首页不再仅换色：纯白、侘寂、中世纪现代、玻璃态分别拥有独立 Hero、面板、指标与背景装饰规则。"
    evidence: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart；四套 docs/design/templates/*.html"
  - fact: "原生 Canvas/Orb 禁用 DWM 外部边框；Orb Flutter 背景透明，原生椭圆 Region 在 WM_SIZE 后重新应用。"
    evidence: "client/flutter_app/windows/runner/win32_window.cpp；adaptive_desktop_home.dart"
  - fact: "首次无历史 Canvas 使用 1240×780 适中 Large；PageWidth/PageHeight/PageX/PageY 跨启动保存，并在当前工作区内安全恢复。"
    evidence: "client/flutter_app/windows/runner/win32_window.cpp；win32_window.h"
  - fact: "设置或其他二级路由继续复用同一原生 Canvas，不触发窗口模式重置。"
    evidence: "Flutter Navigator 路由保持在 HomePage 上层；原生模式只在 Canvas/Orb/Auth 切换时改变"
  - fact: "规划已存档用户授权，并覆盖网页顶部黑边、仅换视觉令牌和每次强制 920×760 的旧规则。"
    evidence: "docs/planning/Innocence-UI设计规划.md 2.19；Windows 自适应桌面体验.md；Windows 信息架构与组件体系.md；docs/03-execution-plan.md"
changed_files:
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "四主题独立首页视觉、背景装饰、面板形态与透明 Orb 表面。"
  - path: "client/flutter_app/windows/runner/win32_window.cpp; win32_window.h"
    change: "无 DWM 描边、持续圆形 Region、首次 Large 与 Canvas 边界持久化。"
  - path: "docs/03-execution-plan.md; docs/planning/Innocence-UI设计规划.md; docs/planning/Innocence-Windows*.md"
    change: "覆盖旧主题同构、黑边与固定 Medium 启动规则。"
evidence:
  - command: "flutter analyze"
    result: "No issues found"
  - command: "flutter test"
    result: "23 项全部通过"
  - command: "flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "Start-Process + GetWindowRect"
    result: "Release 可启动并创建 Innocence 窗口；本机历史/工作区约束后的窗口边界可读取"
  - command: "git diff --check"
    result: "退出码 0；仅有工作区既有 LF/CRLF 提示"
compatibility_and_security:
  contract_impact: "none"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "自动化无法替代四主题与 Orb 在用户桌面壁纸、DPI 和既有注册表窗口历史下的最终视觉确认。"
next_actions:
  - id: NEXT-001
    action: "用户运行最新 Release，切换四主题并提供最终观感反馈。"
    inputs: ["Windows Release"]
  - id: NEXT-002
    action: "验证自由缩放、设置页往返、重启与 Orb 往返四条窗口边界路径。"
    inputs: ["Windows Release", "100%/125%/150% DPI"]
---
