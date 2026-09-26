# Innocence 管理后台网站

独立的 React + Vite 网站，对接同仓库的 Spring Boot 服务。当前页面包括工作概览、举报审核、用户管理、团队管理和系统公告。所有数据来自真实 `/api/admin/v1` 接口；没有演示账号或模拟业务数据。

## 本地运行

先启动 MySQL、Redis 和 `server/innocence-server`，再在本目录运行：

```powershell
npm ci
npm run dev
```

打开终端显示的本地地址。开发服务器把 `/api` 转发到 `http://127.0.0.1:8080`。管理员使用已注册且位于 `innocence.admin.emails` 白名单中的邮箱及密码登录。管理员网页使用独立的 `admin_web` 会话槽位，不会挤掉 Windows 客户端会话；同一管理员再次登录网页时，旧网页会话会失效。

## 生产构建与服务器部署准备

```powershell
npm ci
npm run build
```

静态产物在 `dist/`。用 Nginx 提供静态文件，并将同域 `/api/` 反向代理到 Spring Boot。可参考 [nginx.conf.example](deploy/nginx.conf.example)。必须配置有效 HTTPS 证书，按实际域名、路径和端口替换示例值。浏览器会话凭据只保存在当前标签页的 `sessionStorage`，关闭标签页后不保留。

后端生产环境使用 `SPRING_PROFILES_ACTIVE=prod` 和 `application-prod.yml`，需要通过服务器环境变量提供：

| 变量 | 用途 |
| --- | --- |
| `INNOCENCE_DB_URL`、`INNOCENCE_DB_USER`、`INNOCENCE_DB_PASSWORD` | MySQL 连接 |
| `INNOCENCE_REDIS_HOST`、`INNOCENCE_REDIS_PORT`、`INNOCENCE_REDIS_PASSWORD` | Redis 连接 |
| `INNOCENCE_MAIL_HOST`、`INNOCENCE_MAIL_PORT`、`INNOCENCE_MAIL_USERNAME`、`INNOCENCE_MAIL_PASSWORD` | 邮件服务 |
| `INNOCENCE_ADMIN_EMAILS` | 管理员邮箱白名单，多个地址用逗号分隔 |
| `INNOCENCE_BIND_ADDRESS`、`INNOCENCE_PORT` | 后端监听地址与端口，默认为 `127.0.0.1:8080` |

生产配置不会自动执行 `schema.sql`。首次部署需在经过备份的目标数据库中人工审查并初始化结构；后续结构更新需用受控迁移，不应直接重放整份脚本。头像存储目录也需要挂载持久磁盘。MySQL、Redis 不应直接暴露到公网。

## 当前边界

举报处理可触发警告、禁言、封禁、删帖并留存审核记录；用户页可查看与解除已有处罚。产品草案中的“无举报直接处罚”“定向通知”“复查推翻原结论”和管理趋势图尚无对应服务端接口，网页暂不提供这些操作。公开部署前还需要完成管理员登录限流、现有密码哈希升级、正式域名的 HTTPS 验收以及数据库备份恢复演练。
