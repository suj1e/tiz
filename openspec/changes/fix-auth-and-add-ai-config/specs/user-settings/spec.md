## MODIFIED Requirements

### Requirement: Settings page displays only system preferences
The system SHALL display only system-level preferences on the settings page (theme, notifications, webhooks).

#### Scenario: User views settings page
- **WHEN** user navigates to `/settings`
- **THEN** system displays theme, notification, and webhook sections
- **AND** does NOT display AI configuration section
- **AND** does NOT display account information section

## ADDED Requirements

### Requirement: Account information moved to profile page
The system SHALL NOT display account information section on settings page.

#### Scenario: User views settings page
- **WHEN** user navigates to `/settings`
- **THEN** system does NOT display 账户信息 section
- **AND** account information is available on `/profile` page instead

### Requirement: AI configuration moved to dedicated page
The system SHALL NOT display AI configuration section on settings page.

#### Scenario: User views settings page
- **WHEN** user navigates to `/settings`
- **THEN** system does NOT display AI 配置 section
- **AND** AI configuration is available on `/ai-config` page instead
