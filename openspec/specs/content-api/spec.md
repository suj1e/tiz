## MODIFIED Requirements

### Requirement: Category response includes count

The system SHALL include the count of knowledge sets in each category response.

#### Scenario: Get all categories
- **WHEN** user calls GET /api/content/v1/categories
- **THEN** system returns:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "编程基础",
      "count": 5
    }
  ]
}
```

#### Scenario: Category with no knowledge sets
- **WHEN** a category has no associated knowledge sets
- **THEN** count is 0

### Requirement: Tag response includes count

The system SHALL include the count of knowledge sets for each tag in the response.

#### Scenario: Get all tags
- **WHEN** user calls GET /api/content/v1/tags
- **THEN** system returns:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "JavaScript",
      "count": 8
    }
  ]
}
```

#### Scenario: Tag with no knowledge sets
- **WHEN** a tag has no associated knowledge sets
- **THEN** count is 0

## ADDED Requirements

### Requirement: Category response format

The system SHALL return categories as a direct array in the data field.

#### Scenario: Categories response structure
- **WHEN** user requests categories
- **THEN** response is `{ "data": [CategoryResponse...] }`
- **AND** each CategoryResponse includes id, name, count

### Requirement: Tag response format

The system SHALL return tags as a direct array in the data field.

#### Scenario: Tags response structure
- **WHEN** user requests tags
- **THEN** response is `{ "data": [TagResponse...] }`
- **AND** each TagResponse includes id, name, count
