"""LLM client wrapper for LangChain."""

from typing import AsyncIterator

from langchain_core.messages import AIMessage, BaseMessage, HumanMessage, SystemMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI

from app.config import get_settings


class LLMClient:
    """LLM client wrapper for chat completions."""

    def __init__(self) -> None:
        settings = get_settings()
        self._default_llm = ChatOpenAI(
            api_key=settings.llm_api_key,
            base_url=settings.llm_api_url,
            model=settings.llm_model,
            temperature=settings.llm_temperature,
            max_tokens=settings.llm_max_tokens,
            timeout=settings.llm_timeout,
        )
        self._settings = settings

    def _get_llm(
        self,
        api_key: str | None = None,
        api_url: str | None = None,
        model: str | None = None,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> ChatOpenAI:
        """Get LLM instance with specified or default configuration.

        Args:
            api_key: Custom API key (uses default if None)
            api_url: Custom API URL (uses default if None)
            model: Custom model name (uses default if None)
            temperature: Custom temperature (uses default if None)
            max_tokens: Custom max tokens (uses default if None)

        Returns:
            Configured ChatOpenAI instance
        """
        return ChatOpenAI(
            api_key=api_key or self._settings.llm_api_key,
            base_url=api_url or self._settings.llm_api_url,
            model=model or self._settings.llm_model,
            temperature=temperature if temperature is not None else self._settings.llm_temperature,
            max_tokens=max_tokens or self._settings.llm_max_tokens,
            timeout=self._settings.llm_timeout,
        )

    async def chat(
        self,
        message: str,
        system_prompt: str | None = None,
        history: list[dict] | None = None,
        api_key: str | None = None,
        api_url: str | None = None,
        model: str | None = None,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> str:
        """Send a chat message and get a response.

        Args:
            message: User message
            system_prompt: Optional system prompt
            history: Optional chat history
            api_key: Custom API key for this request
            api_url: Custom API URL for this request
            model: Custom model for this request
            temperature: Custom temperature for this request
            max_tokens: Custom max tokens for this request

        Returns:
            Response content
        """
        llm = self._get_llm(api_key, api_url, model, temperature, max_tokens)
        messages = self._build_messages(message, system_prompt, history)
        response = await llm.ainvoke(messages)
        return response.content

    async def chat_stream(
        self,
        message: str,
        system_prompt: str | None = None,
        history: list[dict] | None = None,
        api_key: str | None = None,
        api_url: str | None = None,
        model: str | None = None,
        temperature: float | None = None,
        max_tokens: int | None = None,
    ) -> AsyncIterator[str]:
        """Send a chat message and stream the response.

        Args:
            message: User message
            system_prompt: Optional system prompt
            history: Optional chat history
            api_key: Custom API key for this request
            api_url: Custom API URL for this request
            model: Custom model for this request
            temperature: Custom temperature for this request
            max_tokens: Custom max tokens for this request

        Yields:
            Response content chunks
        """
        llm = self._get_llm(api_key, api_url, model, temperature, max_tokens)
        messages = self._build_messages(message, system_prompt, history)
        parser = StrOutputParser()

        async for chunk in llm.astream(messages):
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


def get_llm_client() -> LLMClient:
    """Get LLM client instance."""
    return LLMClient()
