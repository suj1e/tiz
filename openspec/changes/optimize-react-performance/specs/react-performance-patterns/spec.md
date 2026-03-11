## ADDED Requirements

### Requirement: Independent async operations SHALL be parallelized

When multiple asynchronous operations are independent (no data dependency between them), the system SHALL execute them in parallel using Promise.all instead of sequential awaits.

#### Scenario: AuthProvider initialization parallelizes user fetch and AI config check
- **WHEN** AuthProvider initializes and needs to fetch user data and check AI config status
- **THEN** both operations SHALL execute in parallel using Promise.all
- **AND** the total wait time SHALL be approximately max(fetchTime, configTime) instead of sum

#### Scenario: LoginPage parallelizes login and subsequent checks when possible
- **WHEN** user logs in and system needs to perform post-login checks
- **THEN** independent operations SHALL execute in parallel
- **AND** dependent operations SHALL wait for their dependencies first

### Requirement: Derived state SHALL be computed during render with useMemo

Derived state that can be calculated from existing state SHALL be computed during render using useMemo, not in useEffect with separate useState.

#### Scenario: LibraryPage filters libraries without extra render cycle
- **WHEN** user selects a category, tags, or enters search query
- **THEN** filtered libraries SHALL be computed via useMemo during the same render cycle
- **AND** no additional render cycle SHALL be triggered for the filtering operation

#### Scenario: Derived state updates reactively when dependencies change
- **WHEN** any dependency of derived state changes (libraries, filters, search)
- **THEN** the derived value SHALL be recalculated automatically
- **AND** the calculation SHALL only occur when dependencies actually change

### Requirement: Large lists SHALL use content-visibility for off-screen optimization

Components rendering lists of 10+ items SHALL apply content-visibility: auto to off-screen items to skip layout and rendering work.

#### Scenario: LibraryList applies content-visibility to library cards
- **WHEN** LibraryList renders a grid of library cards
- **THEN** each card SHALL have content-visibility: auto applied
- **AND** off-screen cards SHALL skip rendering until they approach the viewport

#### Scenario: Scrolled content renders smoothly
- **WHEN** user scrolls through a large list
- **THEN** content SHALL render without visible blank areas
- **AND** contain-intrinsic-size SHALL provide estimated height to prevent layout shift
