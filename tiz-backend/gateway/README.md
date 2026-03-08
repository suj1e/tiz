# gateway

API Gateway for the Tiz platform. Routes requests to backend services and handles JWT authentication.

## Tech Stack

- Java 21
- Spring Boot 4.0.2
- Spring Cloud Gateway (reactive)
- Spring Cloud Nacos (service discovery)
- Spring Cloud LoadBalancer
- JWT (jjwt 0.13.0)

## Features

- **Request Routing**: Routes requests to appropriate microservices
- **JWT Authentication**: Validates JWT tokens and injects user information
- **Whitelist Mechanism**: Configurable paths that don't require authentication
- **CORS Configuration**: Cross-origin request support
- **Global Exception Handling**: Unified error response format
- **Nacos Integration**: Service discovery and configuration center

## Route Rules

| Path | Target Service | Service Name |
|------|----------------|--------------|
| `/api/auth/v1/**` | auth-service | `authsrv` |
| `/api/user/v1/**` | user-service | `usersrv` |
| `/api/chat/v1/**` | chat-service | `chatsrv` |
| `/api/content/v1/**` | content-service | `contentsrv` |
| `/api/practice/v1/**` | practice-service | `practicesrv` |
| `/api/quiz/v1/**` | quiz-service | `quizsrv` |

## Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────▶│ Gateway  │────▶│ Service  │
└──────────┘     └──────────┘     └──────────┘
                      │
                      ▼
               ┌──────────────┐
               │ JWT Filter   │
               │ 1. Extract Token │
               │ 2. Verify Signature │
               │ 3. Check Expiration │
               │ 4. Inject User ID │
               └──────────────┘
```

### Request Headers

After JWT validation, the gateway injects these headers to downstream services:

- `X-User-Id`: User ID
- `X-User-Email`: User email

## Whitelist Paths

These paths do not require JWT authentication:

- `/api/auth/v1/login` - Login
- `/api/auth/v1/register` - Register
- `/api/auth/v1/refresh` - Refresh token
- `/actuator/**` - Health check endpoints

## Configuration

### application.yaml

```yaml
server:
  port: 8080

spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: lb://authsrv
          predicates:
            - Path=/api/auth/v1/**

jwt:
  secret: your-jwt-secret-key

gateway:
  whitelist:
    - /api/auth/v1/login
    - /api/auth/v1/register

cors:
  allowed-origins: http://localhost:5173
  allowed-methods: GET,POST,PUT,PATCH,DELETE,OPTIONS
  allowed-headers: Authorization,Content-Type,X-*
  allow-credentials: true
  max-age: 3600
```

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `NACOS_SERVER_ADDR` | Nacos server address | `localhost:30848` | No |
| `NACOS_NAMESPACE` | Nacos namespace | - | No |
| `CORS_ALLOWED_ORIGINS` | CORS allowed origins | `http://localhost:5173,http://localhost:3000` | No |

## Dependencies

### Infrastructure
- Nacos 3.x+ - Service discovery and configuration

### Services
- **auth-service** - Authentication and authorization
- **user-service** - User profiles
- **chat-service** - Chat functionality
- **content-service** - Content management
- **practice-service** - Practice sessions
- **quiz-service** - Quiz management

### Libraries
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Common utilities (excludes servlet-based dependencies)

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

## Health Check

```bash
curl http://localhost:8080/actuator/health
```

## Error Response Format

```json
{
  "error": {
    "type": "authentication_error",
    "code": "token_invalid",
    "message": "Invalid token signature"
  }
}
```

### Common Error Codes

| Code | Message | HTTP Status |
|------|---------|-------------|
| `token_missing` | Authorization header is required | 401 |
| `token_invalid` | Invalid token signature | 401 |
| `token_expired` | Token has expired | 401 |
| `internal_error` | Internal server error | 500 |

## Project Structure

```
gateway/
├── build.gradle.kts
├── gradle/
│   └── libs.versions.toml
├── settings.gradle.kts
├── src/
│   ├── main/
│   │   ├── java/io/github/suj1e/gateway/
│   │   │   ├── GatewayApplication.java
│   │   │   ├── config/
│   │   │   │   ├── CorsConfig.java
│   │   │   │   ├── JwtProperties.java
│   │   │   │   └── RouteConfig.java
│   │   │   ├── filter/
│   │   │   │   └── JwtAuthenticationFilter.java
│   │   │   └── handler/
│   │   │       ├── GatewayErrorResponse.java
│   │   │       └── GlobalExceptionHandler.java
│   │   └── resources/
│   │       └── application.yaml
│   └── test/
│       ├── java/io/github/suj1e/gateway/
│       │   └── filter/
│       │       └── JwtAuthenticationFilterTest.java
│       └── resources/
│           └── application.yaml
```

## Service Port

- **Default**: 8080
- **Health Check**: http://localhost:8080/actuator/health
