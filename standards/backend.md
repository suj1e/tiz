# tiz 后端开发规范

## 项目结构

每个 Java 服务都是独立的 Gradle 项目，采用 api + app 子模块结构：

```
tiz-backend/
├── common/                    # 公共模块 (发布到 Maven)
│   ├── svc.sh                 # 服务管理脚本
│   ├── build.gradle.kts
│   └── src/main/java/
│
├── llm-api/                   # LLM API DTOs (发布到 Maven)
│   ├── svc.sh
│   └── src/main/java/
│
├── llm-service/               # AI 服务 (Python/FastAPI)
│   ├── svc.sh
│   ├── pixi.toml              # Pixi 包管理
│   ├── pyproject.toml
│   ├── app/
│   │   ├── main.py            # FastAPI 入口
│   │   ├── config.py
│   │   ├── graphs/            # LangGraph 工作流
│   │   ├── nodes/             # 工作流节点
│   │   ├── llm/               # LLM 客户端
│   │   └── utils/
│   └── tests/
│
├── auth-service/              # 认证服务
│   ├── svc.sh                 # 服务管理脚本
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── settings.gradle.kts    # include("api", "app")
│   ├── api/                   # DTO 和客户端接口
│   │   ├── build.gradle.kts   # maven-publish
│   │   └── src/main/java/
│   └── app/                   # 服务实现
│       ├── build.gradle.kts   # spring-boot
│       └── src/main/java/
│
├── chat-service/              # 对话服务 (api + app)
├── content-service/           # 内容服务 (api + app)
├── practice-service/          # 练习服务 (api + app)
├── quiz-service/              # 测验服务 (api + app)
├── user-service/              # 用户服务 (api + app)
│
└── gateway/                   # API 网关 (无 api 子模块)
    ├── svc.sh
    ├── Dockerfile
    ├── docker-compose.yml
    ├── build.gradle.kts
    └── src/main/java/
```

### api 子模块

- 包含 DTO 类和客户端接口
- 发布到 Maven Local 供其他服务依赖
- 不包含业务逻辑或实现

```kotlin
// api/build.gradle.kts
plugins {
    `java-library`
    `maven-publish`
}

dependencies {
    api("io.github.suj1e:common:1.0.0-SNAPSHOT")
    api("jakarta.validation:jakarta.validation-api:3.0.2")
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            artifactId = "content-api"
        }
    }
}
```

### app 子模块

- 包含服务实现、控制器、业务逻辑
- 依赖本地 api 模块和其他服务的 api

### Version Catalog 依赖管理

项目使用 Gradle Version Catalog 统一管理依赖版本，在 `gradle/libs.versions.toml` 中定义：

```toml
[libraries]
common = { module = "io.github.suj1e:common", version = "1.0.0-SNAPSHOT" }
content-api = { module = "io.github.suj1e:content-api", version = "1.0.0-SNAPSHOT" }
llm-api = { module = "io.github.suj1e:llm-api", version = "1.0.0-SNAPSHOT" }

[plugins]
spring-boot = { id = "org.springframework.boot", version = "3.2.0" }
```

在 `build.gradle.kts` 中使用：

```kotlin
// 使用 version catalog
implementation(libs.common)
implementation(libs.content.api)

// 等同于（不推荐）
implementation("io.github.suj1e:common:1.0.0-SNAPSHOT")
implementation("io.github.suj1e:content-api:1.0.0-SNAPSHOT")
```

```kotlin
// app/build.gradle.kts
plugins {
    java
    alias(libs.plugins.spring.boot)
}

dependencies {
    // 本地 api 模块
    implementation(project(":api"))

    // 使用 version catalog 依赖管理
    implementation(libs.common)
    implementation(libs.content.api)
    implementation(libs.llm.api)

    // Spring Boot Starters
    implementation(libs.spring.boot.starter.web)
    implementation(libs.spring.boot.starter.data.jpa)
    // ...
}
```

### 构建流程

