## Why

当前部署方案存在以下问题：
1. **依赖构建耦合** - Dockerfile 中硬编码依赖顺序，每次构建都要重建所有依赖
2. **网络架构混乱** - 三个网络 (npass, tiz-network, tiz-backend)，IP 硬编码
3. **流水线耦合** - 一个 matrix 构建所有服务，改动一个触发全部重建
4. **配置不统一** - Gradle 版本不一致，缺少 gradle.properties
5. **Dockerfile 复杂** - 通用 Dockerfile 120+ 行，难以维护

## What Changes

### 1. GitHub Packages 发布
- common, llmsrv-api, contentsrv-api 发布到 GitHub Packages
- 服务构建时从 GitHub Packages 拉取依赖，解耦构建

### 2. 网络统一到 npass
- 移除 tiz-network, tiz-backend 网络
- 所有服务加入 npass 网络
- 使用 DNS 名称代替 IP 硬编码

### 3. Dockerfile 简化
- 创建 base-jre 基础镜像
- 每个服务独立 Dockerfile (~15行)

### 4. 独立流水线
- lib-publish.yml - library 发布
- srv-*.yml - 每个服务独立流水线
- deploy.yml - 部署
- base-images.yml - 基础镜像构建

### 5. Gradle 配置统一
- common gradle-wrapper: 8.5 → 9.3.1
- 每个项目添加 gradle.properties

## Capabilities

### New Capabilities

- `github-packages`: Library 发布到 GitHub Packages
- `base-image`: JRE 基础镜像
- `independent-pipeline`: 服务独立流水线

### Modified Capabilities

- `docker-network`: 统一到 npass 网络
- `dockerfile`: 简化为 base image + 服务 Dockerfile
- `ci-cd-pipeline`: 拆分为独立流水线

## Impact

### 新增文件

| 文件 | 说明 |
|------|------|
| `tiz-backend/docker/Dockerfile.base-jre` | JRE 基础镜像 |
| `tiz-backend/*/Dockerfile` | 每个服务独立 Dockerfile |
| `tiz-backend/*/gradle.properties` | Gradle 配置 |
| `.github/workflows/lib-publish.yml` | Library 发布流水线 |
| `.github/workflows/srv-*.yml` | 服务构建流水线 (7个) |
| `.github/workflows/base-images.yml` | 基础镜像流水线 |

### 修改文件

| 文件 | 说明 |
|------|------|
| `tiz-backend/common/gradle-wrapper.properties` | 8.5 → 9.3.1 |
| `tiz-backend/common/build.gradle.kts` | 添加 GitHub Packages 发布 |
| `tiz-backend/llmsrv-api/build.gradle.kts` | 添加 GitHub Packages 发布 |
| `tiz-backend/contentsrv/api/build.gradle.kts` | 添加 GitHub Packages 发布 |
| `infra/docker-compose.yml` | 网络改用 npass |
| `deploy/docker-compose.yml` | 网络改用 npass，移除 IP 硬编码 |
| `.github/workflows/deploy.yml` | 简化部署逻辑 |

### 删除文件

| 文件 | 说明 |
|------|------|
| `tiz-backend/docker/Dockerfile.java` | 被独立 Dockerfile 替代 |
| `tiz-backend/docker/Dockerfile.gateway` | 被独立 Dockerfile 替代 |

## Dependencies

- 旧 change `deployment-config` 已归档到 `archive/2026-03-01-deployment-config-obsolete`
