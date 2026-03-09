# practice-service

Practice service for the Tiz platform. Manages user practice sessions and tracks learning progress.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring WebFlux (for calling LLM service)
- Spring Data JPA
- MySQL
- Nacos (service discovery and configuration)
- WebClient (for calling LLM service)

## Dependencies

### Infrastructure
- MySQL 9.2+ - Practice data storage
- Nacos 3.x+ - Service discovery and configuration

### Services
- **llm-service** - AI-powered practice recommendations (via Docker DNS: `llm-service:8106`)
- **content-service** - Content and topic management (via Nacos service discovery)

### Libraries
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Common utilities
- `io.github.suj1e:content-api:1.0.0-SNAPSHOT` - Content service API
- `io.github.suj1e:llm-api:1.0.0-SNAPSHOT` - LLM service API

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `LLM_SERVICE_URL` | LLM service URL | `http://llm-service:8106` | No |
| `NACOS_SERVER_ADDR` | Nacos server address | `localhost:30848` | No |
| `NACOS_NAMESPACE` | Nacos namespace | - | No |
| `SPRING_DATASOURCE_URL` | Database JDBC URL | - | Yes |
| `SPRING_DATASOURCE_USERNAME` | Database username | - | Yes |
| `SPRING_DATASOURCE_PASSWORD` | Database password | - | Yes |

## API Module

This service publishes an API module to Maven:

```kotlin
implementation("io.github.suj1e:practice-api:1.0.0-SNAPSHOT")
```

## Development

### Build

```bash
./svc.sh build
```

### Test

```bash
./svc.sh test
```

### Run

```bash
./svc.sh run
```

Or with specific environment:

```bash
./svc.sh run --env staging
```

### Publish API

```bash
./svc.sh publish
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/practice/v1/sessions` | Create practice session |
| GET | `/practice/v1/sessions` | List user's sessions |
| GET | `/practice/v1/sessions/{id}` | Get session details |
| POST | `/practice/v1/sessions/{id}/submit` | Submit answer |
| POST | `/practice/v1/sessions/{id}/complete` | Complete session |
| GET | `/practice/v1/stats` | Get practice statistics |

## Service Port

- **Default**: 8104
- **Health Check**: http://localhost:8104/actuator/health
