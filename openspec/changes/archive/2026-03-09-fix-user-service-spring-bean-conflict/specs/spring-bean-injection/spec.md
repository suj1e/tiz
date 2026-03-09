## ADDED Requirements

### Requirement: JwtAuthenticationFilter uses primary RequestMappingHandlerMapping
The JwtAuthenticationFilter SHALL use the primary `requestMappingHandlerMapping` bean when multiple RequestMappingHandlerMapping beans are present in the Spring context.

#### Scenario: Service starts successfully with Actuator enabled
- **WHEN** Spring Boot application starts with Actuator dependencies
- **THEN** JwtAuthenticationFilter is initialized with `requestMappingHandlerMapping` bean
- **AND** user-service starts without bean injection conflicts

#### Scenario: Authentication filter handles NoAuth annotated endpoints
- **WHEN** a request is made to an endpoint annotated with @NoAuth
- **THEN** JWT authentication is skipped
- **AND** request proceeds without authentication

#### Scenario: Authentication filter validates JWT tokens
- **WHEN** a request is made to a protected endpoint with valid JWT token
- **THEN** token is validated
- **AND** authentication is set in SecurityContext
