# webhook-api-and-library-ui

## Why

1. **API 文档不完整**: 设置页已支持 Webhook 配置，但 API 文档中缺少相关接口定义
2. **题库页交互失效**: "新建题库"按钮、分类筛选、标签筛选点击无反应

## What Changes

### 1. API 文档更新

在 `standards/api.md` 用户模块下新增 Webhook 配置接口：

- `GET /api/user/v1/webhook` - 获取配置
- `POST /api/user/v1/webhook` - 保存配置
- `DELETE /api/user/v1/webhook` - 删除配置

### 2. 题库页交互修复

- "新建题库"按钮添加点击事件
- 分类筛选传递 `onCategoryChange`
- 标签筛选传递 `onTagToggle`

### 3. Mock 补充

- MSW handlers 添加 Webhook mock

## Scope

### In Scope

- 更新 API 文档（仅配置接口）
- 修复 LibraryPage 交互
- 添加 Webhook mock handlers

### Out of Scope

- Webhook 发送逻辑（后端内部）
- Webhook payload 格式文档
- 复杂的题库创建流程