```bash
# 使用 svc.sh 脚本管理单个服务
cd tiz-backend/common
./svc.sh build        # 构建
./svc.sh publish      # 发布到 Maven

cd tiz-backend/auth-service
./svc.sh build        # 构建
./svc.sh :api:publish # 发布 API
./svc.sh run          # 运行服务

# 使用 svc-all.sh 批量管理所有服务
cd tiz
./svc-all.sh publish              # 发布所有 API 模块
./svc-all.sh publish --changed    # 只发布有变更的服务
./svc-all.sh image                # 构建并推送所有镜像
./svc-all.sh image --local        # 本地构建镜像（不推送）
./svc-all.sh status               # 检查所有服务状态
```

## 服务管理脚本

每个服务目录下都有 `svc.sh` 脚本，用于统一管理服务生命周期。

### 单服务管理 (svc.sh)

#### 库模块 (common, llm-api)

```bash
./svc.sh build      # 构建
./svc.sh test       # 运行测试
./svc.sh publish    # 发布到 Maven
./svc.sh version    # 显示版本
./svc.sh validate   # 验证配置
./svc.sh deps       # 查看依赖

# 注意：库模块不支持 run, image, status, logs, rollback, images
```

#### Java 服务 (api + app 结构)

```bash
./svc.sh build              # 构建服务
./svc.sh test               # 运行测试
./svc.sh run [--env ENV]    # 本地运行 (默认: dev)
./svc.sh publish            # 发布 API 到 Maven
./svc.sh image [--local]    # 构建 Docker 镜像
./svc.sh status             # 检查服务健康
./svc.sh logs [N]           # 查看日志 (默认: 100 行)
./svc.sh validate           # 验证配置
./svc.sh version            # 显示版本
./svc.sh version bump       # 升级版本号
./svc.sh tag                # 创建 Git 标签
./svc.sh rollback <v>       # 回滚到指定版本
./svc.sh images [list|clean] # 管理本地镜像
./svc.sh deps [list|update] # 管理依赖
```

#### Python 服务 (llm-service)

```bash
./svc.sh install            # 安装依赖 (pixi)
./svc.sh build              # 构建
./svc.sh test               # 运行测试
./svc.sh run [--env ENV]    # 本地运行
./svc.sh lint               # 代码检查
./svc.sh format             # 格式化代码
./svc.sh publish            # 发布到 PyPI
./svc.sh image [--local]    # 构建 Docker 镜像
./svc.sh status             # 检查服务健康
```

#### 网关服务 (gateway)

```bash
# 与 Java 服务相同，但无 publish 命令（无 API 模块）
./svc.sh build
./svc.sh run
./svc.sh image
./svc.sh status
# ...
```

### 批量管理 (svc-all.sh)

根目录下的 `svc-all.sh` 用于批量操作所有服务：

```bash
# 发布 API 模块 (8 个服务)
./svc-all.sh publish              # 发布所有
./svc-all.sh publish --changed    # 只发布有变更的
./svc-all.sh publish --dry-run    # 预览

# 构建 Docker 镜像 (9 个服务)
./svc-all.sh image                # 构建并推送
./svc-all.sh image --local        # 只构建不推送
./svc-all.sh image --changed      # 只构建有变更的

# 其他命令 (11 个服务)
./svc-all.sh build                # 构建所有
./svc-all.sh test                 # 测试所有
./svc-all.sh validate             # 验证所有
./svc-all.sh status               # 检查可运行服务
./svc-all.sh version              # 显示所有版本
```

### 服务分类

| 类别 | 服务 | publish | image | status | run |
|------|------|:-------:|:-----:|:------:|:---:|
| 库模块 | common, llm-api | ✓ | ✗ | ✗ | ✗ |
| 业务服务 | auth-service, chat-service, content-service, practice-service, quiz-service, user-service | ✓ (api) | ✓ | ✓ | ✓ |
| 网关 | gateway | ✗ | ✓ | ✓ | ✓ |
| Python | llm-service | ✓ (PyPI) | ✓ | ✓ | ✓ |
| 前端 | tiz-web | ✗ | ✓ | ✓ | dev |

