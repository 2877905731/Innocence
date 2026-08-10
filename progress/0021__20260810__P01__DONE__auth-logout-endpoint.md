---
schema_version: 1
document_type: checkpoint
sequence: "0021"
created_at: "2026-08-10T16:14:00+08:00"
phase: P01
type: DONE
status: complete
title: "认证当前设备退出登录接口"
objective: "补齐认证契约中的 /auth/logout，使服务端按当前 Bearer 会话撤销设备槽位"
completed:
  - fact: "新增 POST /api/app/v1/auth/logout；接口从 Authorization Bearer token 和 X-Device-Type 解析当前活动会话，不信任 X-User-Id"
    evidence: "AuthController.logout、SessionAuthService.logoutActiveSession"
  - fact: "退出登录仅将令牌对应的活动会话置为 status=0 并写入 logout_time，不影响用户其他设备槽位"
    evidence: "UserMapper.logoutSessionById 与 UserMapper.xml logoutSessionById SQL"
  - fact: "新增退出活动会话安全测试并保留未知令牌拒绝路径"
    evidence: "SessionAuthServiceTest"
changed_files:
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/controller/AuthController.java"
    change: "新增当前设备退出登录路由与 Bearer 解析"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/SessionAuthService.java"
    change: "新增按活动 Bearer 会话执行退出登录的方法"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/mapper/UserMapper.java"
    change: "新增按会话 ID 撤销活动会话的 Mapper 契约"
  - path: "server/innocence-server/src/main/resources/mapper/account/UserMapper.xml"
    change: "新增 status=0/logout_time 更新 SQL"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/SessionAuthServiceTest.java"
    change: "新增当前设备退出登录测试"
evidence:
  - command: "mvn -q -Dtest='!InnocenceServerApplicationTests' test"
    result: "通过；排除数据库上下文的 19 项单元/安全测试全部通过"
  - command: "mvn -q -Dspring.datasource.url=jdbc:mysql://127.0.0.1:3307/innocence -Dspring.datasource.username=root -Dspring.datasource.password=root123456 -Dspring.data.redis.port=6380 test"
    result: "通过；隔离 MySQL 8.0 / Redis 7.2 环境下完整上下文与全部 20 项测试通过"
  - command: "mvn -q -DskipTests package"
    result: "通过；Spring Boot JAR 打包成功"
  - command: "git diff --check"
    result: "通过；无空白错误"
compatibility_and_security:
  contract_impact: "补齐既有认证接口清单中的 /auth/logout；不改变登录、注册和现有会话字段"
  tenant_impact: "退出操作只作用于 Bearer token 对应的当前用户活动会话，不能通过客户端身份头操作其他用户"
  sensitive_data: "未记录真实账号、密码或会话令牌；测试使用合成令牌"
risks_or_blockers:
  - "认证邮件/验证码接口尚未完成真实 SMTP HTTP 回放；Windows 实机 DPI、四主题视觉和真实头像选择仍待验收"
next_actions:
  - id: NEXT-001
    action: "为 U01/U02/U07/U08 建立脱敏认证 HTTP 回放或邮件发送替身，并核对统一错误响应"
    inputs: ["隔离 MySQL/Redis", "可控邮件发送替身", "合成账号"]
---

# 检查点说明

本检查点完成 P01 认证当前设备退出登录服务端实现；邮件验证码的真实外部发送仍需用脱敏替身或测试 SMTP 完成回放。
