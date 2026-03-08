# user-service

User service for the Tiz platform. Manages user profiles and preferences.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring Data JPA
- Spring Data Redis
- Spring Security
- MySQL
- Redis
- Nacos (service discovery and configuration)

## Dependencies

### Infrastructure
- MySQL 9.2+ - User profile storage
- Redis 7.4+ - User session caching
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
implementation("io.github.suj1e:user-api:1.0.0-SNAPSHOT")
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
| GET | `/user/v1/me` | Get current user profile |
| PATCH | `/user/v1/me` | Update current user profile |
| PATCH | `/user/v1/me/password` | Change password |
| PATCH | `/user/v1/me/preferences` | Update user preferences |
| GET | `/user/v1/me/stats` | Get user statistics |

## Service Port

- **Default**: 8107
- **Health Check**: http://localhost:8107/actuator/health
