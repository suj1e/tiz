"""Tests for FastAPI main application."""

import json
import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch, MagicMock

from app.main import app
from app.models import Question, QuestionType, GradeResponse


@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)


@pytest.fixture
async def async_client():
    """Create async test client."""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        yield client


class TestHealthCheck:
    """Tests for health check endpoint."""

    def test_health_check(self, client):
        """Test health check returns healthy status."""
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "llmsrv"


class TestChatEndpoint:
    """Tests for chat endpoint."""

    @pytest.mark.asyncio
    async def test_chat_returns_sse_stream(self, async_client, mock_llm_client):
        """Test that chat endpoint returns SSE stream."""
        # Mock LLM responses
        mock_llm_client.chat = AsyncMock(side_effect=[
            json.dumps({"intent": "chat"}),
            "Hello! How can I help you?"
        ])

        response = await async_client.post(
            "/internal/ai/chat",
            json={
                "message": "Hello",
                "session_id": None,
                "history": []
            }
        )

        assert response.status_code == 200
        assert response.headers["content-type"] == "text/event-stream"

    @pytest.mark.asyncio
    async def test_chat_generates_session_id(self, async_client, mock_llm_client):
        """Test that chat generates session ID if not provided."""
        mock_llm_client.chat = AsyncMock(side_effect=[
            json.dumps({"intent": "chat"}),
            "Hello!"
        ])

        response = await async_client.post(
            "/internal/ai/chat",
            json={
                "message": "Hello",
                "history": []
            }
        )

        assert response.status_code == 200
        # Check that session event is sent
        content = response.text
        assert "event: session" in content

    @pytest.mark.asyncio
    async def test_chat_sends_done_event(self, async_client, mock_llm_client):
        """Test that chat sends done event at the end."""
        mock_llm_client.chat = AsyncMock(side_effect=[
            json.dumps({"intent": "chat"}),
            "Hello!"
        ])

        response = await async_client.post(
            "/internal/ai/chat",
            json={
                "message": "Hello",
                "history": []
            }
        )

        content = response.text
        assert "event: done" in content


class TestGenerateEndpoint:
    """Tests for generate endpoint."""

    @pytest.mark.asyncio
    async def test_generate_questions(self, async_client, mock_llm_client):
        """Test generating questions via API."""
        mock_llm_client.chat.return_value = json.dumps({
            "questions": [
                {
                    "type": "choice",
                    "content": "Test question?",
                    "options": ["A", "B", "C", "D"],
                    "answer": "A",
                    "explanation": "A is correct"
                }
            ]
        })

        response = await async_client.post(
            "/internal/ai/generate",
            json={
                "topic": "Test Topic",
                "count": 1,
                "difficulty": "medium",
                "question_types": ["choice"]
            }
        )

        assert response.status_code == 200
        data = response.json()
        assert "questions" in data
        assert len(data["questions"]) == 1

    @pytest.mark.asyncio
    async def test_generate_with_default_params(self, async_client, mock_llm_client):
        """Test generate with default parameters."""
        mock_llm_client.chat.return_value = json.dumps({
            "questions": []
        })

        response = await async_client.post(
            "/internal/ai/generate",
            json={
                "topic": "Test"
            }
        )

        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_generate_handles_error(self, async_client, mock_llm_client):
        """Test generate error handling."""
        mock_llm_client.chat.side_effect = Exception("API error")

        response = await async_client.post(
            "/internal/ai/generate",
            json={
                "topic": "Test"
            }
        )

        assert response.status_code == 500


class TestGradeEndpoint:
    """Tests for grade endpoint."""

    @pytest.mark.asyncio
    async def test_grade_answer(self, async_client, mock_llm_client):
        """Test grading an answer via API."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 90,
            "is_correct": True,
            "feedback": "Great answer!",
            "suggestions": []
        })

        response = await async_client.post(
            "/internal/ai/grade",
            json={
                "question_content": "What is 2 + 2?",
                "question_answer": "4",
                "user_answer": "Four"
            }
        )

        assert response.status_code == 200
        data = response.json()
        assert data["score"] == 90
        assert data["is_correct"] is True
        assert data["feedback"] == "Great answer!"

    @pytest.mark.asyncio
    async def test_grade_with_rubric(self, async_client, mock_llm_client):
        """Test grading with rubric."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 85,
            "is_correct": True,
            "feedback": "Good",
            "suggestions": []
        })

        response = await async_client.post(
            "/internal/ai/grade",
            json={
                "question_content": "Explain X",
                "question_answer": "X is...",
                "user_answer": "X means...",
                "rubric": "1 point for definition, 1 for example"
            }
        )

        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_grade_handles_error(self, async_client, mock_llm_client):
        """Test grade error handling."""
        mock_llm_client.chat.side_effect = Exception("API error")

        response = await async_client.post(
            "/internal/ai/grade",
            json={
                "question_content": "Test?",
                "question_answer": "Answer",
                "user_answer": "User answer"
            }
        )

        assert response.status_code == 500
