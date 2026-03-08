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
    service_name: str = "llm-service"
    service_port: int = 8106
    debug: bool = False

    # Nacos configuration
    nacos_enabled: bool = True
    nacos_server_addr: str = "localhost:30848"
    nacos_namespace: str = ""
    nacos_username: str = "nacos"
    nacos_password: str = "nacos"

    # Legacy env var support (for Docker Compose)
    @property
    def nacos_server_addr_resolved(self) -> str:
        """Resolve Nacos server address."""
        # Support both NACOS_SERVER_ADDR and nacos_server_addr
        return self.nacos_server_addr

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
