"""Tests for grade workflow."""

import json
import pytest
from unittest.mock import AsyncMock

from app.graphs.grade_graph import build_grade_graph, run_grade_workflow
from app.models import GradeResponse


class TestGradeGraph:
    """Tests for grade graph."""

    @pytest.mark.asyncio
    async def test_build_grade_graph(self):
        """Test that grade graph can be built."""
        graph = build_grade_graph()
        assert graph is not None

    @pytest.mark.asyncio
    async def test_grade_correct_answer(self, mock_llm_client):
        """Test grading a correct answer."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 95,
            "is_correct": True,
            "feedback": "Excellent answer! You covered all the key points.",
            "suggestions": []
        })

        result = await run_grade_workflow(
            question_content="What is the capital of France?",
            question_answer="Paris",
            user_answer="The capital of France is Paris.",
        )

        assert result["result"] is not None
        assert result["result"].score == 95
        assert result["result"].is_correct is True
        assert "Excellent" in result["result"].feedback

    @pytest.mark.asyncio
    async def test_grade_partially_correct_answer(self, mock_llm_client):
        """Test grading a partially correct answer."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 60,
            "is_correct": False,
            "feedback": "Partially correct. You missed some key points.",
            "suggestions": [
                "Include more details about the process",
                "Add examples to support your answer"
            ]
        })

        result = await run_grade_workflow(
            question_content="Explain photosynthesis.",
            question_answer="Photosynthesis is the process by which plants convert sunlight into energy...",
            user_answer="Plants use sunlight to make food.",
        )

        assert result["result"] is not None
        assert result["result"].score == 60
        assert result["result"].is_correct is False
        assert len(result["result"].suggestions) == 2

    @pytest.mark.asyncio
    async def test_grade_incorrect_answer(self, mock_llm_client):
        """Test grading an incorrect answer."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 20,
            "is_correct": False,
            "feedback": "Your answer is incorrect. Please review the material.",
            "suggestions": [
                "Review the basic concepts",
                "Try the practice exercises"
            ]
        })

        result = await run_grade_workflow(
            question_content="What is 2 + 2?",
            question_answer="4",
            user_answer="5",
        )

        assert result["result"] is not None
        assert result["result"].score == 20
        assert result["result"].is_correct is False

    @pytest.mark.asyncio
    async def test_grade_with_rubric(self, mock_llm_client):
        """Test grading with custom rubric."""
        mock_llm_client.chat.return_value = json.dumps({
            "score": 85,
            "is_correct": True,
            "feedback": "Good answer with most points covered.",
            "suggestions": ["Add more detail to the conclusion"]
        })

        result = await run_grade_workflow(
            question_content="Explain the water cycle.",
            question_answer="Evaporation, condensation, precipitation",
            user_answer="Water evaporates, forms clouds, and rains.",
            rubric="1 point for mentioning evaporation, 1 for condensation, 1 for precipitation",
        )

        assert result["result"] is not None
        assert result["result"].score == 85

    @pytest.mark.asyncio
    async def test_grade_handles_error(self, mock_llm_client):
        """Test error handling in grading."""
        mock_llm_client.chat.side_effect = Exception("API error")

        result = await run_grade_workflow(
            question_content="Test question?",
            question_answer="Test answer",
            user_answer="User answer",
        )

        assert result["error"] is not None
        assert result["result"] is not None
        assert result["result"].score == 0
        assert result["result"].is_correct is False

    @pytest.mark.asyncio
    async def test_grade_malformed_response(self, mock_llm_client):
        """Test handling malformed LLM response."""
        mock_llm_client.chat.return_value = "This is not valid JSON"

        result = await run_grade_workflow(
            question_content="Test?",
            question_answer="Answer",
            user_answer="User answer",
        )

        assert result["error"] is not None
        assert result["result"].score == 0


class TestGradeAnswer:
    """Tests for grade_answer node."""

    @pytest.mark.asyncio
    async def test_grade_answer_with_all_params(self, mock_llm_client):
        """Test grading with all parameters."""
        from app.graphs.grade_graph import grade_answer

        mock_llm_client.chat.return_value = json.dumps({
            "score": 90,
            "is_correct": True,
            "feedback": "Great answer!",
            "suggestions": []
        })

        state = {
            "question_content": "Test question",
            "question_answer": "Test answer",
            "user_answer": "User's answer",
            "rubric": "Test rubric",
            "result": None,
            "error": None,
        }

        result = await grade_answer(state)

        assert result["result"] is not None
        assert result["result"].score == 90
        assert result["result"].is_correct is True
