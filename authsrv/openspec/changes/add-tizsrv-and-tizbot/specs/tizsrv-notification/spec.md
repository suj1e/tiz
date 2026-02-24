## ADDED Requirements

### Requirement: Notification List
The system SHALL provide a list of notifications for the authenticated user.

#### Scenario: Get notifications
- **WHEN** authenticated user calls GET /api/v1/notifications
- **THEN** system returns paginated list of notifications

#### Scenario: Mark notification as read
- **WHEN** user clicks on a notification
- **THEN** notification is marked as read

### Requirement: Send Notification
The system SHALL allow sending notifications to users.

#### Scenario: Create notification
- **WHEN** admin creates a notification
- **THEN** notification is stored and delivered to target users

### Requirement: Notification Types
The system SHALL support different notification types.

#### Scenario: System notifies user
- **WHEN** system generates a notification
- **THEN** notification has type: SYSTEM, MESSAGE, ALERT, or PROMOTION
