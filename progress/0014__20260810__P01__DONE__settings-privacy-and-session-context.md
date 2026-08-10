---
schema_version: 1
document_type: checkpoint
sequence: "0014"
created_at: "2026-08-10T10:30:00+08:00"
phase: P01
type: DONE
status: complete
title: "设置隐私黑名单与当前设备会话上下文"
objective: "继续 P01 资料、隐私与设置页面重建，补齐黑名单和当前设备会话的真实客户端链路"
completed:
  - fact: "客户端新增 BlacklistItem 与 CurrentDeviceSession canonical model；CurrentDeviceSession 不保留服务端会话凭据字段"
    evidence: "client/flutter_app/lib/features/account/domain/models/blacklist_item.dart；client/flutter_app/lib/features/account/domain/models/current_device_session.dart"
  - fact: "SettingsApi 已接入 GET account/blacklist、DELETE account/blacklist/{targetUserId} 与 GET account/sessions/current，并复用当前登录会话 headers"
    evidence: "client/flutter_app/lib/features/settings/data/settings_api.dart；server/innocence-server/src/main/java/com/innocence/server/modules/account/controller/AccountController.java"
  - fact: "SessionController 维护黑名单和当前设备会话状态，登出、会话失效、注销账号时清理账号范围状态"
    evidence: "client/flutter_app/lib/app/session_controller.dart"
  - fact: "设置页显示隐私开关、黑名单空/非空态、解除拉黑二次确认、当前设备在线/替换状态，并将旧桌面挂件文案改为 Canvas / Focus Orb"
    evidence: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
  - fact: "设置页表面切换为无玻璃、无渐变、直角边界的纯色平面，保留现有业务回调与危险操作确认"
    evidence: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
changed_files:
  - path: "client/flutter_app/lib/features/account/domain/models/blacklist_item.dart"
    change: "新增黑名单条目模型与安全数值解析"
  - path: "client/flutter_app/lib/features/account/domain/models/current_device_session.dart"
    change: "新增当前设备会话模型，仅保留展示所需字段"
  - path: "client/flutter_app/lib/features/settings/data/settings_api.dart"
    change: "新增黑名单读取/解除与当前设备会话读取"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "新增账号安全上下文状态、加载/解除动作与退出清理"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "将新增设置安全上下文回调传入 SettingsPage"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "完成 SessionController 到 HomePage 的回调 wiring"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "新增黑名单和当前设备会话表面，更新 Focus Orb 文案与平面设置面板"
  - path: "client/flutter_app/test/account/settings_account_models_test.dart"
    change: "新增黑名单/当前设备会话模型的正常、数值标志和缺字段测试源码"
  - path: "docs/06-contract-inventory.md"
    change: "登记 U09-U11"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "fixture contract 范围更新为 U01-U11"
evidence:
  - command: "PowerShell Dart 源码分隔符扫描"
    result: "8 个受影响 Dart/测试文件括号、字符串和注释状态均平衡"
  - command: "PowerShell 后端路由与客户端路径对齐扫描"
    result: "后端 /blacklist、/blacklist/{targetUserId}、/sessions/current 与客户端三条路径均存在"
  - command: "PowerShell 敏感字段 UI 扫描"
    result: "设置页未引用 session/access token 字段；未新增密码、邮箱或验证码日志"
  - command: "git diff --check"
    result: "通过；仅报告工作副本 LF/CRLF 转换提示"
  - command: "Get-Command flutter；Get-Command dart"
    result: "Flutter 和 Dart 均不可用，因此未执行 flutter analyze、flutter test 或 Windows 构建"
compatibility_and_security:
  contract_impact: "新增客户端调用均对应既有接口草案和后端 AccountController 路由；脱敏请求回放仍待收集"
  tenant_impact: "黑名单与当前设备会话请求只使用当前 AppSession，服务端以 RequestUserContext.currentUserId 绑定用户"
  sensitive_data: "CurrentDeviceSession 忽略服务端 sessionToken；设置页未渲染 accessToken、sessionToken、密码或验证码"
risks_or_blockers:
  - "Flutter/Dart SDK 不在当前环境，模型测试源码和页面仍未执行"
  - "G01 仍未通过：会话冲突真实回放、租户不匹配/权限拒绝负向回放、头像上传和黑名单新增入口待补"
next_actions:
  - id: NEXT-001
    action: "完成设置页 Large/Medium/Small 三档独立编排，补头像上传和黑名单新增入口"
    inputs: []
  - id: NEXT-002
    action: "Flutter SDK 可用后执行 analyze/test，并回放 U09-U11 的正常、空、权限拒绝和会话替换样本"
    inputs: []
---
