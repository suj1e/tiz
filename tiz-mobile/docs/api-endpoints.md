# Tiz API 端点清单

基于 Flutter 代码分析，以下是所有需要后端 API 支持的功能端点。

## 基础信息

- **基础 URL**: `/api/v1`
- **认证方式**: Bearer Token
- **请求头**:
  - `Authorization`: `Bearer {{token}}`
  - `Content-Type`: `application/json`

---

## 1. 认证模块 (`/auth`)

### 1.1 用户登录

**端点**: `POST /api/v1/auth/login`

**描述**: 用户使用邮箱和密码登录

**请求参数**:
```json
{
  "email": "string (必填)",
  "password": "string (必填)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "string (JWT token)",
    "user": {
      "id": "string",
      "name": "string",
      "email": "string",
      "avatar": "string | null",
      "bio": "string | null",
      "joinDate": "ISO8601 datetime",
      "studyDays": "number",
      "wordsLearned": "number",
      "quizzesCompleted": "number",
      "streak": "number",
      "level": "beginner|elementary|intermediate|advanced|expert",
      "achievements": ["string"],
      "languageProgress": {
        "en": "number",
        "ja": "number",
        "de": "number"
      }
    }
  }
}
```

**错误码**:
- `400`: 邮箱格式无效
- `401`: 密码错误
- `404`: 用户不存在

---

### 1.2 用户注册

**端点**: `POST /api/v1/auth/register`

**描述**: 新用户注册

**请求参数**:
```json
{
  "name": "string (必填)",
  "email": "string (必填)",
  "password": "string (必填, 长度>6)",
  "confirmPassword": "string (必填)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "token": "string (JWT token)",
    "user": {
      "id": "string",
      "name": "string",
      "email": "string"
    }
  }
}
```

**错误码**:
- `400`: 参数验证失败（姓名为空、邮箱格式、密码长度、密码不匹配）
- `409`: 邮箱已注册

---

### 1.3 用户登出

**端点**: `POST /api/v1/auth/logout`

**描述**: 用户登出，使 token 失效

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "登出成功"
}
```

---

### 1.4 刷新 Token

**端点**: `POST /api/v1/auth/refresh`

**描述**: 使用过期 token 获取新 token

**请求头**:
- `Authorization`: `Bearer {{expired_token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "Token 刷新成功",
  "data": {
    "token": "string (new JWT token)"
  }
}
```

---

## 2. 用户模块 (`/users`)

### 2.1 获取当前用户信息

**端点**: `GET /api/v1/users/me`

**描述**: 获取当前登录用户的详细信息

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "name": "string",
    "email": "string",
    "avatar": "string | null",
    "bio": "string | null",
    "joinDate": "ISO8601 datetime",
    "studyDays": "number",
    "wordsLearned": "number",
    "quizzesCompleted": "number",
    "streak": "number",
    "level": "string",
    "achievements": ["string"],
    "languageProgress": {
      "en": "number",
      "ja": "number",
      "de": "number"
    },
    "preferences": {
      "themeMode": "system|light|dark",
      "defaultLanguage": "string",
      "favoriteLanguages": ["string"],
      "enableNotifications": "boolean",
      "enableSoundEffects": "boolean",
      "enableVibration": "boolean",
      "autoPlayAudio": "boolean",
      "dailyGoalMinutes": "number",
      "enableDeepThinking": "boolean"
    }
  }
}
```

---

### 2.2 更新用户信息

**端点**: `PUT /api/v1/users/me`

**描述**: 更新当前用户信息

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "name": "string (可选)",
  "bio": "string (可选)",
  "avatar": "string (可选, URL)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "user": { /* 用户对象 */ }
  }
}
```

---

### 2.3 更新用户偏好设置

**端点**: `PUT /api/v1/users/me/preferences`

**描述**: 更新用户偏好设置

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "themeMode": "system|light|dark (可选)",
  "defaultLanguage": "string (可选)",
  "favoriteLanguages": ["string"] (可选),
  "enableNotifications": "boolean (可选)",
  "enableSoundEffects": "boolean (可选)",
  "enableVibration": "boolean (可选)",
  "autoPlayAudio": "boolean (可选)",
  "dailyGoalMinutes": "number (可选)",
  "enableDeepThinking": "boolean (可选)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "偏好设置已更新",
  "data": {
    "preferences": { /* 偏好设置对象 */ }
  }
}
```

