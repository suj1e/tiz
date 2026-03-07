## Why

The current deploy workflows (deploy-*.yml) use an embedded docker-compose.yml pattern that is disconnected from the source-controlled docker-compose.yml files in each service directory. After migrating from Nacos config to environment variables, the deploy workflows would need ongoing maintenance to stay in sync with local configurations. Removing these workflows simplifies the CI/CD pipeline and eliminates the drift between local and deployment configurations.

## What Changes

- **BREAKING**: Remove all 9 deploy workflows from `.github/workflows/`:
  - `deploy-authsrv.yml`
  - `deploy-chatsrv.yml`
  - `deploy-contentsrv.yml`
  - `deploy-practicesrv.yml`
  - `deploy-quizsrv.yml`
  - `deploy-usersrv.yml`
  - `deploy-gatewaysrv.yml`
  - `deploy-llmsrv.yml`
  - `deploy-tiz-web.yml`

- Staging deployment will be handled by alternative methods (manual deployment, new pipeline, or other tooling)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `ci-cd`: Removes the staging deploy workflows from CI/CD capabilities. Docker build workflows remain for image publishing.

## Impact

- **Files removed**: 9 workflow files in `.github/workflows/`
- **Unaffected**: Docker build workflows (docker-*.yml), Maven publish workflows (publish-*.yml)
- **Staging environment**: Will need alternative deployment method
- **Documentation**: README.md and CLAUDE.md references to staging deploy workflows should be removed
