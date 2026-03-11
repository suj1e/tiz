# Auth Initialization Specification

## ADDED Requirements

### Requirement: Token persistence

The system SHALL persist the authentication token to localStorage when user logs in.

#### Scenario: Login saves token
- **WHEN** user successfully logs in
- **THEN** system stores the token in localStorage with key `tiz-web-token`

#### Scenario: Logout clears token
- **WHEN** user logs out
- **THEN** system removes the token from localStorage

### Requirement: Auth state initialization on app start

The system SHALL initialize the authentication state when the application starts.

#### Scenario: Valid token in localStorage
- **WHEN** app starts and localStorage contains a valid token
- **THEN** system validates the token by calling `/auth/v1/me`
- **THEN** system sets `isAuthenticated` to `true` if token is valid
- **THEN** system sets `isLoading` to `false` after initialization

#### Scenario: No token in localStorage
- **WHEN** app starts and localStorage does not contain a token
- **THEN** system sets `isAuthenticated` to `false`
- **THEN** system sets `isLoading` to `false`

#### Scenario: Expired token in localStorage
- **WHEN** app starts and localStorage contains an expired token
- **THEN** system attempts to validate the token
- **THEN** system receives 401 error
- **THEN** system clears the token from localStorage
- **THEN** system sets `isAuthenticated` to `false`
- **THEN** system sets `isLoading` to `false`

### Requirement: Protected route behavior

The system SHALL properly handle protected routes during and after auth initialization.

#### Scenario: Access protected route while loading
- **WHEN** user navigates to a protected route while `isLoading` is `true`
- **THEN** system displays a loading indicator
- **THEN** system waits for initialization to complete

#### Scenario: Access protected route after initialization (authenticated)
- **WHEN** user navigates to a protected route and `isAuthenticated` is `true`
- **THEN** system renders the protected content

#### Scenario: Access protected route after initialization (not authenticated)
- **WHEN** user navigates to a protected route and `isAuthenticated` is `false`
- **THEN** system redirects to `/login`
- **THEN** system preserves the original destination in location state

### Requirement: Start trial button navigation

The system SHALL navigate users appropriately based on their authentication and AI configuration status when clicking "开始试用".

#### Scenario: Not logged in
- **WHEN** user clicks "开始试用" and is not logged in
- **THEN** system redirects to `/login`

#### Scenario: Logged in but AI not configured
- **WHEN** user clicks "开始试用" and is logged in but has not configured AI
- **THEN** system redirects to `/ai-config`

#### Scenario: Logged in and AI configured
- **WHEN** user clicks "开始试用" and is logged in and has configured AI
- **THEN** system redirects to `/chat`

### Requirement: 404 page back button

The system SHALL handle the back button gracefully when there is no browser history.

#### Scenario: Back button with history
- **WHEN** user clicks "返回上页" and browser has history
- **THEN** system navigates to the previous page

#### Scenario: Back button without history
- **WHEN** user clicks "返回上页" and browser has no history
- **THEN** system navigates to `/home`
