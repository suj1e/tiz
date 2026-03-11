## ADDED Requirements

### Requirement: User can configure AI settings on dedicated page
The system SHALL provide a dedicated `/ai-config` page for AI configuration, separate from settings.

#### Scenario: User navigates to AI config page
- **WHEN** user navigates to `/ai-config`
- **THEN** system displays AI configuration form with all required fields

### Requirement: All AI config fields are required
The system SHALL require all AI configuration fields to be filled before saving.

#### Scenario: User submits complete config
- **WHEN** user fills all fields and clicks save
- **THEN** system validates all fields
- **AND** saves configuration to database
- **AND** displays success message

#### Scenario: User submits incomplete config
- **WHEN** user leaves any field empty and clicks save
- **THEN** system displays validation error
- **AND** does not save configuration

### Requirement: Preferred model configuration
The system SHALL require user to select a preferred AI model.

#### Scenario: User selects model
- **WHEN** user selects a model from the dropdown
- **THEN** system records the selection

### Requirement: Temperature configuration
The system SHALL require user to set generation temperature (0.0-2.0).

#### Scenario: User sets valid temperature
- **WHEN** user enters a value between 0.0 and 2.0
- **THEN** system accepts the value

#### Scenario: User sets invalid temperature
- **WHEN** user enters a value outside 0.0-2.0 range
- **THEN** system displays validation error

### Requirement: Max tokens configuration
The system SHALL require user to set maximum tokens for responses.

#### Scenario: User sets max tokens
- **WHEN** user enters a positive integer
- **THEN** system records the value

### Requirement: System prompt configuration
The system SHALL require user to provide a system prompt.

#### Scenario: User enters system prompt
- **WHEN** user enters text in the system prompt textarea
- **THEN** system records the prompt

### Requirement: Response language configuration
The system SHALL require user to select a response language (zh or en).

#### Scenario: User selects language
- **WHEN** user selects zh or en
- **THEN** system records the language preference

### Requirement: Custom API URL configuration
The system SHALL require user to provide an API endpoint URL.

#### Scenario: User enters valid URL
- **WHEN** user enters a valid https URL
- **THEN** system accepts the URL

#### Scenario: User enters invalid URL
- **WHEN** user enters an invalid URL format
- **THEN** system displays validation error

### Requirement: Custom API Key configuration
The system SHALL require user to provide an API key.

#### Scenario: User enters API key
- **WHEN** user enters their API key
- **THEN** system saves the key

#### Scenario: API Key display is masked
- **WHEN** user views their saved API key
- **THEN** system displays masked version (e.g., sk-***...***abc)

### Requirement: User can modify AI config
The system SHALL allow users to update their AI configuration at any time.

#### Scenario: User updates config
- **WHEN** user modifies any field and saves
- **THEN** system updates the configuration
- **AND** subsequent requests use new settings
