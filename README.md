# Innocence

`Innocence` 是一个面向学习、自律、陪伴和团队互助的双端软件。

当前仓库已经进入第一阶段开发准备：

- 后端：Spring Boot + MyBatis + Redis + MySQL
- 客户端：Flutter，后续同时支持手机端和桌面端
- 基础设施：Docker 本地开发环境
- 文档：产品规划、数据库草案、接口草案、MVP 范围

## 仓库结构

```text
docs/                        产品与技术文档
server/innocence-server/     Spring Boot 后端工程
client/flutter_app/          Flutter 客户端代码骨架
infra/docker/                本地开发环境编排
scripts/                     辅助脚本
```

## 当前开发状态

- 已完成产品计划与接口规划文档归档
- 已完成 Spring Boot 初始工程骨架
- 已完成 Flutter 代码层骨架
- 已补充 Docker 本地开发环境样板

## 推荐下一步

1. 完成 Flutter SDK 接入并生成平台目录
2. 初始化用户与账户模块
3. 初始化数据库脚本与表结构
4. 建立前后端第一个联调接口
