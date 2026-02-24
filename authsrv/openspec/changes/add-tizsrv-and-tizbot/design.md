## Context

当前 Tiz 平台需要新增两个后端服务来支持移动端功能：
- **tizsrv**: 核心业务服务，支持 Inbox 和 Explore Tab
- **tizbot**: AI 聊天服务，支持 Chat Tab

## Goals / Non-Goals

**Goals:**
- 使用 panck 生成 tizsrv 服务骨架
- 实现通知消息功能
- 实现内容发现功能
- 使用 LangGraph 构建 tizbot AI Agent
- 实现流式响应

**Non-Goals:**
- 用户权限管理 (RBAC) - 后续迭代
- 复杂的内容推荐算法 - 后续迭代
- 多模态 AI - 后续迭代

## Decisions

### Decision 1: Tizsrv 技术栈

**选择**: Spring Boot 3.x + Java 21

**理由**:
- 与现有 authsrv 保持一致
- 使用 nexora starters
- Nacos 服务发现

### Decision 2: Tizbot 技术栈

**选择**: Python + LangGraph + FastAPI

**理由**:
- LangGraph 是 Python 库
- FastAPI 原生支持 SSE 流式响应
- 生态丰富，易于集成各种 LLM

### Decision 3: 服务通信

**选择**: HTTP (REST) + Kafka 事件

**理由**:
- 简单直接的服务间调用
- Kafka 用于异步事件（如通知推送）

### Decision 4: LLM Provider

**选择**: 支持多 Provider (OpenAI, Gemini, 本地模型)

**理由**:
- 灵活切换
- 便于开发和测试

## Risks / Trade-offs

### Risk 1: 跨语言服务管理
**→ Mitigation**: 两个服务独立部署，使用标准 REST API 通信

### Risk 2: 流式响应延迟
**→ Mitigation**: 使用 SSE，在网关层开启 chunked 响应

### Risk 3: LangGraph 版本兼容性
**→ Mitigation**: 固定版本，定期更新

## Migration Plan

1. **Phase 1**: 生成 tizsrv
   - 使用 panck 生成骨架
   - 配置 Nacos
   - 实现通知 API
   - 实现内容 API

2. **Phase 2**: 创建 tizbot
   - 项目初始化
   - LangGraph Agent 开发
   - SSE 流式响应
   - 集成测试

3. **Phase 3**: 网关配置
   - 添加 tizsrv 路由
   - 添加 tizbot 路由
   - 认证白名单配置

4. **Phase 4**: 移动端对接
   - 实现 Inbox API 调用
   - 实现 Explore API 调用
   - 实现 Chat API 调用
