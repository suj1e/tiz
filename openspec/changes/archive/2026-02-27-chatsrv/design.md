# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring WebFlux (SSE 支持)
- Spring Data JPA
- MySQL, Redis
- HTTP Exchange

## 2. 项目结构

```
chatsrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/chat/
    ├── ChatApplication.java
    ├── controller/
    │   ├── ChatController.java
    │   └── InternalChatController.java
    ├── service/
    │   ├── ChatService.java
    │   └── ChatHistoryService.java
    ├── repository/
    │   ├── ChatSessionRepository.java
    │   └── ChatMessageRepository.java
    ├── entity/
    │   ├── ChatSession.java
    │   └── ChatMessage.java
    ├── dto/
    │   ├── ChatRequest.java
    │   └── ChatEvent.java
    ├── client/
    │   ├── LlmClient.java
    │   └── ContentClient.java
    └── sse/
        └── SseEmitterService.java
```

## 3. API 端点

### 对外 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/chat/v1/stream` | SSE 流式对话 |
| POST | `/api/chat/v1/confirm` | 确认生成题库 |
| GET | `/api/chat/v1/history/{id}` | 获取对话历史 |

## 4. SSE 事件类型

```typescript
type SSEEvent =
  | { type: 'session', data: { session_id: string } }
  | { type: 'message', data: { content: string } }
  | { type: 'confirm', data: { summary: GenerationSummary } }
  | { type: 'done', data: {} }
  | { type: 'error', data: { code: string, message: string } }
```

## 5. 数据库表

- `chat_sessions` - 对话会话表
- `chat_messages` - 对话消息表

## 6. 服务依赖

- llmsrv (AI 对话)
- contentsrv (保存题库)
