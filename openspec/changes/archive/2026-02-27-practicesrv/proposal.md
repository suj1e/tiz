# practicesrv

## Why

练习服务提供逐题练习模式，用户提交答案后立即获得反馈。

## What Changes

### 1. 练习流程

- 开始练习 (获取题目)
- 提交答案 (立即反馈)
- 完成练习 (统计结果)

### 2. AI 评分

- 选择题：直接判断
- 简答题：调用 llmsrv 评分

## Scope

### In Scope

- 练习流程管理
- 答案提交和反馈
- 简答题 AI 评分
- 练习结果统计

### Out of Scope

- 题目存储 (contentsrv)
- Webhook 发送 (可选后续)
