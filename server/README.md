# 后端目录

这里存放 `Innocence` 的后端服务代码。当前主服务工程为 `innocence-server`。

## 目录说明

```text
innocence-server/            Spring Boot 主服务
README.md                    当前目录说明
```

## 技术栈

- Java 21
- Spring Boot 3.3.2
- Spring Web
- Spring Validation
- Spring WebSocket
- Spring Data Redis
- Spring Mail
- MyBatis
- MySQL

## 当前模块概览

后端已经按业务模块拆分，包含但不限于：

- `account`
- `checkin`
- `focus`
- `friend`
- `home`
- `memo`
- `notification`
- `plan`
- `report`
- `setting`
- `stats`
- `team`
- `system`

## 本地运行前准备

- JDK 21
- Maven 3.9+
- MySQL 8
- Redis 7

建议优先配合 `infra/docker/docker-compose.dev.yml` 启动本地依赖。

## 配置说明

重点配置文件：

- `server/innocence-server/src/main/resources/application.yml`
- `server/innocence-server/src/main/resources/application-local.yml`

当前本地配置默认指向：

- MySQL：`127.0.0.1:3306`
- Redis：`127.0.0.1:6379`

邮件配置说明：

- 邮件用户名默认来自 `INNOCENCE_MAIL_USERNAME`
- 邮件密码建议通过 `INNOCENCE_MAIL_PASSWORD` 环境变量设置
- 还支持额外导入 `./config/application-local-secret.yml`

## 数据库

- 初始化脚本位于 `server/innocence-server/src/main/resources/schema.sql`
- 当前开启了 `spring.sql.init.mode=always`

说明：

- 本地开发时请注意数据库账号密码与你实际环境保持一致
- `application-local.yml` 和 `docker-compose.dev.yml` 当前的默认凭据并不完全相同，使用时建议统一一份本地配置

## 你通常会在这里改什么

- `controller`：对外接口
- `service`：业务逻辑
- `mapper`：MyBatis 访问层
- `domain` / `dto`：模型与请求响应对象
- `resources/mapper`：XML SQL 映射

## 关联目录

- 主服务说明建议从 `server/innocence-server` 继续阅读
- 基础依赖说明见 [infra/README.md](/F:/springmvc1/Innocence/infra/README.md)
