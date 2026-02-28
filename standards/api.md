# tiz API 文档

## 服务架构

每个服务都是独立的 Gradle 项目，采用 api + app 子模块结构：

| 服务 | 端口 | 职责 | 依赖服务 |
|------|------|------|----------|
| gatewaysrv | 8080 | API 网关、路由、鉴权 | - |
| authsrv | 8101 | 用户注册、登录、Token 管理 | - |
| chatsrv | 8102 | 对话入口、会话管理 | llmsrv |
| contentsrv | 8103 | 题库、题目、分类、标签 | llmsrv |
| practicesrv | 8104 | 练习记录、答案 | contentsrv, llmsrv |
| quizsrv | 8105 | 测验、结果 | contentsrv, llmsrv |
| usersrv | 8107 | 用户设置、偏好、Webhook | - |
| llmsrv | 8106 | AI 对话、题目生成、评分 | - |

### 服务间通信

- **Java ↔ Java**: 通过 Maven Local 共享 DTO (xxx-api 模块)
- **Java ↔ llmsrv**: HTTP/WebClient (SSE 流式)

## 概述

- **Base URL**: `/api/v1`
- **认证方式**: Bearer Token (JWT)
- **响应格式**: JSON
- **流式响应**: SSE (Server-Sent Events)

## 认证

除了标注为"否"的接口外，其他接口都需要在请求头中携带 Token：

```
Authorization: Bearer <token>
```

---

## 认证模块 (auth-service)

### 注册

```
POST /api/auth/v1/register
认证: 否
```

**请求体**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**成功响应** `200`

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "created_at": "2024-02-26T00:00:00Z",
      "settings": {
        "theme": "system"
      }
    }
  }
}
```

**错误响应**

| type | code | message | HTTP |
|------|------|---------|------|
| validation_error | email_exists | 该邮箱已被注册 | 400 |
| validation_error | invalid_email | 邮箱格式错误 | 400 |
| validation_error | password_too_short | 密码长度至少8位 | 400 |

---

### 登录

```
POST /api/auth/v1/login
认证: 否
```

**请求体**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**成功响应** `200`

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "created_at": "2024-02-26T00:00:00Z",
      "settings": {
        "theme": "system"
      }
    }
  }
}
```

**错误响应**

| type | code | message | HTTP |
|------|------|---------|------|
| authentication_error | invalid_credentials | 邮箱或密码错误 | 401 |

---

### 登出

```
POST /api/auth/v1/logout
认证: 是
```

**成功响应** `200`

```json
{
  "data": null
}
```

---

### 获取当前用户

```
GET /api/auth/v1/me
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "created_at": "2024-02-26T00:00:00Z",
      "settings": {
        "theme": "system"
      }
    }
  }
}
```

---

## 对话模块 (chat-service)

### 对话探索 (SSE)

```
POST /api/chat/v1/stream
认证: 可选
Content-Type: application/json
Accept: text/event-stream
```

**请求体**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "message": "我想学习 React Hooks"
}
```

> 首次对话 `session_id` 为 `null`，后续传入返回的 `session_id`

**成功响应** `200` (SSE)

```
event: session
data: {"session_id": "550e8400-e29b-41d4-a716-446655440001"}

event: message
data: {"content": "你好！"}

event: message
data: {"content": "想学习 React Hooks 是吧？"}

event: message
data: {"content": "请问你目前的水平是？初级/中级/高级？"}

event: done
data: {}
```

**确认生成时**

```
event: confirm
data: {
  "summary": {
    "title": "React Hooks 面试题",
    "category": "前端开发",
    "tags": ["React", "Hooks"],
    "difficulty": "medium",
    "estimated_count": 15
  }
}

event: done
data: {}
```

**错误事件**

```
event: error
data: {"type": "api_error", "code": "ai_service_error", "message": "AI 服务异常"}
```

---

### 确认生成题目

```
POST /api/chat/v1/confirm
认证: 是
```

**请求体**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "save": true
}
```

**成功响应** `200`

```json
{
  "data": {
    "knowledge_set_id": "550e8400-e29b-41d4-a716-446655440002"
  }
}
```

---

### 获取对话历史

```
GET /api/chat/v1/history/:id
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "messages": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440003",
        "role": "user",
        "content": "我想学习 React Hooks",
        "created_at": "2024-02-26T00:00:00Z"
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440004",
        "role": "assistant",
        "content": "你好！想学习 React Hooks 是吧？",
        "created_at": "2024-02-26T00:00:01Z"
      }
    ]
  }
}
```

---

## 内容模块 (content-service)

### 生成题目

```
POST /api/content/v1/generate
认证: 是
```

