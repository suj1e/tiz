# 任务清单

## 项目初始化

- [x] 创建项目结构 (Python/FastAPI)
- [x] 配置 pixi.toml
- [x] 配置 pyproject.toml
- [x] 配置 app/config.py

## LLM 客户端

- [x] LLM 客户端 (app/llm/client.py)

## Pydantic 模型

- [x] 对话模型 (app/models/chat.py)
- [x] 题目模型 (app/models/question.py)
- [x] 评分模型 (app/models/grade.py)

## LangGraph 工作流

- [x] 对话工作流 (app/graphs/chat_graph.py)
- [x] 生成题目工作流 (app/graphs/generate_graph.py)
- [x] 评分工作流 (app/graphs/grade_graph.py)

## 工作流节点

- [x] 分析意图节点 (app/nodes/analyze.py)
- [x] 生成内容节点 (app/nodes/generate.py)
- [x] 提取参数节点 (app/nodes/extract.py)

## FastAPI 控制器

- [x] FastAPI 入口 (app/main.py)
- [x] SSE 流式响应

## Prompt 设计

- [x] 对话 Prompt (app/utils/prompt.py)
- [x] 生成 Prompt (app/utils/prompt.py)
- [x] 评分 Prompt (app/utils/prompt.py)

## 测试

- [x] 对话测试 (Mock LLM)
- [x] 生成测试
- [x] 评分测试

## Docker

- [x] Dockerfile