---

### 2.4 获取用户成就

**端点**: `GET /api/v1/users/me/achievements`

**描述**: 获取用户的所有成就（已解锁和未解锁）

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "unlocked": [
      {
        "id": "string",
        "title": "string",
        "description": "string",
        "icon": "string",
        "xpReward": "number",
        "unlockedAt": "ISO8601 datetime"
      }
    ],
    "locked": [
      {
        "id": "string",
        "title": "string",
        "description": "string",
        "icon": "string",
        "xpReward": "number"
      }
    ]
  }
}
```

---

### 2.5 获取学习统计

**端点**: `GET /api/v1/users/me/stats`

**描述**: 获取用户学习统计数据

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `period`: `day|week|month|year|all` (可选，默认: all)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalXP": "number",
    "studyDays": "number",
    "wordsLearned": "number",
    "quizzesCompleted": "number",
    "currentStreak": "number",
    "level": "string",
    "levelProgress": "number (0-1)",
    "sessions": [
      {
        "id": "string",
        "startTime": "ISO8601 datetime",
        "endTime": "ISO8601 datetime | null",
        "type": "translation|quiz|conversation|vocabulary|grammar|dialect",
        "language": "string | null",
        "durationMinutes": "number",
        "wordsLearned": "number",
        "quizScore": "number | null",
        "quizTotal": "number | null"
      }
    ]
  }
}
```

---

## 3. 翻译模块 (`/translations`)

### 3.1 执行翻译

**端点**: `POST /api/v1/translations/translate`

**描述**: 执行文本翻译，支持 AI 增强翻译

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "sourceText": "string (必填)",
  "sourceLanguage": "string (必填, zh|en|ja|de|yue|ko|fr)",
  "targetLanguage": "string (必填, zh|en|ja|de|yue|ko|fr)",
  "enhanceWithAI": "boolean (可选, 默认: false)",
  "model": "string (可选, gpt4|gpt35|claude|gemini, enhanceWithAI=true 时需要)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "翻译成功",
  "data": {
    "id": "string",
    "sourceText": "string",
    "translatedText": "string",
    "sourceLanguage": "string",
    "targetLanguage": "string",
    "timestamp": "ISO8601 datetime",
    "enhanced": "boolean",
    "model": "string | null"
  }
}
```

---

### 3.2 获取翻译历史

**端点**: `GET /api/v1/translations/history`

**描述**: 获取用户的翻译历史记录

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)
- `sourceLanguage`: `string` (可选，筛选源语言)
- `targetLanguage`: `string` (可选，筛选目标语言)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "page": "number",
    "pageSize": "number",
    "items": [
      {
        "id": "string",
        "sourceText": "string",
        "translatedText": "string",
        "sourceLanguage": "string",
        "targetLanguage": "string",
        "timestamp": "ISO8601 datetime",
        "enhanced": "boolean"
      }
    ]
  }
}
```

---

### 3.3 保存翻译

**端点**: `POST /api/v1/translations/save`

**描述**: 保存翻译记录到收藏

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "translationId": "string (必填)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "已保存"
}
```

---

### 3.4 获取收藏的翻译

**端点**: `GET /api/v1/translations/favorites`

**描述**: 获取用户收藏的翻译列表

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "page": "number",
    "pageSize": "number",
    "items": [ /* 翻译对象数组 */ ]
  }
}
```

---

## 4. AI 聊天模块 (`/ai`)

### 4.1 发送聊天消息

**端点**: `POST /api/v1/ai/chat`

**描述**: 发送消息给 AI 助手，获取回复

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "sessionId": "string (可选, 继续已有会话)",
  "message": "string (必填)",
  "model": "string (可选, 默认: gpt35)",
  "enableDeepThinking": "boolean (可选, 默认: false)",
  "stream": "boolean (可选, 默认: false)"
}
```

**响应示例** (非流式):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "string",
    "message": {
      "id": "string",
      "role": "assistant",
      "content": "string",
      "timestamp": "ISO8601 datetime",
      "isDeepThinking": "boolean",
      "thinkingProcess": "string | null",
      "model": "string"
    }
  }
}
```

