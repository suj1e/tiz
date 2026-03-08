# quiz-service

Quiz service for the Tiz platform. Manages quizzes, quiz attempts, and uses outbox pattern for event publishing.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring WebFlux (for calling LLM service)
- Spring Data JPA
- Spring Data Redis
- Spring Security
- MySQL
- Redis
- Kafka 7.8+ (for event publishing)
- Nacos (service discovery and configuration)

## Dependencies

### Infrastructure
- MySQL 9.2+ - Quiz data storage
- Redis 7.4+ - Caching
- Kafka 7.8+ - Event streaming (quiz completion events)
- Nacos 3.x+ - Service discovery and configuration

### Services
- **llm-service** - AI-powered quiz generation and grading (via Docker DNS: `llmsrv:8106`)
- **content-service** - Content and topic management (via Nacos service discovery)

### Libraries
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Common utilities
- `io.github.suj1e:content-api:1.0.0-SNAPSHOT` - Content service API
- `io.github.suj1e:llm-api:1.0.0-SNAPSHOT` - LLM service API

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `LLM_SERVICE_URL` | LLM service URL | `http://llmsrv:8106` | No |
| `NACOS_SERVER_ADDR` | Nacos server address | `localhost:30848` | No |
| `NACOS_NAMESPACE` | Nacos namespace | - | No |
| `SPRING_DATASOURCE_URL` | Database JDBC URL | - | Yes |
| `SPRING_DATASOURCE_USERNAME` | Database username | - | Yes |
| `SPRING_DATASOURCE_PASSWORD` | Database password | - | Yes |
| `SPRING_DATA_REDIS_HOST` | Redis host | `localhost` | No |
| `SPRING_DATA_REDIS_PORT` | Redis port | `6379` | No |
| `SPRING_KAFKA_BOOTSTRAP_SERVERS` | Kafka bootstrap servers | `localhost:9092` | No |
| `OUTBOX_SCAN_INTERVAL` | Outbox scan interval (ms) | `5000` | No |
| `OUTBOX_BATCH_SIZE` | Outbox batch size | `100` | No |
| `OUTBOX_MAX_RETRIES` | Outbox max retries | `3` | No |

## API Module

This service publishes an API module to Maven:

```kotlin
implementation("io.github.suj1e:quiz-api:1.0.0-SNAPSHOT")
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
| POST | `/quiz/v1/quizzes` | Create quiz |
| GET | `/quiz/v1/quizzes` | List quizzes (with pagination) |
| GET | `/quiz/v1/quizzes/{id}` | Get quiz details |
| PATCH | `/quiz/v1/quizzes/{id}` | Update quiz |
| DELETE | `/quiz/v1/quizzes/{id}` | Delete quiz |
| POST | `/quiz/v1/quizzes/{id}/start` | Start quiz attempt |
| POST | `/quiz/v1/attempts/{id}/submit` | Submit quiz answer |
| POST | `/quiz/v1/attempts/{id}/complete` | Complete quiz attempt |
| GET | `/quiz/v1/attempts/{id}` | Get attempt results |

## Service Port

- **Default**: 8105
- **Health Check**: http://localhost:8105/actuator/health

## Event Publishing

This service uses the outbox pattern to publish quiz completion events to Kafka:
- Topic: `quiz.completed`
- Event published when a quiz attempt is completed
