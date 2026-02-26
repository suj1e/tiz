# 任务清单

## 项目初始化

- [ ] 创建项目结构
- [ ] 配置 build.gradle.kts (含 Kafka)
- [ ] 配置 application.yaml

## 实体和 Repository

- [ ] QuizSession 实体
- [ ] QuizAnswer 实体
- [ ] QuizResult 实体
- [ ] QuizResultDetail 实体
- [ ] OutboxEvent 实体
- [ ] 各 Repository

## 服务层

- [ ] QuizService
- [ ] GradingService
- [ ] OutboxService

## 控制器

- [ ] QuizController

## HTTP Client

- [ ] ContentClient (HTTP Exchange)
- [ ] LlmClient (HTTP Exchange)

## Outbox

- [ ] OutboxPublisher (Kafka 发送)
- [ ] Outbox 定时扫描任务

## 测试

- [ ] 开始测验测试
- [ ] 批量提交测试
- [ ] 结果查询测试
