# Tizbot - AI Chat Service

## Project Overview

Tizbot 是基于 LangGraph + FastAPI 的 AI 聊天服务，为 Tiz 平台提供 Chat Tab 功能。

## Tech Stack

- **LangGraph** - AI Agent 框架
- **FastAPI** - Web 框架
- **OpenAI/Gemini/Anthropic** - LLM Providers

## Quick Start

### 1. Install pixi (if not installed)

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your LLM API key
```

### 3. Run

```bash
pixi run dev
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /api/v1/chats | Create new chat |
| GET | /api/v1/chats | List user chats |
| GET | /api/v1/chats/{chat_id} | Get chat with messages |
| DELETE | /api/v1/chats/{chat_id} | Delete chat |
| POST | /api/v1/chats/{chat_id}/messages | Send message (non-streaming) |
| POST | /api/v1/chats/{chat_id}/messages/stream | Send message (streaming) |
| GET | /api/v1/chats/{chat_id}/messages | Get message history |
| GET | /health | Health check |

## Project Structure

```
tizbot/
├── app/
│   ├── __init__.py
│   ├── main.py              # Application entry
│   ├── config.py            # Configuration
│   ├── agent/
│   │   └── graph.py         # LangGraph Agent
│   ├── api/
│   │   └── routes.py        # API routes
│   ├── models/
│   │   └── chat.py          # Data models
│   └── services/
│       ├── llm.py           # LLM Provider
│       └── chat_store.py   # Chat storage
├── pixi.toml
├── .env.example
└── README.md
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| LLM_PROVIDER | LLM provider (openai/gemini/anthropic) | openai |
| OPENAI_API_KEY | OpenAI API key | - |
| OPENAI_MODEL | OpenAI model | gpt-4o-mini |
| GEMINI_API_KEY | Gemini API key | - |
| GEMINI_MODEL | Gemini model | gemini-1.5-flash |
| ANTHROPIC_API_KEY | Anthropic API key | - |
| ANTHROPIC_MODEL | Anthropic model | claude-3-haiku-20240307 |
| SERVICE_PORT | Service port | 40008 |

## Streaming Response

Use SSE (Server-Sent Events) for streaming:

```bash
curl -N http://localhost:40008/api/v1/chats/{chat_id}/messages/stream \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{"content": "Hello"}'
```

## Development

```bash
# Install dependencies (automatic with pixi)
pixi install

# Run in development
pixi run dev

# Run tests
pixi run test
```
