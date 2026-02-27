"""Test configuration and fixtures."""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch


@pytest.fixture
def mock_llm_client():
    """Mock LLM client for testing."""
    client = MagicMock()
    client.chat = AsyncMock()
    client.chat_stream = AsyncMock()
    return client


@pytest.fixture
def mock_settings():
    """Mock settings for testing."""
    settings = MagicMock()
    settings.llm_api_key = "test-key"
    settings.llm_api_url = "https://api.test.com/v1"
    settings.llm_model = "test-model"
    settings.llm_temperature = 0.7
    settings.llm_max_tokens = 4096
    settings.llm_timeout = 60
    settings.service_port = 8106
    settings.debug = True
    return settings


@pytest.fixture(autouse=True)
def mock_get_settings(mock_settings):
    """Auto-mock get_settings for all tests."""
    with patch("app.config.get_settings", return_value=mock_settings):
        yield mock_settings


@pytest.fixture(autouse=True)
def mock_get_llm_client(mock_llm_client):
    """Auto-mock get_llm_client for all tests."""
    with patch("app.llm.client.get_llm_client", return_value=mock_llm_client):
        yield mock_llm_client
