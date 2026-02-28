## ADDED Requirements

### Requirement: Generate questions from chat session

The system SHALL allow users to generate practice questions from a completed chat session.

#### Scenario: Generate questions with default options
- **WHEN** user calls POST /api/content/v1/generate with session_id
- **THEN** system creates a knowledge set and returns questions in batches
- **AND** response includes knowledge_set_id, questions, and batch metadata

#### Scenario: Generate questions with custom options
- **WHEN** user calls POST /api/content/v1/generate with session_id, question_types, difficulty, question_count
- **THEN** system generates questions matching the specified options
- **AND** response includes knowledge_set_id, questions, and batch metadata

### Requirement: Fetch question batches

The system SHALL allow users to fetch additional question batches for a generation session.

#### Scenario: Fetch next batch
- **WHEN** user calls GET /api/content/v1/generate/:id/batch?page=2
- **THEN** system returns the next batch of questions
- **AND** response includes questions and batch metadata with has_more flag

#### Scenario: No more batches
- **WHEN** user calls GET /api/content/v1/generate/:id/batch with page exceeding total batches
- **THEN** system returns empty questions array
- **AND** has_more is false

### Requirement: Generation response format

The system SHALL return generation responses in the following format:

```json
{
  "data": {
    "knowledge_set_id": "uuid",
    "questions": [
      {
        "id": "uuid",
        "type": "choice|essay",
        "content": "question text",
        "options": ["A", "B", "C", "D"],
        "answer": "B",
        "explanation": "explanation text"
      }
    ],
    "batch": {
      "current": 1,
      "total": 3,
      "has_more": true
    }
  }
}
```

#### Scenario: Response includes all required fields
- **WHEN** generation completes
- **THEN** response includes knowledge_set_id, questions array, and batch metadata
- **AND** batch includes current, total, and has_more fields
