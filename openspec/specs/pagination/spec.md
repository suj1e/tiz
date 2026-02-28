## MODIFIED Requirements

### Requirement: Cursor-based pagination format

The system SHALL return paginated responses using cursor-based pagination for better performance and mobile-friendly infinite scrolling.

#### Scenario: First page request
- **WHEN** client requests paginated data without a token
- **THEN** query parameter is: page_size (default 10)
- **AND** response body uses this format:
```json
{
  "data": [...],
  "has_more": true,
  "next_token": "eyJpZDoxMDA..."
}
```

#### Scenario: Subsequent page request
- **WHEN** client requests next page with page_token
- **THEN** query parameters are: page_size (default 10), page_token (from previous response)
- **AND** response returns items after the cursor position

#### Scenario: Empty result set
- **WHEN** API returns no results
- **THEN** data array is empty
- **AND** has_more is false
- **AND** next_token is null or absent

#### Scenario: Last page
- **WHEN** client requests the last page
- **THEN** has_more is false
- **AND** next_token is null or absent

### Requirement: Pagination parameter names

The system SHALL use cursor-based pagination parameters.

#### Scenario: Request parameters
- **WHEN** client requests paginated data
- **THEN** query parameters are:
  - page_size (optional, default 10, max 100)
  - page_token (optional, cursor from previous response)

#### Scenario: Custom page size
- **WHEN** client specifies page_size=20
- **THEN** response contains up to 20 items
- **AND** has_more indicates if more items exist

### Requirement: Cursor token format

The system SHALL encode cursor tokens in a secure and stateless manner.

#### Scenario: Token encoding
- **WHEN** system generates a next_token
- **THEN** token is a base64-encoded JSON string containing the cursor position
- **AND** token typically contains the last item's ID or timestamp
