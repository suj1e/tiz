# Staging 部署流水线

## 概述

创建 9 个 GitHub Actions 流水线，通过 SSH 部署服务到 staging 服务器。

## 部署架构

```
服务器目录结构:
/opt/dev/deploy/staging/
├── .env                    # 共享环境变量
├── authsrv/
│   └── docker-compose.yml  # 每次部署时写入
├── chatsrv/
│   └── docker-compose.yml
├── ... (其他服务)
└── tiz-web/
    └── docker-compose.yml
```

## 部署流程

1. SSH 到服务器
2. 创建服务目录
3. 写入最新的 docker-compose.yml（使用 SHA 版本镜像）
4. docker-compose pull
5. docker-compose up -d

## 镜像版本策略

使用 commit SHA 作为镜像版本：
- `registry.cn-hangzhou.aliyuncs.com/nxo/authsrv:sha-abc1234`

好处：
- 精确版本控制
- 可回滚
- 避免缓存问题

## 需要的 Secrets

| Secret | 说明 |
|--------|------|
| DEPLOY_HOST | 服务器 IP |
| DEPLOY_USER | SSH 用户名 |
| DEPLOY_KEY | SSH 私钥 |

## 流水线列表 (9个)

| 流水线 | 服务 | 部署路径 |
|--------|------|----------|
| deploy-authsrv.yml | authsrv | /opt/dev/deploy/staging/authsrv |
| deploy-chatsrv.yml | chatsrv | /opt/dev/deploy/staging/chatsrv |
| deploy-contentsrv.yml | contentsrv | /opt/dev/deploy/staging/contentsrv |
| deploy-practicesrv.yml | practicesrv | /opt/dev/deploy/staging/practicesrv |
| deploy-quizsrv.yml | quizsrv | /opt/dev/deploy/staging/quizsrv |
| deploy-usersrv.yml | usersrv | /opt/dev/deploy/staging/usersrv |
| deploy-gatewaysrv.yml | gatewaysrv | /opt/dev/deploy/staging/gatewaysrv |
| deploy-llmsrv.yml | llmsrv | /opt/dev/deploy/staging/llmsrv |
| deploy-tiz-web.yml | tiz-web | /opt/dev/deploy/staging/tiz-web |

## 流水线模板

```yaml
name: Deploy authsrv

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_KEY }}
          script: |
            mkdir -p /opt/dev/deploy/staging/authsrv
            
            cat > /opt/dev/deploy/staging/authsrv/docker-compose.yml << 'EOF'
            services:
              authsrv:
                image: registry.cn-hangzhou.aliyuncs.com/nxo/authsrv:sha-${{ github.sha }}
                pull_policy: always
                container_name: tiz-authsrv
                restart: always
                ports:
                  - "8101:8101"
                env_file:
                  - ../.env
                networks:
                  - npass
                logging:
                  driver: "json-file"
                  options:
                    max-size: "10m"
                    max-file: "3"
            
            networks:
              npass:
                external: true
            EOF
            
            cd /opt/dev/deploy/staging/authsrv
            docker-compose pull
            docker-compose up -d
```

## 服务器前置准备

1. 安装 Docker + docker-compose
2. 登录阿里云镜像仓库
3. 创建 npass 网络: `docker network create npass`
4. 创建共享 .env 文件

```bash
# /opt/dev/deploy/staging/.env
NACOS_SERVER_ADDR=nacos:8080
NACOS_NAMESPACE=staging
MYSQL_PASSWORD=xxx
REDIS_PASSWORD=xxx
```
