## ADDED Requirements

### Requirement: Check AI config on first login
The system SHALL check if user has configured AI settings after first login.

#### Scenario: First login without AI config
- **WHEN** user logs in for the first time without AI config
- **THEN** system redirects to `/ai-config`
- **AND** displays onboarding message

#### Scenario: First login with AI config
- **WHEN** user logs in and already has AI config
- **THEN** system redirects to `/home`

### Requirement: Check AI config when starting chat
The system SHALL check if user has configured AI settings when starting a chat.

#### Scenario: User starts chat without AI config
- **WHEN** user navigates to chat page without AI config
- **THEN** system redirects to `/ai-config`
- **AND** displays message "请先配置 AI 设置"

#### Scenario: User starts chat with AI config
- **WHEN** user navigates to chat page with valid AI config
- **THEN** system displays chat interface

### Requirement: Backend returns AI config status
The system SHALL provide an API to check if user has configured AI settings.

#### Scenario: Check config status
- **WHEN** frontend calls `GET /user/v1/ai-config/status`
- **THEN** system returns `{ "configured": true/false }`

### Requirement: API calls fail gracefully without AI config
The system SHALL return a specific error when AI features are used without config.

#### Scenario: Chat request without AI config
- **WHEN** user attempts chat without AI config
- **THEN** backend returns error with code `AI_CONFIG_REQUIRED`
- **AND** frontend redirects to `/ai-config`
