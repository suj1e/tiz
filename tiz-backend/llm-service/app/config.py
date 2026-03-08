"""Application configuration using Pydantic Settings."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Service configuration
    service_name: str = "llmsrv"
    service_port: int = 8106
    debug: bool = False

    # LLM configuration
    llm_api_key: str = ""
    llm_api_url: str = "https://api.openai.com/v1"
    llm_model: str = "gpt-4o"
    llm_temperature: float = 0.7
    llm_max_tokens: int = 4096

    # Timeout settings
    llm_timeout: int = 60
    stream_timeout: int = 120


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
