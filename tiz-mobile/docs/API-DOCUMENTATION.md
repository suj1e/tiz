# Tiz API 文档

## 概述

Tiz API 是一个为语言学习应用提供的 RESTful API，支持翻译、AI 聊天、测验、通知等功能。

### 基础信息

- **基础 URL**: `https://api.example.com/api/v1`
- **API 版本**: v1
- **数据格式**: JSON
- **字符编码**: UTF-8

### 认证方式

Tiz API 使用 Bearer Token 认证。在请求头中包含：

```
Authorization: Bearer <your_token>
```

获取 token 的方式：
1. 用户登录后，服务器返回 JWT token
2. 使用该 token 访问需要认证的接口
3. Token 过期后，使用 `/auth/refresh` 刷新 token

---

## 目录

1. [认证模块](#1-认证模块)
2. [用户模块](#2-用户模块)
3. [翻译模块](#3-翻译模块)
4. [AI 聊天模块](#4-ai-聊天模块)
5. [测验模块](#5-测验模块)
6. [通知模块](#6-通知模块)
7. [AI 配置模块](#7-ai-配置模块)
8. [指令模块](#8-指令模块)
9. [系统模块](#9-系统模块)

---

## 1. 认证模块

### 1.1 用户登录

**端点**: `POST /auth/login`

**描述**: 用户使用邮箱和密码登录系统

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | 是 | 用户邮箱 |
| password | string | 是 | 用户密码 |

**请求示例**:
```json
{
  "email": "user@tiz.app",
  "password": "password123"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user_001",
      "name": "Tiz 用户",
      "email": "user@tiz.app",
      "avatar": null,
      "bio": "学习语言，探索世界 🌍",
      "joinDate": "2024-01-01T00:00:00Z",
      "studyDays": 45,
      "wordsLearned": 350,
      "quizzesCompleted": 12,
      "streak": 7,
      "level": "intermediate",
      "achievements": ["first_quiz", "word_collector"],
      "languageProgress": {
        "en": 65,
        "ja": 40,
        "de": 25
      }
    }
  }
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "请输入有效的邮箱地址"
}
```

```json
{
  "code": 401,
  "message": "密码错误"
}
```

---

### 1.2 用户注册

**端点**: `POST /auth/register`

**描述**: 新用户注册账号

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 用户姓名 |
| email | string | 是 | 用户邮箱 |
| password | string | 是 | 密码（长度 > 6） |
| confirmPassword | string | 是 | 确认密码 |

**请求示例**:
```json
{
  "name": "张三",
  "email": "zhangsan@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user_002",
      "name": "张三",
      "email": "zhangsan@example.com"
    }
  }
}
```

---

### 1.3 用户登出

**端点**: `POST /auth/logout`

**需要认证**: 是

**描述**: 用户登出，使当前 token 失效

**响应示例**:
```json
{
  "code": 200,
  "message": "登出成功"
}
```

---

### 1.4 刷新 Token

**端点**: `POST /auth/refresh`

**需要认证**: 是

**描述**: 使用即将过期的 token 获取新的 token

**响应示例**:
```json
{
  "code": 200,
  "message": "Token 刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## 2. 用户模块

### 2.1 获取当前用户信息

**端点**: `GET /users/me`

**需要认证**: 是

**描述**: 获取当前登录用户的完整信息

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "user_001",
    "name": "Tiz 用户",
    "email": "user@tiz.app",
    "avatar": null,
    "bio": "学习语言，探索世界 🌍",
    "joinDate": "2024-01-01T00:00:00Z",
    "studyDays": 45,
    "wordsLearned": 350,
    "quizzesCompleted": 12,
    "streak": 7,
    "level": "intermediate",
    "achievements": ["first_quiz", "word_collector"],
    "languageProgress": {
      "en": 65,
      "ja": 40,
      "de": 25
    },
    "totalXP": 5750,
    "levelProgress": 0.45,
    "preferences": {
      "themeMode": "system",
      "defaultLanguage": "zh",
      "favoriteLanguages": ["en", "ja"],
      "enableNotifications": true,
      "enableSoundEffects": true,
      "enableVibration": true,
      "autoPlayAudio": false,
      "dailyGoalMinutes": 30,
      "enableDeepThinking": false
    }
  }
}
```

**用户等级说明**:

| 等级 | 所需 XP | 说明 |
|------|---------|------|
| beginner | 0 | 初学者 |
| elementary | 100 | 初级 |
| intermediate | 500 | 中级 |
| advanced | 1500 | 高级 |
| expert | 3000 | 专家 |

---

### 2.2 更新用户信息

**端点**: `PUT /users/me`

**需要认证**: 是

**描述**: 更新用户的基本信息

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 否 | 用户姓名 |
| bio | string | 否 | 个人简介 |
| avatar | string | 否 | 头像 URL |

**请求示例**:
```json
{
  "name": "新名字",
  "bio": "这是我的个人简介",
  "avatar": "https://example.com/avatar.jpg"
}
```

---

### 2.3 更新用户偏好设置

**端点**: `PUT /users/me/preferences`

**需要认证**: 是

**描述**: 更新用户的偏好设置

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| themeMode | string | 否 | 主题模式: system/light/dark |
| defaultLanguage | string | 否 | 默认语言代码 |
| favoriteLanguages | array | 否 | 常用语言列表 |
| enableNotifications | boolean | 否 | 是否启用通知 |
| enableSoundEffects | boolean | 否 | 是否启用音效 |
| enableVibration | boolean | 否 | 是否启用震动 |
| autoPlayAudio | boolean | 否 | 是否自动播放音频 |
| dailyGoalMinutes | number | 否 | 每日学习目标（分钟） |
| enableDeepThinking | boolean | 否 | 是否启用深度思考 |

---

### 2.4 获取用户成就

**端点**: `GET /users/me/achievements`

**需要认证**: 是

**描述**: 获取用户的所有成就，包括已解锁和未解锁的

**成就列表**:

| ID | 名称 | 说明 | XP 奖励 |
|----|------|------|---------|
| first_quiz | 初次测验 | 完成第一个测验 | 50 |
| quiz_master | 测验达人 | 完成10个测验 | 200 |
| word_collector | 词汇收集者 | 学习100个单词 | 100 |
| streak_week | 坚持一周 | 连续学习7天 | 150 |
| streak_month | 坚持一月 | 连续学习30天 | 500 |
| polyglot | 多语言学习者 | 同时学习3种语言 | 300 |
| perfect_score | 完美表现 | 测验中获得100%分数 | 100 |
| translation_pro | 翻译专家 | 使用翻译功能50次 | 150 |

---

### 2.5 获取学习统计

**端点**: `GET /users/me/stats`

**需要认证**: 是

**Query 参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | string | 否 | 统计周期: day/week/month/year/all |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalXP": 5750,
    "studyDays": 45,
    "wordsLearned": 350,
    "quizzesCompleted": 12,
    "currentStreak": 7,
    "level": "intermediate",
    "levelProgress": 0.45,
    "sessions": [
      {
        "id": "session_001",
        "startTime": "2024-02-08T10:00:00Z",
        "endTime": "2024-02-08T10:15:00Z",
        "type": "quiz",
        "language": "en",
        "durationMinutes": 15,
        "wordsLearned": 5,
        "quizScore": 8,
        "quizTotal": 10
      }
    ]
  }
}
```

---

## 3. 翻译模块

### 3.1 执行翻译

**端点**: `POST /translations/translate`

**需要认证**: 是

**描述**: 执行文本翻译，支持 AI 增强翻译

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sourceText | string | 是 | 待翻译的文本 |
| sourceLanguage | string | 是 | 源语言代码 |
| targetLanguage | string | 是 | 目标语言代码 |
| enhanceWithAI | boolean | 否 | 是否使用 AI 增强翻译（默认: false） |
| model | string | 否 | AI 模型（enhanceWithAI=true 时需要） |

**语言代码**:
- `zh`: 中文
- `en`: 英语
- `ja`: 日语
- `de`: 德语
- `yue`: 粤语
- `ko`: 韩语
- `fr`: 法语

**请求示例**:
```json
{
  "sourceText": "Hello, how are you?",
  "sourceLanguage": "en",
  "targetLanguage": "zh",
  "enhanceWithAI": false
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "翻译成功",
  "data": {
    "id": "trans_001",
    "sourceText": "Hello, how are you?",
    "translatedText": "你好，你好吗？",
    "sourceLanguage": "en",
    "targetLanguage": "zh",
    "timestamp": "2024-02-08T10:00:00Z",
    "enhanced": false,
    "model": null
  }
}
```

---

### 3.2 获取翻译历史

**端点**: `GET /translations/history`

**需要认证**: 是

**Query 参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码（默认: 1） |
| pageSize | number | 否 | 每页数量（默认: 20） |
| sourceLanguage | string | 否 | 筛选源语言 |
| targetLanguage | string | 否 | 筛选目标语言 |

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "items": [
      {
        "id": "trans_001",
        "sourceText": "Hello",
        "translatedText": "你好",
        "sourceLanguage": "en",
        "targetLanguage": "zh",
        "timestamp": "2024-02-08T10:00:00Z",
        "enhanced": false
      }
    ]
  }
}
```

---

### 3.3 保存翻译到收藏

**端点**: `POST /translations/save`

**需要认证**: 是

**请求参数**:
```json
{
  "translationId": "trans_001"
}
```

---

## 4. AI 聊天模块

### 4.1 发送聊天消息

**端点**: `POST /ai/chat`

**需要认证**: 是

**描述**: 发送消息给 AI 助手，获取回复

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sessionId | string | 否 | 继续已有会话的 ID |
| message | string | 是 | 用户消息内容 |
| model | string | 否 | AI 模型（默认: gpt35） |
| enableDeepThinking | boolean | 否 | 是否启用深度思考（默认: false） |
| stream | boolean | 否 | 是否使用流式响应（默认: false） |

**AI 模型选项**:
- `gpt4`: GPT-4（复杂推理，增强翻译）
- `gpt35`: GPT-3.5 Turbo（快速响应）
- `claude`: Claude 3 Opus（长文本分析）
- `gemini`: Gemini Pro（多模态）
- `local`: 本地模型（隐私保护）

**请求示例**:
```json
{
  "message": "如何学习英语单词？",
  "model": "gpt35",
  "enableDeepThinking": false,
  "stream": false
}
```

**响应示例** (非流式):
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "session_001",
    "message": {
      "id": "msg_001",
      "role": "assistant",
      "content": "学习英语单词有很多有效的方法...",
      "timestamp": "2024-02-08T10:00:00Z",
      "isDeepThinking": false,
      "thinkingProcess": null,
      "model": "gpt35"
    }
  }
}
```

---

### 4.2 获取聊天会话列表

**端点**: `GET /ai/chat/sessions`

**需要认证**: 是

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 10,
    "page": 1,
    "pageSize": 20,
    "sessions": [
      {
        "id": "session_001",
        "title": "英语学习方法",
        "createdAt": "2024-02-08T10:00:00Z",
        "lastUpdatedAt": "2024-02-08T10:30:00Z",
        "isPinned": false,
        "messageCount": 15,
        "lastMessage": {
          "role": "assistant",
          "content": "希望这些建议对你有帮助！",
          "timestamp": "2024-02-08T10:30:00Z"
        }
      }
    ]
  }
}
```

---

### 4.3 获取会话详情

**端点**: `GET /ai/chat/sessions/{sessionId}`

**需要认证**: 是

**描述**: 获取指定会话的所有消息历史

---

### 4.4 删除会话

**端点**: `DELETE /ai/chat/sessions/{sessionId}`

**需要认证**: 是

---

### 4.5 清空所有会话

**端点**: `DELETE /ai/chat/sessions`

**需要认证**: 是

---

## 5. 测验模块

### 5.1 获取测验分类

**端点**: `GET /quizzes/categories`

**需要认证**: 是

**描述**: 获取所有可用的测验分类

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
        "icon": "🇬🇧",
        "description": "英语语言测验",
        "questionCount": 100,
        "difficulty": "intermediate"
      },
      {
        "id": "japanese",
        "name": "日语",
        "icon": "🇯🇵",
        "description": "日语语言测验",
        "questionCount": 80,
        "difficulty": "intermediate"
      },
      {
        "id": "german",
        "name": "德语",
        "icon": "🇩🇪",
        "description": "德语语言测验",
        "questionCount": 60,
        "difficulty": "beginner"
      }
    ]
  }
}
```

---

### 5.2 开始测验

**端点**: `POST /quizzes/start`

**需要认证**: 是

**描述**: 开始一个新的测验会话

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | string | 是 | 测验分类: english/japanese/german |
| mode | string | 是 | 测验模式: choice/conversation/voiceCall |
| difficulty | string | 否 | 难度: beginner/intermediate/advanced（默认: intermediate） |
| questionCount | number | 否 | 问题数量（默认: 5，最大: 10） |

**请求示例**:
```json
{
  "category": "english",
  "mode": "choice",
  "difficulty": "intermediate",
  "questionCount": 5
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "测验已开始",
  "data": {
    "sessionId": "quiz_001",
    "category": "english",
    "mode": "choice",
    "difficulty": "intermediate",
    "questionCount": 5,
    "startedAt": "2024-02-08T10:00:00Z",
    "questions": [
      {
        "id": "en1",
        "question": "What is the past tense of \"go\"?",
        "options": [
          "A. goed",
          "B. went",
          "C. gone",
          "D. goes"
        ],
        "difficulty": "beginner"
      }
    ]
  }
}
```

---

### 5.3 提交答案

**端点**: `POST /quizzes/{sessionId}/answer`

**需要认证**: 是

**描述**: 提交当前问题的答案

**请求参数**:
```json
{
  "questionId": "en1",
  "answer": 1
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "答案已提交",
  "data": {
    "isCorrect": true,
    "explanation": "\"Went\" is the irregular past tense of \"go\".",
    "currentScore": 1,
    "currentIndex": 1,
    "isFinished": false
  }
}
```

---

### 5.4 获取测验结果

**端点**: `GET /quizzes/{sessionId}/result`

**需要认证**: 是

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "sessionId": "quiz_001",
    "category": "english",
    "mode": "choice",
    "difficulty": "intermediate",
    "startedAt": "2024-02-08T10:00:00Z",
    "completedAt": "2024-02-08T10:05:00Z",
    "score": 4,
    "total": 5,
    "percentage": 80,
    "passed": true,
    "xpEarned": 200,
    "answers": [
      {
        "questionId": "en1",
        "question": "What is the past tense of \"go\"?",
        "userAnswer": 1,
        "correctAnswer": 1,
        "isCorrect": true,
        "explanation": "\"Went\" is the irregular past tense of \"go\"."
      }
    ]
  }
}
```

**及格标准**: 分数 ≥ 60% 即为通过

---

## 6. 通知模块

### 6.1 获取通知列表

**端点**: `GET /notifications`

**需要认证**: 是

**Query 参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码（默认: 1） |
| pageSize | number | 否 | 每页数量（默认: 20） |
| type | string | 否 | 筛选类型 |
| isRead | boolean | 否 | 筛选已读/未读 |

**通知类型**:
- `translationComplete`: 翻译完成
- `newFeature`: 新功能上线
- `learningReminder`: 学习提醒
- `system`: 系统通知

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 50,
    "unreadCount": 3,
    "page": 1,
    "pageSize": 20,
    "items": [
      {
        "id": "notif_001",
        "title": "翻译完成",
        "body": "已翻译: Hello, how are you?",
        "type": "translationComplete",
        "timestamp": "2024-02-08T10:00:00Z",
        "isRead": false
      },
      {
        "id": "notif_002",
        "title": "新功能上线",
        "body": "欢迎使用 AI深度思考模式功能",
        "type": "newFeature",
        "timestamp": "2024-02-08T09:00:00Z",
        "isRead": false
      }
    ]
  }
}
```

---

### 6.2 标记通知为已读

**端点**: `PUT /notifications/{notificationId}/read`

**需要认证**: 是

---

### 6.3 标记所有通知为已读

**端点**: `PUT /notifications/read-all`

**需要认证**: 是

---

### 6.4 删除通知

**端点**: `DELETE /notifications/{notificationId}`

**需要认证**: 是

---

### 6.5 清空所有通知

**端点**: `DELETE /notifications`

**需要认证**: 是

---

## 7. AI 配置模块

### 7.1 获取 AI 配置

**端点**: `GET /ai/config`

**需要认证**: 是

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "model": "gpt35",
    "temperature": 0.7,
    "maxTokens": 2048,
    "systemPrompt": "You are a helpful AI assistant.",
    "enhanceTranslation": true,
    "smartRecommend": true,
    "voiceAssistant": false,
    "deepThinkingMode": false,
    "lastUpdated": "2024-02-08T10:00:00Z"
  }
}
```

