## ADDED Requirements

### Requirement: Multi-environment directory structure

The infrastructure SHALL support separate configuration directories for dev, staging, and prod environments.

#### Scenario: Directory structure exists
- **WHEN** infrastructure is deployed
- **THEN** directories `infra/envs/dev/`, `infra/envs/staging/`, `infra/envs/prod/` SHALL exist
- **AND** each directory SHALL contain `docker-compose.yml` and `.env` files

### Requirement: Dev environment configuration

Dev environment SHALL use Docker named volumes and lower resource allocation for local development.

#### Scenario: Dev uses Docker named volumes
- **WHEN** dev environment is started
- **THEN** data SHALL be stored in Docker named volumes (mysql-data, redis-data, etc.)

#### Scenario: Dev resource limits
- **WHEN** dev environment is running
- **THEN** MySQL SHALL use default buffer pool
- **AND** Elasticsearch SHALL use 512M heap
- **AND** Kafka SHALL use 512M heap

### Requirement: Staging environment configuration

Staging environment SHALL use host directory mounts and medium resource allocation.

#### Scenario: Staging uses host directories
- **WHEN** staging environment is started
- **THEN** data SHALL be stored in host directory specified by `DATA_PATH` env var

#### Scenario: Staging resource limits
- **WHEN** staging environment is running
- **THEN** MySQL SHALL use 1G buffer pool
- **AND** Elasticsearch SHALL use 1G heap
- **AND** Kafka SHALL use 1G heap

### Requirement: Prod environment configuration

Prod environment SHALL use host directory mounts, high resource allocation, and minimal port exposure.

#### Scenario: Prod uses host directories
- **WHEN** prod environment is started
- **THEN** data SHALL be stored in host directory specified by `DATA_PATH` env var

#### Scenario: Prod resource limits
- **WHEN** prod environment is running
- **THEN** MySQL SHALL use 2G buffer pool
- **AND** Elasticsearch SHALL use 2G heap
- **AND** Kafka SHALL use 2G heap

#### Scenario: Prod minimal port exposure
- **WHEN** prod environment is running
- **THEN** only essential ports SHALL be exposed to host
- **AND** Kafka UI SHALL NOT be deployed

### Requirement: Unified management script

The `infra.sh` script SHALL support environment parameter to manage different environments.

#### Scenario: Start specific environment
- **WHEN** user runs `./infra.sh start --env staging`
- **THEN** staging environment SHALL be started

#### Scenario: Default to dev environment
- **WHEN** user runs `./infra.sh start` without --env
- **THEN** dev environment SHALL be started

#### Scenario: Show environment in status
- **WHEN** user runs `./infra.sh status`
- **THEN** current environment SHALL be displayed
