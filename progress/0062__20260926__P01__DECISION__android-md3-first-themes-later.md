---
schema_version: 1
document_type: checkpoint
sequence: "0062"
created_at: "2026-09-26T22:46:07+08:00"
phase: P01
type: DECISION
status: complete
title: "Android 首版采用 MD3，四主题移动适配后置"
objective: "按用户新决策调整 Android 视觉范围与项目门禁，确保 Windows 四主题要求不受影响"
completed:
  - fact: "用户明确 Android 规划的首要视觉要求为 Material Design 3，四个产品主题的移动适配可以延后。"
    evidence: "用户原文：‘主题可以先不着急做，但是要ui依照md3来自做’；已存入 Android 规划和 UI 设计规划 2.34。"
  - fact: "Android A0–A5 改为验收 MD3 手机页面、浅／深色、语义色与组件状态；五项底部导航及未登录离线入口仍保持提案状态。"
    evidence: "Android 规划的视觉范围决策、4.1 组件规则、A0/A1/A5 阶段和验收矩阵。"
  - fact: "产品范围、执行计划和项目画像明确区分 Windows 四主题与 Android MD3；Windows 既有主题提示词和验收要求继续保留。"
    evidence: "docs/01-product-scope.md SCOPE-008、docs/03-execution-plan.md android_track/G05/G06、docs/08-project-profile.md RULE-003/RULE-014。"
  - fact: "核对现有 Flutter 虽已设置 useMaterial3=true，但 MaterialApp 仍由 AppVisualTokens 四主题生成主题数据；Android 移动页面尚未按本决策实现。"
    evidence: "client/flutter_app/lib/app/app.dart:50-55；client/flutter_app/lib/app/app_visual_theme.dart:201。"
changed_files:
  - path: "AGENTS.md"
    change: "更新项目摘要、当前里程碑、Android MD3 约束和条件读取路径。"
  - path: "docs/01-product-scope.md"
    change: "将 SCOPE-008 拆明 Windows 四主题与 Android MD3 首版验收。"
  - path: "docs/03-execution-plan.md"
    change: "Android 轨道标明 MD3；相关双端、主题和 G05/G06 表述按平台分开。"
  - path: "docs/08-project-profile.md"
    change: "限定四主题规则到 Windows，新增 Android MD3 首版规则与证据。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "存入用户原话并追加 2.34，覆盖此前移动端需同步四主题的实施顺序。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "MD3 成为首版页面基线，四主题移至后续；补齐页面组件、浅／深色和验收要求。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录 DEC-0040 与 Android MD3 的下一步。"
  - path: "progress/INDEX.md"
    change: "追加 0062 决策检查点。"
  - path: "progress/0062__20260926__P01__DECISION__android-md3-first-themes-later.md"
    change: "记录本次用户决策、影响范围和未验证边界。"
evidence:
  - command: "Get-Content progress/0000__AI-RESUME.md；Get-Content progress/INDEX.md 尾部；Get-Content Android 规划"
    result: "续写状态为 P01/G01、最新 0061；Android 初稿此前把四主题移动令牌列入 A0，已按新决策替换。"
  - command: "rg -n 'useMaterial3: true|final visualTokens =|theme: visualTokens' client/flutter_app/lib/app/app.dart client/flutter_app/lib/app/app_visual_theme.dart"
    result: "确认 useMaterial3 已启用，但根应用当前主题仍来自四主题 AppVisualTokens；不能据此宣称 Android MD3 页面已完成。"
  - command: "查阅 Flutter 官方 Material Design、主题和 NavigationBar 文档"
    result: "Flutter 官方说明 MD3 为默认样式，但 NavigationBar 等新组件需在页面中采用；已在 Android 规划中加入官方链接。"
  - command: "rg -n 'Android 首版|MD3|Material Design 3|四主题.*双端' AGENTS.md docs/01-product-scope.md docs/03-execution-plan.md docs/08-project-profile.md docs/planning/"
    result: "新约束已落在范围、执行、画像与设计规划；保留 Windows 四主题，Android A0–A5 不再要求四主题适配。"
  - command: "git diff --check"
    result: "退出码 0，无空白错误；仅有 Git 的 LF/CRLF 行尾提示。"
  - command: "Flutter Android 构建、模拟器或真机运行"
    result: "未执行；本次仅更新用户决策与计划文本。"
compatibility_and_security:
  contract_impact: "none；未修改接口、字段或业务语义。"
  tenant_impact: "none；Android 规划继续要求 Bearer 用户边界和 ownerScope 隔离。"
  sensitive_data: "未写入账号、密码、令牌或签名材料。"
risks_or_blockers:
  - "Android 五项主导航、未登录离线资料首发范围和具体 MD3 品牌色值仍待 A0 确认。"
  - "Android MD3 页面、浅／深色与真机效果尚未编码或验证。"
next_actions:
  - id: NEXT-ANDROID-MD3-A0
    action: "制作 MD3 手机页面地图、主导航线框、浅／深色语义色板和状态组件清单，确认移动离线范围后进入 A1。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md", "client/flutter_app/lib/app/app.dart"]
---
