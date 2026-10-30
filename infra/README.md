# 基础设施目录

这里存放 `Innocence` 项目本地开发依赖与服务器部署配置。

## 目录结构

```text
docker/
  docker-compose.dev.yml     本地开发环境编排
README.md                    当前目录说明
deploy/                      Debian 13 首次部署包与 SSH 隧道入口
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

## 服务器首次部署

参见 [Debian 13 小内存服务器首次部署](deploy/README.zh-CN.md)。提供 Java 21 后端、管理网页、MySQL 8.4/Redis 7.2 编排、持久化和服务器端凭据生成。后台先通过 SSH 隧道访问，不直接开放公网管理入口；本地打包检查不等于服务器启动或账号验收完成。

开发编排的默认密码和数据库端口映射仅用于本地环境，不应原样用于公网服务器。

## 公网开放前继续完成

- 公网 HTTPS、证书自动续期与实际访问验收
- 登录/验证码限流与密码哈希升级
- 数据库及头像备份恢复演练
- 真实账号、邮件投递与资源负载验证
