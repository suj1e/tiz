## 1. Nacos 配置准备

- [x] 1.1 创建 Nacos namespaces: dev, staging, prod (通过 nacos-init 自动创建)
- [x] 1.2 创建 common.yaml 配置模板 (dev/staging/prod)
- [x] 1.3 创建 nacos-init 容器自动导入配置

## 2. 服务配置改造

- [x] 2.1 authsrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.2 chatsrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.3 contentsrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.4 practicesrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.5 quizsrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.6 usersrv: 启用 Nacos Config，移除硬编码配置
- [x] 2.7 gatewaysrv: 启用 Nacos Config，移除硬编码配置

## 3. 部署配置更新

- [x] 3.1 更新 deploy/docker-compose.yml 简化环境变量配置
- [x] 3.2 敏感信息通过环境变量传递 (JWT_SECRET, MYSQL_PASSWORD, REDIS_PASSWORD)

## 4. 动态刷新支持

- [x] 4.1 所有服务启用 refresh-enabled: true
- [x] 4.2 shared-configs 配置 refresh: true

## 5. 验证

- [x] 5.1 配置文件结构正确
- [x] 5.2 nacos-init 脚本可执行
- [x] 5.3 敏感信息不从 Nacos 泄露
