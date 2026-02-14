# Tasks: Implement authsrv Business Logic

## Phase 1: Core Domain

- [x] 1.1 Create User entity (core/domain/User.java)
- [x] 1.2 Create Role entity (core/domain/Role.java)
- [x] 1.3 Create UserRepository interface (adapter/infra/repository)
- [x] 1.4 Create RoleRepository interface

## Phase 2: Domain Services

- [x] 2.1 Create AuthDomainService (login/register logic)
- [x] 2.2 Create UserDomainService (user management)
- [x] 2.3 Create TokenDomainService (JWT tokens)

## Phase 3: API DTOs

- [x] 3.1 LoginRequest/RegisterRequest (api/dto/request)
- [x] 3.2 TokenResponse/UserResponse (api/dto/response)

## Phase 4: REST Controllers

- [x] 4.1 AuthController (login, register, logout)
- [x] 4.2 UserController (CRUD)

## Phase 5: Security & Caching

- [x] 5.1 Configure Security (use nexora-starter-security)
- [x] 5.2 Configure Redis caching (use nexora-starter-redis)

## Phase 6: Verification

- [x] 6.1 Run `./gradlew clean build`
- [ ] 6.2 Run `./gradlew test` (no tests yet)
