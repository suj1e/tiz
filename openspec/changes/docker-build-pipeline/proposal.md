# Docker 镜像构建流水线

## 概述

为后端服务（Java/Python）和前端创建 GitHub Actions 流水线，构建并推送 Docker 镜像到阿里云容器镜像仓库。

## 背景

现有流水线仅支持 Maven artifacts 发布，缺少 Docker 镜像构建能力。需要支持：
- 8 个后端服务（7 个 Java + 1 个 Python）
- 1 个前端应用

## 变更范围

### 新增文件（9 个流水线）

**后端 Java 服务：**
- `.github/workflows/docker-authsrv.yml`
- `.github/workflows/docker-chatsrv.yml`
- `.github/workflows/docker-contentsrv.yml`
- `.github/workflows/docker-practicesrv.yml`
- `.github/workflows/docker-quizsrv.yml`
- `.github/workflows/docker-usersrv.yml`
- `.github/workflows/docker-gatewaysrv.yml`

**后端 Python 服务：**
- `.github/workflows/docker-llmsrv.yml`

**前端：**
- `.github/workflows/docker-tiz-web.yml`

### GitHub Secrets 配置

需要在 GitHub 仓库中配置：
- `ALIYUN_REGISTRY_USERNAME` - 阿里云镜像仓库用户名
- `ALIYUN_REGISTRY_PASSWORD` - 阿里云镜像仓库密码

## 技术方案

### 镜像仓库

- **地址**: `registry.cn-hangzhou.aliyuncs.com`
- **命名空间**: `nxo`
- **完整地址**: `registry.cn-hangzhou.aliyuncs.com/nxo/<service>`

### 镜像标签策略

每次构建推送两个标签：
- `latest` - 最新版本
- `sha-<short-commit>` - 可追溯版本

示例：
```
registry.cn-hangzhou.aliyuncs.com/nxo/authsrv:latest
registry.cn-hangzhou.aliyuncs.com/nxo/authsrv:sha-abc1234
```

### 触发方式

手动触发（`workflow_dispatch`）

### 流水线结构

```yaml
name: Docker <service>

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Aliyun Registry
        uses: docker/login-action@v3
        with:
          registry: registry.cn-hangzhou.aliyuncs.com
          username: ${{ secrets.ALIYUN_REGISTRY_USERNAME }}
          password: ${{ secrets.ALIYUN_REGISTRY_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: <service-path>
          push: true
          tags: |
            registry.cn-hangzhou.aliyuncs.com/nxo/<service>:latest
            registry.cn-hangzhou.aliyuncs.com/nxo/<service>:sha-${{ github.sha }}
          build-args: |
            GITHUB_TOKEN=${{ github.token }}
            PORT=<port>
```

## 服务清单

| 服务 | 类型 | 路径 | 端口 |
|------|------|------|------|
| authsrv | Java | tiz-backend/authsrv | 8101 |
| chatsrv | Java | tiz-backend/chatsrv | 8102 |
| contentsrv | Java | tiz-backend/contentsrv | 8103 |
| practicesrv | Java | tiz-backend/practicesrv | 8104 |
| quizsrv | Java | tiz-backend/quizsrv | 8105 |
| usersrv | Java | tiz-backend/usersrv | 8107 |
| gatewaysrv | Java | tiz-backend/gatewaysrv | 8080 |
| llmsrv | Python | tiz-backend/llmsrv | 8106 |
| tiz-web | Node | tiz-web | 80 |

## 风险评估

- **低风险** - 仅新增流水线文件，不影响现有代码
- **依赖** - 需要 GitHub Secrets 配置完成后才能正常工作
