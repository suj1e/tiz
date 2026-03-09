## ADDED Requirements

### Requirement: Single container for desktop and mobile
The frontend SHALL be built as a single Docker container containing both desktop and mobile builds, with nginx routing based on User-Agent.

#### Scenario: Container contains both builds
- **WHEN** frontend container is built
- **THEN** both `/usr/share/nginx/html/desktop` and `/usr/share/nginx/html/mobile` directories exist

#### Scenario: Desktop routing
- **WHEN** request has User-Agent without mobile indicators
- **THEN** nginx serves files from `/usr/share/nginx/html/desktop`

#### Scenario: Mobile routing
- **WHEN** request has User-Agent containing "mobile", "android", or "iphone"
- **THEN** nginx serves files from `/usr/share/nginx/html/mobile`

### Requirement: Nginx configuration with UA detection
The nginx configuration SHALL use `map` directive to detect mobile User-Agents and route accordingly.

#### Scenario: UA detection mapping
- **WHEN** nginx processes a request
- **THEN** `$http_user_agent` is evaluated against mobile patterns
- **AND** `$frontend_root` variable is set to appropriate path

### Requirement: Image naming convention
The merged frontend image SHALL follow naming convention `registry.cn-hangzhou.aliyuncs.com/nxo/tiz-web:latest`.

#### Scenario: Image tag format
- **WHEN** frontend image is built
- **THEN** image is tagged as `registry.cn-hangzhou.aliyuncs.com/nxo/tiz-web:latest`
