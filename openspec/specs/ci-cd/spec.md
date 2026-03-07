## REMOVED Requirements

### Requirement: Staging deploy workflows
The system SHALL NOT include GitHub Actions workflows for automated staging deployment via SSH.

**Reason**: The embedded docker-compose pattern in deploy workflows creates configuration drift from source-controlled docker-compose files. After migrating to environment variables, maintaining two sets of configurations adds unnecessary complexity.

**Migration**: Use manual deployment or implement a new deployment pipeline that uses the source-controlled docker-compose.yml files directly.

---

## ADDED Requirements

### Requirement: CI/CD retains build and publish capabilities
The system SHALL provide GitHub Actions workflows for:
- Building and pushing Docker images (docker-*.yml)
- Publishing artifacts to Maven repository (publish-*.yml)

#### Scenario: Docker image build
- **WHEN** a maintainer triggers a docker-* workflow
- **THEN** the workflow builds and pushes the image to Aliyun Container Registry

#### Scenario: Maven artifact publish
- **WHEN** code changes on main branch in monitored paths
- **THEN** the corresponding publish-* workflow automatically publishes to Aliyun Maven