### 服务间依赖

| 服务 | 依赖 |
|------|------|
| chat-service | content-api, llm-api |
| practice-service | content-api, llm-api |
| quiz-service | content-api, llm-api |
| gateway | common |

## 微服务架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              gateway (网关)                                  │
│                      Java / Spring Boot / Spring Cloud Gateway              │
│                                   :8080                                     │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
    ┌──────────────────────────┼──────────────────────────┐
    │                          │                          │
    ▼                          ▼                          ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ auth-service  │      │ chat-service  │      │content-service│
│   :8101       │      │   :8102       │      │   :8103       │
│    (Java)     │      │    (Java)     │      │    (Java)     │
└───────────────┘      └───────┬───────┘      └───────────────┘
                               │
                               │ HTTP
                               ▼
                       ┌───────────────┐
                       │  llm-service  │
                       │   :8106       │
                       │  (Python)     │
                       │  LangGraph    │
                       └───────────────┘
                               │
                               ▼
                       ┌───────────────┐
                       │  AI Model     │
                       │ (国产大模型)   │
                       └───────────────┘

    ┌──────────────────────────┼──────────────────────────┐
    │                          │                          │
    ▼                          ▼                          ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│practice-service│     │ quiz-service  │      │ user-service  │
│   :8104       │      │   :8105       │      │   :8107       │
│    (Java)     │      │    (Java)     │      │    (Java)     │
└───────────────┘      └───────────────┘      └───────────────┘
```

## 服务划分

| 服务 | 端口 | 语言 | 职责 | 数据库 |
|------|------|------|------|--------|
| gateway | 8080 | Java | API 网关、路由、鉴权、限流 | - |
| auth-service | 8101 | Java | 用户注册、登录、Token 管理 | users |
| chat-service | 8102 | Java | 对话入口、会话管理 | sessions |
| content-service | 8103 | Java | 题库、题目、分类、标签 | content |
| practice-service | 8104 | Java | 练习记录、答案 | practice |
| quiz-service | 8105 | Java | 测验、结果 | quiz |
| llm-service | 8106 | Python | AI 对话、题目生成、评分 | - |
| user-service | 8107 | Java | 用户设置、偏好 | users |

## AI 服务架构 (llm-service)

### 技术栈

```
Python 3.11+
├── LangGraph      # AI 工作流编排
├── LangChain      # LLM 工具链
├── FastAPI        # HTTP 服务
├── Pydantic       # 数据验证
├── httpx          # HTTP 客户端
└── Pixi           # 包管理
```

### LangGraph 工作流

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LangGraph 工作流                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐             │
│   │  START  │────▶│ 分析意图 │────▶│ 生成回复 │────▶│   END   │             │
│   └─────────┘     └────┬────┘     └─────────┘     └─────────┘             │
│                        │                                                    │
│                        │ 确认生成                                           │
│                        ▼                                                    │
│                  ┌─────────┐     ┌─────────┐     ┌─────────┐              │
│                  │ 提取参数 │────▶│ 生成题目 │────▶│ 返回结果 │              │
│                  └─────────┘     └─────────┘     └─────────┘              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### llm-service 接口

```
POST /internal/ai/chat        # 对话（流式）
POST /internal/ai/generate    # 生成题目
POST /internal/ai/grade       # 简答题评分
```

### chat-service → llm-service 调用

```java
// chat-service 调用 llm-service
@Service
class LlmServiceClient(
    private val webClient: WebClient
) {
    suspend fun chat(sessionId: String?, message: String): Flow<ChatEvent> {
        return webClient.post()
            .uri("http://llm-service:8106/internal/ai/chat")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(mapOf(
                "session_id" to sessionId,
                "message" to message
            ))
            .retrieve()
            .bodyToFlow<ChatEvent>()
    }
}
```

### llm-service 实现

```python
# llm-service/app/main.py
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from langgraph.graph import StateGraph, END
from typing import TypedDict, AsyncGenerator
import json

