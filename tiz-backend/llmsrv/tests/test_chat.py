"""Tests for chat workflow."""

import json
import pytest
from unittest.mock import AsyncMock, patch

from app.graphs.chat_graph import build_chat_graph, run_chat_workflow, stream_chat_workflow
from app.nodes.analyze import ChatState


class TestChatGraph:
    """Tests for chat graph."""

    @pytest.mark.asyncio
    async def test_build_chat_graph(self):
        """Test that chat graph can be built."""
        graph = build_chat_graph()
        assert graph is not None

    @pytest.mark.asyncio
    async def test_chat_intent_chat(self, mock_llm_client):
        """Test chat workflow with regular chat intent."""
        # Mock LLM response for intent analysis
        mock_llm_client.chat.return_value = json.dumps({
            "intent": "chat"
        })

        # Then mock response for content generation
        mock_llm_client.chat.return_value = "Hello! How can I help you today?"

        graph = build_chat_graph()
        initial_state: ChatState = {
            "session_id": "test-session",
            "message": "Hello",
            "history": [],
            "response": "",
            "intent": "chat",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await graph.ainvoke(initial_state)

        assert result["intent"] == "chat"
        assert result["response"] != ""

    @pytest.mark.asyncio
    async def test_chat_intent_generate(self, mock_llm_client):
        """Test chat workflow with generate intent."""
        # Mock LLM responses
        responses = [
            # Intent analysis response
            json.dumps({
                "intent": "generate",
                "topic": "Python basics",
                "count": 3,
                "difficulty": "medium",
                "question_types": ["choice"]
            }),
            # Content generation response with confirmation
            """[CONFIRM]
主题: Python basics
数量: 3
难度: medium
类型: choice
[/CONFIRM]
I'll generate 3 questions about Python basics.""",
            # Question generation response
            json.dumps({
                "questions": [
                    {
                        "type": "choice",
                        "content": "What is Python?",
                        "options": ["A programming language", "A snake", "A tool", "A game"],
                        "answer": "A programming language",
                        "explanation": "Python is a high-level programming language."
                    }
                ]
            }),
        ]

        mock_llm_client.chat = AsyncMock(side_effect=responses)

        graph = build_chat_graph()
        initial_state: ChatState = {
            "session_id": "test-session",
            "message": "Generate 3 Python questions",
            "history": [],
            "response": "",
            "intent": "chat",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await graph.ainvoke(initial_state)

        assert result["intent"] == "generate"
        assert result["topic"] == "Python basics"

    @pytest.mark.asyncio
    async def test_run_chat_workflow(self, mock_llm_client):
        """Test run_chat_workflow helper function."""
        mock_llm_client.chat.return_value = json.dumps({"intent": "chat"})

        result = await run_chat_workflow(
            message="Hello",
            session_id="test-session",
            history=[],
        )

        assert "session_id" in result
        assert result["session_id"] == "test-session"

    @pytest.mark.asyncio
    async def test_stream_chat_workflow(self, mock_llm_client):
        """Test stream_chat_workflow helper function."""
        mock_llm_client.chat.return_value = json.dumps({"intent": "chat"})

        events = []
        async for event in stream_chat_workflow(
            message="Hello",
            session_id="test-session",
            history=[],
        ):
            events.append(event)

        assert len(events) > 0


class TestAnalyzeIntent:
    """Tests for analyze_intent node."""

    @pytest.mark.asyncio
    async def test_analyze_chat_intent(self, mock_llm_client):
        """Test analyzing chat intent."""
        from app.nodes.analyze import analyze_intent

        mock_llm_client.chat.return_value = json.dumps({"intent": "chat"})

        state: ChatState = {
            "session_id": None,
            "message": "Hello, how are you?",
            "history": [],
            "response": "",
            "intent": "",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await analyze_intent(state)

        assert result["intent"] == "chat"

    @pytest.mark.asyncio
    async def test_analyze_generate_intent(self, mock_llm_client):
        """Test analyzing generate intent."""
        from app.nodes.analyze import analyze_intent

        mock_llm_client.chat.return_value = json.dumps({
            "intent": "generate",
            "topic": "Mathematics",
            "count": 5,
            "difficulty": "hard",
            "question_types": ["choice", "essay"]
        })

        state: ChatState = {
            "session_id": None,
            "message": "Generate 5 hard math questions",
            "history": [],
            "response": "",
            "intent": "",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await analyze_intent(state)

        assert result["intent"] == "generate"
        assert result["topic"] == "Mathematics"
        assert result["count"] == 5
        assert result["difficulty"] == "hard"


class TestGenerateContent:
    """Tests for generate_content node."""

    @pytest.mark.asyncio
    async def test_generate_simple_response(self, mock_llm_client):
        """Test generating simple response."""
        from app.nodes.generate import generate_content

        mock_llm_client.chat.return_value = "Hello! How can I help you?"

        state: ChatState = {
            "session_id": None,
            "message": "Hello",
            "history": [],
            "response": "",
            "intent": "chat",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await generate_content(state)

        assert result["response"] == "Hello! How can I help you?"

    @pytest.mark.asyncio
    async def test_generate_with_confirmation(self, mock_llm_client):
        """Test generating response with confirmation marker."""
        from app.nodes.generate import generate_content

        mock_llm_client.chat.return_value = """[CONFIRM]
主题: Python
数量: 3
难度: easy
类型: choice
[/CONFIRM]
I'll generate 3 easy Python questions for you."""

        state: ChatState = {
            "session_id": None,
            "message": "Generate Python questions",
            "history": [],
            "response": "",
            "intent": "chat",
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
            "summary": None,
            "questions": None,
            "error": None,
        }

        result = await generate_content(state)

        assert "[CONFIRM]" in result["response"]
        assert result["intent"] == "generate"
        assert result["summary"] is not None
        assert result["summary"]["topic"] == "Python"
