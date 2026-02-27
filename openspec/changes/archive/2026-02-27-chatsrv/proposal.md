# chatsrv

## Why

对话服务是用户与 AI 交互的入口，通过 SSE 流式对话探索学习主题。

## What Changes

### 1. 对话流

- SSE 流式对话
- 对话历史管理
- 生成确认 (用户确认后创建题库)

### 2. 内部依赖

- 调用 llmsrv 进行 AI 对话
- 调用 contentsrv 保存题库

## Scope

### In Scope

- SSE 流式对话
- 对话历史
- 生成确认
- 内部 API

### Out of Scope

- AI 模型调用 (llmsrv 负责)
- 题库存储 (contentsrv 负责)
