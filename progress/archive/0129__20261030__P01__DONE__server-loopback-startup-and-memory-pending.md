---
schema_version: 1
document_type: checkpoint
sequence: "0129"
created_at: "2026-10-30T21:40:00+08:00"
phase: P01
type: DONE
status: complete
title: "用户服务器回环启动健康回执，1.8GB内存报告待实际指标核对"
objective: "记录首轮真实服务器启动截图的可验证范围，区分瞬时健康与容量验收"
completed:
  - fact: "用户服务器截图显示mysql、redis、backend均healthy，后端127.0.0.1:8080映射，数据库和Redis仅显示容器端口。"
    evidence: "当前用户截图中的docker compose ps；本人未SSH认证或操作远端。"
  - fact: "首轮启动脚本输出Nginx语法成功、Actuator status UP、静态页检查成功及无凭据后台401。"
    evidence: "同一截图的start.sh执行输出，与0127脚本对应；没有真实管理员登录或邮件结果。"
changed_files:
  - path: "progress/0000__AI-RESUME.md"
    change: "更新已运行回执、待核对内存和真实账号/恢复/公网范围。"
  - path: "progress/INDEX.md"
    change: "升序追加0129。"
  - path: "progress/0129__20261030__P01__DONE__server-loopback-startup-and-memory-pending.md"
    change: "记录用户服务器首轮健康证据及容量边界。"
evidence:
  - command: "docker compose ps；首轮start.sh输出（用户执行并提供截图）"
    result: "三容器healthy；Nginx配置成功、health UP、静态页和无凭据admin401通过。"
  - command: "free -h；docker stats --no-stream"
    result: "本轮尚未取得用户执行结果；1.8GB仅为用户面板占用报告，不能区分可回收缓存或真实内存压力。"
compatibility_and_security:
  contract_impact: "none；没有更改内存配额、业务代码或服务器配置。"
  tenant_impact: "空库不迁移保持；仅无凭据401有服务器回执，其他身份隔离/权限及真实账号仍待验。"
  sensitive_data: "本轮只记录健康与内存范围，不存储截图中的账号、密码或授权码。"
risks_or_blockers:
  - "2GB机器部署三服务的持续容量需结合MemAvailable、容器占用和运行负载判断，不能据一次healthy保证稳定或给出支持用户数。"
  - "邮件健康项关闭，Actuator UP不证明SMTP投递；注册/管理员登录、备份恢复及公网HTTPS仍待。"
  - "此前无swap；是否增加缓冲或调参待实际数据，不盲目压缩数据库/JVM或清缓存。"
next_actions:
  - id: NEXT-001
    action: "读取用户free -h和docker stats --no-stream，核对缓存、实际可用和容器配额余量。"
    inputs: ["infra/deploy/compose.yaml", "infra/deploy/Dockerfile"]
  - id: NEXT-002
    action: "继续SSH隧道真实邮件/注册/管理员登录、负向路径、恢复和后续公网HTTPS。"
    inputs: ["infra/deploy/register-admin.ps1", "infra/deploy/README.zh-CN.md"]
---
