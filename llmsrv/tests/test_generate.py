"""Tests for generate workflow."""

import json
import pytest
from unittest.mock import AsyncMock

from app.graphs.generate_graph import build_generate_graph, run_generate_workflow
from app.models import Question, QuestionType


class TestGenerateGraph:
    """Tests for generate graph."""

    @pytest.mark.asyncio
    async def test_build_generate_graph(self):
        """Test that generate graph can be built."""
        graph = build_generate_graph()
        assert graph is not None

    @pytest.mark.asyncio
    async def test_generate_choice_questions(self, mock_llm_client):
        """Test generating choice questions."""
        mock_llm_client.chat.return_value = json.dumps({
            "questions": [
                {
                    "type": "choice",
                    "content": "What is 2 + 2?",
                    "options": ["3", "4", "5", "6"],
                    "answer": "4",
                    "explanation": "2 + 2 = 4"
                },
                {
                    "type": "choice",
                    "content": "What is 3 * 3?",
                    "options": ["6", "7", "8", "9"],
                    "answer": "9",
                    "explanation": "3 * 3 = 9"
                }
            ]
        })

        result = await run_generate_workflow(
            topic="Basic Math",
            count=2,
            difficulty="easy",
            question_types=["choice"],
        )

        assert result["questions"] is not None
        assert len(result["questions"]) == 2
        assert result["questions"][0].type == QuestionType.CHOICE

    @pytest.mark.asyncio
    async def test_generate_essay_questions(self, mock_llm_client):
        """Test generating essay questions."""
        mock_llm_client.chat.return_value = json.dumps({
            "questions": [
                {
                    "type": "essay",
                    "content": "Explain the concept of recursion.",
                    "answer": "Recursion is when a function calls itself...",
                    "rubric": "Points for: definition, example, use cases"
                }
            ]
        })

        result = await run_generate_workflow(
            topic="Programming",
            count=1,
            difficulty="medium",
            question_types=["essay"],
        )

        assert result["questions"] is not None
        assert len(result["questions"]) == 1
        assert result["questions"][0].type == QuestionType.ESSAY
        assert result["questions"][0].rubric is not None

    @pytest.mark.asyncio
    async def test_generate_mixed_questions(self, mock_llm_client):
        """Test generating mixed question types."""
        mock_llm_client.chat.return_value = json.dumps({
            "questions": [
                {
                    "type": "choice",
                    "content": "What is Python?",
                    "options": ["Language", "Snake", "Both", "Neither"],
                    "answer": "Both",
                    "explanation": "Python is both a language and a snake."
                },
                {
                    "type": "essay",
                    "content": "Describe Python's GIL.",
                    "answer": "The GIL is...",
                    "rubric": "Points for: full name, purpose, impact"
                }
            ]
        })

        result = await run_generate_workflow(
            topic="Python",
            count=2,
            difficulty="hard",
            question_types=["choice", "essay"],
        )

        assert result["questions"] is not None
        assert len(result["questions"]) == 2
        assert result["summary"] is not None

    @pytest.mark.asyncio
    async def test_generate_handles_error(self, mock_llm_client):
        """Test error handling in generation."""
        mock_llm_client.chat.side_effect = Exception("API error")

        result = await run_generate_workflow(
            topic="Test",
            count=1,
            difficulty="easy",
            question_types=["choice"],
        )

        assert result["error"] is not None
        assert result["questions"] == []


class TestGenerateQuestions:
    """Tests for generate_questions node."""

    @pytest.mark.asyncio
    async def test_generate_questions_with_params(self, mock_llm_client):
        """Test generate_questions with all parameters."""
        from app.nodes.generate import generate_questions

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

        state = {
            "topic": "Test Topic",
            "count": 1,
            "difficulty": "medium",
            "question_types": ["choice"],
        }

        result = await generate_questions(state)

        assert result["questions"] is not None
        assert len(result["questions"]) == 1
        assert result["summary"]["topic"] == "Test Topic"

    @pytest.mark.asyncio
    async def test_generate_questions_malformed_response(self, mock_llm_client):
        """Test handling malformed LLM response."""
        from app.nodes.generate import generate_questions

        mock_llm_client.chat.return_value = "This is not valid JSON"

        state = {
            "topic": "Test Topic",
            "count": 1,
            "difficulty": "medium",
            "question_types": ["choice"],
        }

        result = await generate_questions(state)

        assert result["error"] is not None
        assert result["questions"] == []


class TestExtractParams:
    """Tests for extract_params node."""

    @pytest.mark.asyncio
    async def test_extract_params_normalization(self):
        """Test parameter normalization."""
        from app.nodes.extract import extract_params

        state = {
            "topic": "Test",
            "count": 5,
            "difficulty": "简单",  # Chinese for easy
            "question_types": ["选择题"],  # Chinese for choice
        }

        result = await extract_params(state)

        assert result["difficulty"] == "easy"
        assert result["question_types"] == ["choice"]

    @pytest.mark.asyncio
    async def test_extract_params_defaults(self):
        """Test default parameter values."""
        from app.nodes.extract import extract_params

        state = {
            "topic": None,
            "count": None,
            "difficulty": None,
            "question_types": None,
        }

        result = await extract_params(state)

        assert result["count"] == 5
        assert result["difficulty"] == "medium"
        assert result["question_types"] == ["choice"]
        # Topic should fallback to something
        assert result["topic"] is not None
