## ADDED Requirements

### Requirement: Dependabot checks Gradle dependencies

The system SHALL use Dependabot to check for Gradle dependency updates in all Java services.

#### Scenario: Weekly Gradle dependency check
- **WHEN** Dependabot runs its scheduled check
- **THEN** it scans all `tiz-backend/*/build.gradle.kts` and `libs.versions.toml` files
- **AND** creates PRs for outdated dependencies

#### Scenario: Gradle dependency PR includes version catalog
- **WHEN** a Gradle dependency is outdated
- **THEN** the PR updates `libs.versions.toml` version references
- **AND** PR title includes the dependency name and version change

### Requirement: Dependabot checks npm dependencies

The system SHALL use Dependabot to check for npm/pnpm dependency updates in the frontend.

#### Scenario: Weekly npm dependency check
- **WHEN** Dependabot runs its scheduled check
- **THEN** it scans `tiz-web/package.json`
- **AND** creates PRs for outdated dependencies

### Requirement: Dependabot checks Python dependencies

The system SHALL use Dependabot to check for Python/pixi dependency updates in the LLM service.

#### Scenario: Weekly Python dependency check
- **WHEN** Dependabot runs its scheduled check
- **THEN** it scans `tiz-backend/llm-service/pyproject.toml`
- **AND** creates PRs for outdated dependencies

### Requirement: Dependabot groups related updates

The system SHALL group related dependency updates to reduce PR count.

#### Scenario: Group dependencies by ecosystem
- **WHEN** multiple dependencies in the same ecosystem have updates
- **THEN** Dependabot groups them into a single PR
- **AND** maximum 5 PRs per ecosystem per run

### Requirement: Dependabot runs on weekly schedule

The system SHALL run Dependabot checks on a weekly schedule.

#### Scenario: Weekly schedule execution
- **WHEN** Monday arrives (UTC)
- **THEN** Dependabot checks all configured ecosystems
- **AND** creates PRs before 06:00 UTC
