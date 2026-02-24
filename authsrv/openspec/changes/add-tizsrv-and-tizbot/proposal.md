# Proposal: add-tizsrv-and-tizbot

## Why

当前 Tiz 平台已有 authsrv（认证）和 gatewaysrv（网关），tiz-mobile 的 Inbox、Explore、Chat 三个 Tab 缺少对应的后端服务支持。需要新增 tizsrv（核心业务服务）和 tizbot（AI 聊天服务），实现移动端功能的完整闭环。

## What Changes

### tizsrv (核心业务服务)
- 用 panck skill 生成 Spring Boot 微服务
- 实现 Inbox（通知消息）功能
- 实现 Explore（内容发现）功能
- 与 authsrv 集成获取用户身份
- 注册到 Nacos 进行服务发现

### tizbot (AI 聊天服务)
- 用 LangGraph 构建 AI Agent
- 支持多轮对话上下文
- 支持流式响应 (Streaming)
- 与 LLM 集成 (OpenAI/Gemini/本地模型)
- 对话历史存储

## Capabilities

### New Capabilities
- `tizsrv-generation`: 使用 panck 生成 tizsrv 微服务骨架
- `tizsrv-notification`: 通知/消息功能 (Inbox Tab)
- `tizsrv-content`: 内容发现功能 (Explore Tab)
- `tizbot-ai-agent`: LangGraph AI Agent 构建
- `tizbot-chat-api`: 聊天 API 接口
- `tizbot-streaming`: 流式响应支持

### Modified Capabilities
- (无 - 新增服务)

## Impact

- `tizsrv/` - 新增服务目录
- `tizbot/` - 新增 AI 聊天服务目录
- `gatewaysrv/` - 添加路由配置
- `tiz-mobile/` - 连接新服务实现完整功能
