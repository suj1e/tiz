# Staging 部署配置改造

## 概述

修改各服务的 docker-compose.yml，使用阿里云镜像仓库的镜像，支持团队自治部署。

## 背景

- 镜像已推送到阿里云: `registry.cn-hangzhou.aliyuncs.com/nxo/<service>`
- 需要支持各团队独立负责和部署自己的服务
- 采用手动触发、pull 镜像的方式部署

## 变更范围

修改 9 个服务的 docker-compose.yml：

| 服务 | 文件路径 |
|------|----------|
| authsrv | tiz-backend/authsrv/docker-compose.yml |
| chatsrv | tiz-backend/chatsrv/docker-compose.yml |
| contentsrv | tiz-backend/contentsrv/docker-compose.yml |
| practicesrv | tiz-backend/practicesrv/docker-compose.yml |
| quizsrv | tiz-backend/quizsrv/docker-compose.yml |
| usersrv | tiz-backend/usersrv/docker-compose.yml |
| gatewaysrv | tiz-backend/gatewaysrv/docker-compose.yml |
| llmsrv | tiz-backend/llmsrv/docker-compose.yml |
| tiz-web | tiz-web/docker-compose.yml |

## 改动内容

每个 docker-compose.yml 的改动：

```yaml
# 改前
services:
  xxxsrv:
    build:
      context: .
    image: xxxsrv:latest
    ...

# 改后
services:
  xxxsrv:
    image: registry.cn-hangzhou.aliyuncs.com/nxo/xxxsrv:latest
    pull_policy: always
    ...
```

## 部署流程

团队部署时：
```bash
cd tiz-backend/authsrv
docker-compose pull
docker-compose up -d
```

## 镜像地址

所有镜像统一使用：`registry.cn-hangzhou.aliyuncs.com/nxo/<service>:latest`
