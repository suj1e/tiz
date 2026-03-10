## ADDED Requirements

### Requirement: Button has enhanced hover states

The system SHALL provide buttons with refined visual feedback.

#### Scenario: Primary button hover
- **WHEN** user hovers over a primary button
- **THEN** the button SHALL show a lighter primary color
- **AND** apply a subtle scale transform

#### Scenario: Button active state
- **WHEN** user presses a button
- **THEN** the button SHALL show a darker color
- **AND** the transition SHALL complete within 150ms

### Requirement: Card has hover elevation

The system SHALL provide cards with hover elevation effect.

#### Scenario: Card hover effect
- **WHEN** user hovers over a card
- **THEN** the card SHALL translate up by 4px
- **AND** show an expanded shadow
- **AND** the transition SHALL complete within 200ms

### Requirement: Chat message has entry animation

The system SHALL animate chat messages on entry.

#### Scenario: User message appears
- **WHEN** a user message is added
- **THEN** it SHALL fade in (opacity 0 to 1)
- **AND** slide up (translateY 8px to 0)
- **AND** the animation SHALL complete within 200ms

#### Scenario: AI message appears
- **WHEN** an AI message is added
- **THEN** it SHALL fade in from the left
- **AND** the animation SHALL complete within 200ms

### Requirement: Chat bubble styles differentiated

The system SHALL visually differentiate user and AI messages.

#### Scenario: User message style
- **WHEN** a user message is displayed
- **THEN** it SHALL have primary color background
- **AND** white text
- **AND** be right-aligned

#### Scenario: AI message style
- **WHEN** an AI message is displayed
- **THEN** it SHALL have muted color background
- **AND** normal text color
- **AND** be left-aligned
- **AND** display an AI avatar indicator

### Requirement: Typing indicator shows cursor

The system SHALL display a blinking cursor during AI streaming.

#### Scenario: Streaming cursor visible
- **WHEN** AI is streaming a response
- **THEN** a blinking cursor SHALL appear at the end of the message
- **AND** the blink cycle SHALL be 1 second

### Requirement: Question options show selection state

The system SHALL provide clear visual feedback for selected options.

#### Scenario: Option selected
- **WHEN** user selects a question option
- **THEN** the option SHALL show a left border in primary color
- **AND** the background SHALL have a subtle primary tint

#### Scenario: Option hover
- **WHEN** user hovers over an unselected option
- **THEN** the option SHALL show a subtle background change

### Requirement: Progress bar shows gradient

The system SHALL display progress bars with gradient colors.

#### Scenario: Progress bar gradient
- **WHEN** a progress bar is displayed
- **THEN** it SHALL show a gradient from primary to accent color

#### Scenario: Progress bar completion
- **WHEN** progress reaches 100%
- **THEN** the progress bar SHALL transition to success color

### Requirement: Difficulty badges color-coded

The system SHALL display difficulty badges with appropriate colors.

#### Scenario: Easy difficulty
- **WHEN** a question set has "easy" difficulty
- **THEN** the badge SHALL use success (green) color

#### Scenario: Medium difficulty
- **WHEN** a question set has "medium" difficulty
- **THEN** the badge SHALL use warning (orange) color

#### Scenario: Hard difficulty
- **WHEN** a question set has "hard" difficulty
- **THEN** the badge SHALL use destructive (red) color

### Requirement: Landing page hero has gradient background

The system SHALL display a gradient background on the landing page hero.

#### Scenario: Hero gradient visible
- **WHEN** the landing page is displayed
- **THEN** the hero section SHALL have a subtle gradient or glow effect

### Requirement: Empty state has visual appeal

The system SHALL display visually appealing empty states.

#### Scenario: Chat empty state
- **WHEN** the chat has no messages
- **THEN** it SHALL display the Logo with glow effect
- **AND** show a welcoming headline
- **AND** show quick-start suggestion buttons with hover effects
