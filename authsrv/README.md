# authsrv

{{SERVICE_DESCRIPTION}}

## Quick Start

```bash
# Development
./run.sh dev

# Build
./gradlew clean build

# Test
./gradlew test

# Docker
docker build -t nexora/authsrv:latest .
```

## Ports

| Port | Purpose |
|------|---------|
| 40006 | Application |
| 40007 | Management/Actuator |

## API

Base URL: `http://localhost:40006/auth/v1`

## Health Check

```bash
curl http://localhost:40007/actuator/health
```

## Documentation

See [CLAUDE.md](./CLAUDE.md) for development guidelines.
