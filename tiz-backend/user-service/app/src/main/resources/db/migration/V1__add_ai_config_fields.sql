-- Add AI configuration columns to user_settings table
ALTER TABLE user_settings
    ADD COLUMN preferred_model VARCHAR(100) NOT NULL DEFAULT '',
    ADD COLUMN temperature DOUBLE NOT NULL DEFAULT 0.7,
    ADD COLUMN max_tokens INT NOT NULL DEFAULT 2048,
    ADD COLUMN system_prompt TEXT NOT NULL DEFAULT '',
    ADD COLUMN response_language VARCHAR(20) NOT NULL DEFAULT '',
    ADD COLUMN custom_api_url VARCHAR(500) NOT NULL DEFAULT '',
    ADD COLUMN custom_api_key VARCHAR(255) NOT NULL DEFAULT '';
