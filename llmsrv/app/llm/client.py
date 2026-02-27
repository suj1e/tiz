"""LLM client wrapper for LangChain."""

from functools import lru_cache
from typing import AsyncIterator

from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, SystemMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

from app.config import get_settings


class LLMClient:
    """LLM client wrapper for chat completions."""

    def __init__(self) -> None:
        settings = get_settings()
        self._llm = ChatOpenAI(
            api_key=settings.llm_api_key,
            base_url=settings.llm_api_url,
            model=settings.llm_model,
            temperature=settings.llm_temperature,
            max_tokens=settings.llm_max_tokens,
            timeout=settings.llm_timeout,
        )
        self._settings = settings

    async def chat(
        self,
        message: str,
        system_prompt: str | None = None,
        history: list[dict] | None = None,
    ) -> str:
        """Send a chat message and get a response."""
        messages = self._build_messages(message, system_prompt, history)
        response = await self._llm.ainvoke(messages)
        return response.content

    async def chat_stream(
        self,
        message: str,
        system_prompt: str | None = None,
        history: list[dict] | None = None,
    ) -> AsyncIterator[str]:
        """Send a chat message and stream the response."""
        messages = self._build_messages(message, system_prompt, history)
        parser = StrOutputParser()

        async for chunk in self._llm.astream(messages):
            parsed = parser.parse(chunk)
            if parsed:
                yield parsed

    def _build_messages(
        self,
        message: str,
        system_prompt: str | None = None,
        history: list[dict] | None = None,
    ) -> list[BaseMessage]:
        """Build message list for LLM."""
        messages: list[BaseMessage] = []

        if system_prompt:
            messages.append(SystemMessage(content=system_prompt))

        if history:
            for msg in history:
                role = msg.get("role", "")
                content = msg.get("content", "")
                if role == "user":
                    messages.append(HumanMessage(content=content))
                elif role == "assistant":
                    messages.append(AIMessage(content=content))

        messages.append(HumanMessage(content=message))
        return messages


@lru_cache
def get_llm_client() -> LLMClient:
    """Get cached LLM client instance."""
    return LLMClient()
