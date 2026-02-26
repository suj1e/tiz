# Tiz 后端微服务开发指南

## 技术栈

| 组件 | 版本 |
|------|------|
| Java | 21 |
| Spring Boot | 4.0.2 |
| Spring Cloud | 2025.1.1 |
| Spring Cloud Alibaba | 2025.1.0.0 |
| Spring Data JPA + QueryDSL | - |
| Spring Security + JWT | jjwt 0.13.0 |
| MySQL | 9.2 |
| Redis | 7.4 |
| Kafka | 7.8 |
| 包名前缀 | `io.github.suj1e` |

## 已完成

1. **common 模块** - 公共代码 (`common/`)
   - ApiResponse / PagedResponse
   - ErrorCode / BusinessException
   - BaseEntity / SoftDeletableEntity
   - HTTP Exchange Clients
   - JwtUtils / 配置类

2. **数据库 DDL** - `infra/config/docker/mysql/init/03-tiz-schema.sql`
   - 无外键约束
   - 8 个服务的表结构

3. **OpenSpec 提案** - `openspec/changes/*/`
   - proposal.md - 提案
   - design.md - 设计文档
   - tasks.md - 任务清单

## 服务列表

| 服务 | 端口 | 职责 | 数据库表 |
|------|------|------|----------|
| gatewaysrv | 8080 | API 网关 | - |
| authsrv | 8101 | 认证、JWT | users, refresh_tokens |
| usersrv | 8107 | 用户设置、Webhook | user_settings, webhooks |
| contentsrv | 8103 | 题库、题目 | knowledge_sets, questions, categories, tags |
| chatsrv | 8102 | 对话、SSE | chat_sessions, chat_messages |
| practicesrv | 8104 | 练习模式 | practice_sessions, practice_answers |
| quizsrv | 8105 | 测验模式 | quiz_sessions, quiz_results, ... |
| llmsrv | 8106 | AI 能力 | - |

## 服务依赖关系

```
llmsrv (无依赖)
    ↓
┌───────────────────────────────────────────┐
│  contentsrv  chatsrv  practicesrv  quizsrv │
│      ↓          ↓          ↓          ↓    │
│      └──────────┴──────────┴──────────┘    │
│                    ↓                       │
│               usersrv                      │
│                    ↓                       │
│              gatewaysrv                    │
│                    ↓                       │
│               authsrv                      │
└───────────────────────────────────────────┘
```

## 开发顺序

**第一批** (无依赖，可并行):
- authsrv
- llmsrv

**第二批** (依赖第一批):
- usersrv
- contentsrv

**第三批** (依赖前两批):
- chatsrv
- practicesrv
- quizsrv

**最后**:
- gatewaysrv

## Worktree 使用

### 首次设置

```bash
# 拉取所有分支
git fetch --all

# 创建本地分支
for branch in authsrv llmsrv usersrv contentsrv chatsrv practicesrv quizsrv gatewaysrv; do
  git checkout -b feature/$branch origin/feature/$branch
done
git checkout main

# 创建 worktrees
./scripts/setup-worktrees.sh
```

### 开发某个服务

```bash
# 进入对应 worktree
cd .claude/worktrees/authsrv

# 开发完成后提交
git add .
git commit -m "feat(authsrv): implement user authentication"
git push origin feature/authsrv
```

### 合并到 main

```bash
# 回到主目录
cd /path/to/tiz

# 合并分支
git checkout main
git merge feature/authsrv
git push origin main
```

## API 规范

### 响应格式

```json
// 成功
{ "data": { ... } }

// 错误
{ "error": { "type": "validation_error", "code": "AUTH_1001", "message": "..." } }
```

### 分页

```json
// 请求
GET /api/content/v1/library?page=1&page_size=10

// 响应
{
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "limit": 10
  }
}
```

### 错误码分配

| 服务 | 前缀 | 范围 |
|------|------|------|
| common | COMMON | 0xxx |
| auth | AUTH | 1xxx |
| user | USER | 2xxx |
| content | CONTENT | 3xxx |
| chat | CHAT | 4xxx |
| practice | PRACTICE | 5xxx |
| quiz | QUIZ | 6xxx |
| llm | LLM | 7xxx |

## 基础设施

```bash
# 启动
cd infra && ./scripts/docker/start-lite.sh

# 访问
MySQL:          localhost:30001 (root/Tiz@2026)
Redis:          localhost:30002 (password: Tiz@2026)
Elasticsearch:  localhost:30003 (elastic/Tiz@2026)
Nacos:          http://localhost:30006 (nacos/nacos)
Kafka:          localhost:30009
Kafka UI:       http://localhost:30010
```

## 给 Claude 的提示词

继续开发时，发送以下内容：

```
请阅读以下文件了解上下文，然后继续开发：

1. BACKEND_DEV.md - 开发指南
2. openspec/changes/authsrv/proposal.md - 认证服务提案
3. openspec/changes/llmsrv/proposal.md - AI 服务提案
4. common/ - 公共模块代码

按照开发顺序，在 worktree 中实现服务。
```
