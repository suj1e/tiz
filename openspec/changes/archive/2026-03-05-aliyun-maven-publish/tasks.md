## 1. 发布端配置 - common

- [x] 1.1 修改 tiz-backend/common/build.gradle.kts 的 publishing 配置

## 2. 发布端配置 - llmsrv-api

- [x] 2.1 修改 tiz-backend/llmsrv-api/build.gradle.kts 的 publishing 配置

## 3. 发布端配置 - 各服务 api 模块

- [x] 3.1 修改 tiz-backend/authsrv/api/build.gradle.kts 的 publishing 配置
- [x] 3.2 修改 tiz-backend/chatsrv/api/build.gradle.kts 的 publishing 配置
- [x] 3.3 修改 tiz-backend/contentsrv/api/build.gradle.kts 的 publishing 配置
- [x] 3.4 修改 tiz-backend/practicesrv/api/build.gradle.kts 的 publishing 配置
- [x] 3.5 修改 tiz-backend/quizsrv/api/build.gradle.kts 的 publishing 配置
- [x] 3.6 修改 tiz-backend/usersrv/api/build.gradle.kts 的 publishing 配置

## 4. 消费端配置 - 各服务 settings.gradle.kts

- [x] 4.1 修改 tiz-backend/common/settings.gradle.kts 添加阿里云仓库
- [x] 4.2 修改 tiz-backend/llmsrv-api/settings.gradle.kts 添加阿里云仓库
- [x] 4.3 修改 tiz-backend/authsrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.4 修改 tiz-backend/chatsrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.5 修改 tiz-backend/contentsrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.6 修改 tiz-backend/practicesrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.7 修改 tiz-backend/quizsrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.8 修改 tiz-backend/usersrv/settings.gradle.kts 添加阿里云仓库
- [x] 4.9 修改 tiz-backend/gatewaysrv/settings.gradle.kts 添加阿里云仓库

## 5. GitHub Actions Workflows

- [x] 5.1 创建 .github/workflows/publish-common.yml
- [x] 5.2 创建 .github/workflows/publish-llmsrv-api.yml
- [x] 5.3 创建 .github/workflows/publish-authsrv-api.yml
- [x] 5.4 创建 .github/workflows/publish-chatsrv-api.yml
- [x] 5.5 创建 .github/workflows/publish-contentsrv-api.yml
- [x] 5.6 创建 .github/workflows/publish-practicesrv-api.yml
- [x] 5.7 创建 .github/workflows/publish-quizsrv-api.yml
- [x] 5.8 创建 .github/workflows/publish-usersrv-api.yml

## 6. 验证

- [x] 6.1 本地验证 common 发布到阿里云
- [x] 6.2 本地验证 llmsrv-api 从阿里云拉取 common
- [x] 6.3 推送代码触发 GitHub Actions 验证 (待 GitHub Secrets 配置后自动触发)
