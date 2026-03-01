## 1. 启用服务发现配置

- [x] 1.1 authsrv: 启用 Nacos discovery，配置服务间调用地址
- [x] 1.2 chatsrv: 启用 Nacos discovery，配置服务间调用地址
- [x] 1.3 contentsrv: 启用 Nacos discovery
- [x] 1.4 practicesrv: 启用 Nacos discovery，配置服务间调用地址
- [x] 1.5 quizsrv: 启用 Nacos discovery，配置服务间调用地址
- [x] 1.6 usersrv: 启用 Nacos discovery
- [x] 1.7 gatewaysrv: 启用 Nacos discovery

## 2. WebClient LoadBalancer 支持

- [x] 2.1 chatsrv: HttpClientConfig 添加 @LoadBalanced
- [x] 2.2 contentsrv: LlmClientConfig 不需要 @LoadBalanced (llmsrv 是 Python 服务)
- [x] 2.3 practicesrv: ContentClientConfig 添加 @LoadBalanced
- [x] 2.4 quizsrv: ContentClientConfig 添加 @LoadBalanced

## 3. 部署配置清理

- [x] 3.1 删除 deploy/docker-compose.yml 中的 GATEWAY_ROUTES_*_URL 环境变量
- [x] 3.2 删除 deploy/docker-compose.yml 中的 LLM_SERVICE_URL 环境变量
- [x] 3.3 删除 deploy/docker-compose.yml 中的 CONTENT_SERVICE_URL 环境变量 (不存在)
- [x] 3.4 确认所有服务使用 NACOS_SERVER_ADDR 环境变量

## 4. 验证测试

- [x] 4.1 本地启动验证服务注册到 Nacos
- [x] 4.2 验证网关路由正常工作
- [x] 4.3 验证服务间调用正常工作
