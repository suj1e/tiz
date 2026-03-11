## ADDED Requirements

### Requirement: User can view their profile information
The system SHALL display a profile page showing user's basic information.

#### Scenario: User navigates to profile page
- **WHEN** user clicks "个人信息" in the user menu
- **THEN** system navigates to /profile
- **AND** displays user's avatar, nickname, and email

### Requirement: User can edit their nickname
The system SHALL allow users to update their display name.

#### Scenario: User changes nickname
- **WHEN** user enters a new nickname and clicks save
- **THEN** system updates the nickname
- **AND** displays success message

#### Scenario: Empty nickname
- **WHEN** user submits an empty nickname
- **THEN** system shows validation error

### Requirement: User can view account status
The system SHALL display the user's account type and status on the profile page.

#### Scenario: Free account display
- **WHEN** user with free account views profile
- **THEN** system displays "免费账户" status

### Requirement: User can initiate email change
The system SHALL allow users to request an email address change.

#### Scenario: User clicks change email
- **WHEN** user clicks the "修改" button next to email
- **THEN** system shows email change dialog (placeholder for future implementation)

### Requirement: User can initiate password change
The system SHALL allow users to request a password change.

#### Scenario: User clicks change password
- **WHEN** user clicks the "修改" button next to password
- **THEN** system shows password change dialog (placeholder for future implementation)