app = FastAPI()

class ChatState(TypedDict):
    session_id: str | None
    message: str
    history: list[dict]
    response: str
    intent: str
    summary: dict | None

# 定义 LangGraph 工作流
def build_chat_graph():
    workflow = StateGraph(ChatState)

    # 节点
    workflow.add_node("analyze_intent", analyze_intent)
    workflow.add_node("generate_response", generate_response)
    workflow.add_node("extract_params", extract_params)
    workflow.add_node("generate_questions", generate_questions)

    # 边
    workflow.set_entry_point("analyze_intent")
    workflow.add_edge("analyze_intent", "generate_response")
    workflow.add_conditional_edges(
        "generate_response",
        should_generate,
        {
            "generate": "extract_params",
            "end": END
        }
    )
    workflow.add_edge("extract_params", "generate_questions")
    workflow.add_edge("generate_questions", END)

    return workflow.compile()

@app.post("/internal/ai/chat")
async def chat(request: ChatRequest) -> StreamingResponse:
    async def generate() -> AsyncGenerator[str, None]:
        graph = build_chat_graph()

        async for event in graph.astream({
            "session_id": request.session_id,
            "message": request.message,
            "history": []
        }):
            # 转换为 SSE 格式
            yield f"data: {json.dumps(event)}\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream"
    )

@app.post("/internal/ai/generate")
async def generate_questions(request: GenerateRequest) -> dict:
    # 生成题目逻辑
    pass

@app.post("/internal/ai/grade")
async def grade_answer(request: GradeRequest) -> dict:
    # 简答题评分逻辑
    pass
```

### 目录结构

```
llm-service/
├── svc.sh                   # 服务管理脚本
├── pixi.toml                # Pixi 包管理配置
├── pyproject.toml           # Python 项目配置
├── Dockerfile
├── docker-compose.yml
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 入口
│   ├── config.py            # 配置
│   ├── models/
│   │   ├── __init__.py
│   │   ├── chat.py          # 对话模型
│   │   ├── question.py      # 题目模型
│   │   └── grade.py         # 评分模型
│   ├── graphs/
│   │   ├── __init__.py
│   │   ├── chat_graph.py    # 对话工作流
│   │   ├── generate_graph.py# 生成题目工作流
│   │   └── grade_graph.py   # 评分工作流
│   ├── nodes/
│   │   ├── __init__.py
│   │   ├── analyze.py       # 分析意图
│   │   ├── generate.py      # 生成内容
│   │   └── extract.py       # 提取参数
│   ├── llm/
│   │   ├── __init__.py
│   │   └── client.py        # LLM 客户端
│   └── utils/
│       ├── __init__.py
│       └── prompt.py        # Prompt 模板
└── tests/
```

## 服务间通信

### Java ↔ Java

```
方式: HTTP (HttpExchange)
服务发现: Docker DNS / Kubernetes Service
```

### Java ↔ Python (llm-service)

```
方式: HTTP (WebClient)
协议: REST + SSE (流式)
```

## API 路径规范

## API 路径规范

### URL 格式

```
/api/{service}/v1/{resource}

