# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Authsrv is an enterprise authentication and authorization service built with Java 21 and Spring Boot 4.0.2, implementing Domain-Driven Design (DDD) with clean layered architecture. It provides REST API and HTTP Interface (@HttpExchange) endpoints for integration.

## Project Structure

```
authsrv/
├── authsrv-api/          # API SDK - Client interfaces, DTOs, events (published as Maven artifact)
├── authsrv-core/         # Domain Layer - Entities, domain services (pure business logic)
├── authsrv-adapter/      # Adapter Layer - Controllers, repositories, infrastructure
├── authsrv-boot/         # Boot Layer - Application entry, main configuration
└── qa/                   # Quality Assurance - K6 load tests
```

**Module Dependencies:** Boot → Adapter → Core; API is standalone SDK used by other services.

## Common Commands

### Build & Run

```bash
# Build entire project
./gradlew clean build

# Run application (foreground)
./run.sh dev

# Run application (background)
./run.sh bg dev

# Check status
./run.sh status

# View logs
./run.sh logs [-f]

# Stop service
./run.sh stop

# Build JAR only
./gradlew :authsrv-boot:bootJar

# Build Docker image (Jib)
./gradlew jibDockerBuild
```

### Testing

```bash
# Run all tests
./gradlew test

# Run single test class
./gradlew test --tests AuthServiceTest

# Run single test method
./gradlew test --tests AuthServiceTest.testLogin

# Run K6 load tests
cd qa/k6
./load-test.sh -s smoke
./load-test.sh -s load
./load-test.sh -s stress

# Quick benchmark (requires wrk/hey/ab)
./benchmark.sh
```

### Database Migrations

```bash
# Flyway migrations run automatically on startup
# To manually migrate:
./gradlew :authsrv-boot:flywayMigrate

# Check migration status
./gradlew :authsrv-boot:flywayInfo
```

## Architecture

### API Routing

**Context Path:** `/auth`
**API Version:** `/v1`
**Management Port:** 40006 (app), 40007 (actuator)

Final URL format: `http://host:40006/auth/v1/{endpoint}`

Examples:
- Login: `POST /auth/v1/login`
- Register: `POST /auth/v1/register`
- Token refresh: `POST /auth/v1/refresh`
- Validate token: `GET /auth/v1/validate` (used by gateway)
- User info: `GET /auth/v1/users/me`
- Batch users: `GET /auth/v1/users/batch?ids=1,2,3`

### Layered Architecture

**Domain Layer** (`authsrv-core`):
- `User`, `Role`, `RefreshToken`, `AuditLog`, `OutboxEvent` entities
- `AuthDomainService`, `UserDomainService`, `TokenDomainService`

**Application Layer** (`authsrv-adapter/service`):
- `AuthService`, `UserService`, `TokenService`, `AuditService`

**Infrastructure Layer** (`authsrv-adapter/infra`):
- `repository/*` - JPA repositories with QueryDSL
- `security/*` - JWT filter, OAuth2 handlers
- `job/*` - Quartz jobs (account unlock, outbox publisher, token cleanup)

**Adapter Layer** (`authsrv-adapter/rest`):
- `AuthController`, `UserController`, `OAuth2Controller`, `FileUploadController`

### HTTP Interface SDK

The `authsrv-api` module provides `@HttpExchange` interfaces for other services:

```java
// In authsrv-api
@HttpExchange(url = "/v1", accept = "application/json")
public interface AuthClient {
    @PostExchange("/login")
    LoginResponse login(@RequestBody LoginRequest request);

    @GetExchange("/validate")
    TokenValidationResponse validateToken(@RequestParam String token);
}

// In consuming service
@Bean
public AuthClient authClient() {
    RestClient restClient = RestClient.builder()
        .baseUrl("http://authsrv:40006/auth")
        .build();
    HttpServiceProxyFactory factory = HttpServiceProxyFactory.builder()
        .clientAdapter(RestClientAdapter.create(restClient))
        .build();
    return factory.createClient(AuthClient.class);
}
```

## Configuration Management

**Hybrid Approach:** Local `.env` files + Nacos configuration center

### Environment Files

- `.env.example` - Template (in repo)
- `.env.{dev|test|prod}` - Environment defaults (gitignored)
- `.env.local` - Local overrides for dev (gitignored)

Loading order: `.env.{env}` → `.env.local` → environment variables

