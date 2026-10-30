---
schema_version: 1
document_type: checkpoint
sequence: "0131"
created_at: "2026-10-30T22:04:00+08:00"
phase: P01
type: DONE
status: complete
title: "专用SSH认证和只读健康核对通过，本机后台隧道可用"
objective: "核对用户公钥已实际生效，直接读取服务器健康并提供本机后台访问入口"
completed:
  - fact: "专用Ed25519身份通过SSH认证，远端id -u返回0。"
    evidence: "BatchMode/IdentitiesOnly/StrictHostKeyChecking=yes直接SSH exit0，不依赖用户提供root密码。"
  - fact: "本人SSH读取三容器healthy、health UP、远端后台200/无凭据管理401；可用约1.0GiB，三容器约560MiB。"
    evidence: "free -h、docker compose ps、docker stats、curl逐项命令均exit0。"
  - fact: "本机127.0.0.1:18080转发到远端127.0.0.1:18081的SSH隧道已建立，首页及无凭据请求分别200/401。"
    evidence: "exec session19569运行；本机Invoke-WebRequest状态检查通过。"
changed_files:
  - path: "progress/0000__AI-RESUME.md"
    change: "更新SSH已连接、只读回执和本机隧道及账号待验边界。"
  - path: "progress/INDEX.md"
    change: "升序追加0131。"
  - path: "progress/0131__20261030__P01__DONE__ssh-connected-and-local-admin-tunnel.md"
    change: "记录直接SSH和隧道的已验证范围。"
evidence:
  - command: "专用身份ssh id -u；逐项free -h/docker compose ps/docker stats/curl"
    result: "UID0；backend/MySQL/Redis均healthy；Actuator UP；后台200、无凭据admin401。backend251.4MiB、MySQL291.5MiB、Redis17.19MiB，available1.0GiB/无swap。"
  - command: "ssh -N -L 127.0.0.1:18080:127.0.0.1:18081；本机HTTP状态检查"
    result: "隧道session19569运行，HTTP200/401通过；没有打开公网管理入口。"
compatibility_and_security:
  contract_impact: "none；没有修改远端配置、业务代码、初始化或重启服务。"
  tenant_impact: "仅无凭据401通过；未读取业务账号或执行身份写入。"
  sensitive_data: "不输出.env、SMTP值、请求正文或令牌，专用私钥继续本机忽略目录/用户专属ACL。"
risks_or_blockers:
  - "批量远程脚本一次被执行策略以blocked by policy拒绝，改为可审查的逐项只读SSH命令成功；账户计数、OOM和额外配置检查未执行，不计通过。"
  - "实际SMTP/注册/管理员登录、身份隔离、备份恢复、持续负载及公开HTTPS仍待；本次HTTP200不是UI渲染或登录验收。"
  - "隧道依赖本机当前SSH进程，退出/休眠可能断开，可用专用身份重建。"
next_actions:
  - id: NEXT-001
    action: "交付本机后台URL，用户如尚未注册则通过本机辅助脚本接收真实验证码并自行登录。"
    inputs: ["infra/deploy/register-admin.ps1", "infra/deploy/README.zh-CN.md"]
  - id: NEXT-002
    action: "沿用户SSH授权继续实际权限、数据恢复和公网HTTPS/加固，不重跑空库初始化。"
    inputs: ["build/deployment/ssh-control/id_ed25519_innocence"]
---
