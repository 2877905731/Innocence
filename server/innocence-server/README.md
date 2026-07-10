# innocence-server

这里是 `Innocence` 项目的 Spring Boot 主服务工程。

## 基本信息

- 服务名：`innocence-server`
- 运行端口：`8080`
- Spring Profile：默认 `local`
- Java 版本：`21`

## 依赖栈

- Spring Boot Web
- Spring Boot Validation
- Spring Boot Actuator
- Spring Boot WebSocket
- MyBatis
- Redis
- MySQL
- Spring Mail
- Lombok

## 目录结构

```text
src/main/java/com/innocence/server/
  common/                    公共配置与通用能力
  modules/                   业务模块
src/main/resources/
  application.yml            基础配置
  application-local.yml      本地开发配置
  mapper/                    MyBatis XML
  schema.sql                 初始化脚本
pom.xml                      Maven 配置
```

## 当前业务模块

目前已经围绕客户端主流程展开了较完整的模块拆分：

- 账号与登录：`account`
- 首页聚合：`home`
- 今日计划与周模板：`plan`
- 专注：`focus`
- 签到：`checkin`
- 统计：`stats`
- 备忘录：`memo`
- 通知：`notification`
- 好友：`friend`
- 团队：`team`
- 设置：`setting`
- 举报与后台管理：`report`

## 本地启动前提

- MySQL 已就绪
- Redis 已就绪
- 邮件账号可用，或至少允许本地启动时使用空密码占位

推荐直接配合：

- [infra/docker/docker-compose.dev.yml](/F:/springmvc1/Innocence/infra/docker/docker-compose.dev.yml)

## 配置重点

### application.yml

这里定义了：

- 应用名
- 默认 Profile
- 端口
- MyBatis 基础配置
- Actuator 暴露项

### application-local.yml

这里定义了：

- 本地数据库地址
- Redis 地址
- 邮件服务器
- 管理员邮箱白名单

如果你要在别的机器上启动，通常优先改这里或额外补 `config/application-local-secret.yml`。

## 开发提示

- `schema.sql` 当前会参与初始化流程，改表时记得同步维护
- `resources/mapper` 下的 SQL 与 Java `mapper` 接口需要保持一致
- 如果客户端功能“点了没反应”，排查时不要只看前端，也要确认后端对应模块接口是否已接通
