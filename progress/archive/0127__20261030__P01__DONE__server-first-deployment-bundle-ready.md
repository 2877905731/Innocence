---
schema_version: 1
document_type: checkpoint
sequence: "0127"
created_at: "2026-10-30T18:45:00+08:00"
phase: P01
type: DONE
status: complete
title: "Debian13首轮SSH隧道部署包就绪，服务器启动与数据方案待验"
objective: "为用户已有香港2GB服务器准备可上传的管理网页/后端首次部署包，明确尚未执行的远端和数据动作"
completed:
  - fact: "用户确认香港/有公网IPv4/无域名；两次面板截图确认Debian13.7/x86_64/SSH22、可用约1.7GiB/28GB、Docker29.9.2/Compose5.6.1/Nginx1.26.3与本机HTTP200。"
    evidence: "当前会话截图；本机TcpClient到用户给定地址22端口连接成功。只证明TCP连通，未进行SSH认证。"
  - fact: "新增小内存Compose、Java21镜像、回环Nginx、服务器生成.env和显式空库初始化脚本。MySQL/Redis不映射宿主机端口，后端127.0.0.1:8080、管理站点127.0.0.1:18081；三持久卷和日志限额齐备。"
    evidence: "infra/deploy/；Compose5.6.1解析及端口/内存/健康依赖/缺管理员字段拒绝核对通过。"
  - fact: "本机16文件归档40193731bytes/SHA256 37818eb0bc7aba50cdde55e35f1f79a1ceb0f824e005ee0671afb13bb98cf1c7及侧车摘要就绪。仅部署JAR排除application-local.yml，其余ZIP条目载荷与原构建SHA相同；CRC、Boot分层读取及归档逐字节一致。"
    evidence: "build/deployment/20261030-184445/innocence-deploy.tar.gz、bundle/manifest.json、SHA256SUMS；不包含本地业务数据或外部secret文件。"
changed_files:
  - path: "infra/deploy/"
    change: "10份部署源文件：属性、Docker忽略/镜像、Compose、环境模板、回环Nginx、两POSIX脚本、打包器和中文步骤。"
  - path: "infra/README.md"
    change: "关联首次部署入口，区分开发配置及公网开放待办。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新本轮恢复/服务器准备状态及下一步，保留现行客户端发行边界。"
  - path: "progress/INDEX.md"
    change: "升序追加0127。"
  - path: "progress/0127__20261030__P01__DONE__server-first-deployment-bundle-ready.md"
    change: "本机包就绪检查点，不表示服务器部署完成。"
evidence:
  - command: "mvn -q clean verify（server/innocence-server）"
    result: "exit0；18份Surefire报告/80项、Failures0/Errors0/Skipped0；JAR44647134bytes。沿现有本地测试配置运行，不代替远端HTTP。"
  - command: "npm ci --no-audit --no-fund；npm run build（client/admin_web）"
    result: "exit0；TypeScript检查与Vite5.4.21生产构建成功。"
  - command: "官方docker-compose-windows-x86_64.exe v5.6.1及其同源SHA256；config --format json/config --quiet"
    result: "官方资产SHA91b1492f…匹配；三服务/端口/配额/prod绑定/健康依赖通过；合成保留域样例管理员变量缺失时拒绝。未连接Docker daemon、构建Linux镜像或执行容器。"
  - command: "捆绑Git的sh.exe -n prepare.sh/start.sh；Python3.12 infra/deploy/package.py"
    result: "语法exit0；16文件/JAR CRC与载荷摘要/归档字节校验PASS；产物目录build/deployment/20261030-184445。"
  - command: "java -Djarmode=layertools -jar 首轮同源部署JAR list"
    result: "exit0；四层列出，提示layertools弃用；只验证打包器/嵌套依赖读取，不启动业务服务。"
  - command: "git diff --check"
    result: "exit0；infra/README.md有既有Windows换行提示。"
compatibility_and_security:
  contract_impact: "未改业务API/客户端。新部署使用现有prod配置；关闭邮件健康项避免未配置SMTP阻断基础设施检查，健康UP不代表邮件成功。"
  tenant_impact: "未迁移或上传本地账号/资料；管理员白名单不创建账号，实际身份隔离及远端权限仍须验证。"
  sensitive_data: "真实密码/私钥/授权码未读取、复制或写入仓库。数据库/Redis密码只由用户在服务器生成；模板是占位值，Compose语义检查仅用保留域合成值。"
risks_or_blockers:
  - "空库/迁移和SMTP有无已向用户询问，尚未回复；未上传文件、SSH登录或修改服务器。"
  - "Linux镜像构建、Nginx运行时配置、容器/真实账号/邮件、身份隔离与失败路径、持久化恢复及实际内存负载仍未验证。"
  - "未开放公网后台/HTTPS；密码哈希升级、完整登录/验证码限流与备份恢复继续待。现有80回归不能替代远端通过。"
  - "Android及鸿蒙离线发行不随后端部署自动联网，原权益/设备/G01门禁保持。"
next_actions:
  - id: NEXT-001
    action: "交付SCP命令和包摘要；用户在服务器核验/解包/prepare生成私有.env，再根据空库或迁移选择处理数据库、SMTP和注册账号。"
    inputs: ["infra/deploy/README.zh-CN.md", "build/deployment/20261030-184445/innocence-deploy.tar.gz", "build/deployment/20261030-184445/innocence-deploy.tar.gz.sha256"]
  - id: NEXT-002
    action: "在真实服务器启动后通过SSH隧道验登录、拒绝路径和数据恢复，再准备公网HTTPS及加固。"
    inputs: ["infra/deploy/compose.yaml", "infra/deploy/start.sh", "infra/deploy/nginx/innocence-local.conf"]
---

本检查点的完成范围是本机部署包准备。原发行结果保留；截图的本机Nginx200仅为欢迎页/服务基础证据，不是管理后台或后端已经上线。
