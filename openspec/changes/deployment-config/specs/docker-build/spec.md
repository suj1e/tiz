## ADDED Requirements

### Requirement: Java service Dockerfile

The system SHALL provide a multi-stage Dockerfile for Java services.

#### Scenario: Build Java service image
- **WHEN** Docker builds a Java service image
- **THEN** it uses gradle:8.12-jdk21 for building
- **AND** uses eclipse-temurin:21-jre-alpine for runtime
- **AND** the final image size is under 200MB

#### Scenario: Build arguments
- **WHEN** building a specific service
- **THEN** SERVICE_NAME build argument specifies the service
- **AND** PORT build argument specifies the exposed port

### Requirement: Frontend Dockerfile

The system SHALL provide a multi-stage Dockerfile for the frontend.

#### Scenario: Build frontend image
- **WHEN** Docker builds tiz-web image
- **THEN** it uses node:20-alpine for building
- **AND** uses nginx:alpine for serving
- **AND** the final image size is under 50MB

### Requirement: Python service Dockerfile

The system SHALL provide a multi-stage Dockerfile for llmsrv.

#### Scenario: Build llmsrv image
- **WHEN** Docker builds llmsrv image
- **THEN** it uses python:3.11-slim for building and runtime
- **AND** uses pixi for dependency management
- **AND** runs as non-root user

### Requirement: Image tagging

The system SHALL tag images consistently.

#### Scenario: Version tag
- **WHEN** building from Git tag v1.0.0
- **THEN** image is tagged as ghcr.io/suj1e/tiz/<service>:v1.0.0
- **AND** image is also tagged as ghcr.io/suj1e/tiz/<service>:latest

#### Scenario: Branch build
- **WHEN** building from main branch without tag
- **THEN** image is tagged as ghcr.io/suj1e/tiz/<service>:main-<sha>
