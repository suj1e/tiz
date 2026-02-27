# usersrv

## Why

用户服务管理用户设置和 Webhook 配置，与认证服务分离，遵循单一职责原则。

## What Changes

### 1. 用户设置

- 获取/更新用户设置 (主题等)

### 2. Webhook 管理

- CRUD Webhook 配置
- 支持 practice.complete, quiz.complete, library.update 事件

## Scope

### In Scope

- 用户设置管理
- Webhook 配置管理
- 内部 Webhook 查询 API

### Out of Scope

- Webhook 发送逻辑 (各业务服务负责)
