# Design: Align authsrv with Panck Skill Standards

## Context

authsrv currently uses:
- Package: `com.nexora`
- Redundant Gradle plugins (java + java-library)
- Jib for containerization
- Complex repository configuration with private repos

Panck skill defines:
- Package: `io.github.suj1e`
- Single plugin per module type (java-library for libraries, java+spring-boot for boot)
- Dockerfile for containerization
- Simplified repos (mavenLocal, aliyun mirror, mavenCentral)

## Goals / Non-Goals

**Goals:**
- Align build configuration with panck skill templates
- Migrate package namespace to `io.github.suj1e`
- Simplify Gradle configuration
- Add missing tooling (z.sh)

**Non-Goals:**
- Change business logic or functionality
- Add new features
- Modify API contracts

## Decisions

### Decision 1: Package Migration Strategy

Use IDE refactoring or find-and-replace to migrate all Java files from `com.nexora.auth` to `io.github.suj1e.auth`. This is a mechanical change with no runtime impact.

### Decision 2: Plugin Simplification

- Root: Only `java` plugin (aggregation project)
- api/core/adapter: Only `java-library` plugin (includes java transitively)
- boot: `java` + `spring-boot` plugins (executable application)

### Decision 3: Containerization

Remove Jib plugin and rely on existing Dockerfile. This matches panck standard and simplifies build.

### Decision 4: Testcontainers

Add testcontainers dependencies since authsrv uses both Kafka and JPA:
- `testcontainers-kafka` for Kafka integration tests
- `testcontainers-mysql` for database integration tests
- `testcontainers-junit` for JUnit 5 support
