# llm-service

AI service for the Tiz platform. Provides question generation, essay grading, and chat capabilities using LangGraph and LLMs.

## Tech Stack

- Python 3.11+
- FastAPI - HTTP service framework
- LangGraph - AI workflow orchestration
- LangChain - LLM toolchain
- Pydantic - Data validation
- pixi - Dependency management

## Dependencies

### Infrastructure
- LLM API (OpenAI or compatible) - Required for AI operations

### Services
None (this is a standalone Python service, not dependent on other Tiz services)

### Libraries
- This service publishes an API module for Java services: `io.github.suj1e:llm-api:1.0.0-SNAPSHOT`

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `LLM_API_KEY` | LLM provider API key | - | Yes |
| `LLM_API_BASE` | LLM API base URL | OpenAI default | No |
| `LLM_MODEL` | Model name | gpt-4o-mini | No |
| `LOG_LEVEL` | Logging level | INFO | No |

## API Module

This service publishes a Java API module to Maven for other services to use:

```kotlin
implementation("io.github.suj1e:llm-api:1.0.0-SNAPSHOT")
```

The llm-api module is located at `/Users/sujie/workspace/dev/apps/tiz/tiz-backend/llm-api/`

## Development

### Prerequisites

- [pixi](https://pixi.sh) installed
- LLM API key (OpenAI or compatible)

### Setup

1. Install dependencies:
```bash
pixi install
```

2. Copy and configure environment file:
```bash
cp .env.example .env
# Edit .env and add your LLM_API_KEY
```

### Build

```bash
./svc.sh build
```

### Test

```bash
./svc.sh test
```

### Run

```bash
./svc.sh run
```

Or with pixi directly:

```bash
pixi run dev    # Development with hot reload
pixi run start  # Production mode
```

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
llm-service/
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

## Docker

Build and run with Docker:

```bash
# Build
docker build -t llm-service .

# Run
docker run -p 8106:8106 --env-file .env llm-service
```

## Service Port

- **Default**: 8106
- **Health Check**: http://localhost:8106/health
