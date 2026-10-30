---
schema_version: 1
document_type: checkpoint
sequence: "0135"
created_at: "2026-10-31T00:12:00+08:00"
phase: P01
type: DECISION
status: complete
title: "后台注册控制与删除用户需求，团队MySQL字段歧义已定位"
objective: "固定新增管理接口与数据影响范围，再实现网页调用并修复团队创建"
completed:
  - fact: "用户要求修复后台不可达、新增接受注册开关、后台删除用户，并报告创建团队失败。"
    evidence: "本轮用户原文及后台地址回复http://127.0.0.1:18080/刚刚无法运行。"
  - fact: "当前远端健康UP、Nginx active、三容器healthy；本机入口静态200/无凭据管理401。"
    evidence: "本人SSH及不使用代理的本机HTTP读取；当前隧道监听18080。历史断连原因不能仅据当前200定论。"
  - fact: "MySQL1052已通过真实EXPLAIN复现，限定dpi.user_id的查询通过。"
    evidence: "diagnose-team-query.py：TEAM_STATS_AMBIGUOUS_USER_ID_MYSQL_1052_CONFIRMED_QUALIFIED_QUERY_PASS；两段TeamMapper查询均使用歧义字段。"
changed_files:
  - path: docs/development/后台注册控制与用户删除.md
    change: "固化注册开关、删除预览/执行、数据清理与权限/事务边界。"
  - path: docs/06-contract-inventory.md
    change: "登记新增管理接口。"
  - path: progress/0135__20261031__P01__DECISION__admin-registration-user-deletion-and-team-error.md
    change: "记录用户请求和已复现故障。"
  - path: progress/0000__AI-RESUME.md
    change: "切换当前任务与下一动作。"
  - path: progress/INDEX.md
    change: "升序追加0135。"
evidence:
  - command: "本机HTTP首页及无凭据管理接口；SSH健康/容器/Nginx状态；服务器MySQL EXPLAIN"
    result: "200/401、UP/healthy/active；原团队子查询1052，限定字段后EXPLAIN通过。"
compatibility_and_security:
  contract_impact: "新增后台管理接口；关闭时两个注册端点403，登录沿旧契约；默认开放且持久化。删除采用档案入口+一次确认，保护管理员。"
  tenant_impact: "管理员显式发起删除才清理该目标及关联；队长删除会解散其团队并在确认中说明，其余成员个人资料保留。验证仅使用合成用户。"
  sensitive_data: "诊断不输出真实数据库/邮件凭据、请求正文或用户身份；未删除真实用户。"
risks_or_blockers:
  - "新功能及团队端到端验证/实际部署尚未完成，不计为功能通过。"
next_actions:
  - id: NEXT-001
    action: "实现数据库策略/删除事务与后台UI，真实MySQL隔离回归后备份并部署；补本机隧道自动重连。"
    inputs: [docs/development/后台注册控制与用户删除.md]
---