**请求体**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "save": true
}
```

**成功响应** `200`

```json
{
  "data": {
    "knowledge_set": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "React Hooks 面试题",
      "category": "前端开发",
      "tags": ["React", "Hooks"],
      "difficulty": "medium"
    },
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "type": "choice",
        "content": "useEffect 的依赖数组为空数组时，回调函数何时执行？",
        "options": [
          "每次渲染后",
          "只在挂载时",
          "只在卸载时",
          "永不执行"
        ],
        "answer": "B",
        "explanation": "useEffect 依赖数组为空时，回调只在组件挂载后执行一次。"
      }
    ],
    "batch": {
      "current": 1,
      "total": 2,
      "has_more": true
    }
  }
}
```

---

### 获取后续批次

```
GET /api/content/v1/generate/:id/batch?page=2
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440006",
        "type": "essay",
        "content": "请解释 useMemo 和 useCallback 的区别",
        "answer": "useMemo 返回缓存的值，useCallback 返回缓存的函数...",
        "rubric": "回答需要包含：1. 两者的作用 2. 使用场景 3. 性能影响"
      }
    ],
    "batch": {
      "current": 2,
      "total": 2,
      "has_more": false
    }
  }
}
```

---

### 获取题库列表

```
GET /api/content/v1/library?page_size=10&page_token=&category=&tag=&keyword=
认证: 是
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page_size | int | 否 | 每页数量，默认 10，最大 100 |
| page_token | string | 否 | 游标，来自上次响应的 next_token |
| category | string | 否 | 分类筛选 |
| tag | string | 否 | 标签筛选 |
| keyword | string | 否 | 关键词搜索 |

**成功响应** `200`

```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "React Hooks 面试题",
      "category": "前端开发",
      "tags": ["React", "Hooks"],
      "difficulty": "medium",
      "question_count": 15,
      "created_at": "2024-02-26T00:00:00Z"
    }
  ],
  "has_more": true,
  "next_token": "eyJpZDoiNTUwZTg0MDAtZTI5Yi00MWRkLWE3MTYtNDQ2NjU1NDQwMDAyIn0="
}
```

**最后一页响应**

```json
{
  "data": [...],
  "has_more": false
}
```

---

### 获取题库详情

```
GET /api/content/v1/library/:id
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "knowledge_set": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "React Hooks 面试题",
      "category": "前端开发",
      "tags": ["React", "Hooks"],
      "difficulty": "medium",
      "created_at": "2024-02-26T00:00:00Z"
    },
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "type": "choice",
        "content": "useEffect 的依赖数组为空数组时...",
        "options": ["...", "...", "...", "..."],
        "answer": "B",
        "explanation": "..."
      }
    ]
  }
}
```

---

### 更新题库

```
PATCH /api/content/v1/library/:id
认证: 是
```

**请求体**

```json
{
  "title": "React Hooks 进阶面试题",
  "category": "前端开发",
  "tags": ["React", "Hooks", "进阶"]
}
```

**成功响应** `200`

```json
{
  "data": {
    "knowledge_set": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "React Hooks 进阶面试题",
      "category": "前端开发",
      "tags": ["React", "Hooks", "进阶"],
      "difficulty": "medium",
      "created_at": "2024-02-26T00:00:00Z"
    }
  }
}
```

---

### 删除题库

```
DELETE /api/content/v1/library/:id
认证: 是
```

**成功响应** `200`

```json
{
  "data": null
}
```

---

### 获取分类列表

```
GET /api/content/v1/categories
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "categories": [
      { "name": "前端开发", "count": 15 },
      { "name": "后端开发", "count": 12 },
      { "name": "数据库", "count": 8 },
      { "name": "系统设计", "count": 5 }
    ]
  }
}
```

---

### 获取标签列表

```
GET /api/content/v1/tags
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "tags": [
      { "name": "React", "count": 25 },
      { "name": "Vue", "count": 18 },
      { "name": "Node.js", "count": 14 },
      { "name": "TypeScript", "count": 22 },
      { "name": "Python", "count": 30 }
    ]
  }
}
```

---

## 练习模块 (practice-service)

### 开始练习

```
POST /api/practice/v1/start
认证: 是
```

**请求体**

```json
{
  "knowledge_set_id": "550e8400-e29b-41d4-a716-446655440002"
}
```

**成功响应** `200`

```json
{
  "data": {
    "practice_id": "550e8400-e29b-41d4-a716-446655440007",
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "type": "choice",
        "content": "useEffect 的依赖数组为空数组时...",
        "options": ["...", "...", "...", "..."]
      }
    ]
  }
}
```

---

### 提交答案

```
POST /api/practice/v1/:id/answer
认证: 是
```

