# Debian 13 小内存服务器首次部署

范围：React 管理网页 + Java 21 后端 + MySQL 8.4 + Redis 7.2。宿主机 Nginx 通过 SSH 隧道提供首轮自用入口。此包不表示公网部署、真实登录、邮件发送、数据迁移或备份恢复已经通过。

## 本地构建与打包

1. 在 `server/innocence-server` 执行 `mvn clean verify`。
2. 在 `client/admin_web` 执行 `npm ci --no-audit --no-fund`、`npm run build`。
3. 在项目根目录使用 Python 3.10+ 执行 `python infra/deploy/package.py`。

输出位于忽略目录 `build/deployment/<时间>/`。上传的白名单只有管理网页 dist、后端 JAR、结构 SQL 和本目录必要模板/脚本；没有外部 secret 配置、本地数据库、上传头像、签名材料或真实环境变量。部署 JAR 排除开发配置 `application-local.yml`；其余 ZIP 条目的内容与原构建逐项 SHA256 相同，嵌套 JAR 的存储方式保留，并核对 CRC。

## 上传到新服务器

在本机 PowerShell 执行，替换包所在绝对路径及服务器地址：

```powershell
scp -P 22 'F:\项目路径\build\deployment\时间\innocence-deploy.tar.gz' 'F:\项目路径\build\deployment\时间\innocence-deploy.tar.gz.sha256' root@SERVER_IP:/root/
```

首次 SSH 连接时，可在服务商终端运行 `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`，与客户端显示的主机指纹核对。SSH 密码仅在客户端提示时输入。

在服务器终端执行：

```sh
cd /root
sha256sum -c innocence-deploy.tar.gz.sha256
```

只有显示 `OK` 才继续。以下目录应是本次专用的新目录；已有部署时先停止并规划升级，不覆盖旧环境。

```sh
mkdir -p /opt/innocence
tar -xzf /root/innocence-deploy.tar.gz -C /opt/innocence
cd /opt/innocence
sh prepare.sh
```

`prepare.sh` 仅在服务器生成数据库/Redis 的随机密码，写入权限为 600 的 `.env`，不打印值；已有 `.env` 会保留。模板和已构建文件由 SHA256SUMS 检查。

编辑 `.env`，可使用 `nano .env`；如果没有 nano，先安装编辑器。填写 `INNOCENCE_ADMIN_EMAILS`，以及已有 SMTP 服务的配置。不要把 `.env`、邮箱授权码或其截图发到聊天或提交 Git。值包含 `$`、`#`、空格时应按 Compose `.env` 语法使用单引号；不要在 shell 中 `source .env`。

- `INNOCENCE_ADMIN_EMAILS` 只授予权限，不创建账号，也不迁移本地账号。
- 默认 `smtp.invalid` 只允许先检查基础设施，不能发送验证码或完成注册；空库没有可直接登录的演示账号。
- 465 默认使用 SSL。若供应商要求 587/STARTTLS，设置端口为 587、`INNOCENCE_MAIL_SSL=false`、`INNOCENCE_MAIL_STARTTLS=true`。
- Actuator 的 mail 健康项关闭，数据库/Redis 健康仍启用；`UP` 不代表邮件投递成功。

## 选择空库或迁移

只有明确选择全新空库才执行：

```sh
sh start.sh --initialize-empty-database
```

该操作创建独立命名卷，MySQL 镜像只在新数据目录运行 `database/schema.sql`。后端本身启用 prod、关闭 SQL 自动初始化。现有数据库卷不会重放此脚本；已有结构升级需另行受控迁移，不能靠重启容器更新表。

若需迁移本地账号或业务数据，先停在此处。需要用户明确数据范围、在来源库备份、在隔离目标恢复并验证，再按既有表结构决定是否执行迁移。不从本机自动导出或上传账号资料。

启动脚本等待数据库/Redis及后端健康，安装 `/etc/nginx/conf.d/innocence-local.conf` 并在 `nginx -t` 成功后重载。已有不同名下同路径配置会保留并中止；现有 80 端口默认站点保留。

## SSH 隧道访问

在本机 PowerShell 保持以下会话：

```powershell
ssh -p 22 -N -L 18080:127.0.0.1:18081 root@SERVER_IP
```

浏览器打开 `http://127.0.0.1:18080/`。HTTP 段仅在本机及服务器回环地址，跨公网段通过 SSH 加密。后端映射 `127.0.0.1:8080`，MySQL/Redis 不发布宿主机端口，管理站点只监听 `127.0.0.1:18081`。公网 80 端口的 Nginx 欢迎页不是管理后台。

## 配额、持久化与验证

- 容器上限：后端 768MiB（Java 堆 320MiB）、MySQL 640MiB（buffer pool 256MiB）、Redis 128MiB（业务内存 48MiB/noeviction）。这些是起始预算，需用真实负载观察；内存不足时不能把 swap 当成容量保证。
- MySQL、Redis、头像分别使用命名卷；容器重建保留数据。不要运行 `docker compose down -v`，它会删除数据卷。
- 每个服务日志最多 3×10MiB；不把日志、备份或 `.env` 放进网页目录。
- `docker compose ps` 查看状态；`docker stats --no-stream` 查看实际内存。只分享脱敏状态，不分享 `docker compose config` 完整展开结果或 `docker inspect` 的环境变量。
- 启动后检查 `/actuator/health`、静态首页、无凭据后台返回 401。真实管理员登录、非管理员拒绝/会话失效、身份隔离、邮件失败、字段缺失和必要生成失败仍需按实际功能逐项验证。
- 新账号通过正常邮箱注册流程创建，再用白名单账号登录后台。没有 SMTP 或没有选定迁移路径时，基础服务运行不等于管理账号已可用。

## 新空库的管理员注册（本机操作）

当已配置真实SMTP、服务器启动成功且SSH隧道保持连接时，在本机另一个PowerShell窗口执行仓库中的辅助脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'F:\springmvc1\Innocence\infra\deploy\register-admin.ps1'
```

按提示填写与服务器白名单一致的注册邮箱、邮件验证码和新的Innocence密码。验证码和密码以隐藏输入读取；脚本仅访问本机SSH隧道，不打印请求/响应正文或令牌。它调用现有正常邮箱注册API，不绕过验证码，不改数据库直接造账号；成功后尝试退出注册产生的临时Windows会话，再由用户在管理网页登录独立admin_web会话。

此脚本在本机运行，不需要重新上传0127服务器包。原包及SHA256SUMS保持不变；不要直接修改已上传包里的README/脚本，否则启动前的完整性检查会拒绝。

## 公网与后续工作

这份配置提供 SSH 隧道自用入口。公开开放前继续处理密码哈希升级、注册/登录与验证码的完整限流、数据库及头像备份恢复、HTTPS 自动续期及真实访问验收。IP HTTPS 需支持 IP 证书的 ACME 客户端与续期后的 Nginx 重载，现阶段不修改公网入口。

官方依据：

- Docker Compose 依赖健康检查：https://docs.docker.com/compose/how-tos/startup-order/
- MySQL 镜像的新数据目录初始化行为：https://hub.docker.com/_/mysql
- Compose 环境变量文件语法：https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/
- IP 证书及 Certbot：https://letsencrypt.org/2026/03/11/shorter-certs-certbot

已发布 Android/鸿蒙仍保持既有离线边界；本次服务器包不改变客户端权限、API 地址或自动上传本机资料。
