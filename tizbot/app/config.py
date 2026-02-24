"""Configuration module for Tizbot."""

from typing import Literal
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    # LLM Configuration
    llm_provider: Literal["openai", "gemini", "anthropic"] = "openai"

    # OpenAI
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"

    # Gemini
    gemini_api_key: str = ""
    gemini_model: str = "gemini-1.5-flash"

    # Anthropic
    anthropic_api_key: str = ""
    anthropic_model: str = "claude-3-haiku-20240307"

    # Service Configuration
    service_host: str = "0.0.0.0"
    service_port: int = 40008
    log_level: str = "INFO"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )


settings = Settings()
