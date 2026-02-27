# quizsrv

## Why

测验服务提供限时测验模式，用户批量提交答案后获得综合结果。

## What Changes

### 1. 测验流程

- 开始测验 (获取题目、计时)
- 批量提交答案
- 获取测验结果

### 2. AI 评分

- 选择题：直接判断
- 简答题：调用 llmsrv 评分

### 3. 事件发布

- 测验完成后发布事件 (Outbox 模式)
- 触发 Webhook 通知

## Scope

### In Scope

- 测验流程管理
- 批量答案评分
- 测验结果存储
- Outbox 事件发布

### Out of Scope

- 题目存储 (contentsrv)
- Webhook 发送 (usersrv + 消费者)
