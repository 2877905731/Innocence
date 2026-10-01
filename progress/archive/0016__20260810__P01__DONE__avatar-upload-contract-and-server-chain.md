---
schema_version: 1
document_type: checkpoint
sequence: "0016"
created_at: "2026-08-10T11:45:00+08:00"
phase: P01
type: DONE
status: complete
title: "头像上传契约与服务端存储链路"
objective: "固化头像文件上传边界，并实现当前用户鉴权下的本地存储、资料回写和安全失败路径"
completed:
  - fact: "新增 U13：POST /api/app/v1/account/avatar/upload，字段 file，接受 JPEG/PNG，单文件最大 5 MiB，服务端生成 UUID 文件名"
    evidence: "docs/02-contract-and-compatibility-rules.md；docs/06-contract-inventory.md；docs/planning/Innocence-接口清单草案.md"
  - fact: "上传服务写入 innocence.avatar.storage-dir，公开资源映射到 innocence.avatar.public-path，并在数据库更新当前用户 app_user.avatar_url"
    evidence: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AvatarStorageService.java；AvatarUploadService.java；WebMvcConfig.java"
  - fact: "服务端校验缺失文件、大小、MIME、JPEG/PNG 文件签名和可解码内容；数据库回写失败时清理本次新文件，不删除旧 URL 指向的文件"
    evidence: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AvatarStorageService.java；AvatarUploadService.java"
  - fact: "新增运行时上传目录忽略规则和 multipart 限制，未将用户文件或凭据写入仓库"
    evidence: ".gitignore；server/innocence-server/src/main/resources/application.yml"
changed_files:
  - path: "docs/02-contract-and-compatibility-rules.md"
    change: "补充头像上传字段、大小、鉴权、返回和错误语义"
  - path: "docs/06-contract-inventory.md"
    change: "登记 U13"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "fixture contract 范围更新为 U01-U13"
  - path: "docs/planning/Innocence-接口清单草案.md"
    change: "将文件上传建议细化为可执行契约"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/config/AvatarStorageProperties.java"
    change: "新增头像存储配置"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AvatarStorageService.java"
    change: "新增本地头像存储与内容校验"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AvatarUploadService.java"
    change: "新增当前用户上传与资料回写"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/controller/AccountController.java"
    change: "新增 multipart 上传路由"
  - path: "server/innocence-server/src/main/java/com/innocence/server/common/web/WebMvcConfig.java"
    change: "新增头像静态资源映射"
  - path: "server/innocence-server/src/main/java/com/innocence/server/common/web/GlobalExceptionHandler.java"
    change: "新增超限业务错误处理"
  - path: "server/innocence-server/src/main/resources/application.yml"
    change: "新增 multipart 与头像存储配置"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/AvatarUploadServiceTest.java"
    change: "新增正常、缺失、类型、伪图片、超限和未知用户测试"
  - path: ".gitignore"
    change: "忽略运行时上传目录"
evidence:
  - command: "mvn -q \"-Dtest=AvatarUploadServiceTest,SessionAuthServiceTest,AccountServiceSecurityTest,FriendServiceSecurityTest\" test"
    result: "通过；头像测试与既有会话、账户、好友安全测试全部通过"
  - command: "mvn -q test"
    result: "未通过；共执行 14 项，13 项通过，InnocenceServerApplicationTests.contextLoads 因本机 MySQL root@172.19.0.1 认证失败产生 1 error"
  - command: "git diff --check"
    result: "通过；仅报告工作副本 LF/CRLF 转换提示"
compatibility_and_security:
  contract_impact: "新增 U13；客户端只依赖返回 avatarUrl，不依赖本地目录或原始文件名"
  tenant_impact: "上传入口由当前会话拦截，服务层以 currentUserId 查询并回写资料；请求不接受 userId 或目标路径"
  sensitive_data: "测试使用合成用户和内存图片；未记录真实邮箱、密码、验证码、Token 或文件内容"
risks_or_blockers:
  - "Flutter/Dart SDK 不在当前环境，客户端 multipart 调用和 Windows DPI 验收未执行"
  - "完整 Spring Boot contextLoads 仍依赖本机 MySQL，HTTP 层真实会话与租户隔离回放未执行"
next_actions:
  - id: NEXT-001
    action: "Flutter SDK 与文件选择/multipart 依赖可用后，实现资料页选择头像、调用 U13、同步 profile.avatarUrl，并执行 flutter analyze/test"
    inputs: ["U13", "Flutter SDK", "客户端文件选择依赖"]
  - id: NEXT-002
    action: "数据库集成环境可用后回放正常上传、空文件、超限、伪图片、会话失效和跨用户边界 HTTP 路径"
    inputs: ["MySQL/Redis 集成环境", "U13"]
---

# 检查点说明

本检查点完成头像上传契约和服务端链路；客户端入口按 TRUTHFUL-SCOPE 暂不添加未具备文件选择与 multipart 工具链的占位实现。
