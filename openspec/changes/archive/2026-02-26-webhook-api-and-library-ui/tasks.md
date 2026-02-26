# 任务清单

## API 文档

- [x] 更新 standards/api.md 添加 Webhook 配置接口
  - GET /api/user/v1/webhook
  - POST /api/user/v1/webhook
  - DELETE /api/user/v1/webhook

## 数据库

- [x] 更新 standards/backend.md 添加 webhook_configs 表

## 题库页修复

- [x] 修复 LibraryPage 新建题库按钮
  - 添加 Dialog
  - 添加创建逻辑

- [x] 修复 LibraryPage 筛选交互
  - 传递 onCategoryChange
  - 传递 onTagToggle

## Mock

- [x] 添加 Webhook mock handlers

## 类型和服务

- [x] 添加 WebhookConfig 类型
- [x] 添加 Webhook API 方法
