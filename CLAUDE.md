# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Tiz** is an enterprise microservices platform combining backend services, mobile app, web admin, and infrastructure. The platform uses an **event-driven architecture** with eventual consistency, eliminating distributed transactions in favor of the Outbox pattern.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Tiz Platform                                │
│                                                                      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   tiz-mobile │    │  nexora-web  │    │   Clients    │       │
│  │   (Swift)    │    │   (React)    │    │  (Third-party)│       │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘       │
│         │                    │                     │                   │
│         └────────────────────┼─────────────────────┘                   │
│                              │                                       │
│                              ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    gatewaysrv (40004)                         │   │
│  │              Spring Cloud Gateway + WebFlux                      │   │
│  │         JWT Validation • Routing • Rate Limiting                 │   │
│  └──────────────────────────┬───────────────────────────────────────┘   │
│                             │                                       │
│         ┌─────────────────────┼─────────────────────┐                 │
│         │                     │                     │                   │
│         ▼                     ▼                     ▼                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   authsrv    │    │   usersrv    │    │  Other Srvs  │       │
│  │   (40006)    │    │   (4000X)    │    │              │       │
│  └──────┬───────┘    └──────┬───────┘    └──────────────┘       │
│         │                     │                                       │
│         └─────────────────────┼─────────────────────┐                 │
│                               │                     │                   │
│                               ▼                     ▼                   │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │              Infrastructure (infra/docker-compose.yml)           │    │
│  │                                                              │    │
│  │  MySQL(30001) • Redis(30002) • ES(30003) • Nacos(30006)   │    │
│  │  Kafka(30009) • Tempo(30014) • Grafana(30018)                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    nexora (Framework)                        │    │
│  │         Spring Boot Starters - Shared Libraries               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
tiz/
├── authsrv/          # Authentication & SSO service (Spring Boot 3.2.7)
├── gatewaysrv/       # API Gateway (Spring Cloud Gateway + WebFlux)
├── usersrv/          # User service (Spring Boot)
├── infra/            # Infrastructure deployment (Docker Compose + K8s)
├── tiz-mobile/       # Mobile app (Swift 5.9+)
├── nexora-web/       # Admin web frontend (React 18 + Vite)
├── nexora/          # Shared Spring Boot Starters framework
├── optr/            # OPTR plugin for Claude Code
├── PLAN.md           # Project planning document
├── CLAUDE.md         # This file
└── .gitignore        # Git ignore rules
```

## Quick Start

### 1. Start Infrastructure

```bash
cd infra
./scripts/docker/start.sh
```

This starts all infrastructure services (MySQL, Redis, Elasticsearch, Nacos, Kafka, Tempo, Grafana) on ports 30001-30018.

### 2. Start Backend Services

Each service has its own startup script:

```bash
# Gateway (port 40004/40005)
cd gatewaysrv && ./run.sh dev

# Auth Service (port 40006/40007)
cd authsrv && ./run.sh dev

# User Service
cd usersrv && ./gradlew bootRun
```

### 3. Run Mobile App

```bash
cd tiz-mobile
swift build
swift run
```

### 4. Run Web Admin

```bash
cd nexora-web
pnpm install
pnpm dev
```

## Common Commands

### Backend Services (Java/Spring Boot)

All Java services use Gradle 8.11+ with Kotlin DSL and TOML version catalogs:

```bash
# Build entire service
./gradlew clean build

# Run tests
./gradlew test

# Run single test
./gradlew test --tests "*AuthServiceTest"

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

# Build Docker image
./gradlew jibDockerBuild
```

**Important**: All dependency versions are managed in `gradle/libs.versions.toml`. Never hardcode versions in `build.gradle.kts`.

### Mobile App (Swift)

```bash
# Build the project
cd tiz-mobile
swift build

# Run the app
swift run

# Build for macOS
swift build -c release

# Run tests
swift test
```

### Web Admin (React/Vite)

```bash
# Install dependencies
pnpm install

# Development server
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Run tests
pnpm test
```

### Infrastructure

```bash
# Start all services
cd infra && ./scripts/docker/start.sh

