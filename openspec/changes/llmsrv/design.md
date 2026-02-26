# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring WebFlux (SSE 支持)
- OpenAI Java SDK
- Redis (对话上下文缓存)

## 2. 项目结构

```
llmsrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/llm/
    ├── LlmApplication.java
    ├── controller/
    │   └── InternalLlmController.java
    ├── service/
    │   ├── ChatService.java
    │   ├── QuestionGeneratorService.java
    │   └── GradingService.java
    ├── client/
    │   └── OpenAiClient.java
    ├── dto/
    │   ├── ChatRequest.java
    │   ├── ChatEvent.java
    │   ├── GenerateRequest.java
    │   ├── GradeRequest.java
    │   └── GradeResponse.java
    └── config/
        └── OpenAiConfig.java
```

## 3. API 端点 (仅内部)

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/internal/llm/v1/chat/stream` | SSE 流式对话 |
| POST | `/internal/llm/v1/generate` | 生成题目 |
| POST | `/internal/llm/v1/grade` | 评分 |

## 4. OpenAI 集成

```java
// 使用 OpenAI Java SDK
@Component
public class OpenAiClient {

    private final OpenAiClient client;

    public Flux<ChatCompletionChunk> chatStream(List<ChatMessage> messages) {
        // 调用 OpenAI API
    }
}
```

## 5. Prompt 设计

### 对话 Prompt

```
你是一个专业的知识问答助手。通过对话了解用户想学习的主题，
然后生成相关的练习题目。当用户确认主题后，返回 JSON 格式的摘要。
```

### 评分 Prompt

```
你是一个专业的评分助手。根据题目、标准答案、评分标准，
对用户的答案进行评分。返回 JSON 格式的评分结果。
```

## 6. 配置

```yaml
openai:
  api-key: ${OPENAI_API_KEY}
  model: gpt-4o
  temperature: 0.7
```

## 7. Redis 缓存

- 对话上下文缓存 (减少 Token 消耗)
- 评分结果缓存
