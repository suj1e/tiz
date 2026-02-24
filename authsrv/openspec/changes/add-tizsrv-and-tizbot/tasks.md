# Tasks: add-tizsrv-and-tizbot

## 1. Tizsrv - 服务生成

- [x] 1.1 使用 panck 生成 tizsrv 服务骨架
- [x] 1.2 配置 Nacos 服务注册
- [x] 1.3 配置 MySQL/Redis/Kafka 连接
- [x] 1.4 运行 tizsrv 验证启动

## 2. Tizsrv - 通知功能 (Inbox)

- [x] 2.1 创建 Notification 实体和 Repository
- [x] 2.2 实现 NotificationDomainService
- [x] 2.3 实现 NotificationController (GET /notifications)
- [x] 2.4 实现标记已读接口

## 3. Tizsrv - 内容功能 (Explore)

- [x] 3.1 创建 Content 实体和 Repository
- [x] 3.2 实现 ContentDomainService
- [x] 3.3 实现 ContentController (GET /contents, GET /categories)
- [x] 3.4 实现搜索功能

## 4. Tizbot - 项目初始化

- [x] 4.1 创建 tizbot Python 项目
- [x] 4.2 安装 LangGraph, FastAPI, uvicorn
- [x] 4.3 配置 LLM Provider (OpenAI/Gemini)

## 5. Tizbot - LangGraph Agent

- [x] 5.1 设计 Agent 图结构
- [x] 5.2 实现节点 (LLM 调用, 工具, 内存)
- [x] 5.3 实现边 (条件路由)
- [x] 5.4 实现多轮对话上下文

## 6. Tizbot - Chat API

- [x] 6.1 实现 Chat/Message 数据模型
- [x] 6.2 实现 POST /chats/{id}/messages
- [x] 6.3 实现 GET /chats/{id}/messages
- [x] 6.4 实现 GET /chats (列表)

## 7. Tizbot - 流式响应

- [x] 7.1 配置 SSE (Server-Sent Events)
- [x] 7.2 实现流式输出
- [x] 7.3 处理连接断开

## 8. 网关配置

- [x] 8.1 添加 tizsrv 路由配置
- [x] 8.2 添加 tizbot 路由配置
- [x] 8.3 配置认证白名单

## 9. 移动端对接

- [x] 9.1 tiz-mobile 实现 InboxService
- [x] 9.2 tiz-mobile 实现 ExploreService
- [x] 9.3 tiz-mobile 实现 ChatService
- [x] 9.4 更新 UI 对接新 API
