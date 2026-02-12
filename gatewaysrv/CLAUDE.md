# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GatewaySrv is a Spring Cloud Gateway-based API gateway using a reactive architecture (WebFlux + Reactor). It routes requests to backend services (authsrv, mixsrv, mealsrv, recommendsrv) discovered via Nacos.

**Key Architecture Principle**: Configuration-driven design using Nacos as the configuration center. Routes, rate limiting, circuit breaking, and sensitive configs (via environment variable placeholders) are stored in Nacos, while `application.yml` contains only bootstrap settings.

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   Client    │────▶│  Gateway    │────▶│  Nacos       │
│             │     │  (WebFlux)  │     │  (Config +   │
└─────────────┘     └─────────────┘     │   Discovery) │
                          │              └──────────────┘
                          ▼                       │
                   ┌─────────────┐                │
                   │  Backend    │◀───────────────┘
                   │  Services   │
                   │ (lb://srv)  │
                   └─────────────┘
```

---

## Build & Test Commands

```bash
# Build JAR
./gradlew bootJar

# Run all tests
./gradlew test

# Run single test class
./gradlew test --tests "*AuthFilterTest"

# Quality check (test + verify)
./gradlew qualityCheck

# Local development
./run.sh dev              # foreground
./run.sh bg dev           # background
./run.sh logs             # tail logs
./run.sh stop             # stop
```

**Docker build** (Jib plugin removed, use Dockerfile):
```bash
# 基础构建（使用默认 Maven 仓库）
docker build -t gatewaysrv:latest .

# CI/CD 构建（需要私有仓库认证）
docker build \
  --build-arg MAVEN_USERNAME=<用户名> \
  --build-arg MAVEN_PASSWORD=<密码> \
  -t gatewaysrv:latest .

# 切换到其他 Maven 仓库
docker build \
  --build-arg MAVEN_USERNAME=<用户名> \
  --build-arg MAVEN_PASSWORD=<密码> \
  --build-arg MAVEN_REPO_URL=<仓库URL> \
  -t gatewaysrv:latest .
```

---

## Configuration Architecture

### Two-Tier Configuration

| Location | Purpose | Examples |
|----------|---------|----------|
| `application.yml` | Bootstrap (immutable) | server.port, Nacos connection |
| Nacos Config Center | Business configs (dynamic) | routes, rate limits, JWT secret (via ${JWT_SECRET} placeholder) |

### Critical Environment Variables

**Local Development**: Use `.env.local` file (loaded by `run.sh`)

```bash
# REQUIRED
NACOS_HOST=nexora-nacos           # Nacos server
NACOS_PORT=8848

# Optional - for sensitive configs in Nacos
JWT_SECRET=xxx                    # JWT signing key (use ${JWT_SECRET} in Nacos config)

# Other
SPRING_PROFILES_ACTIVE=dev
REDIS_HOST=nexora-redis
LOG_LEVEL=INFO

# Observability (Optional)
OTLP_ENDPOINT=http://host.docker.internal:4317/v1/spans  # Tempo tracing endpoint
SPRING_CLOUD_NACOS_LOGGING_DEFAULT_CONFIG_ENABLED=false   # Disable Nacos file logging
```

**Setup**: Copy `.env.example` to `.env.local` and fill in actual values:

```bash
cp .env.example .env.local
# Edit .env.local with your values
```

`run.sh` automatically loads:
- `.env.{env}` (e.g., `.env.dev`)
- `.env.local` (for local overrides, not committed)

### Nacos Configuration Format

**Data ID**: `gatewaysrv-{profile}.yml` (e.g., `gatewaysrv-dev.yml`)
**Group**: `DEFAULT_GROUP`

Routes use `lb://` protocol for load balancing to Nacos-registered services:
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: authsrv
          uri: lb://authsrv
          predicates:
            - Path=/api/v1/auth/**
          filters:
            - StripPrefix=2
```

---

## Code Architecture

### Package Structure

```
src/main/java/com/nexora/gateway/
├── GatewayApplication.java           # Entry point
├── config/
│   ├── SecurityConfig.java          # Spring Security WebFlux config
│   └── ObservabilityConfig.java     # Metrics/Tracing
├── filter/
│   ├── AuthFilter.java              # JWT validation filter
│   ├── RateLimitFilter.java         # Rate limiting
│   └── CircuitBreakerFilter.java    # Circuit breaker
├── handler/
│   ├── GatewayFallbackHandler.java  # Fallback responses
│   └── RouterConfig.java           # Route configuration
├── exception/
│   └── *Exception.java
├── constants/
│   ├── ErrorCode.java
│   └── GatewayConstants.java
└── util/
    └── ResponseUtils.java
```

### Filter Chain Order

Filters are applied in this order (by design):
1. `AuthFilter` - JWT validation for protected paths
2. `RateLimitFilter` - Redis-based distributed rate limiting
3. `CircuitBreakerFilter` - Resilience4j circuit breaking
4. Backend service via `lb://service-name`

### Key Patterns

- **Reactive**: All filters return `Mono<Void>`, use reactive operators
- **Non-blocking**: Never call `.block()` or blocking I/O
- **Configuration external**: Routes in Nacos, not in Java code
- **Secret injection**: Use Nacos placeholders `${VAR_NAME}` for sensitive data

---

## Sensitive Data Handling

Sensitive configs should use Nacos environment variable placeholders. The actual values are injected at runtime via environment variables:

```yaml
# In Nacos config
nexora:
  security:
    jwt:
      secret: ${JWT_SECRET}
```

```bash
# Set the actual value at runtime
export JWT_SECRET=your-actual-secret-key
```

---

## Important Files Reference

| File | Purpose |
|------|---------|
| `docs/config-spec.md` | Complete configuration specification |
| `docs/nacos-config.md` | Nacos setup guide with encryption examples |
| `docs/refactoring-plan.md` | Project simplification history |
| `docs/observability-guide.md` | Observability setup (Prometheus, Tempo, Elasticsearch) |
| `.env.example` | Environment variable template |
| `Dockerfile` | Multi-stage build (Gradle → JRE) |
| `run.sh` | Local development launcher |

---

## Testing Notes

- Uses JUnit 5 + WebFlux Test
- `@SpringBootTest` with `WebEnvironment.RANDOM_PORT` for integration tests
- Reactive assertions use `StepVerifier`
- Test profile: `application-test.yml`

---

## Deployment

The project produces a standard Docker image. No pre-built K8s manifests or Docker Compose files are maintained - write deployment configs specific to your environment.

**Required for deployment**:
1. Nacos server with `gatewaysrv-{profile}.yml` config
2. Environment variables for sensitive configs (e.g., `JWT_SECRET`)
3. Backend services registered in Nacos

### Production Deployment Example

```bash
docker run -d \
  --name gatewaysrv \
  --restart always \
  -p 40004:40004 \
  -p 40005:40005 \
  -e NACOS_HOST=172.28.0.14 \
  -e NACOS_PORT=8848 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e SPRING_CLOUD_NACOS_LOGGING_DEFAULT_CONFIG_ENABLED=false \
  -e OTLP_ENDPOINT=http://tempo:4317/v1/spans \
  gatewaysrv:latest
```

---

## Observability

### Metrics (Prometheus)

The service exposes Prometheus metrics on port 40005:

```
http://localhost:40005/actuator/prometheus
```

**Key metrics**:
- JVM metrics (memory, GC, threads)
- HTTP requests (latency, rate, status codes)
- Circuit breaker states
- Rate limit statistics

### Tracing (Tempo)

Distributed tracing is enabled via OpenTelemetry. Configure the OTLP endpoint in Nacos:

```yaml
# In Nacos: gatewaysrv-{profile}.yml
management:
  tracing:
    enabled: true
  otlp:
    tracing:
      endpoint: ${OTLP_ENDPOINT}  # e.g., http://tempo:4317/v1/spans
```

**Environment variables for OTLP endpoint**:
- **Local dev**: `http://host.docker.internal:4317/v1/spans`
- **Same server (Docker network)**: `http://172.28.0.18:4317/v1/spans`
- **Cross server**: `http://SERVER_IP:4317/v1/spans`

### Health Checks

```bash
# Service health
curl http://localhost:40004/actuator/health

# Prometheus scrape endpoint
curl http://localhost:40005/actuator/prometheus

# Circuit breaker states
curl http://localhost:40005/actuator/circuitbreakers
```
