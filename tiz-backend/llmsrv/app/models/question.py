"""Question models for generation."""

from enum import Enum
from typing import Any

from pydantic import BaseModel, Field


class QuestionType(str, Enum):
    """Question types."""

    CHOICE = "choice"
    ESSAY = "essay"


class Question(BaseModel):
    """A generated question."""

    type: QuestionType = Field(..., description="Question type")
    content: str = Field(..., description="Question content")
    options: list[str] | None = Field(default=None, description="Options for choice questions")
    answer: str = Field(..., description="Correct answer")
    explanation: str | None = Field(default=None, description="Answer explanation")
    rubric: str | None = Field(default=None, description="Rubric for essay questions")


class GenerateRequest(BaseModel):
    """Question generation request."""

    topic: str = Field(..., min_length=1, description="Topic for question generation")
    count: int = Field(default=5, ge=1, le=20, description="Number of questions to generate")
    difficulty: str = Field(default="medium", description="Difficulty level: easy, medium, hard")
    question_types: list[QuestionType] = Field(
        default_factory=lambda: [QuestionType.CHOICE],
        description="Types of questions to generate",
    )
    context: dict[str, Any] | None = Field(default=None, description="Additional context")


class GenerateResponse(BaseModel):
    """Question generation response."""

    questions: list[Question] = Field(..., description="Generated questions")
    summary: dict[str, Any] = Field(
        default_factory=dict,
        description="Summary of generation (counts by type)",
    )