---

### 7.2 更新 AI 配置

**端点**: `PUT /ai/config`

**需要认证**: 是

**请求参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| model | string | 否 | AI 模型 |
| temperature | number | 否 | 温度参数 (0-1) |
| maxTokens | number | 否 | 最大 token 数 |
| systemPrompt | string | 否 | 系统提示词 |
| enhanceTranslation | boolean | 否 | AI 增强翻译 |
| smartRecommend | boolean | 否 | AI 智能推荐 |
| voiceAssistant | boolean | 否 | AI 语音助手 |
| deepThinkingMode | boolean | 否 | 深度思考模式 |

---

### 7.3 设置 API Key

**端点**: `POST /ai/config/api-key`

**需要认证**: 是

**请求参数**:
```json
{
  "model": "gpt35",
  "apiKey": "sk-xxxxxxxxxxxxxxxxxxxxxxxx"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "API Key 已保存",
  "data": {
    "model": "gpt35",
    "isConfigured": true
  }
}
```

---

### 7.4 删除 API Key

**端点**: `DELETE /ai/config/api-key/{model}`

**需要认证**: 是

---

## 8. 指令模块

### 8.1 执行指令

**端点**: `POST /commands/execute`

**需要认证**: 是

**描述**: 执行自然语言指令

**请求参数**:
```json
{
  "command": "制定一个英语学习计划",
  "context": {}
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "指令执行成功",
  "data": {
    "taskId": "task_001",
    "command": "制定一个英语学习计划",
    "status": "running",
    "progress": 0.5,
    "currentStep": "正在分析用户水平...",
    "result": null
  }
}
```

