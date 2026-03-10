"""Shared state definitions for LangGraph workflows."""

from typing import TypedDict

from app.models import Question
from app.models.ai_config import AiConfig


class ChatState(TypedDict):
    """State for chat workflow."""

    session_id: str | None
    message: str
    history: list[dict]
    response: str
    intent: str
    topic: str | None
    count: int | None
    difficulty: str | None
    question_types: list[str] | None
    summary: dict | None
    questions: list[Question] | None
    error: str | None
    ai_config: AiConfig | None


class GenerateState(TypedDict):
    """State for generate workflow."""

    topic: str
    count: int
    difficulty: str
    question_types: list[str]
    questions: list[Question] | None
    summary: dict | None
    error: str | None
    ai_config: AiConfig


class GradeState(TypedDict):
    """State for grade workflow."""

    question_content: str
    question_answer: str
    user_answer: str
    rubric: str | None
    result: "GradeResponse | None"
    error: str | None
    ai_config: AiConfig


# Import GradeResponse here for type hint to avoid circular import
from app.models import GradeResponse  # noqa: E402

GradeState.__annotations__["result"] = "GradeResponse | None"


__all__ = [
    "ChatState",
    "GenerateState",
    "GradeState",
]
