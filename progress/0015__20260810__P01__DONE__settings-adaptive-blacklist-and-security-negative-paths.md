---
schema_version: 1
document_type: checkpoint
sequence: "0015"
created_at: "2026-08-10T11:30:38+08:00"
phase: P01
type: DONE
status: complete
title: "设置页三档编排、黑名单新增与安全负向路径"
objective: "完成设置页 Large/Medium/Small 自适应编排和黑名单新增链路，并为 G01 的会话、认证、拉黑与租户权限负向路径建立可执行证据"
completed:
  - fact: "设置页按 DesktopPresentationTier 分为 Large 左侧分组导航加右侧表单、Medium 顶部分组导航加单表单、Small 列表到详情三种独立组合"
    evidence: "client/flutter_app/lib/features/settings/presentation/settings_presentation.dart；client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
  - fact: "黑名单新增从设置页输入目标用户 ID，经 HomePage、SessionController、SettingsApi 调用既有 POST account/blacklist/{targetUserId}，成功后刷新当前用户黑名单"
    evidence: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart；client/flutter_app/lib/app/session_controller.dart；client/flutter_app/lib/features/settings/data/settings_api.dart"
  - fact: "客户端在提交前拒绝无效 ID 和当前用户 ID，并明确提示拉黑会解除好友关系；服务端继续以当前会话用户作为数据边界"
    evidence: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart；server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AccountService.java"
  - fact: "新增会话认证测试覆盖缺失凭据、同类型新设备替换旧桌面会话、非法设备类型和有效桌面槽位"
    evidence: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/SessionAuthServiceTest.java"
  - fact: "新增账户与好友安全测试覆盖错误密码、拉黑自己，以及非申请接收者跨用户处理好友申请时返回 FORBIDDEN 且不写入接受状态"
    evidence: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/AccountServiceSecurityTest.java；server/innocence-server/src/test/java/com/innocence/server/modules/friend/service/FriendServiceSecurityTest.java"
  - fact: "头像上传未添加占位入口：当前后端仅支持写入 avatarUrl 字段，没有文件上传路由、存储位置或返回 URL 契约"
    evidence: "server/innocence-server/src/main/java/com/innocence/server/modules/account/dto/request/UpdateProfileRequest.java；docs/06-contract-inventory.md"
changed_files:
  - path: "client/flutter_app/lib/features/settings/presentation/settings_presentation.dart"
    change: "新增三档设置页组合策略"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "实现三档编排、分组导航、Small 列表详情和黑名单新增对话框"
  - path: "client/flutter_app/test/features/settings/settings_presentation_test.dart"
    change: "新增 Large/Medium/Small 组合映射测试源码"
  - path: "client/flutter_app/lib/features/settings/data/settings_api.dart"
    change: "新增黑名单 POST 调用"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "新增黑名单写入动作、列表刷新和用户反馈"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "向设置页传递黑名单新增回调"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "完成 SessionController 到 HomePage 的新增回调 wiring"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/SessionAuthServiceTest.java"
    change: "新增四项会话认证负向与槽位测试"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/AccountServiceSecurityTest.java"
    change: "新增错误密码和拉黑自己测试"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/friend/service/FriendServiceSecurityTest.java"
    change: "新增跨用户好友申请权限拒绝测试"
  - path: "docs/06-contract-inventory.md"
    change: "登记 U12 黑名单新增契约"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "fixture contract 范围更新为 U01-U12"
evidence:
  - command: "mvn -q '-Dtest=SessionAuthServiceTest,AccountServiceSecurityTest,FriendServiceSecurityTest' test"
    result: "通过；共 7 项，failures=0、errors=0、skipped=0"
  - command: "mvn -q test"
    result: "未通过；共执行 8 项，新增 7 项通过，既有 InnocenceServerApplicationTests.contextLoads 因本机数据库连接不可用产生 1 error"
  - command: "git diff --check"
    result: "通过；仅报告工作副本 LF/CRLF 转换提示"
  - command: "PowerShell 受影响 Dart 文件分隔符计数扫描"
    result: "7 个受影响 Dart/测试文件的圆括号、方括号和花括号数量平衡"
  - command: "Get-Command flutter；Get-Command dart"
    result: "Flutter 和 Dart 均不可用，因此未执行 flutter analyze、flutter test 或 Windows 构建"
compatibility_and_security:
  contract_impact: "新增 U12 客户端调用，对齐既有 AccountController POST /account/blacklist/{targetUserId}；头像上传仍待先行固化契约"
  tenant_impact: "黑名单写入使用当前 AppSession；好友申请跨用户响应通过服务层 FORBIDDEN 测试验证不得修改他人申请"
  sensitive_data: "测试仅使用合成 ID、合成凭据和 example.test 地址；未记录真实 token、密码、验证码或个人身份信息"
risks_or_blockers:
  - "Flutter/Dart SDK 不在当前环境，自适应策略测试源码和 Flutter 页面尚未由工具链执行"
  - "完整 Spring Boot contextLoads 依赖本机数据库，当前连接不可用；HTTP 层真实会话和租户隔离回放尚未完成"
  - "头像上传缺少后端文件上传与存储契约，按 TRUTHFUL-SCOPE 不添加不可工作的客户端入口"
next_actions:
  - id: NEXT-001
    action: "固化头像上传文件类型、大小、存储、鉴权和 URL 返回契约，再实现后端及客户端链路"
    inputs: []
  - id: NEXT-002
    action: "Flutter SDK 与数据库集成环境可用后执行客户端工具链、Windows DPI 和 HTTP 负向验收"
    inputs: []
---
