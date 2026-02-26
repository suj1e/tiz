# 设计文档

## 1. Webhook 配置 API

### 数据模型

```typescript
interface WebhookConfig {
  url: string
  enabled: boolean
  events: ('practice.complete' | 'quiz.complete' | 'library.update')[]
}
```

### API 端点

#### 获取配置

```
GET /api/user/v1/webhook
认证: 是
```

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

#### 保存配置

```
POST /api/user/v1/webhook
认证: 是
```

```json
{
  "url": "https://your-server.com/webhook",
  "enabled": true,
  "events": ["practice.complete", "quiz.complete"]
}
```

#### 删除配置

```
DELETE /api/user/v1/webhook
认证: 是
```

## 2. 题库页交互修复

### 问题

```tsx
// LibraryPage.tsx
<Button>  // 缺少 onClick
  新建题库
</Button>

<LibraryFilter
  // 缺少 onCategoryChange
  // 缺少 onTagToggle
/>
```

### 修复

```tsx
// 传递 store 方法
const { setSelectedCategory, toggleTag } = useLibraryStore()

<Button onClick={() => setCreateOpen(true)}>
  新建题库
</Button>

<LibraryFilter
  onCategoryChange={setSelectedCategory}
  onTagToggle={toggleTag}
/>
```

### 新建题库

简单 Dialog，输入名称后创建空题库（仅 mock 实现）。