# Stop all services
./scripts/docker/stop.sh

# Check status
./scripts/docker/status.sh

# Backup data
./scripts/docker/backup.sh

# Deploy to Kubernetes
./scripts/k8s/deploy.sh
```

## Service Communication Architecture

### HTTP Interface (@HttpExchange)

Services communicate via **type-safe HTTP clients** using `@HttpExchange`:

```java
// In authsrv-api SDK
@HttpExchange(url = "/auth/v1", accept = "application/json")
public interface AuthClient {
    @GetExchange("/validate")
    TokenValidationResponse validateToken(@RequestParam String token);
}

// In consuming service
@Bean
public AuthClient authClient() {
    RestClient restClient = RestClient.builder()
        .baseUrl("http://authsrv:40006")
        .build();
    HttpServiceProxyFactory factory = HttpServiceProxyFactory.builder()
        .clientAdapter(RestClientAdapter.create(restClient))
        .build();
    return factory.createClient(AuthClient.class);
}
```

### Event-Driven Communication (Kafka)

Services use **Kafka events** for async communication with the **Outbox pattern**:

1. Business logic writes to `outbox_event` table in same transaction
2. Background Quartz job (every 10s) scans and publishes to Kafka
3. Ensures at-least-once delivery with retry

**Topic naming**: `{domain}.{entity}.{action}.v{version}` (e.g., `user.user.created.v1`)

## Configuration Management

### Hybrid Approach: Local Files + Nacos

**Two-tier configuration**:
- **Local (immutable)**: Ports, Nacos connection, basic infrastructure
- **Nacos (dynamic)**: Business rules, routing, security settings

### Environment File Loading

Services load environment files in this order:
1. `.env.{env}` (e.g., `.env.dev`) - Environment defaults
2. `.env.local` - Local overrides (gitignored)
3. System environment variables

### Sensitive Configuration

Use Nacos environment variable placeholders for secrets:

```yaml
# In Nacos config
nexora:
  security:
    jwt:
      secret: ${JWT_SECRET}

# Set actual value at runtime
export JWT_SECRET=your-actual-secret
```

## Service Ports

| Service | App Port | Mgmt Port | Context Path |
|---------|-----------|------------|--------------|
| gatewaysrv | 40004 | 40005 | - |
| authsrv | 40006 | 40007 | `/auth` |
| usersrv | TBD | TBD | TBD |
| MySQL | 30001 | - | - |
| Redis | 30002 | - | - |
| Elasticsearch | 30003 | - | - |
| Kibana | 30005 | - | - |
| Nacos | 30006 | - | - |
| Kafka | 30009 | - | - |
| Tempo | 30014 | - | - |
| Grafana | 30018 | - | - |

## API Routing Convention

### Gateway Routing

Gateway routes use `lb://` protocol for load balancing:

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

Final URL: `http://gateway:40004/api/v1/auth/login` → `http://authsrv:40006/auth/v1/login`

### Service Context Paths

| Service | Context Path | Example |
|---------|--------------|----------|
| authsrv | `/auth` | `/auth/v1/login` |
| gatewaysrv | - | `/api/v1/...` |

## Key Technologies

### Backend (Java Services)
- **Spring Boot** 3.2.7 - 4.0.2
- **Spring Cloud** 2025.1.1
- **Spring Cloud Alibaba** 2025.1.0.0
- **Java** 21 LTS
- **Nacos** - Service discovery & config
- **MySQL** 9.2 - Primary database
- **Redis** 7.4 - Caching
- **Kafka** 7.8 KRaft - Event streaming
- **Quartz** - Scheduled jobs

### Nexora Starters (Internal Framework)

Shared Spring Boot Starters providing zero-configuration auto-configuration:

| Starter | Purpose |
|---------|---------|
| `nexora-spring-boot-starter-web` | Unified `Result<T>` response, global exception handling |
| `nexora-spring-boot-starter-redis` | Multi-level caching (Caffeine L1 + Redis L2) |
| `nexora-spring-boot-starter-kafka` | Event publishing with DLQ support |
| `nexora-spring-boot-starter-resilience` | Circuit breaker, retry, timeout |
| `nexora-spring-boot-starter-security` | JWT provider, configuration encryption |
| `nexora-spring-boot-starter-file-storage` | File upload (local/OSS/S3/MinIO) |
| `nexora-spring-boot-starter-data-jpa` | JPA auditing, soft delete |
| `nexora-spring-boot-starter-audit` | Entity audit logging |

