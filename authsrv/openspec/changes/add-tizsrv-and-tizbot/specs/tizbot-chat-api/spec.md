## ADDED Requirements

### Requirement: Chat API
The system SHALL provide REST API for chat functionality.

#### Scenario: Send message
- **WHEN** authenticated user sends POST /api/v1/chats/{chatId}/messages
- **THEN** message is processed and response is returned

#### Scenario: Get chat history
- **WHEN** user requests GET /api/v1/chats/{chatId}/messages
- **THEN** conversation history is returned

#### Scenario: Create new chat
- **WHEN** user creates new conversation
- **THEN** new chat session is created and returned

### Requirement: Chat Management
The system SHALL allow users to manage their chats.

#### Scenario: List user chats
- **WHEN** user calls GET /api/v1/chats
- **THEN** list of user's chat sessions is returned

#### Scenario: Delete chat
- **WHEN** user deletes a chat
- **THEN** chat and messages are removed
