"""LLM Provider service."""

from typing import AsyncGenerator, Optional

from app.config import settings


class LLMProvider:
    """LLM Provider interface."""

    async def chat(
        self,
        messages: list[dict],
    ) -> str:
        """Send chat request to LLM (non-streaming)."""
        raise NotImplementedError

    async def chat_stream(
        self,
        messages: list[dict],
    ) -> AsyncGenerator[str, None]:
        """Send chat request to LLM (streaming)."""
        raise NotImplementedError


class OpenAIProvider(LLMProvider):
    """OpenAI LLM Provider."""

    def __init__(self, api_key: str, model: str):
        self.api_key = api_key
        self.model = model
        self._client = None

    def _get_client(self):
        """Get or create OpenAI client."""
        if self._client is None:
            from openai import AsyncOpenAI
            self._client = AsyncOpenAI(api_key=self.api_key)
        return self._client

    async def chat(
        self,
        messages: list[dict],
    ) -> str:
        """Send chat request to OpenAI (non-streaming)."""
        client = self._get_client()
        response = await client.chat.completions.create(
            model=self.model,
            messages=messages,
        )
        return response.choices[0].message.content

    async def chat_stream(
        self,
        messages: list[dict],
    ) -> AsyncGenerator[str, None]:
        """Send chat request to OpenAI (streaming)."""
        client = self._get_client()
        response = await client.chat.completions.create(
            model=self.model,
            messages=messages,
            stream=True,
        )
        async for chunk in response:
            if chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content


class GeminiProvider(LLMProvider):
    """Google Gemini LLM Provider."""

    def __init__(self, api_key: str, model: str):
        self.api_key = api_key
        self.model = model

    async def chat(
        self,
        messages: list[dict],
    ) -> str:
        """Send chat request to Gemini (non-streaming)."""
        import google.genai as genai

        client = genai.Client(api_key=self.api_key)

        # Convert messages to Gemini format
        contents = []
        for msg in messages:
            role = "user" if msg["role"] == "user" else "model"
            contents.append({
                "role": role,
                "parts": [{"text": msg["content"]}],
            })

        response = await client.aio.models.generate_content(
            model=self.model,
            contents=contents,
        )
        return response.text

    async def chat_stream(
        self,
        messages: list[dict],
    ) -> AsyncGenerator[str, None]:
        """Send chat request to Gemini (streaming)."""
        import google.genai as genai

        client = genai.Client(api_key=self.api_key)

        # Convert messages to Gemini format
        contents = []
        for msg in messages:
            role = "user" if msg["role"] == "user" else "model"
            contents.append({
                "role": role,
                "parts": [{"text": msg["content"]}],
            })

        response = await client.aio.models.generate_content_stream(
            model=self.model,
            contents=contents,
        )
        async for chunk in response:
            if chunk.text:
                yield chunk.text


class AnthropicProvider(LLMProvider):
    """Anthropic LLM Provider."""

    def __init__(self, api_key: str, model: str):
        self.api_key = api_key
        self.model = model

    async def chat(
        self,
        messages: list[dict],
    ) -> str:
        """Send chat request to Anthropic (non-streaming)."""
        import anthropic

        client = anthropic.AsyncAnthropic(api_key=self.api_key)

        # Convert messages to Anthropic format
        system_message = ""
        anthropic_messages = []
        for msg in messages:
            if msg["role"] == "system":
                system_message = msg["content"]
            else:
                anthropic_messages.append(msg)

        response = await client.messages.create(
            model=self.model,
            system=system_message,
            messages=anthropic_messages,
        )
        return response.content[0].text

    async def chat_stream(
        self,
        messages: list[dict],
    ) -> AsyncGenerator[str, None]:
        """Send chat request to Anthropic (streaming)."""
        import anthropic

        client = anthropic.AsyncAnthropic(api_key=self.api_key)

        # Convert messages to Anthropic format
        system_message = ""
        anthropic_messages = []
        for msg in messages:
            if msg["role"] == "system":
                system_message = msg["content"]
            else:
                anthropic_messages.append(msg)

        async with client.messages.stream(
            model=self.model,
            system=system_message,
            messages=anthropic_messages,
        ) as stream:
            async for text in stream.text_stream:
                yield text


def get_llm_provider() -> LLMProvider:
    """Get configured LLM provider."""
    provider = settings.llm_provider.lower()

    if provider == "openai":
        if not settings.openai_api_key:
            raise ValueError("OPENAI_API_KEY is required")
        return OpenAIProvider(settings.openai_api_key, settings.openai_model)

    elif provider == "gemini":
        if not settings.gemini_api_key:
            raise ValueError("GEMINI_API_KEY is required")
        return GeminiProvider(settings.gemini_api_key, settings.gemini_model)

    elif provider == "anthropic":
        if not settings.anthropic_api_key:
            raise ValueError("ANTHROPIC_API_KEY is required")
        return AnthropicProvider(settings.anthropic_api_key, settings.anthropic_model)

    else:
        raise ValueError(f"Unknown LLM provider: {provider}")
