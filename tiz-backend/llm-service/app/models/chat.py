"""Chat models for request/response."""

from enum import Enum
from typing import Any

from pydantic import BaseModel, Field


class ChatEventType(str, Enum):
    """SSE event types for chat."""

    SESSION = "session"
    MESSAGE = "message"
    CONFIRM = "confirm"
    DONE = "done"
    ERROR = "error"


class ChatRequest(BaseModel):
    """Chat request model."""

    session_id: str | None = Field(default=None, description="Session ID for context")
    message: str = Field(..., min_length=1, description="User message")
    history: list[dict[str, str]] = Field(default_factory=list, description="Chat history")


class ChatSessionEvent(BaseModel):
    """Session event data."""

    session_id: str = Field(..., description="Session ID")


class ChatMessageEvent(BaseModel):
    """Message event data."""

    content: str = Field(..., description="Message content chunk")


class ChatConfirmEvent(BaseModel):
    """Confirm event data for question generation."""

    summary: dict[str, Any] = Field(..., description="Summary of questions to generate")


class ChatDoneEvent(BaseModel):
    """Done event data."""

    pass


class ChatErrorEvent(BaseModel):
    """Error event data."""

    type: str = Field(..., description="Error type")
    code: str = Field(..., description="Error code")
    message: str = Field(..., description="Error message")
