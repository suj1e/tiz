"""Chat API routes."""

from typing import AsyncGenerator
from uuid import uuid4

from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import StreamingResponse
from sse_starlette.sse import EventSourceResponse

from app.models.chat import (
    ChatCreate,
    ChatResponse,
    ChatWithMessagesResponse,
    MessageCreate,
    MessageResponse,
    MessageRole,
)
from app.services.chat_store import chat_store
from app.agent.graph import get_agent


router = APIRouter(prefix="/api/v1", tags=["chat"])


def get_current_user_id(request: Request) -> str:
    """Get current user ID from request.

    In production, this would extract from JWT token.
    For now, use a header or default to a test user.
    """
    # TODO: Implement proper JWT validation
    user_id = request.headers.get("X-User-ID")
    if not user_id:
        user_id = "test-user"
    return user_id


@router.post("/chats", response_model=ChatResponse)
async def create_chat(
    data: ChatCreate,
    request: Request,
) -> ChatResponse:
    """Create a new chat."""
    user_id = get_current_user_id(request)
    chat = await chat_store.create_chat(user_id, data)
    return ChatResponse(
        id=chat.id,
        user_id=chat.user_id,
        title=chat.title,
        created_at=chat.created_at,
        updated_at=chat.updated_at,
    )


@router.get("/chats", response_model=list[ChatResponse])
async def list_chats(request: Request) -> list[ChatResponse]:
    """List all chats for the current user."""
    user_id = get_current_user_id(request)
    chats = await chat_store.get_user_chats(user_id)
    return [
        ChatResponse(
            id=chat.id,
            user_id=chat.user_id,
            title=chat.title,
            created_at=chat.created_at,
            updated_at=chat.updated_at,
        )
        for chat in chats
    ]


@router.get("/chats/{chat_id}", response_model=ChatWithMessagesResponse)
async def get_chat(chat_id: str, request: Request) -> ChatWithMessagesResponse:
    """Get a specific chat with messages."""
    user_id = get_current_user_id(request)
    chat = await chat_store.get_chat(chat_id)

    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    if chat.user_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return ChatWithMessagesResponse(
        id=chat.id,
        user_id=chat.user_id,
        title=chat.title,
        created_at=chat.created_at,
        updated_at=chat.updated_at,
        messages=[
            MessageResponse(
                id=msg.id,
                chat_id=msg.chat_id,
                role=msg.role,
                content=msg.content,
                created_at=msg.created_at,
            )
            for msg in chat.messages
        ],
    )


@router.delete("/chats/{chat_id}")
async def delete_chat(chat_id: str, request: Request) -> dict:
    """Delete a chat."""
    user_id = get_current_user_id(request)
    chat = await chat_store.get_chat(chat_id)

    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    if chat.user_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")

    await chat_store.delete_chat(chat_id)
    return {"message": "Chat deleted"}


@router.post("/chats/{chat_id}/messages", response_model=MessageResponse)
async def create_message(
    chat_id: str,
    data: MessageCreate,
    request: Request,
) -> MessageResponse:
    """Send a message to a chat (non-streaming)."""
    user_id = get_current_user_id(request)
    chat = await chat_store.get_chat(chat_id)

    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    if chat.user_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")

    # Save user message
    user_message = await chat_store.add_message(
        chat_id, MessageRole.USER, data.content
    )

    # Get agent response
    agent = get_agent()
    messages = [{"role": msg.role, "content": msg.content} for msg in chat.messages]

    response_content = await agent.run(
        chat_id=chat_id,
        user_id=user_id,
        messages=messages,
    )

    # Save assistant message
    assistant_message = await chat_store.add_message(
        chat_id, MessageRole.ASSISTANT, response_content
    )

    return MessageResponse(
        id=assistant_message.id,
        chat_id=chat_id,
        role=assistant_message.role,
        content=assistant_message.content,
        created_at=assistant_message.created_at,
    )


async def generate_stream(
    chat_id: str,
    user_id: str,
    user_message_content: str,
) -> AsyncGenerator[str, None]:
    """Generate streaming response."""
    # Save user message
    await chat_store.add_message(chat_id, MessageRole.USER, user_message_content)

    # Get chat history
    chat = await chat_store.get_chat(chat_id)
    messages = [{"role": msg.role, "content": msg.content} for msg in chat.messages]

    # Get agent and stream response
    agent = get_agent()
    full_response = ""

    async for token in agent.run_stream(
        chat_id=chat_id,
        user_id=user_id,
        messages=messages,
    ):
        full_response += token
        yield f"data: {token}\n\n"

    # Save assistant message
    await chat_store.add_message(chat_id, MessageRole.ASSISTANT, full_response)

    yield "data: [DONE]\n\n"


@router.post("/chats/{chat_id}/messages/stream")
async def create_message_stream(
    chat_id: str,
    data: MessageCreate,
    request: Request,
) -> StreamingResponse:
    """Send a message to a chat with streaming response."""
    user_id = get_current_user_id(request)
    chat = await chat_store.get_chat(chat_id)

    if not chat:
        raise HTTPException(status_code=404, detail="Chat not found")

    if chat.user_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return StreamingResponse(
        generate_stream(chat_id, user_id, data.content),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