**响应示例** (流式):
```
SSE 流，每个事件包含:
data: {"id": "string", "role": "assistant", "content": "partial content", ...}
```

---

### 4.2 获取聊天会话历史

**端点**: `GET /api/v1/ai/chat/sessions`

**描述**: 获取用户的所有聊天会话列表

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "page": "number",
    "pageSize": "number",
    "sessions": [
      {
        "id": "string",
        "title": "string",
        "createdAt": "ISO8601 datetime",
        "lastUpdatedAt": "ISO8601 datetime | null",
        "isPinned": "boolean",
        "messageCount": "number",
        "lastMessage": {
          "role": "user|assistant",
          "content": "string",
          "timestamp": "ISO8601 datetime"
        }
      }
    ]
  }
}
```

---

### 4.3 获取会话详情

**端点**: `GET /api/v1/ai/chat/sessions/{sessionId}`

**描述**: 获取指定会话的所有消息

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "session": {
      "id": "string",
      "title": "string",
      "createdAt": "ISO8601 datetime",
      "lastUpdatedAt": "ISO8601 datetime | null",
      "isPinned": "boolean"
    },
    "messages": [
      {
        "id": "string",
        "role": "user|assistant|system",
        "content": "string",
        "timestamp": "ISO8601 datetime",
        "isDeepThinking": "boolean",
        "thinkingProcess": "string | null"
      }
    ]
  }
}
```

---

### 4.4 删除会话

**端点**: `DELETE /api/v1/ai/chat/sessions/{sessionId}`

**描述**: 删除指定的聊天会话

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "会话已删除"
}
```

---

### 4.5 清空所有会话

**端点**: `DELETE /api/v1/ai/chat/sessions`

**描述**: 清空用户的所有聊天会话

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "所有会话已清空"
}
```

---

## 5. 测验模块 (`/quizzes`)

### 5.1 获取测验分类列表

**端点**: `GET /api/v1/quizzes/categories`

**描述**: 获取所有可用的测验分类

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "categories": [
      {
        "id": "english",
        "name": "英语",
        "icon": "string",
        "description": "string",
        "questionCount": "number",
        "difficulty": "beginner|intermediate|advanced"
      },
      {
        "id": "japanese",
        "name": "日语",
        ...
      },
      {
        "id": "german",
        "name": "德语",
        ...
      }
    ]
  }
}
```

---

### 5.2 开始测验

**端点**: `POST /api/v1/quizzes/start`

**描述**: 开始一个新的测验会话

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "category": "english|japanese|german (必填)",
  "mode": "choice|conversation|voiceCall (必填)",
  "difficulty": "beginner|intermediate|advanced (可选, 默认: intermediate)",
  "questionCount": "number (可选, 默认: 5, 最大: 10)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "测验已开始",
  "data": {
    "sessionId": "string",
    "category": "string",
    "mode": "string",
    "difficulty": "string",
    "questionCount": "number",
    "questions": [
      {
        "id": "string",
        "question": "string",
        "options": ["string"],
        "difficulty": "string"
      }
    ],
    "startedAt": "ISO8601 datetime"
  }
}
```

---

### 5.3 提交答案

**端点**: `POST /api/v1/quizzes/{sessionId}/answer`

**描述**: 提交当前问题的答案

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "questionId": "string (必填)",
  "answer": "number (必填, 选项索引, 从0开始)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "答案已提交",
  "data": {
    "isCorrect": "boolean",
    "explanation": "string",
    "currentScore": "number",
    "currentIndex": "number",
    "isFinished": "boolean"
  }
}
```

---

### 5.4 获取测验结果

**端点**: `GET /api/v1/quizzes/{sessionId}/result`

**描述**: 获取测验的最终结果

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "string",
    "category": "string",
    "mode": "string",
    "difficulty": "string",
    "startedAt": "ISO8601 datetime",
    "completedAt": "ISO8601 datetime",
    "score": "number",
    "total": "number",
    "percentage": "number",
    "passed": "boolean",
    "xpEarned": "number",
    "answers": [
      {
        "questionId": "string",
        "question": "string",
        "userAnswer": "number | null",
        "correctAnswer": "number",
        "isCorrect": "boolean",
        "explanation": "string"
      }
    ]
  }
}
```

