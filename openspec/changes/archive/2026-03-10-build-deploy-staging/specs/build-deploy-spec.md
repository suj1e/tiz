# Spec: Build and Deploy

## 前置条件
- Docker 已登录阿里云镜像仓库
- infra/staging 基础设施运行中 (MySQL, Redis, Kafka, Nacos, ES)
- 所有服务代码已通过本地测试

## 镜像规格
- 基础镜像: `eclipse-temurin:21-jre-alpine`
- 镜像仓库: `registry.cn-hangzhou.aliyuncs.com/nxo`
- 标签策略: `latest` + Git commit SHA

## 部署规格
- 命名: `<service-name>-staging`
- 网络: `tiz-staging-network`
- 资源限制: CPU 512m, Memory 512Mi

## 验证规格
- 健康检查: `/actuator/health` 返回 200
- API 测试: 登录注册功能正常
