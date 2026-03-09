## Why

The user-service container is stuck in a restart loop during deployment due to a Spring bean conflict. The `JwtAuthenticationFilter` requires `RequestMappingHandlerMapping`, but Spring Boot creates two beans of this type (`requestMappingHandlerMapping` and `controllerEndpointHandlerMapping` from Actuator), causing dependency injection to fail with "expected single matching bean but found 2".

This blocks all staging deployments and prevents the service from starting.

## What Changes

- Add `@Qualifier("requestMappingHandlerMapping")` annotation to the `RequestMappingHandlerMapping` constructor parameter in `JwtAuthenticationFilter`
- No breaking changes - this is a pure bug fix

## Capabilities

### New Capabilities
- None (bug fix only)

### Modified Capabilities
- None (no spec-level behavior changes, only implementation fix)

## Impact

**Affected Code:**
- `tiz-backend/user-service/app/src/main/java/io/github/suj1e/user/security/JwtAuthenticationFilter.java`

**Dependencies:**
- Spring Boot 4.0.2
- Spring Framework 7.0.3

**Services Affected:**
- user-service (only service affected)

**Deployment:**
- After fix, rebuild and push `registry.cn-hangzhou.aliyuncs.com/nxo/user-service:latest`
- Redeploy to staging environment