**请求体**

```json
{
  "question_id": "550e8400-e29b-41d4-a716-446655440005",
  "answer": "B"
}
```

**成功响应 (选择题)** `200`

```json
{
  "data": {
    "correct": true,
    "explanation": "useEffect 依赖数组为空时，回调只在组件挂载后执行一次。"
  }
}
```

**成功响应 (简答题)** `200`

```json
{
  "data": {
    "correct": false,
    "score": 80,
    "explanation": "useMemo 返回缓存的值，useCallback 返回缓存的函数...",
    "ai_feedback": "核心概念正确，但可以更详细地说明使用场景。"
  }
}
```

---

### 完成练习

```
POST /api/practice/v1/:id/complete
认证: 是
```

**成功响应** `200`

```json
{
  "data": null
}
```

---

## 测验模块 (quiz-service)

### 开始测验

```
POST /api/quiz/v1/start
认证: 是
```

**请求体**

```json
{
  "knowledge_set_id": "550e8400-e29b-41d4-a716-446655440002",
  "time_limit": 15,
  "question_count": 10
}
```

**成功响应** `200`

```json
{
  "data": {
    "quiz_id": "550e8400-e29b-41d4-a716-446655440008",
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "type": "choice",
        "content": "useEffect 的依赖数组为空数组时...",
        "options": ["...", "...", "...", "..."]
      }
    ],
    "time_limit": 15,
    "started_at": "2024-02-26T00:00:00Z"
  }
}
```

---

### 提交测验

```
POST /api/quiz/v1/:id/submit
认证: 是
```

**请求体**

```json
{
  "answers": [
    {
      "question_id": "550e8400-e29b-41d4-a716-446655440005",
      "answer": "B"
    },
    {
      "question_id": "550e8400-e29b-41d4-a716-446655440006",
      "answer": "useMemo 缓存值，useCallback 缓存函数..."
    }
  ]
}
```

**成功响应** `200`

```json
{
  "data": {
    "result_id": "550e8400-e29b-41d4-a716-446655440009",
    "score": 85,
    "total": 100,
    "correct_count": 8,
    "time_spent": 720
  }
}
```

---

### 获取测验结果

```
GET /api/quiz/v1/result/:id
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "result": {
      "id": "550e8400-e29b-41d4-a716-446655440009",
      "knowledge_set_id": "550e8400-e29b-41d4-a716-446655440002",
      "score": 85,
      "total": 100,
      "correct_count": 8,
      "time_spent": 720,
      "completed_at": "2024-02-26T00:12:00Z",
      "answers": [
        {
          "question_id": "550e8400-e29b-41d4-a716-446655440005",
          "question": {
            "id": "550e8400-e29b-41d4-a716-446655440005",
            "type": "choice",
            "content": "useEffect 的依赖数组为空数组时...",
            "options": ["...", "...", "...", "..."],
            "answer": "B",
            "explanation": "..."
          },
          "user_answer": "B",
          "correct": true
        },
        {
          "question_id": "550e8400-e29b-41d4-a716-446655440006",
          "question": {
            "id": "550e8400-e29b-41d4-a716-446655440006",
            "type": "essay",
            "content": "请解释 useMemo 和 useCallback 的区别",
            "answer": "useMemo 返回缓存的值...",
            "rubric": "..."
          },
          "user_answer": "useMemo 缓存值...",
          "correct": false,
          "score": 80,
          "ai_feedback": "核心概念正确，但可以更详细..."
        }
      ]
    }
  }
}
```

---

## 用户模块 (user-service)

### 获取用户设置

```
GET /api/user/v1/settings
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "settings": {
      "theme": "system"
    }
  }
}
```

---

### 更新用户设置

```
PATCH /api/user/v1/settings
认证: 是
```

**请求体**

```json
{
  "theme": "dark"
}
```

**成功响应** `200`

```json
{
  "data": null
}
```

---

### 获取 Webhook 配置

```
GET /api/user/v1/webhook
认证: 是
```

**成功响应** `200`

```json
{
  "data": {
    "webhook": {
      "url": "https://your-server.com/webhook",
      "enabled": true,
      "events": ["practice.complete", "quiz.complete"]
    }
  }
}
```

**无配置时**

```json
{
  "data": {
    "webhook": null
  }
}
```

---

### 保存 Webhook 配置

```
POST /api/user/v1/webhook
认证: 是
```

**请求体**

```json
{
  "url": "https://your-server.com/webhook",
  "enabled": true,
  "events": ["practice.complete", "quiz.complete", "library.update"]
}
```

**events 可选值**

