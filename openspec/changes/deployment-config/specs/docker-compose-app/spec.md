## ADDED Requirements

### Requirement: Application services orchestration

The system SHALL define all application services in docker-compose-app.yml.

#### Scenario: Service list
- **WHEN** docker-compose-app.yml is deployed
- **THEN** following services are running: tiz-web, gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv, quizsrv, llmsrv, usersrv

### Requirement: Network configuration

The system SHALL configure proper network isolation.

#### Scenario: Frontend network
- **WHEN** tiz-web starts
- **THEN** it is connected to npass network
- **AND** can be accessed by npass reverse proxy

#### Scenario: Gateway network
- **WHEN** gatewaysrv starts
- **THEN** it is connected to npass network
- **AND** it is connected to tiz-backend network
- **AND** can route to all backend services

#### Scenario: Backend network isolation
- **WHEN** backend services start (authsrv, chatsrv, contentsrv, etc.)
- **THEN** they are connected only to tiz-backend network
- **AND** are NOT directly accessible from external

### Requirement: Service discovery

The system SHALL enable service-to-service communication via container names.

#### Scenario: Gateway routes to auth
- **WHEN** gatewaysrv receives request to /api/auth/v1/*
- **THEN** it proxies to authsrv:8101

#### Scenario: Contentsrv calls llmsrv
- **WHEN** contentsrv needs AI generation
- **THEN** it calls http://llmsrv:8106

### Requirement: Environment configuration

The system SHALL use environment variables for configuration.

#### Scenario: Database connection
- **WHEN** services need database
- **THEN** they use DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD variables

#### Scenario: Redis connection
- **WHEN** services need Redis
- **THEN** they use REDIS_HOST, REDIS_PORT variables

#### Scenario: External services
- **WHEN** services need external services
- **THEN** they use SERVICE_URLS from environment

### Requirement: Health checks

The system SHALL configure health checks for all services.

#### Scenario: Service health endpoint
- **WHEN** docker health check runs
- **THEN** it calls /actuator/health (Java) or /health (Python)
- **AND** expects 200 response within 30 seconds

### Requirement: Resource limits

The system SHALL configure resource limits for services.

#### Scenario: Memory limits
- **WHEN** services are deployed
- **THEN** Java services have max 512MB memory
- **AND** llmsrv has max 1GB memory
- **AND** tiz-web has max 128MB memory
