## ADDED Requirements

### Requirement: LLM service requires user AI configuration
The system SHALL require ai_config parameter in all llm-service requests.

#### Scenario: Request with valid ai_config
- **WHEN** service calls llm-service with complete ai_config
- **THEN** llm-service uses the provided configuration
- **AND** makes API call with user's settings

#### Scenario: Request without ai_config
- **WHEN** service calls llm-service without ai_config
- **THEN** llm-service returns validation error
- **AND** does NOT use any fallback configuration

### Requirement: Chat service passes user AI config to llm-service
The system SHALL have chat-service retrieve and pass user AI config when calling llm-service.

#### Scenario: User has AI config
- **WHEN** user sends a chat message
- **THEN** chat-service fetches user's AI config from user-service
- **AND** passes it to llm-service
- **AND** returns error `AI_CONFIG_REQUIRED` if config not found

### Requirement: Practice service passes user AI config to llm-service
The system SHALL have practice-service retrieve and pass user AI config when grading essays.

#### Scenario: Grading with AI config
- **WHEN** user submits an essay answer for grading
- **THEN** practice-service fetches user's AI config from user-service
- **AND** passes it to llm-service
- **AND** returns error `AI_CONFIG_REQUIRED` if config not found

### Requirement: Content service passes user AI config to llm-service
The system SHALL have content-service retrieve and pass user AI config when generating questions.

#### Scenario: Question generation with AI config
- **WHEN** user triggers question generation
- **THEN** content-service fetches user's AI config from user-service
- **AND** passes it to llm-service
- **AND** returns error `AI_CONFIG_REQUIRED` if config not found

### Requirement: User service exposes internal AI config API
The system SHALL provide an internal API for other services to query user AI configuration.

#### Scenario: Service queries AI config
- **WHEN** a backend service calls `GET /internal/user/v1/ai-config?user_id=xxx`
- **THEN** user-service returns the user's complete AI configuration
- **OR** returns 404 if not configured

### Requirement: LLM service validates custom API URL
The system SHALL validate custom API URL before making requests.

#### Scenario: Invalid custom URL
- **WHEN** ai_config contains invalid API URL
- **THEN** llm-service returns validation error
- **AND** does not attempt the request

#### Scenario: Custom URL request fails
- **WHEN** request to custom API URL fails (timeout, auth error)
- **THEN** llm-service returns appropriate error message with details
