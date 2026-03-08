# auth-service

Authentication service for the Tiz platform. Handles user registration, login, and JWT token management.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring Data JPA
- Spring Security
- Redis (for token storage)
- MySQL
- Nacos (service discovery and configuration)

## Dependencies

### Infrastructure
- MySQL 9.2+ - User data storage
- Redis 7.4+ - Token blacklist storage
- Nacos 3.x+ - Service discovery and configuration

### Services
None (this service is independent and does not call other services)

### Libraries
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Common utilities

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `NACOS_SERVER_ADDR` | Nacos server address | `localhost:30848` | No |
| `NACOS_NAMESPACE` | Nacos namespace | - | No |
| `SPRING_DATASOURCE_URL` | Database JDBC URL | - | Yes |
| `SPRING_DATASOURCE_USERNAME` | Database username | - | Yes |
| `SPRING_DATASOURCE_PASSWORD` | Database password | - | Yes |
| `SPRING_DATA_REDIS_HOST` | Redis host | `localhost` | No |
| `SPRING_DATA_REDIS_PORT` | Redis port | `6379` | No |

## API Module

This service publishes an API module to Maven:

```kotlin
implementation("io.github.suj1e:auth-api:1.0.0-SNAPSHOT")
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
| POST | `/auth/v1/register` | Register new user |
| POST | `/auth/v1/login` | Login and get tokens |
| POST | `/auth/v1/refresh` | Refresh access token |
| POST | `/auth/v1/logout` | Logout (invalidate token) |
| GET | `/auth/v1/me` | Get current user info |

## Service Port

- **Default**: 8101
- **Health Check**: http://localhost:8101/actuator/health
