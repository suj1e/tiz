# Tiz Mobile API 接口文档

## 概述

Tiz Mobile 是一款极简主义语言学习应用，具备 AI 驱动功能。本文档描述了应用所需的所有后端 API 接口。

**基础 URL:** `https://api.tiz.app/api/v1`

**API 版本:** `1.0.0`

---

## 后端架构

### 微服务架构

Tiz 后端采用微服务架构，通过 Java API 网关统一对外提供服务：

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter Mobile App                    │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Java API Gateway (Spring Cloud)          │
│                      Path: /api/v1/*                        │
│  - 路由转发 / 服务发现                                        │
│  - 统一认证鉴权 (JWT)                                        │
│  - 限流熔断                                                  │
│  - 请求/响应日志                                            │
└─────┬───────────────────────────────────────────────┬───────┘
      │                                               │
      ▼                                               ▼
┌──────────────────────┐                    ┌──────────────────────┐
│   Java 微服务集群     │                    │   Python 服务集群     │
│  (Spring Boot)       │                    │  (FastAPI)           │
│                      │                    │                      │
│  ┌────────────────┐  │                    │  ┌────────────────┐  │
│  │ auth-service   │  │                    │  │ ai-service      │  │
│  │ 认证授权        │  │                    │  │ AI对话/翻译     │  │
│  └────────────────┘  │                    │  └────────────────┘  │
│                      │                    │                      │
│  ┌────────────────┐  │                    │  ┌────────────────┐  │
│  │ user-service   │  │                    │  │ quiz-service    │  │
│  │ 用户管理        │  │                    │  │ 测验系统        │  │
│  └────────────────┘  │                    │  └────────────────┘  │
│                      │                    │                      │
│  ┌────────────────┐  │                    │  ┌────────────────┐  │
│  │ quiz-service   │  │                    │  │ nlp-service     │  │
│  │ 测验管理        │  │                    │  │ 自然语言处理    │  │
│  └────────────────┘  │                    │  └────────────────┘  │
│                      │                    │                      │
│  ┌────────────────┐  │                    │  ┌────────────────┐  │
│  │ notify-service │  │                    │  │ ml-service      │  │
│  │ 通知服务        │  │                    │  │ 机器学习模型    │  │
│  └────────────────┘  │                    │  └────────────────┘  │
└──────────────────────┘                    └──────────────────────┘
```

### 服务路由规则

| 网关路径 | 目标服务 | 技术栈 | 说明 |
|---------|---------|--------|------|
| `/api/v1/auth/*` | auth-service | Java Spring Boot | 用户认证、JWT 签发 |
| `/api/v1/user/*` | user-service | Java Spring Boot | 用户资料、偏好设置 |
| `/api/v1/quiz/*` | quiz-service | Java Spring Boot | 测验会话管理 |
| `/api/v1/ai/*` | ai-service | Python FastAPI | AI 对话、翻译 |
| `/api/v1/ai/commands/*` | ai-service | Python FastAPI | 指令执行与任务管理 |
| `/api/v1/notifications/*` | notify-service | Java Spring Boot | 通知推送 |
| `/api/v1/history/*` | quiz-service | Java Spring Boot | 历史记录查询 |

### 服务注册与发现

- **注册中心**: Consul / Nacos
- **配置中心**: Spring Cloud Config / Apollo
- **服务调用**: OpenFeign (内部) / REST API (外部)
- **负载均衡**: Spring Cloud LoadBalancer

### 数据存储

| 服务 | 数据库 | 缓存 | 消息队列 |
|-----|--------|------|---------|
| auth-service | PostgreSQL | Redis | - |
| user-service | PostgreSQL | Redis | - |
| quiz-service | PostgreSQL | Redis | Kafka |
| notify-service | MongoDB | Redis | Kafka |
| ai-service | - | Redis | Kafka/RabbitMQ |

### 通信协议

- **外部通信**: HTTPS (REST API)
- **内部通信**: gRPC / REST
- **实时通信**: WebSocket (语音通话、流式响应)

---

## 身份认证

大多数接口需要使用 Bearer token 进行身份认证。

```
Authorization: Bearer {access_token}
```

---

## API 接口

### 1. AI 服务

#### 1.1 聊天对话

AI 对话接口，用于问答和对话。

**接口:** `POST /api/v1/ai/chat`

**目标服务:** ai-service (Python)

**身份认证:** 必需

**请求体:**

```json
{
  "model": "gpt35",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful AI assistant for language learning."
    },
    {
      "role": "user",
      "content": "How do I say 'hello' in Japanese?"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 2048,
  "deep_thinking": false,
  "stream": false
}
```

**请求参数:**

| 字段 | 类型 | 必需 | 说明 |
|-------|------|----------|-------------|
| model | string | 是 | 使用的 AI 模型 (gpt4, gpt35, claude, gemini, local, custom) |
| messages | array | 是 | 消息对象数组 |
| temperature | number | 否 | 采样温度 (0-2)，默认: 0.7 |
| max_tokens | integer | 否 | 最大生成 token 数，默认: 2048 |
| deep_thinking | boolean | 否 | 启用深度思考模式，默认: false |
| stream | boolean | 否 | 启用流式响应，默认: false |

**响应:**

```json
{
  "success": true,
  "data": {
    "id": "chatcmpl-abc123",
    "content": "In Japanese, 'hello' is 'こんにちは' (konnichiwa).",
    "role": "assistant",
    "model": "gpt-3.5-turbo",
    "usage": {
      "prompt_tokens": 20,
      "completion_tokens": 15,
      "total_tokens": 35
    },
    "thinking": null
  }
}
```

**深度思考响应:**

```json
{
  "success": true,
  "data": {
    "id": "chatcmpl-xyz789",
    "content": "Based on the context and formality level...",
    "role": "assistant",
    "model": "gpt-4",
    "thinking": "The user is asking about Japanese greetings. I should consider the formality level and provide appropriate examples.",
    "usage": {
      "prompt_tokens": 20,
      "completion_tokens": 50,
      "total_tokens": 70
    }
  }
}
```

**错误响应:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_API_KEY",
    "message": "Invalid API key provided",
    "status": 401
  }
}
```

---

#### 1.2 翻译

AI 驱动的文本翻译，支持上下文理解。

**接口:** `POST /api/v1/ai/translate`

**目标服务:** ai-service (Python)

**身份认证:** 必需

**请求体:**

```json
{
  "text": "你好，世界",
  "source_lang": "zh",
  "target_lang": "en",
  "enhanced": true,
  "model": "gpt35"
}
```

**请求参数:**

| 字段 | 类型 | 必需 | 说明 |
|-------|------|----------|-------------|
| text | string | 是 | 要翻译的文本 |
| source_lang | string | 是 | 源语言代码 (zh, en, ja, de) |
| target_lang | string | 是 | 目标语言代码 |
| enhanced | boolean | 否 | 启用 AI 上下文增强，默认: false |
| model | string | 否 | 使用的 AI 模型，默认: gpt35 |

**响应:**

```json
{
  "success": true,
  "data": {
    "original_text": "你好，世界",
    "translated_text": "Hello, world",
    "source_lang": "zh",
    "target_lang": "en",
    "confidence": 0.98,
    "alternatives": [
      "Hi, world",
      "Greetings, world"
    ]
  }
}
```

---

#### 1.3 智能推荐

基于用户上下文的个性化学习推荐。

**接口:** `POST /api/v1/ai/recommendations`

**目标服务:** ai-service (Python)

**身份认证:** 必需

**请求体:**

```json
{
  "context": {
    "user_id": "user_123",
    "interests": ["vocabulary", "grammar"],
    "recent_activities": ["translation", "quiz"],
    "current_language": "zh",
    "target_language": "en",
    "proficiency_level": 3
  },
  "limit": 5
}
```

**请求参数:**

| 字段 | 类型 | 必需 | 说明 |
|-------|------|----------|-------------|
| context | object | 是 | 用户上下文信息 |
| limit | integer | 否 | 推荐数量，默认: 5 |

**响应:**

```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "id": "rec_1",
        "title": "每日词汇练习",
        "description": "每天学习10个新单词",
        "type": "vocabulary",
        "relevance": 0.92,
        "action_url": "/quiz/vocabulary"
      },
      {
        "id": "rec_2",
        "title": "语法测验",
        "description": "测试你的语法知识",
        "type": "grammar",
        "relevance": 0.85,
        "action_url": "/quiz/grammar"
      }
    ]
  }
}
```

---

#### 1.4 指令执行

执行自动化指令，带进度跟踪。

**接口:** `POST /api/v1/ai/commands`

**目标服务:** ai-service (Python)

**身份认证:** 必需

**请求体:**

```json
{
  "command": "开始英语测验",
  "context": {
    "category": "english",
    "difficulty": "intermediate"
  }
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "task_id": "task_abc123",
    "command": "开始英语测验",
    "status": "processing",
    "steps": [
      {
        "step": "正在分析学习水平",
        "status": "completed"
      },
      {
        "step": "正在生成测验题目",
        "status": "in_progress",
        "progress": 0.65
      }
    ],
    "estimated_completion": "2024-01-15T10:30:45Z"
  }
}
```

**获取任务状态:**

**接口:** `GET /api/v1/ai/commands/{task_id}`

**响应:**

```json
{
  "success": true,
  "data": {
    "task_id": "task_abc123",
    "status": "completed",
    "result": {
      "quiz_id": "quiz_xyz789",
      "questions_count": 10,
      "estimated_duration": "15 minutes"
    }
  }
}
```

---

### 2. 测验系统

#### 2.1 开始测验会话

初始化新的测验会话。

**接口:** `POST /api/v1/quiz/sessions`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**请求体:**

```json
{
  "category": "english",
  "mode": "choice",
  "difficulty": "intermediate",
  "question_count": 10
}
```

**请求参数:**

| 字段 | 类型 | 必需 | 说明 |
|-------|------|----------|-------------|
| category | string | 是 | 测验类别 (english, japanese, german, mixed) |
| mode | string | 是 | 测验模式 (choice, conversation, voice_call) |
| difficulty | string | 否 | 难度级别 (beginner, intermediate, advanced) |
| question_count | integer | 否 | 题目数量，默认: 10 |

**响应:**

```json
{
  "success": true,
  "data": {
    "session_id": "sess_abc123",
    "category": "english",
    "mode": "choice",
    "total_questions": 10,
    "current_index": 0,
    "started_at": "2024-01-15T10:00:00Z"
  }
}
```

---

#### 2.2 获取测验题目

获取测验会话的下一题。

**接口:** `GET /api/v1/quiz/sessions/{session_id}/question`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "question_id": "q_123",
    "session_id": "sess_abc123",
    "index": 0,
    "total": 10,
    "question": "What is the past tense of 'go'?",
    "options": [
      { "id": "A", "text": "goed" },
      { "id": "B", "text": "went" },
      { "id": "C", "text": "gone" },
      { "id": "D", "text": "goes" }
    ],
    "difficulty": "intermediate",
    "time_limit": 30
  }
}
```

---

#### 2.3 提交测验答案

提交测验题目的答案。

**接口:** `POST /api/v1/quiz/sessions/{session_id}/answer`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**请求体:**

```json
{
  "question_id": "q_123",
  "answer": "B",
  "time_spent": 15
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "question_id": "q_123",
    "is_correct": true,
    "correct_answer": "B",
    "explanation": "The past tense of 'go' is 'went'. This is an irregular verb.",
    "score": 10,
    "current_score": 10,
    "is_last_question": false
  }
}
```

---

#### 2.4 获取测验结果

获取已完成测验会话的最终结果。

**接口:** `GET /api/v1/quiz/sessions/{session_id}/results`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "session_id": "sess_abc123",
    "category": "english",
    "mode": "choice",
    "total_questions": 10,
    "correct_answers": 8,
    "score": 80,
    "duration_seconds": 300,
    "completed_at": "2024-01-15T10:05:00Z",
    "breakdown": [
      {
        "question_id": "q_123",
        "is_correct": true,
        "time_spent": 15
      }
    ]
  }
}
```

---

#### 2.5 语音通话会话

初始化语音通话测验会话。

**接口:** `POST /api/v1/quiz/voice-call`

**目标服务:** quiz-service (Java) + ai-service (Python)

**WebSocket:** `wss://api.tiz.app/api/v1/quiz/voice-call/{session_id}`

**身份认证:** 必需

**请求体:**

```json
{
  "category": "english",
  "difficulty": "intermediate"
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "session_id": "voice_sess_123",
    "status": "initialized",
    "voice_settings": {
      "sample_rate": 16000,
      "encoding": "mp3",
      "language": "en-US"
    },
    "websocket_url": "wss://api.tiz.app/v1/quiz/voice-call/voice_sess_123"
  }
}
```

---

### 3. 用户与认证

#### 3.1 用户注册

创建新用户账户。

**接口:** `POST /api/v1/auth/register`

**目标服务:** auth-service (Java)

**身份认证:** 否

**请求体:**

```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "language": "zh",
  "target_language": "en"
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "user_id": "user_abc123",
    "email": "user@example.com",
    "access_token": "jwt_token_here",
    "refresh_token": "refresh_token_here",
    "expires_in": 3600
  }
}
```

---

#### 3.2 用户登录

认证现有用户。

**接口:** `POST /api/v1/auth/login`

**目标服务:** auth-service (Java)

**身份认证:** 否

**请求体:**

```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "user_id": "user_abc123",
    "email": "user@example.com",
    "access_token": "jwt_token_here",
    "refresh_token": "refresh_token_here",
    "expires_in": 3600
  }
}
```

---

#### 3.3 刷新令牌

使用刷新令牌获取新的访问令牌。

**接口:** `POST /api/v1/auth/refresh`

**目标服务:** auth-service (Java)

**身份认证:** 否

**请求体:**

```json
{
  "refresh_token": "refresh_token_here"
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "access_token": "new_jwt_token_here",
    "expires_in": 3600
  }
}
```

---

#### 3.4 获取用户资料

获取当前用户资料信息。

**接口:** `GET /api/v1/user/profile`

**目标服务:** user-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "user_id": "user_abc123",
    "email": "user@example.com",
    "language": "zh",
    "target_language": "en",
    "proficiency_level": 3,
    "created_at": "2024-01-01T00:00:00Z",
    "preferences": {
      "theme": "light",
      "notifications_enabled": true
    }
  }
}
```

---

#### 3.5 更新用户资料

更新用户资料信息。

**接口:** `PUT /api/v1/user/profile`

**目标服务:** user-service (Java)

**身份认证:** 必需

**请求体:**

```json
{
  "language": "zh",
  "target_language": "en",
  "proficiency_level": 4,
  "preferences": {
    "theme": "dark",
    "notifications_enabled": true
  }
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "user_id": "user_abc123",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

---

### 4. AI 配置

#### 4.1 获取 AI 配置

获取用户的 AI 配置。

**接口:** `GET /api/v1/user/ai-config`

**目标服务:** user-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "model": "gpt35",
    "temperature": 0.7,
    "max_tokens": 2048,
    "system_prompt": "You are a helpful AI assistant.",
    "features": {
      "enhance_translation": true,
      "smart_recommend": true,
      "voice_assistant": false,
      "deep_thinking_mode": false
    }
  }
}
```

---

#### 4.2 更新 AI 配置

更新用户的 AI 配置。

**接口:** `PUT /api/v1/user/ai-config`

**目标服务:** user-service (Java)

**身份认证:** 必需

**请求体:**

```json
{
  "model": "gpt4",
  "temperature": 0.5,
  "max_tokens": 4096,
  "features": {
    "enhance_translation": true,
    "deep_thinking_mode": true
  }
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

---

#### 4.3 存储 API 密钥

安全存储 AI 服务的 API 密钥。

**接口:** `POST /api/v1/user/ai-api-key`

**目标服务:** user-service (Java) - 密钥加密存储

**身份认证:** 必需

**请求体:**

```json
{
  "provider": "openai",
  "api_key": "sk-..."
}
```

**响应:**

```json
{
  "success": true,
  "data": {
    "provider": "openai",
    "key_preview": "sk-...abcd",
    "stored_at": "2024-01-15T10:00:00Z"
  }
}
```

---

### 5. 通知

#### 5.1 获取通知

获取用户通知。

**接口:** `GET /api/v1/notifications`

**目标服务:** notify-service (Java)

**身份认证:** 必需

**查询参数:**

| 参数 | 类型 | 必需 | 说明 |
|-----------|------|----------|-------------|
| limit | integer | 否 | 通知数量，默认: 20 |
| offset | integer | 否 | 分页偏移量，默认: 0 |

**响应:**

```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif_123",
        "type": "translation_complete",
        "title": "翻译完成",
        "message": "您的翻译已完成。",
        "is_read": false,
        "created_at": "2024-01-15T10:00:00Z",
        "action_url": null
      }
    ],
    "unread_count": 3,
    "total_count": 25
  }
}
```

---

#### 5.2 标记通知为已读

将通知标记为已读。

**接口:** `PUT /api/v1/notifications/{notification_id}/read`

**目标服务:** notify-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "notification_id": "notif_123",
    "is_read": true
  }
}
```

---

#### 5.3 全部标记为已读

将所有通知标记为已读。

**接口:** `PUT /api/v1/notifications/read-all`

**目标服务:** notify-service (Java)

**身份认证:** 必需

**响应:**

```json
{
  "success": true,
  "data": {
    "marked_count": 15
  }
}
```

---

### 6. 历史记录与同步

#### 6.1 获取翻译历史

获取用户的翻译历史记录。

**接口:** `GET /api/v1/history/translations`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**查询参数:**

| 参数 | 类型 | 必需 | 说明 |
|-----------|------|----------|-------------|
| limit | integer | 否 | 记录数量，默认: 20 |
| offset | integer | 否 | 分页偏移量 |

**响应:**

```json
{
  "success": true,
  "data": {
    "translations": [
      {
        "id": "trans_123",
        "original_text": "你好，世界",
        "translated_text": "Hello, world",
        "source_lang": "zh",
        "target_lang": "en",
        "created_at": "2024-01-15T10:00:00Z"
      }
    ],
    "total_count": 150
  }
}
```

---

#### 6.2 获取测验历史

获取用户的测验历史记录。

**接口:** `GET /api/v1/history/quizzes`

**目标服务:** quiz-service (Java)

**身份认证:** 必需

**查询参数:**

| 参数 | 类型 | 必需 | 说明 |
|-----------|------|----------|-------------|
| limit | integer | 否 | 记录数量 |
| offset | integer | 否 | 分页偏移量 |

**响应:**

```json
{
  "success": true,
  "data": {
    "quizzes": [
      {
        "session_id": "sess_abc123",
        "category": "english",
        "mode": "choice",
        "score": 80,
        "total_questions": 10,
        "completed_at": "2024-01-15T10:00:00Z"
      }
    ],
    "total_count": 45
  }
}
```

---

## 错误代码

| 代码 | 说明 |
|-----|-------------|
| 400 | 请求参数错误 |
| 401 | 未授权 - 令牌无效或缺失 |
| 402 | 需要付费 - API 配额已用完 |
| 403 | 禁止访问 - 权限不足 |
| 404 | 资源未找到 |
| 429 | 请求过多 - 超出速率限制 |
| 500 | 服务器内部错误 |
| 503 | 服务不可用 - AI 服务宕机 |

---

## 速率限制

网关层统一实施速率限制：

| 接口路径 | 速率限制 |
|----------|------------|
| /api/v1/ai/chat | 60 次/分钟 |
| /api/v1/ai/translate | 100 次/分钟 |
| /api/v1/quiz/sessions | 30 次/分钟 |
| 其他接口 | 200 次/分钟 |

**限流策略**:
- 用户级限流：基于 user_id
- IP级限流：基于 client IP
- Token级限流：基于 JWT token
- 限流算法：令牌桶 (Token Bucket)

---

## Webhook

### 测验完成通知

用户配置的 Webhook URL。

**负载:**

```json
{
  "event": "quiz.completed",
  "timestamp": "2024-01-15T10:00:00Z",
  "data": {
    "user_id": "user_abc123",
    "session_id": "sess_123",
    "score": 85
  }
}
```

---

## SDK 与库

提供官方 SDK:
- Flutter (Dart)
- TypeScript/JavaScript
- Python
- Go

---

## 技术支持

- 文档: https://docs.tiz.app
- 支持邮箱: api-support@tiz.app
- 状态页面: https://status.tiz.app
