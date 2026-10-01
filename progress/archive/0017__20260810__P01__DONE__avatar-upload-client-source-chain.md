---
schema_version: 1
document_type: checkpoint
sequence: "0017"
created_at: "2026-08-10T11:58:35+08:00"
phase: P01
type: DONE
status: complete
title: "头像选择与客户端 multipart 源码链路"
objective: "在 U13 契约基础上完成资料页文件选择、multipart 上传、资料刷新和客户端边界拒绝源码"
completed:
  - fact: "资料页移除手填 avatarUrl，新增跨平台 JPEG/PNG 文件选择与更换头像入口；Large/Medium/Small 继续复用同一语义动作"
    evidence: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
  - fact: "ApiClient 新增 multipart/form-data 编码，SettingsApi 对齐 U13 的 file 字段、5 MiB 上限、MIME 和 avatarUrl 返回结构"
    evidence: "client/flutter_app/lib/core/network/api_client.dart；client/flutter_app/lib/features/settings/data/settings_api.dart"
  - fact: "上传回调贯穿 SettingsPage、HomePage、App 和 SessionController；上传成功后重新读取资料并同步 profile 与 settings overview"
    evidence: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart；client/flutter_app/lib/app/app.dart；client/flutter_app/lib/app/session_controller.dart"
  - fact: "新增空文件、非 JPEG/PNG 扩展名和超过 5 MiB 的客户端拒绝测试源码"
    evidence: "client/flutter_app/test/features/settings/avatar_upload_contract_test.dart"
  - fact: "引入 flutter.dev 发布的 file_selector 1.1.0，并依据 pub.dev 官方包元数据固化当前 Dart 3.12 / Flutter 3.44 锁文件所需依赖版本和 SHA-256"
    evidence: "client/flutter_app/pubspec.yaml；client/flutter_app/pubspec.lock"
changed_files:
  - path: "client/flutter_app/lib/core/network/api_client.dart"
    change: "新增 multipart POST 与共用响应解析"
  - path: "client/flutter_app/lib/features/settings/data/settings_api.dart"
    change: "新增 U13 客户端适配与大小/类型前置拒绝"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "新增头像上传动作和资料同步"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "向 HomePage 注入头像上传动作"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "向 SettingsPage 传递头像上传回调"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "新增真实文件选择入口并移除头像 URL 手填"
  - path: "client/flutter_app/test/features/settings/avatar_upload_contract_test.dart"
    change: "新增三项客户端负向测试源码"
  - path: "client/flutter_app/pubspec.yaml"
    change: "新增 file_selector 依赖"
  - path: "client/flutter_app/pubspec.lock"
    change: "登记 file_selector 及其传递依赖"
  - path: "docs/06-contract-inventory.md"
    change: "U13 状态更新为服务端与客户端源码已对齐、HTTP 回放待完成"
evidence:
  - command: "mvn -q \"-Dtest=AvatarUploadServiceTest,SessionAuthServiceTest,AccountServiceSecurityTest,FriendServiceSecurityTest\" test"
    result: "通过；头像服务与既有会话、账户、好友安全测试全部通过"
  - command: "PowerShell 对 7 个受影响 Dart/测试文件执行圆括号、方括号和花括号计数扫描"
    result: "通过；未发现分隔符数量不平衡"
  - command: "Invoke-RestMethod https://pub.dev/api/packages/{package}"
    result: "核对 file_selector 1.1.0 及平台实现、cross_file、http、http_parser、typed_data 的版本、SDK 约束和 archive_sha256"
  - command: "Get-Command flutter；Get-Command dart"
    result: "Flutter 和 Dart 均不可用，因此未执行 flutter pub get、flutter analyze 或 flutter test"
  - command: "git diff --check"
    result: "通过；仅报告工作副本 LF/CRLF 转换提示"
compatibility_and_security:
  contract_impact: "客户端实现 U13，不新增或改写服务端字段；文件名仅作为 multipart 元数据，服务端继续生成存储文件名"
  tenant_impact: "客户端只发送当前 AppSession 鉴权头，不发送 userId 表单字段或目标存储路径"
  sensitive_data: "测试使用合成 token、用户 ID 和内存字节；未记录真实文件、邮箱、密码或会话凭据"
risks_or_blockers:
  - "本机缺少 Flutter/Dart SDK；锁文件依据官方包元数据校对但未由 flutter pub get 重生成，客户端源码尚未经过 analyze/test/Windows 构建"
  - "MySQL/Redis 集成环境不可用，U13 正常与负向 HTTP 回放仍未执行"
next_actions:
  - id: NEXT-001
    action: "Flutter SDK 可用后先执行 flutter pub get、git diff 核对锁文件，再执行 flutter analyze、flutter test 和 Windows 构建"
    inputs: ["Flutter SDK", "Dart SDK"]
  - id: NEXT-002
    action: "数据库集成环境可用后回放 U13 正常上传、缺失、超限、伪图片、会话失效和跨用户边界"
    inputs: ["MySQL/Redis 集成环境", "U13"]
---

# 检查点说明

本检查点只声明客户端源码链路完成；Flutter 工具链与真实 HTTP 验收仍按 TRUTHFUL-SCOPE 保持未完成。
