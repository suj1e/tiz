"""Grade models for answer evaluation."""

from pydantic import BaseModel, Field

from app.models.ai_config import AiConfig


class GradeRequest(BaseModel):
    """Grade request for essay answer evaluation."""

    question_content: str = Field(..., description="The question content")
    question_answer: str = Field(..., description="The correct answer/rubric")
    user_answer: str = Field(..., description="User's answer to grade")
    rubric: str | None = Field(default=None, description="Scoring rubric")
    ai_config: AiConfig = Field(..., description="AI configuration for this request")


class GradeResponse(BaseModel):
    """Grade response with score and feedback."""

    score: float = Field(..., ge=0, le=100, description="Score (0-100)")
    is_correct: bool = Field(..., description="Whether answer is considered correct")
    feedback: str = Field(..., description="Detailed feedback")
    suggestions: list[str] = Field(
        default_factory=list,
        description="Suggestions for improvement",
    )
