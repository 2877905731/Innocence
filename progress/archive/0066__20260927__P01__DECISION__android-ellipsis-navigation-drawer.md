---
schema_version: 1
document_type: checkpoint
sequence: "0066"
created_at: "2026-09-27T11:18:26+08:00"
phase: P01
type: DECISION
status: complete
title: "Android 主导航采用左上角三点按钮与侧边栏"
objective: "将用户对 Android 主导航的明确选择替换原五项底栏提案，锁定后续 MD3 Shell 的导航形态。"
completed:
  - fact: "用户选择侧边栏，并要求左上角“···”按钮收纳上文讨论的主功能；不再采用底部 NavigationBar。"
    evidence: "用户原文：‘采用侧边栏，然后在左上角做一个···按钮把这些功能收纳起来’。"
  - fact: "Android 规划把首页、计划、专注、陪伴、收件箱放入 MD3 NavigationDrawer；统计、备忘录、设置与退出作为次级入口是本轮实施分组。"
    evidence: "docs/planning/Innocence-Android版本实施规划.md §4、§4.2 和 §13；Flutter NavigationDrawer 与 Scaffold.drawer 官方 API。"
  - fact: "未登录本机离线入口是否列入 Android 正式首发仍未得到用户决定，不由导航选择推定。"
    evidence: "原待决事项保留在 Android 规划和当前 RESUME。"
changed_files:
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "将五项底栏提案改为三点按钮侧边栏，并更新线框、组件和 A1 交付物。"
  - path: "docs/03-execution-plan.md"
    change: "同步 Android 主导航已确认、离线首发范围仍待确认的状态。"
  - path: "docs/08-project-profile.md"
    change: "更新 Android 规划引用状态。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录本次导航决策与未决范围。"
  - path: "progress/INDEX.md"
    change: "追加 0066 决策记录。"
  - path: "progress/0066__20260927__P01__DECISION__android-ellipsis-navigation-drawer.md"
    change: "固化用户原话、导航分组和决策边界。"
evidence:
  - command: "Get-Content progress/0000__AI-RESUME.md；Get-Content progress/INDEX.md；rg -n 'NavigationBar|底栏|五项' docs/planning/Innocence-Android版本实施规划.md"
    result: "续写序号从 0065 起；原规划仍把五项底栏作为提案，现已替换为侧边栏决策。"
  - command: "查阅 Flutter 官方 NavigationDrawer、Scaffold.drawer 和 ScaffoldState.openDrawer API"
    result: "确认 Material 3 NavigationDrawer 可置于 Scaffold.drawer，由自定义左上角按钮调用 openDrawer，系统返回可关闭抽屉。"
  - command: "git diff --check -- docs/03-execution-plan.md docs/08-project-profile.md"
    result: "退出码 0，无空白错误；仅有 Git 行尾转换提示。"
compatibility_and_security:
  contract_impact: "none；导航形态不改变服务端接口或字段。"
  tenant_impact: "社交与收件箱必须绑定登录用户；离线时不可展示其他账号缓存。"
  sensitive_data: "none。"
risks_or_blockers:
  - "未登录本机离线资料是否进入 Android 正式首发仍待确认。"
  - "导航决策不代表计划、陪伴、收件箱等业务页面已按 MD3 完整重建。"
next_actions:
  - id: NEXT-ANDROID-DRAWER
    action: "实现并验证左上角三点按钮、MD3 NavigationDrawer、五个主入口、系统返回与离线社交隔离。"
    inputs: ["client/flutter_app/lib/features/home/presentation/pages/home_page.dart", "docs/planning/Innocence-Android版本实施规划.md"]
---
