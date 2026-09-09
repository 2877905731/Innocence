---
schema_version: 1
document_type: checkpoint
sequence: "0045"
created_at: "2026-09-10T02:47:17+08:00"
phase: P01
type: DONE
status: complete
title: "Windows 托盘驻留、暂停计时与首版 Logo 候选稿"
objective: "实现关闭后驻留系统托盘、托盘基础菜单和真实暂停/继续计时，并按用户的白色先锋艺术方向生成首版 Logo 候选稿"
completed:
  - fact: "Windows 关闭消息由原生 Shell 优先拦截并隐藏窗口；托盘单击恢复主界面，只有托盘退出命令销毁进程。"
    evidence: "PowerShell 运行态探针返回 AliveAfterClose=True、HiddenAfterClose=True、VisibleAfterTrayClick=True。"
  - fact: "托盘右键菜单包含显示主界面、设置、暂停/继续计时和退出；设置与计时项按当前应用状态启用，离线模式仍可进入已分级的本机设置。"
    evidence: "最终 Windows Release 中模拟 WM_CONTEXTMENU 后检测到 1 个属于 Innocence 进程的 #32768 原生弹出菜单窗口。"
  - fact: "在线专注新增 pause/resume 契约，保存 pausedAt 与累计暂停秒数；离线 SQLite 升级到 v3 并保存暂停、已用和剩余秒数，暂停区间不计入学习时长。"
    evidence: "Maven 39 项通过（新增 3 项 FocusSessionService 测试）；Flutter 54 项通过（新增暂停 tick、离线生命周期和 SQLite v2→v3 历史时长迁移覆盖）。"
  - fact: "Windows 自适应首页增加暂停/继续与结束两个独立操作，Focus Orb 双击在活动专注中改为暂停/继续。"
    evidence: "flutter analyze 无问题，Windows Release 构建成功。"
  - fact: "生成白色折页/前进箭头、深靛结构线和钴蓝焦点点的透明首版 Logo 候选稿，并归档原始提示词。"
    evidence: "PNG 为 1254×1254、Format32bppArgb，左上角 alpha=0；尚未替换正式 ICO。"
changed_files:
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "关闭驻留、托盘菜单、恢复与真正退出。"
  - path: "client/flutter_app/windows/runner/win32_window.h"
    change: "新增托盘状态与命令接口。"
  - path: "client/flutter_app/windows/runner/flutter_window.cpp"
    change: "原生关闭优先级与托盘 MethodChannel 双向命令。"
  - path: "client/flutter_app/windows/runner/flutter_window.h"
    change: "新增托盘命令回调声明。"
  - path: "client/flutter_app/lib/core/platform/desktop_widget_bridge.dart"
    change: "同步托盘状态并接收托盘命令。"
  - path: "client/flutter_app/lib/core/local/offline_store.dart"
    change: "SQLite v3 专注暂停持久化、旧数据迁移与离线同步时长。"
  - path: "client/flutter_app/lib/features/focus/domain/models/focus_session.dart"
    change: "新增 paused 状态并冻结本地 tick。"
  - path: "client/flutter_app/lib/features/focus/data/focus_session_api.dart"
    change: "新增 pause/resume 客户端调用。"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "统一在线与离线暂停/继续流程。"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "向 Windows 首页传递暂停回调。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "透传暂停回调并补暂停阶段文案。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "托盘协调、Focus Orb 快捷动作与页面暂停按钮。"
  - path: "client/flutter_app/test/core/local/offline_store_test.dart"
    change: "覆盖离线暂停、恢复和结束生命周期。"
  - path: "client/flutter_app/test/features/focus/focus_session_test.dart"
    change: "覆盖暂停不 tick 与活动 tick。"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/focus"
    change: "新增暂停字段、接口、服务计算和 Mapper。"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/sync/service/SyncImportService.java"
    change: "导入离线专注时接受剔除暂停区间后的 durationSeconds。"
  - path: "server/innocence-server/src/main/resources/schema.sql"
    change: "新增在线专注暂停字段的幂等迁移。"
  - path: "server/innocence-server/src/main/resources/mapper/focus/FocusSessionMapper.xml"
    change: "活动/暂停状态查询与状态切换 SQL。"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/focus/service/FocusSessionServiceTest.java"
    change: "新增暂停、恢复和无活动会话负向测试。"
  - path: "docs/06-contract-inventory.md"
    change: "固化 U24/U25 pause/resume 契约。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "覆盖托盘第一版菜单与关闭语义。"
  - path: "docs/design/logo/innocence-logo-v1-candidate.png"
    change: "透明 Logo 候选稿。"
  - path: "docs/design/logo/README.md"
    change: "Logo 语义、状态和原始提示词归档。"
evidence:
  - command: "cd client/flutter_app && flutter analyze"
    result: "No issues found。"
  - command: "cd client/flutter_app && flutter test"
    result: "54 项全部通过。"
  - command: "cd server/innocence-server && mvn test"
    result: "39 项通过，0 failure，0 error。"
  - command: "cd client/flutter_app && flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe。"
  - command: "启动最终 Release，发送 WM_CLOSE，再发送托盘 WM_LBUTTONUP"
    result: "AliveAfterClose=True；HiddenAfterClose=True；VisibleAfterTrayClick=True。"
  - command: "向隐藏窗口发送托盘 WM_CONTEXTMENU 并枚举进程窗口"
    result: "TrayPopupMenuWindows=1。"
  - command: "System.Drawing 读取 docs/design/logo/innocence-logo-v1-candidate.png"
    result: "1254×1254、32bpp ARGB、透明角 alpha=0。"
compatibility_and_security:
  contract_impact: "新增 U24/U25；FocusSession 响应增加向后兼容的 paused 布尔字段；本地数据库由 v2 幂等迁移到 v3。"
  tenant_impact: "在线暂停/继续只通过 Bearer token 解析的 userId 查询和更新；Mapper 更新同时约束 sessionId 与 userId。"
  sensitive_data: "none"
risks_or_blockers:
  - "Logo 仍是候选 PNG，用户确认前未覆盖 app_icon.ico，也未制作新的安装包。"
  - "U24/U25 已有服务单测但尚未使用真实登录会话做 HTTP 回放。"
next_actions:
  - id: NEXT-001
    action: "用户确认或调整 Logo 候选稿；确认后制作多尺寸 ICO、替换桌面/托盘图标并构建下一版 Windows 包。"
    inputs: ["docs/design/logo/innocence-logo-v1-candidate.png", "client/flutter_app/windows/runner/resources/app_icon.ico"]
  - id: NEXT-002
    action: "用合成账号真实回放 pause/resume，并人工点击托盘设置、暂停/继续和退出完成端到端验收。"
    inputs: ["docs/06-contract-inventory.md", "client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe"]
---

# 检查点说明

- 本检查点完成的是托盘与暂停能力，以及 Logo 候选稿；Logo 正式资源替换仍需用户确认。
