# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring Data JPA + QueryDSL
- MySQL
- HTTP Exchange (调用 llmsrv, contentsrv)

## 2. 项目结构

```
practicesrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/practice/
    ├── PracticeApplication.java
    ├── controller/
    │   └── PracticeController.java
    ├── service/
    │   ├── PracticeService.java
    │   └── GradingService.java
    ├── repository/
    │   ├── PracticeSessionRepository.java
    │   └── PracticeAnswerRepository.java
    ├── entity/
    │   ├── PracticeSession.java
    │   └── PracticeAnswer.java
    ├── dto/
    │   ├── StartPracticeResponse.java
    │   ├── SubmitAnswerRequest.java
    │   └── SubmitAnswerResponse.java
    └── client/
        ├── ContentClient.java
        └── LlmClient.java
```

## 3. API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/practice/v1/start` | 开始练习 |
| POST | `/api/practice/v1/{id}/answer` | 提交答案 |
| POST | `/api/practice/v1/{id}/complete` | 完成练习 |

## 4. 练习流程

```
开始练习 → 获取题目 (从 contentsrv)
    ↓
逐题答题 → 提交答案 → 立即反馈
    ↓ (简答题)
调用 llmsrv 评分
    ↓
完成练习 → 统计结果
```

## 5. 数据库表

- `practice_sessions` - 练习会话表
- `practice_answers` - 练习答案表

## 6. 服务依赖

- contentsrv (获取题目)
- llmsrv (简答题评分)
