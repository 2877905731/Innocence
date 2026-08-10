---
schema_version: 1
document_type: checkpoint
sequence: "0020"
created_at: "2026-08-10T16:08:00+08:00"
phase: P01
type: DONE
status: complete
title: "后端会话身份绑定与凭据回传收口"
objective: "修复鉴权层信任客户端用户 ID 的租户隔离缺陷，并完成后端完整测试验证"
completed:
  - fact: "鉴权拦截器改为通过 Bearer session token + 设备槽位反查活动会话和 userId，不再信任 X-User-Id 请求头"
    evidence: "AuthInterceptor、SessionAuthService、UserMapper.findActiveSessionByTokenAndSlot"
  - fact: "当前设备会话响应不再序列化 sessionToken，避免把登录凭据返回给客户端"
    evidence: "CurrentSessionResponse.sessionToken 标记 JsonIgnore；AccountService 不再填充该响应字段"
  - fact: "新增未知令牌拒绝和令牌反查用户的安全单元测试"
    evidence: "SessionAuthServiceTest 新增 2 项测试"
changed_files:
  - path: "server/innocence-server/src/main/java/com/innocence/server/common/web/AuthInterceptor.java"
    change: "移除 X-User-Id 身份信任，严格解析 Bearer 并从活动会话设置请求用户上下文"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/SessionAuthService.java"
    change: "新增按会话令牌和设备槽位解析活动会话的方法"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/mapper/UserMapper.java"
    change: "新增活动会话令牌查询契约"
  - path: "server/innocence-server/src/main/resources/mapper/account/UserMapper.xml"
    change: "实现活动会话令牌查询 SQL"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/dto/response/CurrentSessionResponse.java"
    change: "禁止 sessionToken 字段 JSON 序列化"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/AccountService.java"
    change: "不再向当前会话响应写入 session token"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/controller/AccountController.java"
    change: "统一当前会话接口的 Bearer 令牌解析"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/SessionAuthServiceTest.java"
    change: "补充会话令牌身份绑定和未知令牌拒绝测试"
evidence:
  - command: "mvn -q -Dtest='!InnocenceServerApplicationTests' test"
    result: "通过；排除数据库上下文测试的 17 项单元/安全测试全部通过"
  - command: "mvn -q -DskipTests package"
    result: "通过；Spring Boot JAR 打包成功"
  - command: "mvn -q -Dspring.datasource.url=jdbc:mysql://127.0.0.1:3307/innocence -Dspring.datasource.username=root -Dspring.datasource.password=root123456 -Dspring.data.redis.port=6380 test"
    result: "通过；隔离 MySQL 8.0 / Redis 7.2 环境下完整 Spring 上下文和全部 18 项测试通过"
  - command: "git diff --check"
    result: "通过；无空白错误"
compatibility_and_security:
  contract_impact: "请求仍兼容现有客户端携带的 X-User-Id，但服务端不再使用该字段作为身份来源；当前会话响应不再暴露凭据字段"
  tenant_impact: "显著收紧；userId 只能由活动 Bearer 会话令牌解析得到，伪造 X-User-Id 不再越权"
  sensitive_data: "未记录真实账号、密码或会话令牌；测试使用合成令牌"
risks_or_blockers:
  - "Windows Release 实机 DPI、四主题视觉和真实头像文件选择仍待验收"
next_actions:
  - id: NEXT-001
    action: "继续 P01 G01：启动隔离后端并执行 Windows Release 真实头像链路与 DPI/主题验收"
    inputs: ["Windows Release", "MySQL/Redis", "合成图片"]
---

# 检查点说明

本检查点完成后端会话身份绑定安全收口；客户端仍可继续发送旧的 X-User-Id 兼容头，但服务端不再信任它。
