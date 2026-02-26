# 任务清单

## 项目初始化

- [ ] 创建项目结构
- [ ] 配置 build.gradle.kts (含 WebFlux)
- [ ] 配置 application.yaml

## 实体和 Repository

- [ ] ChatSession 实体
- [ ] ChatMessage 实体
- [ ] ChatSessionRepository
- [ ] ChatMessageRepository

## 服务层

- [ ] ChatService (对话流管理)
- [ ] ChatHistoryService
- [ ] SseEmitterService

## 控制器

- [ ] ChatController (SSE 端点)

## HTTP Client

- [ ] LlmClient (HTTP Exchange)
- [ ] ContentClient (HTTP Exchange)

## 测试

- [ ] SSE 对话测试
- [ ] 历史记录测试
- [ ] 确认生成测试
