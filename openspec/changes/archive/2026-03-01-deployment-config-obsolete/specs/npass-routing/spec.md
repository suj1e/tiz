## ADDED Requirements

### Requirement: Frontend domain routing

The system SHALL route tiz.dmall.ink to the frontend service.

#### Scenario: HTTPS access to frontend
- **WHEN** user visits https://tiz.dmall.ink
- **THEN** npass proxies request to tiz-web:80
- **AND** SSL is terminated at npass
- **AND** response is returned via HTTPS

#### Scenario: HTTP redirect to HTTPS
- **WHEN** user visits http://tiz.dmall.ink
- **THEN** npass returns 301 redirect to https://tiz.dmall.ink

### Requirement: API domain routing

The system SHALL route api.tiz.dmall.ink to the gateway service.

#### Scenario: HTTPS access to API
- **WHEN** user calls https://api.tiz.dmall.ink/*
- **THEN** npass proxies request to gatewaysrv:8080
- **AND** preserves original Host header
- **AND** adds X-Forwarded-* headers

#### Scenario: WebSocket support
- **WHEN** user connects to wss://api.tiz.dmall.ink/chat/stream
- **THEN** npass upgrades connection to WebSocket
- **AND** proxies to gatewaysrv:8080

### Requirement: SSL configuration

The system SHALL use existing dmall.ink wildcard certificate.

#### Scenario: Certificate usage
- **WHEN** any tiz.dmall.ink or api.tiz.dmall.ink request is received
- **THEN** npass uses /etc/letsencrypt/live/dmall.ink/fullchain.pem
- **AND** uses /etc/letsencrypt/live/dmall.ink/privkey.pem
- **AND** supports TLSv1.2 and TLSv1.3

### Requirement: Proxy headers

The system SHALL add standard proxy headers.

#### Scenario: Header forwarding
- **WHEN** npass proxies a request
- **THEN** it adds Host header with original domain
- **AND** adds X-Real-IP with client IP
- **AND** adds X-Forwarded-For with client IP chain
- **AND** adds X-Forwarded-Proto with original scheme

### Requirement: Network connectivity

The system SHALL connect tiz services to npass network.

#### Scenario: Services in npass network
- **WHEN** tiz-web and gatewaysrv are deployed
- **THEN** they are connected to npass external network
- **AND** are reachable by container name from npass nginx
