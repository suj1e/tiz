-- ============================================================
-- Migration: Add AI config columns to user_settings table
-- ============================================================
-- This migration adds AI configuration fields to the user_settings table
-- for storing user's AI preferences and custom API settings
-- ============================================================

USE tiz;

ALTER TABLE user_settings
ADD COLUMN preferred_model VARCHAR(50) NOT NULL DEFAULT 'gpt-4o',
ADD COLUMN temperature DECIMAL(3,2) NOT NULL DEFAULT 0.70,
ADD COLUMN max_tokens INT NOT NULL DEFAULT 4096,
ADD COLUMN system_prompt TEXT NOT NULL DEFAULT 'You are a helpful assistant.',
ADD COLUMN response_language VARCHAR(10) NOT NULL DEFAULT 'zh',
ADD COLUMN custom_api_url VARCHAR(500) NOT NULL DEFAULT 'https://api.openai.com/v1',
ADD COLUMN custom_api_key VARCHAR(255) NOT NULL DEFAULT '';
