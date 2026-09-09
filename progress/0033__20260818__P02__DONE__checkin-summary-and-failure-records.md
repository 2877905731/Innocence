---
schema_version: 1
document_type: checkpoint
project_name: "Innocence"
sequence: "0033"
created_at: "2026-08-18T20:52:00+08:00"
phase: P02
type: DONE
status: complete
title: "补齐签到汇总与失败记录后端接口"
objective: "继续 P02 学习闭环，落地签到汇总与失败记录查询，并完成自动化与 HTTP 认证负向验收。"
facts:
  - "新增 GET /api/app/v1/check-in/summary，返回 consecutiveDays、totalDays、totalStudyDurationMinutes。"
  - "新增 GET /api/app/v1/check-in/fail-records，按当前用户分页查询失败记录，pageSize 上限为 50。"
  - "Controller 只从 RequestUserContext 取得用户身份；Mapper 查询带 user_id 条件，不接受客户端 userId。"
  - "U04 契约状态更新为 implementation_matched_sample_pending；真实带会话回放仍未宣称完成。"
changed_files:
  - "server/innocence-server/src/main/java/com/innocence/server/modules/checkin/controller/CheckInController.java"
  - "server/innocence-server/src/main/java/com/innocence/server/modules/checkin/mapper/CheckInMapper.java"
  - "server/innocence-server/src/main/java/com/innocence/server/modules/checkin/service/CheckInService.java"
  - "server/innocence-server/src/main/java/com/innocence/server/modules/checkin/dto/response/CheckInSummaryResponse.java"
  - "server/innocence-server/src/main/java/com/innocence/server/modules/checkin/dto/response/CheckInFailureRecordResponse.java"
  - "server/innocence-server/src/main/resources/mapper/checkin/CheckInMapper.xml"
  - "server/innocence-server/src/test/java/com/innocence/server/modules/checkin/service/CheckInServiceTest.java"
  - "docs/06-contract-inventory.md"
verification:
  - command: "mvn -q -Dtest=CheckInServiceTest test"
    result: "通过"
  - command: "mvn -q test"
    result: "27 tests, 0 failures, 0 errors"
  - command: "mvn -q -DskipTests package"
    result: "通过"
  - command: "启动 Spring Boot 后 curl 未认证 GET /api/app/v1/check-in/summary 与 /fail-records"
    result: "两个接口均返回 HTTP 401；临时服务已停止"
  - command: "git diff --check"
    result: "通过（仅 Git 报告工作区既有 LF/CRLF 转换提示）"
remaining:
  - "使用合成登录会话完成 U04 正常/重复/计划未完成的真实 HTTP 回放。"
  - "继续补齐 P02 其余计划、专注、首页轻量摘要契约的真实回放与缺失接口。"
---
