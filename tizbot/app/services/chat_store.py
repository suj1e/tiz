"""Chat storage service."""

from datetime import datetime
from typing import Optional

from app.models.chat import Chat, ChatCreate, Message, MessageCreate, MessageRole


class ChatStore:
    """In-memory chat storage (replace with database in production)."""

    def __init__(self):
        self._chats: dict[str, Chat] = {}
        self._user_chats: dict[str, set[str]] = {}

    async def create_chat(self, user_id: str, data: ChatCreate) -> Chat:
        """Create a new chat."""
        chat = Chat(
            user_id=user_id,
            title=data.title or "New Chat",
        )
        self._chats[chat.id] = chat

        if user_id not in self._user_chats:
            self._user_chats[user_id] = set()
        self._user_chats[user_id].add(chat.id)

        return chat

    async def get_chat(self, chat_id: str) -> Optional[Chat]:
        """Get chat by ID."""
        return self._chats.get(chat_id)

    async def get_user_chats(self, user_id: str) -> list[Chat]:
        """Get all chats for a user."""
        chat_ids = self._user_chats.get(user_id, set())
        chats = [self._chats[cid] for cid in chat_ids if cid in self._chats]
        return sorted(chats, key=lambda c: c.updated_at, reverse=True)

    async def update_chat(self, chat_id: str, title: str) -> Optional[Chat]:
        """Update chat title."""
        chat = self._chats.get(chat_id)
        if chat:
            chat.title = title
            chat.updated_at = datetime.utcnow()
        return chat

    async def delete_chat(self, chat_id: str) -> bool:
        """Delete a chat."""
        chat = self._chats.get(chat_id)
        if chat:
            del self._chats[chat_id]
            if chat.user_id in self._user_chats:
                self._user_chats[chat.user_id].discard(chat_id)
            return True
        return False

    async def add_message(self, chat_id: str, role: MessageRole, content: str) -> Optional[Message]:
        """Add a message to a chat."""
        chat = self._chats.get(chat_id)
        if not chat:
            return None

        message = Message(
            chat_id=chat_id,
            role=role,
            content=content,
        )
        chat.messages.append(message)
        chat.updated_at = datetime.utcnow()

        # Update title if first user message
        if role == MessageRole.USER and chat.title == "New Chat":
            chat.title = content[:50] + ("..." if len(content) > 50 else "")

        return message

    async def get_messages(self, chat_id: str) -> list[Message]:
        """Get all messages for a chat."""
        chat = self._chats.get(chat_id)
        return chat.messages if chat else []


# Global store instance
chat_store = ChatStore()
