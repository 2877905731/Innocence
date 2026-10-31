---
schema_version: 1
document_type: checkpoint
sequence: "0130"
created_at: "2026-10-30T21:48:00+08:00"
phase: P01
type: DECISION
status: complete
title: "用户授权直接SSH管理，专用密钥就绪待控制台安装公钥"
objective: "将已有服务器部署继续为直接SSH操作，准备可由用户一次安装的专用公钥并记录最新内存证据"
completed:
  - fact: "用户明确要求直接SSH连接并控制服务器，沿当前部署范围授权。"
    evidence: "用户原文：能不能直接ssh连接过去，让你直接控制服务器。"
  - fact: "新截图available约1.0GiB，backend245.6/MySQL280/Redis17.16MiB，当前瞬时资源有余量。"
    evidence: "用户本轮free -h/docker stats截图；长期负载与无swap峰值仍待验。"
  - fact: "目标已有本机known_hosts记录，但现有身份两轮免交互认证均被拒绝。专用Ed25519密钥已在本机Git忽略目录生成，ACL和配对核对完成，待用户安装公钥。"
    evidence: "StrictHostKeyChecking=yes/BatchMode两次Permission denied；icacls后Get-Acl确认仅当前用户且禁用继承，ssh-keygen -y与公钥一致。"
changed_files:
  - path: "progress/0000__AI-RESUME.md"
    change: "更新SSH授权/认证缺口、专用身份路径及最新内存读数。"
  - path: "progress/INDEX.md"
    change: "升序追加0130。"
  - path: "progress/0130__20261030__P01__DECISION__direct-ssh-control-and-dedicated-key.md"
    change: "记录本轮用户授权和公钥待安装边界。"
evidence:
  - command: "ssh-keygen -F 目标；ssh -o BatchMode=yes -o StrictHostKeyChecking=yes（两组现有身份）id -u"
    result: "主机记录存在；两次认证均Permission denied(publickey,password)，未得到远端命令执行。"
  - command: "ssh-keygen创建专用密钥；icacls/Get-Acl；ssh-keygen -y；git check-ignore"
    result: "Ed25519专用身份生成，最终ACL只允许当前Windows用户，禁用继承；配对一致；私钥和公钥均位于build/deployment/ssh-control忽略目录。初次Set-Acl需额外特权未成功，随后用icacls收敛并实检通过。"
compatibility_and_security:
  contract_impact: "none；没有改服务/内存配置。用户通过已登录控制台安装公钥后再认证，不降低主机密钥检查。"
  tenant_impact: "不改变空库/不迁移范围，仍未修改远端业务数据。"
  sensitive_data: "不接收root密码，不回显或导出任何现有私钥；新私钥不入Git。对用户仅交付公钥。公钥指纹SHA256:chtAwNNht2+nFew3W3XwDEbZj+nFj/BeBcbOJQyHKQ4。"
risks_or_blockers:
  - "专用公钥尚未进入远端authorized_keys，SSH尚未认证成功，不能声称已接管服务器。"
  - "瞬时内存健康不代替持续容量/真实邮件/管理员登录、恢复和公网HTTPS验收。"
next_actions:
  - id: NEXT-001
    action: "用户在已有Xterm会话追加专用公钥，保留已有authorized_keys条目，再以专用身份连接核对服务器状态。"
    inputs: ["build/deployment/ssh-control/id_ed25519_innocence.pub", "build/deployment/ssh-control/id_ed25519_innocence"]
---
