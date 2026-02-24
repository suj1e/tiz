"""Chat and Message data models."""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class MessageRole(str, Enum):
    """Message role enum."""

    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class Message(BaseModel):
    """Message model."""

    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    chat_id: str
    role: MessageRole
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    model_config = {"use_enum_values": True}


class MessageCreate(BaseModel):
    """Message create request."""

    content: str = Field(..., min_length=1)


class MessageResponse(BaseModel):
    """Message response."""

    id: str
    chat_id: str
    role: MessageRole
    content: str
    created_at: datetime

    model_config = {"use_enum_values": True}


class Chat(BaseModel):
    """Chat model."""

    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    title: str = "New Chat"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    messages: list[Message] = Field(default_factory=list)


class ChatCreate(BaseModel):
    """Chat create request."""

    title: Optional[str] = None


class ChatResponse(BaseModel):
    """Chat response."""

    id: str
    user_id: str
    title: str
    created_at: datetime
    updated_at: datetime

    model_config = {"use_enum_values": True}


class ChatWithMessagesResponse(ChatResponse):
    """Chat response with messages."""

    messages: list[MessageResponse] = Field(default_factory=list)
