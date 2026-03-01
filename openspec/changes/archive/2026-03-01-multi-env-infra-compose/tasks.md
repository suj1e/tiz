## 1. Directory Structure Setup

- [x] 1.1 Create `infra/envs/dev/` directory
- [x] 1.2 Create `infra/envs/staging/` directory
- [x] 1.3 Create `infra/envs/prod/` directory
- [x] 1.4 Move existing `docker-compose.yml` to `envs/dev/`

## 2. Dev Environment Configuration

- [x] 2.1 Create `envs/dev/docker-compose.yml` (migrate from existing)
- [x] 2.2 Create `envs/dev/.env` with default passwords

## 3. Staging Environment Configuration

- [x] 3.1 Create `envs/staging/docker-compose.yml` with medium resources
- [x] 3.2 Create `envs/staging/.env.example` template

## 4. Prod Environment Configuration

- [x] 4.1 Create `envs/prod/docker-compose.yml` with high resources and minimal ports
- [x] 4.2 Create `envs/prod/.env.example` template

## 5. Management Script Update

- [x] 5.1 Update `infra.sh` to support `--env` parameter
- [x] 5.2 Add environment validation logic
- [x] 5.3 Update help text and usage examples

## 6. Cleanup

- [x] 6.1 Remove old `infra/docker-compose.yml` (moved to envs/dev/)
- [x] 6.2 Update any documentation references
