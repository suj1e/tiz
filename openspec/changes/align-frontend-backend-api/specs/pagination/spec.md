## MODIFIED Requirements

### Requirement: Paginated response format

The system SHALL return paginated responses in a standardized format with consistent field names.

#### Scenario: Successful paginated response
- **WHEN** API returns a paginated list
- **THEN** response body uses this format:
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "page_size": 10,
    "total": 50,
    "total_pages": 5
  }
}
```

#### Scenario: Empty result set
- **WHEN** API returns no results
- **THEN** data array is empty
- **AND** pagination.total is 0
- **AND** pagination.total_pages is 0

#### Scenario: Last page
- **WHEN** user requests the last page
- **THEN** pagination.page equals pagination.total_pages
- **AND** data array contains remaining items

### Requirement: Pagination parameter names

The system SHALL use consistent pagination parameter names in requests.

#### Scenario: Request with pagination
- **WHEN** client requests paginated data
- **THEN** query parameters are: page (default 1), page_size (default 10)

#### Scenario: Custom page size
- **WHEN** client specifies page_size=20
- **THEN** response contains up to 20 items
- **AND** pagination.page_size is 20