### Mobile (Swift)
- **Swift** 5.9+
- **Swift Package Manager** - Package management
- **SwiftUI** - UI framework
- **Alamofire** - HTTP client

### Web (React)
- **React** 18
- **Vite** 6.0.5
- **TypeScript**
- **pnpm** - Package manager

## Observability

### Distributed Tracing (Tempo)

Services send traces via OpenTelemetry:

```yaml
management:
  tracing:
    enabled: true
  otlp:
    tracing:
      endpoint: ${OTLP_ENDPOINT}  # http://tempo:4317
```

### Metrics (Prometheus)

Each service exposes metrics on management port:

```
http://localhost:{mgmt-port}/actuator/prometheus
```

Visualized in Grafana (port 30018).

### Logging (Elasticsearch + Kibana)

Logs are shipped to Elasticsearch, viewable in Kibana (port 30005).

## Architecture Patterns

### Layered Architecture (DDD)

Java services follow this layering:

```
Boot ──→ Adapter ──→ Core
  ↑                  ↑
  └── API ────────────┘
```

- **Boot**: Application entry, configuration
- **Adapter**: REST controllers, HTTP Interface implementations, repositories
- **Core**: Domain entities, domain services (pure business logic)
- **API**: SDK for other services (@HttpExchange interfaces, DTOs)

### Outbox Pattern

For reliable DB-Kafka consistency:

1. Write business tables + `outbox_event` in same transaction
2. Background job scans `outbox_event` for `status=NEW`
3. Publish to Kafka, mark as `SENT`

### Gateway Filter Chain

```
Request → AuthFilter → RateLimitFilter → CircuitBreakerFilter → Backend Service
```

## Development Workflow

### Adding a New Feature to a Service

1. Implement in Core layer (domain logic)
2. Add REST endpoint in Adapter layer
3. Add @HttpExchange method in API module (if needed by other services)
4. Write unit tests
5. Update Nacos configuration if needed

### Adding a New Service

1. Create service directory with similar structure to authsrv
2. Add Nexora starters as dependencies
3. Configure Nacos for service discovery
4. Add route in gatewaysrv Nacos config
5. Update this CLAUDE.md

### Modifying Nexora Starters

1. Make changes in `nexora/` module
2. Run `./gradlew publishToMavenLocal`
3. Update consuming services' dependency versions
4. Test integration

## Important Notes

### Dependency Management
- **ALL** Java dependency versions MUST use `gradle/libs.versions.toml`
- Never hardcode versions in `build.gradle.kts`

### API Path Convention
- Controllers use `@RequestMapping("/v1")` or `@RequestMapping("/v1/{resource}")`
- Do NOT use `/api/v1` prefix (context path is configured per service)
- Gateway handles `/api/v1/*` routing

### Database Migrations
- Located in `*-boot/src/main/resources/db/migration/`
- Naming: `V{number}__{description}.sql`
- Run automatically via Flyway on startup

### Event Publishing
- Use `EventPublisher` for transactional publishing
- Outbox pattern enabled via `nexora.kafka.outbox.enabled=true`

### Security
- JWT tokens: Access (15min) + Refresh (7 days)
- BCrypt password hashing (strength=12)
- Brute force protection with configurable lockout

## Sub-Service Documentation

Each major component has its own `CLAUDE.md` with detailed guidance:

- `authsrv/CLAUDE.md` - Authentication service architecture
- `gatewaysrv/CLAUDE.md` - Gateway routing and filters
- `tiz-mobile/CLAUDE.md` - Swift app architecture
- `nexora/CLAUDE.md` - Spring Boot Starters framework
- `infra/CLAUDE.md` - Infrastructure deployment

Consult these for service-specific commands, architecture details, and development practices.