---

### 8.2 获取任务状态

**端点**: `GET /commands/tasks/{taskId}`

**需要认证**: 是

**任务状态**:
- `pending`: 等待中
- `running`: 执行中
- `completed`: 已完成
- `failed`: 失败

---

### 8.3 获取指令历史

**端点**: `GET /commands/history`

**需要认证**: 是

---

## 9. 系统模块

### 9.1 获取应用配置

**端点**: `GET /system/config`

**需要认证**: 否

**描述**: 获取应用公共配置（无需认证）

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "appVersion": "1.0.0",
    "supportedLanguages": [
      {
        "code": "zh",
        "name": "Chinese",
        "nativeName": "中文"
      },
      {
        "code": "en",
        "name": "English",
        "nativeName": "English"
      },
      {
        "code": "ja",
        "name": "Japanese",
        "nativeName": "日本語"
      }
    ],
    "supportedModels": [
      {
        "id": "gpt35",
        "name": "GPT-3.5 Turbo",
        "description": "快速响应，简单问答",
        "requiresApiKey": true,
        "supportsDeepThinking": false
      },
      {
        "id": "gpt4",
        "name": "GPT-4",
        "description": "复杂推理，增强翻译",
        "requiresApiKey": true,
        "supportsDeepThinking": true
      }
    ],
    "features": {
      "aiChat": true,
      "voiceCall": true,
      "commandAutomation": true
    }
  }
}
```

---

### 9.2 健康检查

**端点**: `GET /system/health`

**需要认证**: 否

**描述**: 系统健康检查（无需认证）

**响应示例**:
```json
{
  "code": 200,
  "message": "healthy",
  "data": {
    "status": "healthy",
    "timestamp": "2024-02-08T10:00:00Z",
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

### 成功响应

```json
{
  "code": 200,
  "message": "success",
  "data": { /* 响应数据 */ }
}
```

### 错误响应

```json
{
  "code": 400,
  "message": "错误描述",
  "error": {
    "type": "VALIDATION_ERROR",
    "details": { /* 错误详情 */ }
  }
}
```

### 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（token 无效或过期） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |
| 503 | 服务不可用 |

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
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "items": [ /* 数据项 */ ]
  }
}
```

---

## 更新日志

### v1.0.0 (2024-02-08)
- 初始版本发布
- 支持用户认证、翻译、AI 聊天、测验、通知等核心功能

---

## 联系方式

- **技术支持**: support@tiz.app
- **API 文档**: https://docs.tiz.app/api
- **问题反馈**: https://github.com/tiz/app/issues

---

**生成时间**: 2026-02-08
**API 版本**: v1
**文档版本**: 1.0.0