---

### 5.5 获取测验历史

**端点**: `GET /api/v1/quizzes/history`

**描述**: 获取用户的测验历史记录

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)
- `category`: `string` (可选，筛选分类)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "page": "number",
    "pageSize": "number",
    "items": [
      {
        "sessionId": "string",
        "category": "string",
        "mode": "string",
        "score": "number",
        "total": "number",
        "percentage": "number",
        "passed": "boolean",
        "completedAt": "ISO8601 datetime"
      }
    ]
  }
}
```

---

## 6. 通知模块 (`/notifications`)

### 6.1 获取通知列表

**端点**: `GET /api/v1/notifications`

**描述**: 获取用户的通知列表

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)
- `type`: `translationComplete|newFeature|learningReminder|system` (可选，筛选类型)
- `isRead`: `boolean` (可选，筛选已读/未读)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "unreadCount": "number",
    "page": "number",
    "pageSize": "number",
    "items": [
      {
        "id": "string",
        "title": "string",
        "body": "string",
        "type": "translationComplete|newFeature|learningReminder|system",
        "timestamp": "ISO8601 datetime",
        "isRead": "boolean"
      }
    ]
  }
}
```

---

### 6.2 标记通知为已读

**端点**: `PUT /api/v1/notifications/{notificationId}/read`

**描述**: 将指定通知标记为已读

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "通知已标记为已读",
  "data": {
    "notification": { /* 通知对象 */ }
  }
}
```

---

### 6.3 标记所有通知为已读

**端点**: `PUT /api/v1/notifications/read-all`

**描述**: 将所有未读通知标记为已读

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "所有通知已标记为已读",
  "data": {
    "updatedCount": "number"
  }
}
```

---

### 6.4 删除通知

**端点**: `DELETE /api/v1/notifications/{notificationId}`

**描述**: 删除指定通知

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "通知已删除"
}
```

---

### 6.5 清空所有通知

**端点**: `DELETE /api/v1/notifications`

**描述**: 清空用户的所有通知

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "所有通知已清空"
}
```

---

## 7. AI 配置模块 (`/ai/config`)

### 7.1 获取 AI 配置

**端点**: `GET /api/v1/ai/config`

**描述**: 获取用户的 AI 配置

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "model": "gpt4|gpt35|claude|gemini|local|custom",
    "temperature": "number",
    "maxTokens": "number",
    "systemPrompt": "string",
    "enhanceTranslation": "boolean",
    "smartRecommend": "boolean",
    "voiceAssistant": "boolean",
    "deepThinkingMode": "boolean",
    "lastUpdated": "ISO8601 datetime | null"
  }
}
```

---

### 7.2 更新 AI 配置

**端点**: `PUT /api/v1/ai/config`

**描述**: 更新用户的 AI 配置

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "model": "string (可选)",
  "temperature": "number (可选, 0-1)",
  "maxTokens": "number (可选)",
  "systemPrompt": "string (可选)",
  "enhanceTranslation": "boolean (可选)",
  "smartRecommend": "boolean (可选)",
  "voiceAssistant": "boolean (可选)",
  "deepThinkingMode": "boolean (可选)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "AI 配置已更新",
  "data": {
    "config": { /* 配置对象 */ }
  }
}
```

---

### 7.3 设置 API Key

**端点**: `POST /api/v1/ai/config/api-key`

**描述**: 设置或更新 AI 服务的 API Key（加密存储）

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "model": "gpt4|gpt35|claude|gemini|custom (必填)",
  "apiKey": "string (必填)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "API Key 已保存",
  "data": {
    "model": "string",
    "isConfigured": "boolean"
  }
}
```

---

### 7.4 删除 API Key

**端点**: `DELETE /api/v1/ai/config/api-key/{model}`

**描述**: 删除指定模型的 API Key

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "API Key 已删除"
}
```

---

## 8. 指令模块 (`/commands`)

### 8.1 执行指令

**端点**: `POST /api/v1/commands/execute`

**描述**: 执行自然语言指令

**请求头**:
- `Authorization`: `Bearer {{token}}`

