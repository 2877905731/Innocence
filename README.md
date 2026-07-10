# Innocence

`Innocence` 是一个面向学习、自律、陪伴和团队互助的双端项目，当前以 `Flutter + Spring Boot` 为主线推进，目标覆盖移动端与桌面端，并围绕计划、专注、签到、备忘录、通知、熟人圈与团队协作提供完整闭环。

## 当前状态

- 前端主客户端位于 `client/flutter_app`
- 后端主服务位于 `server/innocence-server`
- 本地基础设施使用 `MySQL + Redis + Docker Compose`
- 文档已经沉淀到 `docs/planning` 和 `docs/troubleshooting`
- Windows 桌面端已经具备主页面、二级页面、设置、通知、好友、备忘录、统计、团队等主要交互骨架

## 仓库结构

```text
client/                      客户端目录
  flutter_app/               Flutter 主工程
docs/                        产品、实现约束、排查文档
infra/                       本地开发基础设施
  docker/                    Docker Compose 配置
scripts/                     辅助说明与脚本预留
server/                      后端目录
  innocence-server/          Spring Boot 主服务
```

## 技术栈

### 客户端

- Flutter
- Material 3
- shared_preferences
- Android / Windows 为当前重点平台

### 后端

- Java 21
- Spring Boot 3.3.2
- MyBatis
- Redis
- MySQL 8
- Spring Mail
- Spring WebSocket

## 本地开发建议

### 1. 启动基础依赖

可以先在 `infra/docker` 下使用 `docker-compose.dev.yml` 启动本地 MySQL 和 Redis。

当前默认容器信息：

- MySQL 端口：`3306`
- Redis 端口：`6379`

### 2. 启动后端

后端主工程位于 `server/innocence-server`。

建议准备：

- JDK 21
- Maven 3.9+

本地配置重点文件：

- `server/innocence-server/src/main/resources/application.yml`
- `server/innocence-server/src/main/resources/application-local.yml`

说明：

- `application-local.yml` 当前默认连接本机 `127.0.0.1:3306` 和 `127.0.0.1:6379`
- 邮件密码建议通过 `INNOCENCE_MAIL_PASSWORD` 环境变量注入
- 还支持额外导入 `./config/application-local-secret.yml`

### 3. 启动 Flutter 客户端

主工程位于 `client/flutter_app`。

建议准备：

- Flutter SDK
- Dart SDK
- Android Studio 或 VS Code
- Windows 桌面开发环境

常见开发场景：

- 调试运行：在 `client/flutter_app` 下直接运行 Flutter
- 打包 Windows：构建 `build/windows/x64/runner/Release/innocence_flutter.exe`

注意：

- Flutter 桌面端修改后，如果你验证的是 Windows 发布程序，需要重新构建 `Release`
- 真正承载 Flutter 业务逻辑的关键产物通常是 `build/windows/x64/runner/Release/data/app.so`

## 主要功能方向

- 账号注册、登录、资料编辑
- 今日计划与周计划模板
- 专注计时与番茄钟
- 今日签到与失败记录
- 统计中心
- 通知中心
- 好友与熟人圈
- 备忘录
- 团队、团队聊天与提醒
- 桌面挂件与桌面样式设置

## 文档入口

- 总文档索引：[docs/README.md](/F:/springmvc1/Innocence/docs/README.md)
- 前端修改未生效排查：[docs/troubleshooting/Innocence-前端修改未生效排查.md](/F:/springmvc1/Innocence/docs/troubleshooting/Innocence-前端修改未生效排查.md)
- 项目计划书：[docs/planning/Innocence-项目计划书.md](/F:/springmvc1/Innocence/docs/planning/Innocence-项目计划书.md)

## 备注

- 当前仓库改动较多，前后端都在持续迭代中
- 如果你准备直接运行桌面成品，优先使用 `client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe`
- 如果界面修改后看起来“没有生效”，先确认你运行的是不是最新重新构建出的发布包
