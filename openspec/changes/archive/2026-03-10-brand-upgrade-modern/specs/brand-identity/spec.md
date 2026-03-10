## ADDED Requirements

### Requirement: Logo component exists

The system SHALL provide a reusable Logo component.

#### Scenario: Logo renders with gradient background
- **WHEN** the Logo component renders
- **THEN** it SHALL display a rounded square with gradient background (primary to primary/80)
- **AND** it SHALL display a white "T" character centered
- **AND** the "T" SHALL use the display font (Sora)

#### Scenario: Logo has hover effect
- **WHEN** user hovers over the Logo
- **THEN** it SHALL apply a subtle scale transform (1.05)
- **AND** it SHALL show a glow shadow effect

### Requirement: Fonts loaded from Google Fonts

The system SHALL load brand fonts from Google Fonts CDN.

#### Scenario: Noto Sans SC loaded
- **WHEN** the application loads
- **THEN** Noto Sans SC font (weights 400, 500, 600, 700) SHALL be loaded from Google Fonts

#### Scenario: Sora loaded
- **WHEN** the application loads
- **THEN** Sora font (weights 400, 500, 600, 700) SHALL be loaded from Google Fonts

#### Scenario: Font display swap
- **WHEN** fonts are loading
- **THEN** text SHALL remain visible using fallback fonts (font-display: swap)

### Requirement: Brand colors applied consistently

The system SHALL apply brand colors consistently across all components.

#### Scenario: Primary color used for CTAs
- **WHEN** a primary action button is displayed
- **THEN** it SHALL use the --primary background color

#### Scenario: Accent color used for highlights
- **WHEN** highlighting important information (e.g., difficulty badges, progress)
- **THEN** it SHALL use the --accent color

### Requirement: Logo used in navigation

The system SHALL display the Logo in navigation areas.

#### Scenario: Logo in desktop sidebar
- **WHEN** the desktop layout is displayed
- **THEN** the Logo SHALL appear in the Sidebar header

#### Scenario: Logo in mobile header
- **WHEN** the mobile layout is displayed
- **THEN** the Logo SHALL appear in the Header

#### Scenario: Logo in landing page
- **WHEN** the landing page is displayed
- **THEN** the Logo SHALL appear in the navigation bar
