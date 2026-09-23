---
schema_version: 1
document_type: checkpoint
sequence: "0057"
created_at: "2026-09-23T11:50:46+08:00"
phase: P01
type: DECISION
status: complete
title: "年度脉冲跨度与任务进度合一并支持双向调整"
objective: "按用户最新要求移除年度任务独立进度条，使脉冲条从空框起按任务进度填充，加入对应减量按钮并覆盖冲突计划"
completed:
  - fact: "年度任务卡和首页本月年度任务预览均改用单一充能组件；完整外框表示起止月份，内部填充宽度由 progressPercent 决定，0% 为空、100% 为满"
    evidence: "adaptive_desktop_home.dart 的 _AnnualTaskCard、_ChargingMonthSpan 与 _HomePlanTabs；年度部件测试断言 0%/10%/90%/100% 几何宽度与独立进度条不存在"
  - fact: "+10/−10、+5/−5、+1/−1 成对显示，0% 禁减、100% 禁增且可减量撤销完成；直接完成仍写入 100%"
    evidence: "_adjustTaskProgress 使用 AnnualPlanSegment.adjustProgress 双向钳制；部件与模型测试覆盖增量、减量、边界和完成后回退"
  - fact: "用户原话与统一进度组件提示词存入 UI 规划，并同步修正当前执行计划、年月实施规划、信息架构、数据流和 U20/U22 契约说明"
    evidence: "Innocence-UI设计规划.md 第 2.33 节、D-09C、docs/03-execution-plan.md、docs/06-contract-inventory.md、docs/07-dataflow-and-module-map.md"
changed_files:
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "删除年度卡独立进度条，合并脉冲跨度/进度填充，首页预览复用组件并新增配对减量按钮"
  - path: "client/flutter_app/lib/features/plans/domain/models/annual_plan_overview.dart"
    change: "将单向 incrementProgress 改为双向 adjustProgress 并继续钳制 0–100"
  - path: "client/flutter_app/test/features/home/adaptive_annual_progress_test.dart"
    change: "覆盖空框、平滑填充、各档增减、完成后回退、月度预览共用与月份吸顶"
  - path: "client/flutter_app/test/features/plans/plan_overview_models_test.dart"
    change: "覆盖负向进度调整与 0–100 边界"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "存档最新用户需求与 2.33 可复用设计提示词，明确覆盖旧双进度条方案"
  - path: "docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md"
    change: "新增 D-09C 并替换现行年度板实施描述"
  - path: "docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "年度页面描述改为唯一充能框和双向进度控制"
  - path: "docs/03-execution-plan.md"
    change: "更新执行范围与本轮验证状态"
  - path: "docs/06-contract-inventory.md"
    change: "明确 U20/U22 原字段驱动合并条和增减进度，不新增接口"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "明确外框/填充语义和原接口复用"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前状态、决策及视觉验收下一步"
  - path: "progress/INDEX.md"
    change: "追加 0057 任务日志索引"
  - path: "progress/0057__20260923__P01__DECISION__unified-annual-charge-and-bidirectional-progress.md"
    change: "记录本轮用户决策、实施文件、验证证据与风险"
evidence:
  - command: "flutter test --no-pub test/features/home/adaptive_annual_progress_test.dart test/features/plans/plan_overview_models_test.dart"
    result: "最终通过，3/3；中途有一次部件测试因动画首帧计时断言失败，补齐起始帧后复测通过"
  - command: "flutter analyze --no-pub"
    result: "No issues found"
  - command: "flutter test --no-pub"
    result: "通过，63/63；随后新增的首页预览复用断言另以年度定向测试通过"
  - command: "flutter test --no-pub test/features/home/adaptive_annual_progress_test.dart"
    result: "通过，1/1，包含最后新增的首页本月预览断言"
  - command: "flutter build windows --release --no-pub"
    result: "通过，生成 build/windows/x64/runner/Release/innocence_flutter.exe；AOT app.so 本轮更新为 8,520,592 bytes"
  - command: "git diff --check"
    result: "通过，无空白错误；仅 LF/CRLF 提示"
compatibility_and_security:
  contract_impact: "U20/U22 字段、HTTP 路由与存储结构不变；原 progressPercent 继续持久化，负向按钮只提交钳制后的新值"
  tenant_impact: "沿用原年度任务读写与离线 owner scope；本轮没有新增跨用户数据通道"
  sensitive_data: "未读取或写入真实账号、密码或个人数据"
risks_or_blockers:
  - "Windows Large/Medium/Small 与 100%/125%/150% DPI 的实际视觉和充能动效尚未人工验收；编译和部件测试不能替代目视检查"
  - "本轮未修改服务端代码，也未重跑 Maven；上轮全套 44 项通过，但不作为本轮新 UI 的服务端回归证据"
next_actions:
  - id: NEXT-ANNUAL-CHARGE-VISUAL-QA
    action: "运行本轮 Windows Release，在不同窗口尺寸和 DPI 下人工检查 0/中间值/100% 充能框、成对增减按钮、吸顶月份刻度与首页本月预览"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "client/flutter_app/test/features/home/adaptive_annual_progress_test.dart"]
---
