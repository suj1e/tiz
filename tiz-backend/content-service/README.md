# content-service

Content service for the Tiz platform. Manages learning content including topics, subjects, and question banks.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring WebFlux (for calling LLM service)
- Spring Data JPA
- Spring Security
- MySQL
- Nacos (service discovery and configuration)
- WebClient (for calling LLM service)

## Dependencies

### Infrastructure
- MySQL 9.2+ - Content storage
- Nacos 3.x+ - Service discovery and configuration

### Services
- **llm-service** - AI-powered content analysis (via Docker DNS: `llm-service:8106`)

### Libraries
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Common utilities
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
implementation("io.github.suj1e:content-api:1.0.0-SNAPSHOT")
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
| GET | `/content/v1/subjects` | List all subjects |
| POST | `/content/v1/subjects` | Create subject |
| GET | `/content/v1/subjects/{id}` | Get subject details |
| PATCH | `/content/v1/subjects/{id}` | Update subject |
| DELETE | `/content/v1/subjects/{id}` | Delete subject |
| GET | `/content/v1/topics` | List topics (with pagination) |
| POST | `/content/v1/topics` | Create topic |
| GET | `/content/v1/topics/{id}` | Get topic details |
| PATCH | `/content/v1/topics/{id}` | Update topic |
| DELETE | `/content/v1/topics/{id}` | Delete topic |
| GET | `/content/v1/libraries` | List user's libraries |

## Service Port

- **Default**: 8103
- **Health Check**: http://localhost:8103/actuator/health
