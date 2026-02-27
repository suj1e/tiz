# 设计文档

## 1. 技术栈

```
Python 3.11+
├── FastAPI        # HTTP 服务
├── LangGraph      # AI 工作流编排
├── LangChain      # LLM 工具链
├── Pydantic       # 数据验证
├── httpx          # HTTP 客户端
└── pixi           # 依赖管理
```

## 2. 项目结构

```
llmsrv/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 入口
│   ├── config.py            # 配置
│   ├── models/
│   │   ├── __init__.py
│   │   ├── chat.py          # 对话模型
│   │   ├── question.py      # 题目模型
│   │   └── grade.py         # 评分模型
│   ├── graphs/
│   │   ├── __init__.py
│   │   ├── chat_graph.py    # 对话工作流
│   │   ├── generate_graph.py# 生成题目工作流
│   │   └── grade_graph.py   # 评分工作流
│   ├── nodes/
│   │   ├── __init__.py
│   │   ├── analyze.py       # 分析意图
│   │   ├── generate.py      # 生成内容
│   │   └── extract.py       # 提取参数
│   ├── llm/
│   │   ├── __init__.py
│   │   └── client.py        # LLM 客户端
│   └── utils/
│       ├── __init__.py
│       └── prompt.py        # Prompt 模板
├── tests/
├── pixi.toml
├── pyproject.toml
└── Dockerfile
```

## 3. API 端点 (仅内部)

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/internal/ai/chat` | SSE 流式对话 |
| POST | `/internal/ai/generate` | 生成题目 |
| POST | `/internal/ai/grade` | 简答题评分 |

## 4. LangGraph 工作流

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  START  │────▶│ 分析意图 │────▶│ 生成回复 │────▶│   END   │
└─────────┘     └────┬────┘     └─────────┘     └─────────┘
                     │
                     │ 确认生成
                     ▼
               ┌─────────┐     ┌─────────┐     ┌─────────┐
               │ 提取参数 │────▶│ 生成题目 │────▶│ 返回结果 │
               └─────────┘     └─────────┘     └─────────┘
```

## 5. FastAPI 实现

```python
# llmsrv/app/main.py
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from langgraph.graph import StateGraph, END
from typing import TypedDict, AsyncGenerator
import json

app = FastAPI()

class ChatState(TypedDict):
    session_id: str | None
    message: str
    history: list[dict]
    response: str
    intent: str
    summary: dict | None

# 定义 LangGraph 工作流
def build_chat_graph():
    workflow = StateGraph(ChatState)

    # 节点
    workflow.add_node("analyze_intent", analyze_intent)
    workflow.add_node("generate_response", generate_response)
    workflow.add_node("extract_params", extract_params)
    workflow.add_node("generate_questions", generate_questions)

    # 边
    workflow.set_entry_point("analyze_intent")
    workflow.add_edge("analyze_intent", "generate_response")
    workflow.add_conditional_edges(
        "generate_response",
        should_generate,
        {
            "generate": "extract_params",
            "end": END
        }
    )
    workflow.add_edge("extract_params", "generate_questions")
    workflow.add_edge("generate_questions", END)

    return workflow.compile()

@app.post("/internal/ai/chat")
async def chat(request: ChatRequest) -> StreamingResponse:
    async def generate() -> AsyncGenerator[str, None]:
        graph = build_chat_graph()

        async for event in graph.astream({
            "session_id": request.session_id,
            "message": request.message,
            "history": []
        }):
            # 转换为 SSE 格式
            yield f"data: {json.dumps(event)}\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream"
    )

@app.post("/internal/ai/generate")
async def generate_questions(request: GenerateRequest) -> dict:
    # 生成题目逻辑
    pass

@app.post("/internal/ai/grade")
async def grade_answer(request: GradeRequest) -> dict:
    # 简答题评分逻辑
    pass
```

## 6. 配置

```python
# llmsrv/app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # 服务配置
    service_name: str = "llmsrv"
    service_port: int = 8106

    # LLM 配置
    llm_api_key: str
    llm_api_url: str
    llm_model: str = "gpt-4o"
    llm_temperature: float = 0.7

    class Config:
        env_file = ".env"
```

## 7. SSE 事件格式

```
event: session
data: {"session_id": "xxx"}

event: message
data: {"content": "你好！"}

event: confirm
data: {"summary": {...}}

event: done
data: {}

event: error
data: {"type": "api_error", "code": "ai_service_error", "message": "AI 服务异常"}
```

## 8. pixi 配置

```toml
# pixi.toml
[project]
name = "llmsrv"
version = "0.1.0"
description = "Tiz AI Service"
channels = ["conda-forge"]
platforms = ["linux-64", "osx-64", "osx-arm64"]

[dependencies]
python = ">=3.11"

[pypi-dependencies]
fastapi = ">=0.109.0"
uvicorn = ">=0.27.0"
langgraph = ">=0.0.40"
langchain = ">=0.1.0"
langchain-openai = ">=0.0.5"
pydantic = ">=2.5.0"
pydantic-settings = ">=2.1.0"
httpx = ">=0.26.0"

[tasks]
dev = "uvicorn app.main:app --reload --host 0.0.0.0 --port 8106"
start = "uvicorn app.main:app --host 0.0.0.0 --port 8106"
test = "pytest tests/ -v"
```
