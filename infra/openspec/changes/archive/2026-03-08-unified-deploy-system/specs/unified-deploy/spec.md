## ADDED Requirements

### Requirement: Unified deploy directory structure
The system SHALL provide a `deploy/` directory with staging and prod subdirectories for environment-specific configurations.

#### Scenario: Directory structure exists
- **WHEN** developer inspects the project root
- **THEN** `deploy/staging/` and `deploy/prod/` directories exist
- **AND** each contains `docker-compose.yml` and `.env` files

### Requirement: Unified deploy script
The system SHALL provide a `deploy/deploy.sh` script that manages the full deployment lifecycle.

#### Scenario: Deploy all services
- **WHEN** user runs `./deploy.sh staging deploy`
- **THEN** all application services start in staging environment

#### Scenario: Deploy single service
- **WHEN** user runs `./deploy.sh staging deploy auth-service`
- **THEN** only auth-service is deployed

#### Scenario: Stop services
- **WHEN** user runs `./deploy.sh staging stop`
- **THEN** all services in staging environment stop

#### Scenario: Restart services
- **WHEN** user runs `./deploy.sh staging restart`
- **THEN** all services restart in staging environment

#### Scenario: View logs
- **WHEN** user runs `./deploy.sh staging logs`
- **THEN** logs from all services display
- **WHEN** user runs `./deploy.sh staging logs auth-service`
- **THEN** only auth-service logs display

#### Scenario: Check status
- **WHEN** user runs `./deploy.sh staging status`
- **THEN** health status of all services displays

#### Scenario: List containers
- **WHEN** user runs `./deploy.sh staging ps`
- **THEN** list of running containers with status displays

#### Scenario: Rollback service
- **WHEN** user runs `./deploy.sh staging rollback auth-service`
- **THEN** auth-service reverts to previous image version

### Requirement: Docker compose configuration
Each environment's `docker-compose.yml` SHALL include all application services: frontend (tiz-web), gateway, and 7 backend services.

#### Scenario: All services defined
- **WHEN** docker-compose.yml is parsed
- **THEN** services include: tiz-web, gateway, auth-service, chat-service, content-service, practice-service, quiz-service, user-service, llm-service

#### Scenario: Network configuration
- **WHEN** services start
- **THEN** all services connect to `npass` external network
