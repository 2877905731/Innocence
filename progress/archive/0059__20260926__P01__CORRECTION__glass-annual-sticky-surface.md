---
schema_version: 1
document_type: checkpoint
sequence: "0059"
created_at: "2026-09-26T19:54:56+08:00"
phase: P01
type: CORRECTION
status: complete
title: "玻璃态年度任务吸顶月份栏与进度槽表面纠偏"
objective: "根据用户的 Windows v1.1.0 截图，消除年度任务页近黑色吸顶横条和过亮的未覆盖月份槽，保持现有进度语义与月份对齐"
completed:
  - fact: "核对本地 main 已包含 Windows v1.1.0+3 年度任务源码；截图所示页面在 adaptive_desktop_home.dart，不需要拉取远端"
    evidence: "git log -5 显示 420b832 的 v1.1.0 发布提交，pubspec.yaml 版本为 1.1.0+3；年度任务文案和部件均在本地源码"
  - fact: "玻璃态吸顶月份栏改为半透明蓝紫渐变并加入背景模糊，移除原不透明近黑底；未覆盖月份槽改为半透明蓝紫材质和浅描边；选中月份使用深色文字提高浅色按钮对比"
    evidence: "_AnnualStickyMonthHeader、_AnnualMonthButton 和 _ChargingMonthSpan 的玻璃态分支；其它三个主题仍沿用原配色"
  - fact: "年度页面回归断言覆盖吸顶栏透明材质、模糊层、未覆盖月份槽与选中月份文字；月份几何和进度交互原断言继续通过"
    evidence: "adaptive_annual_progress_test.dart 定向 1/1 与 Flutter 全套 63/63 通过"
changed_files:
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "修正玻璃态年度吸顶栏、月份按钮和充能月份槽视觉样式"
  - path: "client/flutter_app/test/features/home/adaptive_annual_progress_test.dart"
    change: "新增玻璃态视觉令牌回归断言"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前 UI 纠偏状态与实机验收边界"
  - path: "progress/INDEX.md"
    change: "追加本检查点索引"
  - path: "progress/0059__20260926__P01__CORRECTION__glass-annual-sticky-surface.md"
    change: "记录本次修复、验证结果及未完成的视觉验收"
evidence:
  - command: "flutter test --no-pub test/features/home/adaptive_annual_progress_test.dart"
    result: "通过，1/1；启动时 Flutter 自身 Git 标签联网检查失败，但未影响测试结果"
  - command: "flutter analyze --no-pub"
    result: "No issues found"
  - command: "flutter test --no-pub"
    result: "通过，63/63"
  - command: "flutter build windows --release --no-pub"
    result: "通过，生成 build/windows/x64/runner/Release/innocence_flutter.exe；未覆盖正在运行的 D 盘 v1.1.0 便携版"
  - command: "git diff --check"
    result: "通过，无空白错误"
compatibility_and_security:
  contract_impact: "none；年度任务、进度字段、月份几何与 HTTP 契约未变"
  tenant_impact: "none；未改读写路径"
  sensitive_data: "未读取或写入账号、密码或个人数据"
risks_or_blockers:
  - "本轮只完成自动化与 Windows Release 构建，尚未在运行态目视检查新构建的 Large/Medium/Small 与多 DPI 效果"
  - "D 盘当前打开的 v1.1.0 便携版仍是旧二进制，不会自动显示本次源码修正"
next_actions:
  - id: NEXT-GLASS-ANNUAL-VISUAL-QA
    action: "在隔离的 Windows Release 实机检查玻璃态月份栏滚动吸顶、0%/中间值/100% 充能框和 Large/Medium/Small 多 DPI 视觉；确认后再决定安装或发布新版本"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "client/flutter_app/test/features/home/adaptive_annual_progress_test.dart"]
---
