# Tiz AI Service (llmsrv)

LangGraph-based AI backend for question generation and grading.

## Tech Stack

- **Python 3.11+**
- **FastAPI** - HTTP service
- **LangGraph** - AI workflow orchestration
- **LangChain** - LLM toolchain
- **Pydantic** - Data validation
- **pixi** - Dependency management

## Quick Start

### Prerequisites

- [pixi](https://pixi.sh) installed
- LLM API key (OpenAI or compatible)

### Setup

1. Copy environment file:
```bash
cp .env.example .env
```

2. Edit `.env` and add your API key:
```
LLM_API_KEY=your-api-key-here
```

3. Install dependencies:
```bash
pixi install
```

4. Run development server:
```bash
pixi run dev
```

The service will be available at http://localhost:8106

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| POST | `/internal/ai/chat` | Chat with SSE streaming |
| POST | `/internal/ai/generate` | Generate questions |
| POST | `/internal/ai/grade` | Grade essay answers |

### Chat Endpoint

```bash
curl -X POST http://localhost:8106/internal/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Generate 5 Python questions"}'
```

Returns SSE stream with events:
- `session` - Session ID
- `message` - Response content
- `confirm` - Generation confirmation
- `done` - Stream complete
- `error` - Error occurred

### Generate Endpoint

```bash
curl -X POST http://localhost:8106/internal/ai/generate \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Python basics",
    "count": 5,
    "difficulty": "medium",
    "question_types": ["choice"]
  }'
```

### Grade Endpoint

```bash
curl -X POST http://localhost:8106/internal/ai/grade \
  -H "Content-Type: application/json" \
  -d '{
    "question_content": "What is 2 + 2?",
    "question_answer": "4",
    "user_answer": "Four"
  }'
```

## Project Structure

```
llmsrv/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI entry point
│   ├── config.py            # Configuration
│   ├── models/
│   │   ├── __init__.py
│   │   ├── chat.py          # Chat models
│   │   ├── question.py      # Question models
│   │   └── grade.py         # Grade models
│   ├── graphs/
│   │   ├── __init__.py
│   │   ├── chat_graph.py    # Chat workflow
│   │   ├── generate_graph.py
│   │   └── grade_graph.py
│   ├── nodes/
│   │   ├── __init__.py
│   │   ├── analyze.py       # Intent analysis
│   │   ├── generate.py      # Content generation
│   │   └── extract.py       # Parameter extraction
│   ├── llm/
│   │   ├── __init__.py
│   │   └── client.py        # LLM client wrapper
│   └── utils/
│       ├── __init__.py
│       └── prompt.py        # Prompt templates
├── tests/
│   ├── conftest.py
│   ├── test_chat.py
│   ├── test_generate.py
│   ├── test_grade.py
│   └── test_main.py
├── pixi.toml
├── pyproject.toml
├── Dockerfile
└── README.md
```

## Development

### Run Tests

```bash
pixi run test
```

### Run with Hot Reload

```bash
pixi run dev
```

### Production

```bash
pixi run start
```

## Docker

Build and run with Docker:

```bash
# Build
docker build -t llmsrv .

# Run
docker run -p 8106:8106 --env-file .env llmsrv
```

## LangGraph Workflow

The chat workflow uses LangGraph for orchestrating AI interactions:

```
START -> analyze_intent -> generate_content -> (check intent)
                                                      |
                                                      | -> generate: extract_params -> generate_questions -> END
                                                      | -> end: END
```

1. **analyze_intent** - Determines if user wants to generate questions
2. **generate_content** - Generates conversational response
3. **extract_params** - Normalizes parameters for generation
4. **generate_questions** - Creates questions based on parameters

## License

MIT
