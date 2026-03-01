## 1. Gradle 配置统一

- [x] 1.1 更新 common/gradle-wrapper.properties: 8.5 → 9.3.1
- [x] 1.2 添加 common/gradle.properties
- [x] 1.3 添加 llmsrv-api/gradle.properties
- [x] 1.4 添加 contentsrv/api/gradle.properties (或在 contentsrv 根目录)
- [x] 1.5 添加各服务的 gradle.properties (authsrv, chatsrv, contentsrv, practicesrv, quizsrv, usersrv, gatewaysrv)

## 2. GitHub Packages 发布配置

- [x] 2.1 更新 common/build.gradle.kts - 添加 GitHub Packages repository
- [x] 2.2 更新 llmsrv-api/build.gradle.kts - 添加 GitHub Packages repository
- [x] 2.3 更新 contentsrv/api/build.gradle.kts - 添加 GitHub Packages repository
- [x] 2.4 验证本地发布到 GitHub Packages

## 3. 网络统一到 npass

- [x] 3.1 更新 infra/docker-compose.yml - 网络改为 npass (external)
- [x] 3.2 更新 deploy/docker-compose.yml - 移除 tiz-backend 网络，所有服务加入 npass
- [x] 3.3 更新所有服务的环境变量 - IP 改为 DNS 名称 (如 172.28.0.10 → mysql)
- [x] 3.4 验证网络配置正确

## 4. Base Image Dockerfile

- [x] 4.1 创建 tiz-backend/docker/Dockerfile.base-jre
- [x] 4.2 创建 .github/workflows/base-images.yml
- [x] 4.3 构建并推送 base-jre 镜像到 ghcr.io

## 5. 服务独立 Dockerfile

- [x] 5.1 创建 tiz-backend/authsrv/Dockerfile
- [x] 5.2 创建 tiz-backend/chatsrv/Dockerfile
- [x] 5.3 创建 tiz-backend/contentsrv/Dockerfile
- [x] 5.4 创建 tiz-backend/practicesrv/Dockerfile
- [x] 5.5 创建 tiz-backend/quizsrv/Dockerfile
- [x] 5.6 创建 tiz-backend/usersrv/Dockerfile
- [x] 5.7 创建 tiz-backend/gatewaysrv/Dockerfile
- [x] 5.8 删除旧 Dockerfile (Dockerfile.java, Dockerfile.gateway)

## 6. 独立流水线

- [x] 6.1 创建 .github/workflows/lib-publish.yml
- [x] 6.2 创建 .github/workflows/srv-authsrv.yml
- [x] 6.3 创建 .github/workflows/srv-chatsrv.yml
- [x] 6.4 创建 .github/workflows/srv-contentsrv.yml
- [x] 6.5 创建 .github/workflows/srv-practicesrv.yml
- [x] 6.6 创建 .github/workflows/srv-quizsrv.yml
- [x] 6.7 创建 .github/workflows/srv-usersrv.yml
- [x] 6.8 创建 .github/workflows/srv-gatewaysrv.yml
- [x] 6.9 创建 .github/workflows/srv-llmsrv.yml
- [x] 6.10 创建 .github/workflows/web-tiz-web.yml
- [x] 6.11 更新 .github/workflows/deploy.yml

## 7. 验证测试

- [x] 7.1 本地构建 base-jre 镜像
- [x] 7.2 本地构建单个服务镜像 (如 authsrv)
- [x] 7.3 本地 docker-compose up 验证
- [x] 7.4 CI/CD 流水线测试
- [x] 7.5 部署到服务器验证

## 8. 清理和收尾

- [x] 8.1 删除旧的 deploy.yml 中的 matrix 构建
- [x] 8.2 更新 CLAUDE.md 部署说明
- [x] 8.3 归档此 OpenSpec change