示例:
POST /api/auth/v1/login
GET  /api/content/v1/library
POST /api/quiz/v1/start
```

### 网关路由配置

```yaml
# gateway 路由配置
spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://auth-service
          predicates:
            - Path=/api/auth/**

        - id: chat-service
          uri: lb://chat-service
          predicates:
            - Path=/api/chat/**

        - id: content-service
          uri: lb://content-service
          predicates:
            - Path=/api/content/**

        - id: practice-service
          uri: lb://practice-service
          predicates:
            - Path=/api/practice/**

        - id: quiz-service
          uri: lb://quiz-service
          predicates:
            - Path=/api/quiz/**

        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/user/**
```

## 统一响应结构

### 成功响应

```json
{
  "data": {
    // 业务数据
  }
}
```

### 错误响应

```json
{
  "error": {
    "type": "validation_error",
    "code": "email_exists",
    "message": "该邮箱已被注册"
  }
}
```

### HTTP 状态码

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| 200 | OK | GET/PUT/PATCH/DELETE 成功 |
| 201 | Created | POST 创建成功 |
| 400 | Bad Request | 参数错误 |
| 401 | Unauthorized | 未认证 |
| 403 | Forbidden | 无权限 |
| 404 | Not Found | 资源不存在 |
| 429 | Too Many Requests | 请求过多 |
| 500 | Internal Server Error | 服务器错误 |

### 错误类型

| type | code | message | HTTP |
|------|------|---------|------|
| validation_error | missing_field | 参数缺失 | 400 |
| validation_error | invalid_email | 邮箱格式错误 | 400 |
| validation_error | email_exists | 邮箱已存在 | 400 |
| validation_error | password_too_short | 密码太短 | 400 |
| authentication_error | invalid_credentials | 邮箱或密码错误 | 401 |
| authentication_error | token_invalid | 请重新登录 | 401 |
| authentication_error | token_expired | 登录已过期 | 401 |
| permission_error | forbidden | 无权访问 | 403 |
| not_found_error | user_not_found | 用户不存在 | 404 |
| not_found_error | resource_not_found | 资源不存在 | 404 |
| not_found_error | session_not_found | 会话不存在 | 404 |
| rate_limit_error | too_many_requests | 请求过于频繁 | 429 |
| api_error | internal_error | 服务器错误 | 500 |
| api_error | ai_service_error | AI 服务异常 | 502 |
| api_error | service_unavailable | 服务暂不可用 | 503 |

## 认证规范

### JWT Token

```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Token 验证

```
请求头: Authorization: Bearer <token>

网关验证:
1. 解析 Token
2. 验证签名
3. 验证过期时间
4. 提取用户信息，注入请求头
```

### 请求头注入

```yaml
# 网关将用户信息注入请求头
X-User-Id: xxx
X-User-Email: xxx@example.com
```

## SSE 流式响应

### 响应头

```
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

### 事件格式

```
event: session
data: {"session_id": "xxx"}

event: message
data: {"content": "你好！"}

event: confirm
data: {"summary": {...}}

event: done
data: {}

event: error
data: {"type": "api_error", "code": "ai_service_error", "message": "AI 服务异常"}
```

## 数据库规范

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 表名 | snake_case，复数 | `users`, `knowledge_sets` |
| 字段名 | snake_case | `created_at`, `user_id` |
| 主键 | id | `id` |
| 外键 | {table}_id | `user_id`, `knowledge_set_id` |
| 索引 | idx_{table}_{columns} | `idx_users_email` |
| 唯一索引 | uk_{table}_{columns} | `uk_users_email` |

### 通用字段

```sql
id          VARCHAR(36)   PRIMARY KEY  -- UUID
created_at  TIMESTAMP     NOT NULL     -- 创建时间
updated_at  TIMESTAMP     NOT NULL     -- 更新时间
```

### 表结构示例

```sql
-- 用户表
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    theme VARCHAR(20) DEFAULT 'system',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_email UNIQUE (email)
);

-- 知识集表
CREATE TABLE knowledge_sets (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    difficulty VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 题目表
CREATE TABLE questions (
    id VARCHAR(36) PRIMARY KEY,
    knowledge_set_id VARCHAR(36) NOT NULL,
    type VARCHAR(20) NOT NULL,  -- choice, essay
    content TEXT NOT NULL,
    options JSON,               -- 选择题选项
    answer TEXT NOT NULL,
    explanation TEXT,
    rubric TEXT,                -- 简答题评分标准
    sort_order INT DEFAULT 0,
    FOREIGN KEY (knowledge_set_id) REFERENCES knowledge_sets(id)
);

-- 标签表
CREATE TABLE tags (
    id VARCHAR(36) PRIMARY KEY,
    knowledge_set_id VARCHAR(36) NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (knowledge_set_id) REFERENCES knowledge_sets(id)
);

-- 测验记录表
CREATE TABLE quiz_attempts (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    knowledge_set_id VARCHAR(36) NOT NULL,
    score INT,
    total INT,
    correct_count INT,
    time_spent INT,             -- 秒
    answers JSON,               -- 答题记录
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (knowledge_set_id) REFERENCES knowledge_sets(id)
);

-- Webhook 配置表
CREATE TABLE webhook_configs (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    url VARCHAR(500) NOT NULL,
    enabled BOOLEAN DEFAULT true,
    events JSON NOT NULL,       -- ['practice.complete', 'quiz.complete', 'library.update']
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT uk_webhook_user UNIQUE (user_id)
);
```

## Git 规范

### 分支命名

```
main              主分支
develop           开发分支
feature/xxx       功能分支
fix/xxx           修复分支
refactor/xxx      重构分支
```

### Commit 规范

```
feat: 新增功能
fix: 修复 bug
refactor: 重构
style: 代码格式
docs: 文档
chore: 构建/工具
test: 测试
perf: 性能优化

示例:
feat(auth): 添加用户注册接口
fix(chat): 修复 SSE 连接断开问题
refactor(content): 重构题库查询逻辑
```

## 日志规范

### 日志级别

| 级别 | 使用场景 |
|------|----------|
| ERROR | 错误、异常 |
| WARN | 警告、潜在问题 |
| INFO | 重要业务信息 |
| DEBUG | 调试信息 |

### 日志格式

```json
{
  "timestamp": "2024-02-26T00:00:00Z",
  "level": "INFO",
  "service": "auth-service",
  "trace_id": "xxx",
  "user_id": "xxx",
  "message": "User logged in",
  "context": {
    "email": "user@example.com"
  }
}
```

## 配置管理

### 环境变量模板

每个服务都有 `.env.example` 模板文件，列出所有需要的环境变量：

```bash
cd tiz-backend/auth-service
cp .env.example .env
# 编辑 .env 填入实际值
```

### 环境变量配置

服务通过环境变量配置，每个服务目录下有 `.env.dev`、`.env.staging`、`.env.prod` 文件：

```bash
# 数据库
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:30001/tiz
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=xxx

# Redis
SPRING_DATA_REDIS_HOST=localhost
SPRING_DATA_REDIS_PORT=30002
SPRING_DATA_REDIS_PASSWORD=xxx

# Kafka
SPRING_KAFKA_BOOTSTRAP_SERVERS=localhost:30009

# JWT
JWT_SECRET=xxx

# AI 服务
OPENAI_API_KEY=xxx
OPENAI_API_BASE=https://api.openai.com/v1
```

### 服务配置示例

```yaml
# application.yaml
spring:
  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
  data:
    redis:
      host: ${SPRING_DATA_REDIS_HOST}
      port: ${SPRING_DATA_REDIS_PORT}
      password: ${SPRING_DATA_REDIS_PASSWORD}
```

### 服务配置示例

```yaml
# application.yaml
spring:
  cloud:
    nacos:
      discovery:
        enabled: true
        server-addr: ${NACOS_SERVER_ADDR:localhost:30006}
        namespace: ${NACOS_NAMESPACE:}
      config:
        enabled: true
        server-addr: ${NACOS_SERVER_ADDR:localhost:30006}
        namespace: ${NACOS_NAMESPACE:}
        file-extension: yaml
        refresh-enabled: true
        shared-configs:
          - data-id: common.yaml
            group: DEFAULT_GROUP
            refresh: true
```

## 健康检查

```yaml
# Spring Boot Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

```
GET /actuator/health

{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "redis": { "status": "UP" }
  }
}
```
