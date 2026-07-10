# 基础设施目录

这里存放 `Innocence` 项目本地开发依赖与基础设施配置。

## 目录结构

```text
docker/
  docker-compose.dev.yml     本地开发环境编排
README.md                    当前目录说明
```

## 当前提供内容

当前仓库已经提供一份本地开发用的 Docker Compose 配置：

- `infra/docker/docker-compose.dev.yml`

它会启动：

- MySQL 8.4
- Redis 7.2

## 默认端口

- MySQL：`3306`
- Redis：`6379`

## 默认容器名

- `innocence-mysql`
- `innocence-redis`

## 当前默认凭据

### MySQL

- root 密码：`root123456`
- 默认数据库：`innocence`
- 普通用户：`innocence`
- 用户密码：`innocence123`

## 使用时要注意

后端 `application-local.yml` 当前写的是另一组本地数据库凭据：

- 用户名：`root`
- 密码：`root`

所以第一次接环境时，建议二选一：

1. 修改后端本地配置，与 Docker 默认凭据保持一致。
2. 修改 Docker Compose 中的 MySQL 凭据，与后端本地配置保持一致。

否则很容易出现数据库容器已经起来了，但后端仍然连不上的情况。

## 推荐用途

- 新环境初始化
- 本地联调
- 前后端同时开发时的依赖托管

## 后续可继续补充

- Nginx 反向代理
- 生产或测试环境样板
- 数据持久化与备份说明
- 环境变量模板
