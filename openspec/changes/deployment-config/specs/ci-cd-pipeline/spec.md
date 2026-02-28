## ADDED Requirements

### Requirement: Tag-triggered deployment

The system SHALL automatically build and deploy when a Git tag is pushed.

#### Scenario: Push version tag triggers deployment
- **WHEN** developer pushes a tag matching pattern `v*.*.*`
- **THEN** system starts the deployment workflow
- **AND** builds all service images
- **AND** pushes images to ghcr.io
- **AND** deploys to production server

#### Scenario: Non-version tag is ignored
- **WHEN** developer pushes a tag not matching `v*.*.*`
- **THEN** deployment workflow does not trigger

### Requirement: Service image building

The system SHALL build Docker images for all services.

#### Scenario: Build all service images
- **WHEN** deployment workflow runs
- **THEN** system builds images for: tiz-web, gatewaysrv, authsrv, chatsrv, contentsrv, practicesrv, quizsrv, llmsrv, usersrv
- **AND** tags images with the Git tag version
- **AND** pushes to ghcr.io/suj1e/tiz/

### Requirement: Production deployment

The system SHALL deploy services to the production server via SSH.

#### Scenario: Successful deployment
- **WHEN** all images are built and pushed
- **THEN** system SSHs to production server
- **AND** pulls latest images
- **AND** runs docker-compose up -d
- **AND** reports deployment status

#### Scenario: Deployment failure
- **WHEN** deployment fails
- **THEN** system reports error in GitHub Actions
- **AND** existing services continue running

### Requirement: GitHub Secrets configuration

The system SHALL use GitHub Secrets for sensitive configuration.

#### Scenario: Required secrets
- **WHEN** deployment workflow runs
- **THEN** system uses secrets: SERVER_HOST, SERVER_USER, SSH_PRIVATE_KEY, DEPLOY_PATH
- **AND** secrets are not exposed in logs
