# 任务清单

## 项目初始化

- [x] 创建项目结构
- [x] 配置 build.gradle.kts (含 WebFlux)
- [x] 配置 application.yaml

## 实体和 Repository

- [x] ChatSession 实体
- [x] ChatMessage 实体
- [x] ChatSessionRepository
- [x] ChatMessageRepository

## 服务层

- [x] ChatService (对话流管理)
- [x] ChatHistoryService
- [x] SseEmitterService

## 控制器

- [x] ChatController (SSE 端点)

## HTTP Client

- [x] LlmClient (HTTP Exchange)
- [x] ContentClient (HTTP Exchange)

## 测试

- [x] SSE 对话测试
- [x] 历史记录测试
- [x] 确认生成测试
