## ADDED Requirements

### Requirement: Each service has independent docker-compose.yml

Each backend service SHALL have its own docker-compose.yml file for independent deployment.

#### Scenario: Service directory contains docker-compose.yml
- **WHEN** developer navigates to any service directory (authsrv, gatewaysrv, etc.)
- **THEN** a docker-compose.yml file SHALL exist in that directory

#### Scenario: Independent service startup
- **WHEN** developer runs `docker-compose up` in a service directory
- **THEN** only that service SHALL start (no other services)

### Requirement: Nacos config follows code

Nacos configuration files SHALL be located in tiz-backend directory.

#### Scenario: Nacos config location
- **WHEN** developer needs to modify Nacos configuration
- **THEN** configuration files SHALL be found at `tiz-backend/nacos-config/`

#### Scenario: Multi-environment config
- **WHEN** developer checks nacos-config directory
- **THEN** subdirectories for dev, staging, and prod SHALL exist

### Requirement: Services connect to shared network

All services SHALL connect to the external `npass` network.

#### Scenario: Network configuration
- **WHEN** service starts via docker-compose
- **THEN** service SHALL connect to `npass` external network

### Requirement: No centralized deployment file

The deploy/docker-compose.yml file SHALL be removed.

#### Scenario: Deploy directory cleanup
- **WHEN** refactoring is complete
- **THEN** deploy/docker-compose.yml SHALL NOT exist
