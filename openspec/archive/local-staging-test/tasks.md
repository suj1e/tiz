## 1. 清理旧目录

- [x] 1.1 确认 `xxxsrv` 目录内容已迁移到 `xxx-service`
- [x] 1.2 删除 authsrv 目录
- [x] 1.3 删除 chatsrv 目录
- [x] 1.4 删除 contentsrv 目录
- [x] 1.5 删除 gatewaysrv 目录
- [x] 1.6 删除 llmsrv 目录
- [x] 1.7 删除 practicesrv 目录
- [x] 1.8 删除 quizsrv 目录
- [x] 1.9 删除 usersrv 目录

## 2. 创建 Staging 环境配置

- [x] 2.1 创建 auth-service/.env.staging
- [x] 2.2 创建 chat-service/.env.staging
- [x] 2.3 创建 content-service/.env.staging
- [x] 2.4 创建 practice-service/.env.staging
- [x] 2.5 创建 quiz-service/.env.staging
- [x] 2.6 创建 user-service/.env.staging
- [x] 2.7 创建 gateway/.env.staging
- [x] 2.8 创建 llm-service/.env.staging
- [x] 2.9 修复环境变量名称 (MYSQL_PASSWORD → SPRING_DATASOURCE_PASSWORD)

## 3. 修复启动问题

- [ ] 3.1 修复 auth-service WebClient.Builder Bean 缺失问题
- [ ] 3.2 构建所有服务的 JAR 文件
- [ ] 3.3 验证 auth-service 能正常启动

## 4. 启动后端服务

- [ ] 4.1 确认 staging 基础设施已启动（MySQL, Redis, Kafka, Nacos）
- [ ] 4.2 启动批次1: auth-service, user-service, content-service, practice-service, quiz-service
- [ ] 4.3 验证批次1服务健康
- [ ] 4.4 启动批次2: llm-service, chat-service
- [ ] 4.5 验证批次2服务健康
- [ ] 4.6 启动批次3: gateway
- [ ] 4.7 验证 gateway 健康并检查服务路由

## 5. 启动前端

- [ ] 5.1 配置前端 API 指向本地 gateway (localhost:8080)
- [ ] 5.2 启动前端开发服务器
- [ ] 5.3 验证前端页面加载正常

## 6. 端到端验证

- [ ] 6.1 测试用户注册功能
- [ ] 6.2 测试用户登录功能
- [ ] 6.3 测试主要业务流程
- [ ] 6.4 确认所有服务日志无错误
