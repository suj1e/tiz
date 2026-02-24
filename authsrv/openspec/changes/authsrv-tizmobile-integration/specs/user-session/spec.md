## ADDED Requirements

### Requirement: User Login
The system SHALL authenticate users with username and password.

#### Scenario: Successful login
- **WHEN** user provides valid username and password
- **THEN** system returns access token, refresh token, and expiration time

#### Scenario: Invalid credentials
- **WHEN** user provides invalid username or password
- **THEN** system returns 401 Unauthorized with "INVALID_CREDENTIALS" error

#### Scenario: Account locked after failed attempts
- **WHEN** user fails to login 5 times within 15 minutes
- **THEN** account is locked for 30 minutes, subsequent attempts return "ACCOUNT_LOCKED"

### Requirement: User Registration
The system SHALL allow new users to register with username, email, and password.

#### Scenario: Successful registration
- **WHEN** user provides valid username (unique), email (valid format), and password (min 8 chars)
- **THEN** user is created with ACTIVE status, system returns success

#### Scenario: Duplicate username
- **WHEN** user attempts to register with existing username
- **THEN** system returns 400 Bad Request with "USERNAME_EXISTS" error

#### Scenario: Duplicate email
- **WHEN** user attempts to register with existing email
- **THEN** system returns 400 Bad Request with "EMAIL_EXISTS" error

#### Scenario: Weak password
- **WHEN** user provides password less than 8 characters
- **THEN** system returns 400 Bad Request with "WEAK_PASSWORD" error

### Requirement: User Logout
The system SHALL allow authenticated users to logout.

#### Scenario: Successful logout
- **WHEN** authenticated user calls logout endpoint
- **THEN** token is invalidated, session is cleared, returns success

### Requirement: Get Current User
The system SHALL return the current authenticated user's profile.

#### Scenario: Get current user with valid token
- **WHEN** authenticated user calls GET /me endpoint
- **THEN** system returns user profile (id, username, email, nickname, avatar, status)

#### Scenario: Get current user without token
- **WHEN** unauthenticated user calls GET /me endpoint
- **THEN** system returns 401 Unauthorized

### Requirement: Update Current User Profile
The system SHALL allow users to update their profile information.

#### Scenario: Update profile successfully
- **WHEN** authenticated user updates nickname or email
- **THEN** changes are saved, returns updated user profile

#### Scenario: Update email to existing value
- **WHEN** user updates email to another user's email
- **THEN** system returns 400 Bad Request with "EMAIL_EXISTS" error