### Nacos Integration

```yaml
spring:
  config:
    import: optional:nacos:${spring.application.name}-${spring.profiles.active}.yml
```

Configuration split:
- **Local (immutable):** Ports, Nacos connection, JPA, Flyway
- **Nacos (refreshable):** Datasource, Redis, Kafka, security, business rules

### Refreshable Properties

`AuthProperties` class supports `@RefreshScope`:
- Password policy (min length, complexity)
- Brute force protection (max attempts, lockout duration)
- JWT settings (expiration, issuer, audience)
- OAuth2 providers
- CORS configuration

## Key Technologies

- **Spring Boot 4.0.2** + **Spring Cloud 2025.1.1** + **SCA 2025.1.0.0**
- **Nacos** - Service discovery & config management
- **MySQL 9.1.0** + **Flyway** - Database & migrations
- **Redis** - Caching, token blacklist
- **Kafka** - Event streaming (Outbox pattern)
- **Quartz** - Scheduled jobs
- **MapStruct** - DTO mapping
- **QueryDSL** - Type-safe queries

### Nexora Starters (Internal Frameworks)

- `nexora-spring-boot-starter-web` - Unified `Result<T>` response, global exception handling
- `nexora-spring-boot-starter-security` - JWT provider, encryption utilities
- `nexora-spring-boot-starter-redis` - Redis caching, token blacklist
- `nexora-spring-boot-starter-kafka` - Event publishing with DLQ
- `nexora-spring-boot-starter-resilience` - Circuit breaker, retry, timeout
- `nexora-spring-boot-starter-file-storage` - File upload handling
- `nexora-spring-boot-starter-data-jpa` - JPA auditing, soft delete
- `nexora-spring-boot-starter-audit` - Audit logging

## Security Patterns

### Authentication Flow

1. **Local:** Username/password (BCrypt, strength=12)
2. **OAuth2/OIDC:** Google, GitHub, custom providers
3. **JWT:** Access token (15min) + Refresh token (7 days)

### Security Features

- **Brute Force Protection:** Configurable max attempts, auto lockout
- **Account Locking:** Time-based locks with auto-unlock job
- **Password Policy:** Configurable complexity rules
- **Token Blacklist:** Redis-based revocation
- **Session Management:** Max concurrent sessions
- **CORS:** Environment-aware configuration

### Security Configuration

`SecurityConfig.java` - Stateless session management, role-based access control

Public endpoints: `/v1/login`, `/v1/register`, `/v1/refresh`, `/oauth2/**`, `/actuator/health/**`

## Background Jobs (Quartz)

- `AccountUnlockJob` - Auto-unlock expired locks
- `OutboxPublisherJob` - Publish events to Kafka (every 10s)
- `RefreshTokenCleanupJob` - Clean expired tokens

## Event Publishing (Outbox Pattern)

1. Business logic writes to `outbox_event` table in same transaction
2. Background job scans and publishes to Kafka
3. Ensures at-least-once delivery with retry

## Error Handling

`ErrorCode` enum organized by category:
- 10xx: Authentication errors
- 11xx: Registration errors
- 12xx: User errors
- 13xx: Role errors
- 14xx: OAuth2 errors
- 15xx: Session errors
- 16xx: File upload errors
- 17xx: Validation errors
- 50xx: System errors

## Important Notes

### API Path Convention

When adding new endpoints:
- Controllers use `@RequestMapping("/v1")` or `@RequestMapping("/v1/{resource}")`
- Do NOT use `/api/v1` prefix (context path `/auth` is already configured)
- Final URL: `{host}:40006/auth/v1/{endpoint}`

### Dependency Management

**ALL dependency versions must use the TOML catalog** (`gradle/libs.versions.toml`).

Never hardcode versions in `build.gradle.kts`. Use:
```kotlin
implementation(libs.some.library)
```

### Database Migrations

- Location: `authsrv-boot/src/main/resources/db/migration/`
- Naming: `V{number}__{description}.sql`
- Use MySQL syntax (BIGINT AUTO_INCREMENT, DATETIME, JSON)
- ON CONFLICT → ON DUPLICATE KEY UPDATE

### Performance Targets

- P50 < 50ms, P95 < 200ms, P99 < 500ms
- Login throughput: > 500 req/s
- Token validation: > 5000 req/s
- Error rate: < 0.1%
