# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring Data JPA + QueryDSL
- Spring Kafka
- MySQL
- HTTP Exchange

## 2. 项目结构

```
quizsrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/quiz/
    ├── QuizApplication.java
    ├── controller/
    │   └── QuizController.java
    ├── service/
    │   ├── QuizService.java
    │   ├── GradingService.java
    │   └── OutboxService.java
    ├── repository/
    │   ├── QuizSessionRepository.java
    │   ├── QuizAnswerRepository.java
    │   ├── QuizResultRepository.java
    │   ├── QuizResultDetailRepository.java
    │   └── OutboxEventRepository.java
    ├── entity/
    │   ├── QuizSession.java
    │   ├── QuizAnswer.java
    │   ├── QuizResult.java
    │   ├── QuizResultDetail.java
    │   └── OutboxEvent.java
    ├── dto/
    │   ├── StartQuizResponse.java
    │   ├── SubmitQuizRequest.java
    │   └── QuizResultResponse.java
    ├── client/
    │   ├── ContentClient.java
    │   └── LlmClient.java
    └── outbox/
        └── OutboxPublisher.java  # Kafka 发送
```

## 3. API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/quiz/v1/start` | 开始测验 |
| POST | `/api/quiz/v1/{id}/submit` | 批量提交 |
| GET | `/api/quiz/v1/result/{id}` | 获取结果 |

## 4. 测验流程

```
开始测验 → 获取题目 (从 contentsrv)
    ↓
计时开始
    ↓
用户答题 → 批量提交
    ↓
评分 (选择题直接判断，简答题调用 llmsrv)
    ↓
保存结果 + 发布 Outbox 事件
    ↓
Kafka 消费者 → 发送 Webhook
```

## 5. 数据库表

- `quiz_sessions` - 测验会话表
- `quiz_answers` - 测验答案表 (暂存)
- `quiz_results` - 测验结果表
- `quiz_result_details` - 测验结果详情表
- `outbox_events` - Outbox 事件表

## 6. Outbox 事件

```json
{
  "aggregate_type": "quiz_result",
  "aggregate_id": "uuid",
  "event_type": "quiz.completed",
  "payload": {
    "user_id": "uuid",
    "quiz_id": "uuid",
    "score": 85,
    "total": 100
  }
}
```

## 7. 服务依赖

- contentsrv (获取题目)
- llmsrv (简答题评分)
