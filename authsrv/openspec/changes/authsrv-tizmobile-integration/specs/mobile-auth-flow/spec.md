## ADDED Requirements

### Requirement: Login Screen
The mobile app SHALL display a login screen for user authentication.

#### Scenario: Display login screen
- **WHEN** unauthenticated user launches app
- **THEN** login screen is displayed with username/password fields and login button

#### Scenario: Login form validation
- **WHEN** user taps login with empty fields
- **THEN** validation errors are shown for empty required fields

#### Scenario: Login form submission
- **WHEN** user taps login with valid credentials
- **THEN** loading indicator is shown, API call is made

### Requirement: Registration Screen
The mobile app SHALL display a registration screen for new users.

#### Scenario: Navigate to registration
- **WHEN** user taps "Register" link on login screen
- **THEN** registration screen is displayed

#### Scenario: Registration form fields
- **THEN** registration screen contains: username, email, password, confirm password fields

#### Scenario: Successful registration
- **WHEN** user submits valid registration data
- **THEN** user is created, user is auto-logged in, main screen is shown

### Requirement: Authentication State Management
The mobile app SHALL maintain and react to authentication state.

#### Scenario: User is logged in
- **WHEN** valid tokens exist in Keychain
- **THEN** app shows main authenticated content

#### Scenario: User is logged out
- **WHEN** no valid tokens exist
- **THEN** app shows login screen

#### Scenario: Token expired during use
- **WHEN** API returns 401 with TOKEN_EXPIRED
- **THEN** app attempts to refresh token using refresh token

#### Scenario: Token refresh fails
- **WHEN** refresh token is invalid or expired
- **THEN** user is redirected to login screen

### Requirement: Authenticated Navigation
The mobile app SHALL protect routes requiring authentication.

#### Scenario: Access protected route without auth
- **WHEN** user navigates to protected screen without tokens
- **THEN** user is redirected to login screen

#### Scenario: Access protected route with valid auth
- **WHEN** user navigates to protected screen with valid tokens
- **THEN** user sees the protected content
