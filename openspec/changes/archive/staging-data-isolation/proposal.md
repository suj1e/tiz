# Staging环境数据隔离配置

## 概述

修改 staging 环境的配置，使其数据存储与 prod 环境完全隔离。

## 背景

当前 staging 和 prod 环境使用相同的数据目录 `/opt/dev/dockermnt/tiz`，存在以下问题：

1. **数据冲突风险** - 两个环境共用同一套 MySQL、Redis、Kafka 等数据
2. **无法并行运行** - 容器名相同，无法同时启动
3. **测试污染** - staging 测试可能影响 prod 数据

## 变更范围

- `infra/envs/staging/.env.example` - 修改默认 DATA_PATH
- `infra/envs/staging/.env` - 创建实际配置文件（不提交到 git）

## 实施方案

### 1. 修改 .env.example 默认路径

将 `DATA_PATH` 从 `/opt/dev/dockermnt/tiz` 改为 `/opt/dev/dockermnt/tiz-staging`

### 2. 创建 .env 文件

基于用户提供的凭证创建 `.env` 文件（此文件在 .gitignore 中，不会被提交）

## 数据隔离架构

```
┌─────────────────────────────────────────────────────────┐
│                      数据存储                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   dev        → Docker managed volumes (自动隔离)        │
│                                                         │
│   staging    → /opt/dev/dockermnt/tiz-staging          │
│                                                         │
│   prod       → /opt/dev/dockermnt/tiz                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 风险评估

- **低风险** - 仅修改配置文件，不影响代码逻辑
- **数据迁移** - 如需保留现有 staging 数据，需要手动迁移到新目录

## 验收标准

- [ ] staging 的 .env.example 中 DATA_PATH 指向独立目录
- [ ] staging 的 .env 文件创建完成
- [ ] `.env` 文件未被 git 追踪
