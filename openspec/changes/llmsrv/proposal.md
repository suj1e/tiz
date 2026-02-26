# llmsrv

## Why

LLM 服务封装 OpenAI API，为其他服务提供 AI 能力，是整个平台的核心能力提供者。

## What Changes

### 1. 对话能力

- SSE 流式对话
- 多轮对话支持
- 上下文管理

### 2. 题目生成

- 根据对话摘要生成题目
- 支持选择题和简答题
- 分批生成

### 3. 答案评分

- 简答题 AI 评分
- 返回分数和反馈

## Scope

### In Scope

- OpenAI API 封装
- SSE 流式对话
- 题目生成
- 简答题评分
- 内部 API

### Out of Scope

- 对话历史存储 (chatsrv)
- 题目存储 (contentsrv)
- 多模型支持
