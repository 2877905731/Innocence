---
schema_version: 1
document_type: checkpoint
sequence: "0022"
created_at: "2026-08-10T16:23:00+08:00"
phase: P02
type: DONE
status: complete
title: "统计趋势接口投影"
objective: "补齐统计契约中的 /stats/trend，复用既有 7/30 天统计数据生成 xAxis 与 series"
completed:
  - fact: "新增 GET /api/app/v1/stats/trend，rangeType 支持 7d、30d，缺省为 7d"
    evidence: "StatsController.getTrend、StatsService.normalizeRangeType"
  - fact: "返回契约要求的 xAxis 与 series，包含学习时长、番茄完成数、计划完成率和签到成功率"
    evidence: "StatsTrendResponse、StatsTrendSeriesResponse"
  - fact: "非法 rangeType 返回统一 BAD_REQUEST 业务错误"
    evidence: "StatsServiceTest.rejectsUnsupportedRangeType"
changed_files:
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/stats/controller/StatsController.java"
    change: "新增 /trend 路由"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/stats/service/StatsService.java"
    change: "新增 7d/30d 趋势投影与参数校验"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/stats/dto/response/StatsTrendResponse.java"
    change: "新增 xAxis/series 响应模型"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/stats/dto/response/StatsTrendSeriesResponse.java"
    change: "新增趋势序列响应模型"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/stats/service/StatsServiceTest.java"
    change: "新增默认范围、30d 范围和非法范围测试"
evidence:
  - command: "mvn -q -Dtest='!InnocenceServerApplicationTests' test"
    result: "通过；排除数据库上下文的 22 项单元/安全测试全部通过"
  - command: "mvn -q -Dspring.datasource.url=jdbc:mysql://127.0.0.1:3307/innocence -Dspring.datasource.username=root -Dspring.datasource.password=root123456 -Dspring.data.redis.port=6380 test"
    result: "通过；隔离 MySQL 8.0 / Redis 7.2 环境下完整上下文与全部 23 项测试通过"
  - command: "mvn -q -DskipTests package"
    result: "通过；Spring Boot JAR 打包成功"
  - command: "git diff --check"
    result: "通过；无空白错误"
compatibility_and_security:
  contract_impact: "补齐既有 /stats/trend 契约，不改变 /stats/overview；查询仍由当前 Bearer 会话用户上下文限定"
  tenant_impact: "复用 StatsService 的 userId 数据边界，不接受请求体 userId"
  sensitive_data: "未记录真实账号、密码或令牌；测试使用合成 userId"
risks_or_blockers:
  - "认证 U01/U02/U07/U08 真实 HTTP/邮件回放、/home/widget、WebSocket /ws/app 仍未完成"
next_actions:
  - id: NEXT-001
    action: "提交并推送当前后端变更；随后补 U01/U02/U07/U08 脱敏认证回放"
    inputs: ["Git remote", "隔离 MySQL/Redis", "可控邮件发送替身"]
---

# 检查点说明

本检查点只声明 `/stats/trend` 服务端实现和自动化验证完成；真实 HTTP 认证回放及更后续模块仍按 TRUTHFUL-SCOPE 保持未完成。
