---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0154"
created_at: "2026-11-03T01:38:02+08:00"
phase: P01
type: DONE
status: complete
title: "在线更新后台与三平台版本目录上线，真实鉴权完整下载和单一学习账本验证"
objective: "按用户授权完成后台发布、在线更新和手动绑定番茄并重新发行；保留未覆盖的实体门禁。"
completed:
  - fact: "部署fcc4317后端与版本管理后台，三平台1.3.4+16包已通过真实后台上传并发布。新安装方式、原子目录及持久挂载生效。"
    evidence: "JAR c236096bfd06b4c30ec0dc3ae72a771d50df71fb9c30a8fbb32d89830a1b421a；生产健康UP/注册0；三平台目录均published/build16。"
  - fact: "升级前完成私有全量备份及隔离MySQL恢复。"
    evidence: "备份 /opt/innocence/backups/pre-online-20261102173203；verify-backup-restore.sh通过。未重跑既有学习入账迁移，本轮无SQL结构修改。"
  - fact: "三平台均完成已登录账号的完整HTTPS下载、长度/SHA256、Range206及错误平台/匿名/未发布/下架拦截。构建号15可见16，当前16返回空。"
    evidence: "build/deployment/online-update-20261103/production-safe.json；三个完整包与本机发行包字节摘要一致；Nginx internal直链404，公开后台404。"
  - fact: "生产合成专注主窗口完成时0秒/0轮；120秒番茄重复上报仍合计120秒/1轮。临时管理员授权与两合成账号已清理。"
    evidence: "MANUAL_BOUND_SINGLE_LEDGER_PRODUCTION_PASS；普通账号后台403、认证401/缺字段400；移除临时授权并重建正常容器后权限403及持久下载Range仍通过。"
  - fact: "部署后更新包152.62MiB，可用内存1023048kB、磁盘22.36GiB，Nginx配置有效。"
    evidence: "resources-safe.json；单连接2MiB/s/全局5下载连接，上传300MiB、存储3GiB与保留8GiB空间限制已配置。"
changed_files:
  - path: "infra/deploy/compose.yaml"
    change: "0153同源部署到服务器；连同Nginx/备份脚本、前端静态包和后端JAR更新，.env保持。"
  - path: "progress/0000__AI-RESUME.md"
    change: "归档实际上线和保留的实体/权限门禁。"
evidence:
  - command: "python infra/deploy/package.py"
    result: "27文件/41666870字节安全部署包，JAR剔除application-local.yml，CRC/内容/摘要校验通过。"
  - command: "ssh … python3 /opt/innocence/online-update-20261103/deploy.py"
    result: "镜像/JAR校验、备份隔离恢复、真实发布与鉴权完整下载、Range/下架负向和绑定入账通过，退出0。"
  - command: "SSH只读复核manifest/catalog、MemAvailable、磁盘、nginx -t与临时授权文件状态"
    result: "源fcc4317/JARc236096b…；3平台published/build16；Nginx有效；授权文件不存在，临时账号清理通过。"
compatibility_and_security:
  contract_impact: "新增模块上线；旧普通/自动绑定模式保留，新手动窗口不重复记账；没有重复数据迁移。"
  tenant_impact: "仅认证在线账号下载，设备平台与权限校验通过；只写两个隔离合成账号的计时数据并清理，不触碰真实业务任务。"
  sensitive_data: "原.env与真实管理员名单留在服务器，未复制；临时授权只附加合成地址并已移除。审计保留内部操作者ID，公开包无个人Profile。"
risks_or_blockers:
  - "本轮不代表Windows实际安装、Android/OEM、鸿蒙TIMER后台及全部同步/模型门禁通过；鸿蒙通用安装资格未获。"
next_actions:
  - id: NEXT-PUBLIC-RELEASE
    action: "发布既有草稿，核对匿名完整下载；后续客户端发版可直接本机编译上传后台。"
    inputs: [docs/releases/v1.3.4.md]
---
