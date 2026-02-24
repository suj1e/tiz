# Tizbot - AI Chat Service

基于 LangGraph + FastAPI 的 AI 聊天服务。

## Quick Start

### 1. 安装 pixi (如果未安装)

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 配置 LLM Provider
```

### 3. 启动服务

```bash
# 开发模式
pixi run dev

# 生产模式
uvicorn app.main:app --host 0.0.0.0 --port 40008
```

### 4. 测试

```bash
# 发送消息
curl -X POST http://localhost:40008/api/v1/chats/{chatId}/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{"content": "Hello"}'

# 流式响应
curl -N http://localhost:40008/api/v1/chats/{chatId}/messages/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{"content": "Hello"}'
```

## API Endpoints

- `POST /api/v1/chats` - 创建新对话
- `GET /api/v1/chats` - 获取对话列表
- `GET /api/v1/chats/{chatId}` - 获取对话详情
- `DELETE /api/v1/chats/{chatId}` - 删除对话
- `POST /api/v1/chats/{chatId}/messages` - 发送消息
- `POST /api/v1/chats/{chatId}/messages/stream` - 流式发送消息
- `GET /api/v1/chats/{chatId}/messages` - 获取消息历史
