## Context

The project has 9 deploy workflows that were used for staging deployment via SSH. These workflows embed a simplified docker-compose.yml that references a shared `.env` file on the staging server. After migrating from Nacos config to environment variables, maintaining two sets of docker-compose configurations (local and embedded in workflows) creates unnecessary complexity.

## Goals / Non-Goals

**Goals:**
- Remove all deploy-*.yml workflows to simplify CI/CD
- Keep docker-*.yml workflows for image building
- Keep publish-*.yml workflows for Maven publishing

**Non-Goals:**
- Implementing a new deployment solution
- Modifying staging server configuration

## Decisions

### Delete deploy workflows entirely
- **Rationale**: The embedded docker-compose pattern creates drift from source-controlled configs. Removing them eliminates maintenance burden and potential inconsistencies.
- **Alternative considered**: Sync workflow docker-compose with source - rejected because it adds ongoing maintenance without clear benefit.

### Keep other workflows unchanged
- **Rationale**: Docker build and Maven publish workflows serve different purposes and don't have the same drift issues.

## Risks / Trade-offs

- **Risk**: No automated staging deployment → **Mitigation**: Staging can be deployed manually or via a new pipeline when needed
- **Risk**: CLAUDE.md/README.md may reference these workflows → **Mitigation**: Update documentation to remove references
