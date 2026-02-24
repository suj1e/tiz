## ADDED Requirements

### Requirement: API Client Configuration
The mobile app SHALL have a configurable API client pointing to the gateway service.

#### Scenario: API client initialized
- **WHEN** app launches
- **THEN** API client is configured with base URL from configuration

#### Scenario: Base URL configuration
- **WHEN** API client needs to make a request
- **THEN** base URL is loaded from app configuration (not hardcoded)

### Requirement: HTTP Request Execution
The mobile app SHALL execute HTTP requests through the API client.

#### Scenario: GET request
- **WHEN** app needs to fetch data
- **THEN** API client sends GET request with proper headers

#### Scenario: POST request
- **WHEN** app needs to send data
- **THEN** API client sends POST request with JSON body and headers

#### Scenario: Request includes auth header
- **WHEN** authenticated user makes a request
- **THEN** Authorization header is included with Bearer token

### Requirement: Response Handling
The mobile app SHALL handle API responses consistently.

#### Scenario: Successful response
- **WHEN** API returns 2xx status
- **THEN** response data is parsed and returned to caller

#### Scenario: Error response
- **WHEN** API returns 4xx or 5xx status
- **THEN** error is parsed and thrown as appropriate exception type

#### Scenario: Network error
- **WHEN** network request fails
- **THEN** network error is caught and reported to user

### Requirement: Token Management
The mobile app SHALL manage authentication tokens securely.

#### Scenario: Store tokens on login
- **WHEN** login is successful
- **THEN** access token and refresh token are stored securely in Keychain

#### Scenario: Retrieve tokens
- **WHEN** app needs to make authenticated request
- **THEN** tokens are retrieved from Keychain

#### Scenario: Clear tokens on logout
- **WHEN** user logs out
- **THEN** all tokens are removed from Keychain
