"""AI configuration models for LLM requests."""

from pydantic import BaseModel, Field, field_validator


class AiConfig(BaseModel):
    """AI configuration for LLM requests."""

    preferred_model: str = Field(..., min_length=1, description="Preferred LLM model name")
    temperature: float = Field(..., ge=0.0, le=2.0, description="Temperature for generation (0.0-2.0)")
    max_tokens: int = Field(..., gt=0, description="Maximum tokens to generate")
    system_prompt: str = Field(..., min_length=1, description="System prompt for the LLM")
    response_language: str = Field(..., pattern="^(zh|en)$", description="Response language: zh or en")
    custom_api_url: str = Field(..., min_length=1, description="Custom API URL for LLM")
    custom_api_key: str = Field(..., min_length=1, description="Custom API key for authentication")

    @field_validator('custom_api_url')
    @classmethod
    def validate_url(cls, v: str) -> str:
        """Validate that API URL starts with https://."""
        if not v.startswith('https://'):
            raise ValueError('API URL must start with https://')
        return v
