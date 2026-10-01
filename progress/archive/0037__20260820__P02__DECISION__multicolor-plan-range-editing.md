---
schema_version: 1
document_type: checkpoint
sequence: "0037"
created_at: "2026-08-20T01:12:13+08:00"
phase: P02
type: DECISION
status: complete
title: "今日计划多色联动时间条与防重叠边界拖动"
objective: "让多个今日计划以循环浅色渐变区分，在计划卡中显示等量联动小时间条，并允许点击已有时段后拖动首尾安全调整范围。"
completed:
  - fact: "每个计划获得稳定色板序号，使用六组浅色循环；计划内部各半小时条从当前色向下一色平滑插值，多个计划不再共享单一选中色。"
    evidence: "client/flutter_app/lib/features/plans/presentation/widgets/today_plan_editor_dialog.dart 中 _planPastelPalette 与 _planSlotColor。"
  - fact: "计划卡时间右侧显示与时段格数严格一致、等高且同色顺序的小时间条；新建或边界变化后从零缩放到完整尺寸，减少动画模式下立即完成。"
    evidence: "_AnimatedPlanStrips；today-plan-mini-strip-* 部件键。"
  - fact: "点击已有时段只激活所属计划并显示首尾拖动手柄；点击空白时段才开始新建计划。"
    evidence: "_handleSlotTap、today-plan-resize-start-* 与 today-plan-resize-end-*。"
  - fact: "首尾拖动最短保留一个半小时格，并由相邻计划边界钳制；不能越过或覆盖其他计划，主时间轴和计划卡小条同步动画更新。"
    evidence: "_resizeBlock、_beginResizeAtPosition 与 _updateResize。"
  - fact: "现行 UI 规划、Windows 信息架构、自适应体验和 P02 执行计划已删除或替换单一选中色、占用段可新建和已有范围不可调整的冲突要求。"
    evidence: "docs/planning/Innocence-UI设计规划.md 2.25；Windows 两份规划；docs/03-execution-plan.md。"
changed_files:
  - path: "client/flutter_app/lib/features/plans/presentation/widgets/today_plan_editor_dialog.dart"
    change: "新增稳定循环浅色渐变、联动小时间条动画、选中态拖动手柄和防重叠范围调整。"
  - path: "client/flutter_app/test/features/plans/today_plan_editor_dialog_test.dart"
    change: "验证不同计划颜色、计划内渐变、等量小时间条、占用段只激活及拖动到相邻计划自动停止。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "新增2.25决策并替换2.24中与占用段交互冲突的描述。"
  - path: "docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "将多色时间轴、等量计划条和防重叠边界拖动写入页面职责。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "明确三档Canvas共享空白新建、已有段拖动和联动计划条交互。"
  - path: "docs/03-execution-plan.md"
    change: "新增P02多色联动与范围编辑动作及门禁。"
evidence:
  - command: "flutter test test/features/plans/today_plan_editor_dialog_test.dart"
    result: "3 项通过。"
  - command: "flutter test"
    result: "30 项通过。"
  - command: "flutter analyze"
    result: "No issues found! (ran in 2.0s)"
  - command: "git diff --check"
    result: "通过；仅有既有LF/CRLF提示，无空白错误。"
  - command: "flutter build windows --release"
    result: "32.3秒成功生成 build/windows/x64/runner/Release/innocence_flutter.exe。"
  - command: "Start-Process release exe；Get-Process"
    result: "PID 29920，MainWindowTitle=Innocence，Responding=True。"
compatibility_and_security:
  contract_impact: "none；颜色和编辑态仅存在于客户端，保存继续使用既有 startSlot/endSlot。"
  tenant_impact: "none；未改变计划接口的当前用户会话边界。"
  sensitive_data: "none"
risks_or_blockers:
  - "鼠标拖动手感、浅色色差和大量计划时的小时间条密度仍需在当前Release中人工视觉确认。"
next_actions:
  - id: NEXT-001
    action: "在当前Windows Release中创建多个相邻计划，人工确认循环色、首尾拖动、碰撞停止与保存回显。"
    inputs: ["Windows Release", "合成登录会话"]
---

# 检查点说明

本决策覆盖旧的单一选中色、点击占用时段仍进入新建流程和已有时段只能删除重建的交互。历史检查点依不可变规则保留，但冲突内容不再生效。
