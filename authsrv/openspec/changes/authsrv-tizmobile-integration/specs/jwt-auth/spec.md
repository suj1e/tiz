## ADDED Requirements

### Requirement: Access Token Generation
The system SHALL generate a JWT access token upon successful login or token refresh.

#### Scenario: Generate access token on login
- **WHEN** user provides valid username and password
- **THEN** system returns a valid JWT access token with 15-minute expiration

#### Scenario: Access token contains required claims
- **WHEN** system generates an access token
- **THEN** token contains: subject (userId), issued-at, expiration, token-type ("access")

### Requirement: Refresh Token Generation
The system SHALL generate a refresh token upon successful login for token renewal.

#### Scenario: Generate refresh token on login
- **WHEN** user provides valid credentials
- **THEN** system returns a refresh token with 7-day expiration

#### Scenario: Refresh token is opaque
- **WHEN** system generates a refresh token
- **THEN** token is a secure random string (not JWT), stored in database

### Requirement: Token Validation
The system SHALL validate access tokens on protected resource requests.

#### Scenario: Valid access token
- **WHEN** request includes valid, non-expired access token
- **THEN** request is allowed to proceed

#### Scenario: Expired access token
- **WHEN** request includes expired access token
- **THEN** system returns 401 Unauthorized with "TOKEN_EXPIRED" error code

#### Scenario: Invalid access token
- **WHEN** request includes malformed or tampered token
- **THEN** system returns 401 Unauthorized with "TOKEN_INVALID" error code

### Requirement: Token Refresh
The system SHALL allow refreshing an expired access token using a valid refresh token.

#### Scenario: Refresh with valid refresh token
- **WHEN** user provides valid refresh token
- **THEN** system returns new access token and new refresh token

#### Scenario: Refresh with expired/invalid refresh token
- **WHEN** user provides expired or invalid refresh token
- **THEN** system returns 401 Unauthorized, user must re-login

### Requirement: Token Blacklist (Logout)
The system SHALL support logout by invalidating tokens.

#### Scenario: Logout with valid access token
- **WHEN** user calls logout endpoint with valid access token
- **THEN** access token is added to blacklist and invalidated

#### Scenario: Blacklisted token rejected
- **WHEN** request includes a blacklisted token
- **THEN** system returns 401 Unauthorized with "TOKEN_REVOKED" error code
