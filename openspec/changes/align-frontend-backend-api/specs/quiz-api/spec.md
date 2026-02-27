## MODIFIED Requirements

### Requirement: Quiz start accepts JSON body

The system SHALL accept quiz start request parameters in JSON body format.

#### Scenario: Start quiz with JSON body
- **WHEN** user calls POST /api/quiz/v1/start with JSON body:
```json
{
  "knowledge_set_id": "uuid",
  "time_limit": 15
}
```
- **THEN** system creates a quiz session
- **AND** returns HTTP 200 with response:
```json
{
  "data": {
    "quiz_id": "uuid",
    "questions": [...],
    "time_limit": 15,
    "started_at": "2024-02-26T00:00:00Z"
  }
}
```

#### Scenario: Start quiz without time limit
- **WHEN** user calls POST /api/quiz/v1/start with JSON body:
```json
{
  "knowledge_set_id": "uuid"
}
```
- **THEN** system creates a quiz session without time limit
- **AND** time_limit field is null in response

#### Scenario: Missing knowledge_set_id
- **WHEN** user calls POST /api/quiz/v1/start without knowledge_set_id
- **THEN** system returns HTTP 400 with validation error

### Requirement: Quiz start request validation

The system SHALL validate quiz start request parameters.

#### Scenario: Invalid knowledge_set_id format
- **WHEN** user provides non-UUID knowledge_set_id
- **THEN** system returns HTTP 400 with validation error

#### Scenario: Negative time_limit
- **WHEN** user provides negative time_limit value
- **THEN** system returns HTTP 400 with validation error
