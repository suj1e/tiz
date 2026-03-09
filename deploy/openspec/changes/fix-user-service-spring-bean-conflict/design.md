## Context

The user-service fails to start in staging due to a Spring bean injection conflict. The `JwtAuthenticationFilter` uses Lombok's `@RequiredArgsConstructor` to inject `RequestMappingHandlerMapping` via constructor injection. However, Spring Boot with Actuator creates two beans of this type:

1. `requestMappingHandlerMapping` - the main Spring MVC handler mapping
2. `controllerEndpointHandlerMapping` - created by Actuator for exposing health/info endpoints

This causes Spring to fail with: "expected single matching bean but found 2".

## Goals / Non-Goals

**Goals:**
- Fix the bean injection conflict in `JwtAuthenticationFilter`
- Ensure user-service can start successfully in staging

**Non-Goals:**
- Refactoring the authentication filter architecture
- Changes to other services
- Adding new features

## Decisions

### 1. Use `@Qualifier` annotation

**Decision:** Add `@Qualifier("requestMappingHandlerMapping")` to specify the primary bean.

**Rationale:**
- Minimal change - single annotation addition
- Explicitly declares which bean to use
- No behavior change, just disambiguates injection
- Follows Spring best practices for multiple bean scenarios

**Alternative considered:** Disable Actuator's endpoint mapping
- Rejected: Would lose monitoring capabilities
- Actuator endpoints are useful for observability

**Alternative considered:** Use field injection with `@Autowired @Qualifier`
- Rejected: Constructor injection is preferred for testing and immutability
- Lombok's `@RequiredArgsConstructor` pattern should be preserved where possible

### 2. Implementation approach

Replace `@RequiredArgsConstructor` with explicit constructor to add `@Qualifier`:

```java
public JwtAuthenticationFilter(
    JwtTokenProvider jwtTokenProvider,
    @Qualifier("requestMappingHandlerMapping") RequestMappingHandlerMapping handlerMapping,
    ObjectMapper objectMapper
) {
    this.jwtTokenProvider = jwtTokenProvider;
    this.handlerMapping = handlerMapping;
    this.objectMapper = objectMapper;
}
```

**Rationale:**
- Lombok's `@RequiredArgsConstructor` doesn't support parameter-level annotations
- Explicit constructor allows `@Qualifier` on specific parameter
- Still maintains immutability with `final` fields

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Spring bean name changes in future versions | Unlikely - `requestMappingHandlerMapping` is a well-established bean name in Spring MVC |
| Other services might have similar issues | Will check other services during implementation |
