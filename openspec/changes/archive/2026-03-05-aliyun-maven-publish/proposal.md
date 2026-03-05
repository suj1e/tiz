## Why

当前 common 包和各服务 api 模块仅支持发布到 Maven Local 和 GitHub Packages。这导致：
1. CI/CD 远程构建时无法获取依赖，必须先在本地 publishToMavenLocal
2. 团队协作时依赖共享困难
3. 未来拆分多仓库后，跨仓库依赖无法解决

现在配置阿里云制品仓库，可以实现服务独立构建和部署。

## What Changes

- 发布端：修改 common、llmsrv-api、各服务 api 模块的 `build.gradle.kts`，发布到阿里云 Maven 仓库
- 消费端：修改各服务的 `settings.gradle.kts`，添加阿里云仓库配置以拉取依赖
- CI/CD：创建独立的 GitHub Actions workflow 文件，每个可发布单元独立流水线
- 认证：支持本地 gradle.properties 和 CI/CD 环境变量两种方式

### 发布清单

| 模块 | 路径 | artifactId |
|------|------|------------|
| common | tiz-backend/common | common |
| llmsrv-api | tiz-backend/llmsrv-api | llmsrv-api |
| authsrv-api | tiz-backend/authsrv/api | authsrv-api |
| chatsrv-api | tiz-backend/chatsrv/api | chatsrv-api |
| contentsrv-api | tiz-backend/contentsrv/api | contentsrv-api |
| practicesrv-api | tiz-backend/practicesrv/api | practicesrv-api |
| quizsrv-api | tiz-backend/quizsrv/api | quizsrv-api |
| usersrv-api | tiz-backend/usersrv/api | usersrv-api |

## Capabilities

### New Capabilities

- `maven-publish`: 阿里云 Maven 仓库发布能力，支持 SNAPSHOT 和 RELEASE 版本自动路由

### Modified Capabilities

无（这是新增基础设施能力，不修改现有业务规格）

## Impact

**修改的文件：**

发布端（8个 build.gradle.kts）：
- tiz-backend/common/build.gradle.kts
- tiz-backend/llmsrv-api/build.gradle.kts
- tiz-backend/authsrv/api/build.gradle.kts
- tiz-backend/chatsrv/api/build.gradle.kts
- tiz-backend/contentsrv/api/build.gradle.kts
- tiz-backend/practicesrv/api/build.gradle.kts
- tiz-backend/quizsrv/api/build.gradle.kts
- tiz-backend/usersrv/api/build.gradle.kts

消费端（9个 settings.gradle.kts）：
- tiz-backend/common/settings.gradle.kts
- tiz-backend/llmsrv-api/settings.gradle.kts
- tiz-backend/authsrv/settings.gradle.kts
- tiz-backend/chatsrv/settings.gradle.kts
- tiz-backend/contentsrv/settings.gradle.kts
- tiz-backend/practicesrv/settings.gradle.kts
- tiz-backend/quizsrv/settings.gradle.kts
- tiz-backend/usersrv/settings.gradle.kts
- tiz-backend/gatewaysrv/settings.gradle.kts

新增文件（8个 GitHub Actions workflow）：
- .github/workflows/publish-common.yml
- .github/workflows/publish-llmsrv-api.yml
- .github/workflows/publish-authsrv-api.yml
- .github/workflows/publish-chatsrv-api.yml
- .github/workflows/publish-contentsrv-api.yml
- .github/workflows/publish-practicesrv-api.yml
- .github/workflows/publish-quizsrv-api.yml
- .github/workflows/publish-usersrv-api.yml

**依赖：**
- 阿里云制品仓库（已存在）
- GitHub Secrets: ALIYUN_MAVEN_USERNAME, ALIYUN_MAVEN_PASSWORD