**请求参数**:
```json
{
  "command": "string (必填)",
  "context": "object (可选, 额外上下文信息)"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "指令执行成功",
  "data": {
    "taskId": "string",
    "command": "string",
    "status": "pending|running|completed|failed",
    "progress": "number (0-1)",
    "currentStep": "string",
    "result": "object | null"
  }
}
```

---

### 8.2 获取指令执行状态

**端点**: `GET /api/v1/commands/tasks/{taskId}`

**描述**: 获取指令执行任务的状态

**请求头**:
- `Authorization`: `Bearer {{token}}`

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "taskId": "string",
    "command": "string",
    "status": "running",
    "progress": "number",
    "currentStep": "string",
    "steps": [
      {
        "name": "string",
        "status": "pending|running|completed|failed",
        "result": "object | null"
      }
    ],
    "result": "object | null",
    "error": "string | null",
    "createdAt": "ISO8601 datetime",
    "completedAt": "ISO8601 datetime | null"
  }
}
```

---

### 8.3 获取指令历史

**端点**: `GET /api/v1/commands/history`

**描述**: 获取用户的指令执行历史

**请求头**:
- `Authorization`: `Bearer {{token}}`

**Query 参数**:
- `page`: `number` (可选，默认: 1)
- `pageSize`: `number` (可选，默认: 20)
- `status`: `pending|running|completed|failed` (可选)

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "number",
    "page": "number",
    "pageSize": "number",
    "items": [
      {
        "taskId": "string",
        "command": "string",
        "status": "string",
        "progress": "number",
        "createdAt": "ISO8601 datetime",
        "completedAt": "ISO8601 datetime | null"
      }
    ]
  }
}
```

---

## 9. 系统模块 (`/system`)

### 9.1 获取应用配置

**端点**: `GET /api/v1/system/config`

**描述**: 获取应用公共配置（无需认证）

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "appVersion": "string",
    "supportedLanguages": [
      {
        "code": "string",
        "name": "string",
        "nativeName": "string"
      }
    ],
    "supportedModels": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "requiresApiKey": "boolean",
        "supportsDeepThinking": "boolean"
      }
    ],
    "features": {
      "aiChat": "boolean",
      "voiceCall": "boolean",
      "commandAutomation": "boolean"
    }
  }
}
```

---

### 9.2 健康检查

**端点**: `GET /api/v1/system/health`

**描述**: 系统健康检查（无需认证）

**响应示例**:
```json
{
  "code": 200,
  "message": "healthy",
  "data": {
    "status": "healthy",
    "timestamp": "ISO8601 datetime",
    "services": {
      "api": "healthy",
      "database": "healthy",
      "ai": "healthy",
      "storage": "healthy"
    }
  }
}
```

---

## 通用响应格式

所有 API 响应遵循以下格式：

**成功响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": { /* 响应数据 */ }
}
```

**错误响应**:
```json
{
  "code": 400|401|403|404|500,
  "message": "错误描述",
  "error": {
    "type": "string (错误类型)",
    "details": "object (错误详情)"
  }
}
```

**通用错误码**:
- `400`: 请求参数错误
- `401`: 未授权（token 无效或过期）
- `403`: 禁止访问
- `404`: 资源不存在
- `409`: 资源冲突
- `429`: 请求过于频繁
- `500`: 服务器内部错误
- `503`: 服务不可用

---

## 分页格式

列表类 API 支持分页：

**Query 参数**:
- `page`: 页码（从 1 开始）
- `pageSize`: 每页数量（默认 20，最大 100）

**响应格式**:
```json
{
  "data": {
    "total": "number (总数)",
    "page": "number (当前页)",
    "pageSize": "number (每页数量)",
    "items": [ /* 数据项 */ ]
  }
}
```

---

## 语言代码

支持的语言代码：
- `zh`: 中文
- `en`: 英语
- `ja`: 日语
- `de`: 德语
- `yue`: 粤语
- `ko`: 韩语
- `fr`: 法语

---

## AI 模型

支持的 AI 模型：
- `gpt4`: GPT-4
- `gpt35`: GPT-3.5 Turbo
- `claude`: Claude 3 Opus
- `gemini`: Gemini Pro
- `local`: 本地模型
- `custom`: 自定义 API

---

## 更新时间

**生成时间**: 2026-02-08
**基于代码**: tiz-mobile Flutter 项目
