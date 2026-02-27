# 任务清单

## 项目初始化

- [x] 创建项目结构
- [x] 配置 build.gradle.kts (含 Kafka)
- [x] 配置 application.yaml

## 实体和 Repository

- [x] QuizSession 实体
- [x] QuizAnswer 实体
- [x] QuizResult 实体
- [x] QuizResultDetail 实体
- [x] OutboxEvent 实体
- [x] 各 Repository

## 服务层

- [x] QuizService
- [x] GradingService
- [x] OutboxService

## 控制器

- [x] QuizController

## HTTP Client

- [x] ContentClient (HTTP Exchange)
- [x] LlmClient (HTTP Exchange)

## Outbox

- [x] OutboxPublisher (Kafka 发送)
- [x] Outbox 定时扫描任务

## 错误码

- [x] QuizErrorCode 枚举

## 主应用

- [x] QuizApplication

## DTO

- [x] StartQuizResponse
- [x] SubmitQuizRequest
- [x] QuizResultResponse
- [x] QuizCompletedEvent

## 测试

- [x] 开始测验测试
- [x] 批量提交测试
- [x] 结果查询测试