| 值 | 说明 |
|---|---|
| `practice.complete` | 练习完成 |
| `quiz.complete` | 测验完成 |
| `library.update` | 题库更新 |

**成功响应** `200`

```json
{
  "data": {
    "webhook": {
      "url": "https://your-server.com/webhook",
      "enabled": true,
      "events": ["practice.complete", "quiz.complete"]
    }
  }
}
```

**错误响应**

| type | code | message | HTTP |
|------|------|---------|------|
| validation_error | invalid_url | URL 格式错误 | 400 |

---

### 删除 Webhook 配置

```
DELETE /api/user/v1/webhook
认证: 是
```

**成功响应** `200`

```json
{
  "data": null
}
```

---

## AI 服务接口 (llmsrv - 内部)

> 这些接口仅供内部服务调用，不对外暴露

### 对话 (SSE 流式)

```
POST /internal/ai/chat
调用方: chatsrv
Content-Type: application/json
Accept: text/event-stream
```

**请求体**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "message": "我想学习 React Hooks",
  "history": [
    {
      "role": "user",
      "content": "你好"
    },
    {
      "role": "assistant",
      "content": "你好！想学什么？"
    }
  ]
}
```

> 首次对话 `session_id` 为 `null`

**成功响应** (SSE)

```
event: session
data: {"session_id": "550e8400-e29b-41d4-a716-446655440001"}

event: message
data: {"content": "你好！"}

event: message
data: {"content": "想学习 React Hooks 是吧？"}

event: confirm
data: {
  "summary": {
    "title": "React Hooks 面试题",
    "category": "前端开发",
    "tags": ["React", "Hooks"],
    "difficulty": "medium",
    "estimated_count": 15
  }
}

event: done
data: {}

event: error
data: {"type": "api_error", "code": "ai_service_error", "message": "AI 服务异常"}
```

---

### 生成题目

```
POST /internal/ai/generate
调用方: contentsrv
Content-Type: application/json
```

**请求体**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "batch": {
    "page": 1,
    "page_size": 10
  }
}
```

**成功响应** `200`

```json
{
  "data": {
    "questions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "type": "choice",
        "content": "useEffect 的依赖数组为空数组时，回调函数何时执行？",
        "options": [
          "每次渲染后",
          "只在挂载时",
          "只在卸载时",
          "永不执行"
        ],
        "answer": "B",
        "explanation": "useEffect 依赖数组为空时，回调只在组件挂载后执行一次。"
      }
    ],
    "batch": {
      "current": 1,
      "total": 2,
      "has_more": true
    }
  }
}
```

---

### 简答题评分

```
POST /internal/ai/grade
调用方: practicesrv / quizsrv
Content-Type: application/json
```

**请求体**

```json
{
  "question": {
    "id": "550e8400-e29b-41d4-a716-446655440006",
    "content": "请解释 useMemo 和 useCallback 的区别",
    "answer": "useMemo 返回缓存的值，useCallback 返回缓存的函数...",
    "rubric": "回答需要包含：1. 两者的作用 2. 使用场景 3. 性能影响"
  },
  "user_answer": "useMemo 缓存值，useCallback 缓存函数，都用 memoization 优化性能"
}
```

**成功响应** `200`

```json
{
  "data": {
    "score": 80,
    "max_score": 100,
    "correct": false,
    "feedback": "核心概念正确，但可以更详细地说明使用场景和性能影响。",
    "key_points": [
      {"point": "useMemo 缓存值", "covered": true},
      {"point": "useCallback 缓存函数", "covered": true},
      {"point": "使用场景说明", "covered": false},
      {"point": "性能影响分析", "covered": false}
    ]
  }
}
```

---

## 数据类型

### User

```typescript
interface User {
  id: string
  email: string
  created_at: string
  settings: {
    theme: "light" | "dark" | "system"
  }
}
```

### Message

```typescript
interface Message {
  id: string
  role: "user" | "assistant"
  content: string
  created_at: string
}
```

### Question

```typescript
interface Question {
  id: string
  type: "choice" | "essay"
  content: string
  options?: string[]
  answer: string
  explanation?: string
  rubric?: string
}
```

### KnowledgeSet

```typescript
interface KnowledgeSet {
  id: string
  title: string
  category: string
  tags: string[]
  difficulty: "easy" | "medium" | "hard"
  question_count: number
  created_at: string
}
```

### QuizResult

```typescript
interface QuizResult {
  id: string
  knowledge_set_id: string
  score: number
  total: number
  correct_count: number
  time_spent: number
  completed_at: string
  answers: AnswerRecord[]
}

interface AnswerRecord {
  question_id: string
  question: Question
  user_answer: string
  correct: boolean
  score?: number
  ai_feedback?: string
}
```
