## 1. Deploy Directory Setup

- [x] 1.1 Create `deploy/` directory at project root
- [x] 1.2 Create `deploy/staging/` and `deploy/prod/` subdirectories
- [x] 1.3 Create `deploy/staging/.env.example` and `deploy/prod/.env.example`

## 2. Frontend Dockerfile Merge

- [x] 2.1 Create new `tiz-web/Dockerfile` with merged desktop/mobile build
- [x] 2.2 Create `tiz-web/nginx.conf` with UA-based routing
- [x] 2.3 Update `tiz-web/docker-compose.yml` to use merged image
- [x] 2.4 Test local build: `docker build -t tiz-web:test .`

## 3. Docker Compose Configuration
- [x] 3.1 Create `deploy/staging/docker-compose.yml` with all 9 services
- [x] 3.2 Create `deploy/prod/docker-compose.yml` with all 9 services
- [x] 3.3 Configure environment variables and secrets
- [x] 3.4 Set up health checks for each service

## 4. Deploy Script
- [x] 4.1 Create `deploy/deploy.sh` with command parsing
- [x] 4.2 Implement `deploy` command (pull + up)
- [x] 4.3 Implement `stop` command
- [x] 4.4 Implement `restart` command
- [x] 4.5 Implement `logs` command with service filter
- [x] 4.6 Implement `status` command with health checks
- [x] 4.7 Implement `ps` command
- [x] 4.8 Implement `rollback` command

## 5. Testing & Validation
- [x] 5.1 Test staging deployment: `./deploy.sh staging deploy`
- [x] 5.2 Verify tiz-web healthy
- [ ] 5.3 Test frontend UA routing (desktop/mobile) (requires backend services)
- [ ] 5.4 Test rollback functionality (requires multiple image versions)
- [x] 5.5 Test logs and status commands

## 6. Documentation
- [x] 6.1 Update CLAUDE.md with new deploy workflow
- [x] 6.2 Create `.env` files from templates (not committed)
