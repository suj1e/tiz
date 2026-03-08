# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tiz is an AI-driven knowledge practice platform. Users interact with AI through conversational chat to generate personalized practice questions and quizzes.

## Project Structure

```
tiz/
├── tiz-web/           # Frontend (React + TypeScript + Vite)
├── tiz-backend/       # Backend services (independent services in shared directory)
│   ├── common/        # Shared utilities (published to Aliyun Maven)
│   ├── llm-api/       # LLM service API (Java DTOs for Python service)
│   ├── .env.*         # Environment-specific configuration files
│   ├── llm-service/   # AI service (Python/FastAPI) (:8106)
│   ├── auth-service/  # Authentication service (:8101)
│   ├── chat-service/  # Chat service (:8102)
│   ├── content-service/   # Content service (:8103)
│   ├── practice-service/  # Practice service (:8104)
│   ├── quiz-service/      # Quiz service (:8105)
│   ├── user-service/      # User service (:8107)
│   └── gateway/            # API Gateway (:8080)
├── infra/             # Infrastructure
│   ├── dev/           # Development
│   ├── staging/       # Staging
│   ├── prod/          # Production
│   └── infra.sh       # Management script
├── standards/         # Development standards
└── openspec/          # OpenSpec change management
```

## Independent Team Maintenance

每个微服务由独立团队维护。开发时必须遵循：

1. **自包含原则**: 每个服务可以独立理解、构建、测试、部署
2. **文档完整**: 每个服务有 README.md 和 .env.example
3. **依赖明确**: 内部 API 通过 version catalog 引用 (`libs.content.api`)
4. **配置独立**: 每个服务有自己的 libs.versions.toml

**开发检查**:
- 新增服务：复制现有服务的 README.md、.env.example、libs.versions.toml 模板
- 修改服务：确保 README 和 .env.example 同步更新
- 添加依赖：优先使用 version catalog，避免硬编码版本

## Frontend (tiz-web)

### Commands

```bash
cd tiz-web

# Install dependencies
pnpm install

# Development with mock data (no backend needed)
VITE_MOCK=true pnpm dev

# Development connecting to backend
pnpm dev

# Build for production
pnpm build

# Lint and fix
pnpm lint

# Run tests
pnpm test              # Watch mode
pnpm test:run          # Single run
pnpm test:coverage     # With coverage
```

### Tech Stack

- **React 19** + **TypeScript 5.x** (strict mode)
- **Vite 7.x** with `@tailwindcss/vite` plugin
- **Tailwind CSS 4.x** + **shadcn/ui**
- **Zustand 5.x** for state management
- **React Router 7.x** with lazy loading
- **MSW 2.x** for API mocking
- **Vitest 4.x** + **Testing Library** for testing

### Architecture

**Directory Layout:**
- `src/app/` - Page components organized by route groups: `(auth)/`, `(main)/`, `chat/`, `landing/`
- `src/components/` - UI components: `ui/` (shadcn), `layout/`, `chat/`, `question/`, `library/`, `quiz/`, `common/`
- `src/stores/` - Zustand stores: `authStore`, `chatStore`, `libraryStore`, `practiceStore`, `quizStore`, `uiStore`
- `src/services/` - API layer with fetch wrapper; chat.ts handles SSE streaming
- `src/hooks/` - Custom hooks: `useAuth`, `useChat`, `useMediaQuery`, etc.
- `src/mocks/` - MSW handlers and mock data
- `src/types/` - TypeScript type definitions

**Path Alias:** `@/` maps to `src/` (configured in vite.config.ts and tsconfig)

**Route Protection:** `ProtectedRoute` component wraps authenticated routes; checks `authStore.isAuthenticated`

### Key Patterns

**API Service Layer:**
- `src/services/api.ts` provides `api.get()`, `api.post()`, `api.patch()`, `api.delete()`
- Handles auth token injection and 401 redirect
- Use `{ raw: true }` option to get full response (e.g., for cursor pagination)
- SSE streaming for chat via `src/services/chat.ts`

```typescript
// Normal request - extracts response.data automatically
const user = await api.get<User>('/user/v1/me')

// Cursor paginated request - get full response
const res = await api.get<CursorResponse<Library>>('/content/v1/library', { raw: true })
// res = { data: [...], has_more: true, next_token: "eyJ..." }
```

**Error Handling:**
- Route level: `RootErrorBoundary` catches lazy loading and route errors
- Page level: Use `PageError` component with `onRetry` for data loading errors
- Component level: `ErrorBoundary` class component for React render errors

```tsx
// Page-level error handling pattern
const [error, setError] = useState<Error | null>(null)

useEffect(() => {
  loadData().catch(err => setError(err))
}, [])

if (error) {
  return <PageError message={error.message} onRetry={loadData} />
}
```

**State Management:**
```typescript
// Zustand store pattern
interface AuthState {
  user: User | null
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}
export const useAuthStore = create<AuthState>((set) => ({ ... }))
```

**Responsive Design:**
- Mobile-first approach with Tailwind breakpoints (sm:, md:, lg:, xl:)
- Avoid hardcoded pixel values; use Tailwind spacing utilities

**Mock Service (MSW):**
- Enabled via `VITE_MOCK=true` environment variable
- Handlers in `src/mocks/handlers/`
- Mock data in `src/mocks/data/`

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `ChatMessage.tsx` |
| Hooks | camelCase with `use` prefix | `useChat.ts` |
| Stores | camelCase with `Store` suffix | `authStore.ts` |
| Directories | kebab-case | `question-card/` |

### Common Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `ThemeToggle` | `common/ThemeToggle.tsx` | Dark/light mode switch |
| `PageError` | `common/PageError.tsx` | Data loading error display |
| `EmptyState` | `common/EmptyState.tsx` | Empty data placeholder |
| `LoadingState` | `common/LoadingState.tsx` | Loading spinner |
| `ErrorBoundary` | `common/ErrorBoundary.tsx` | React error boundary |
| `RootErrorBoundary` | `common/RootErrorBoundary.tsx` | Route-level error boundary |
| `ProtectedRoute` | `common/ProtectedRoute.tsx` | Auth route guard |

## Backend (tiz-backend)

Each service is an **independent project** with its own Dockerfile and docker-compose.yml. Services are placed in a shared directory for convenience, but can be extracted and deployed separately.

### Service Types

**Java Services** (api + app subproject structure):
- `auth-service`, `chat-service`, `content-service`, `practice-service`, `quiz-service`, `user-service`
- `api/`: DTOs and client interfaces (published to Maven Local)
- `app/`: Service implementation with Spring Boot

**Gateway Service**:
- `gateway` - Single module structure (no api/app split)

**Python Service**:
- `llm-service` - FastAPI + LangGraph

### Tech Stack

- **Java 21** + **Spring Boot 4.0.2**
- **Spring Cloud Gateway** (API Gateway)
- **Spring Data JPA** + **QueryDSL**
- **MySQL 9.2** + **Redis 7.4** + **Kafka 7.8**
- **Python 3.11+** + **FastAPI** + **LangGraph** (llmsrv)

### Quick Start

```bash
# Build and publish common module (to Aliyun Maven)
cd tiz-backend/common
gradle publish

# Build and publish a service's API
cd tiz-backend/content-service
gradle :api:publish

# Build and run a service
cd tiz-backend/content-service
gradle :app:bootRun
```

### Service Dependencies

Services depend on each other via Aliyun Maven Repository:
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Shared utilities
- `io.github.suj1e:auth-api:1.0.0-SNAPSHOT` - Auth service DTOs
- `io.github.suj1e:chat-api:1.0.0-SNAPSHOT` - Chat service DTOs
- `io.github.suj1e:content-api:1.0.0-SNAPSHOT` - Content service DTOs
- `io.github.suj1e:practice-api:1.0.0-SNAPSHOT` - Practice service DTOs
- `io.github.suj1e:quiz-api:1.0.0-SNAPSHOT` - Quiz service DTOs
- `io.github.suj1e:user-api:1.0.0-SNAPSHOT` - User service DTOs
- `io.github.suj1e:llm-api:1.0.0-SNAPSHOT` - LLM service DTOs

### Version Catalog

Each service uses `libs.versions.toml` for dependency management. Internal APIs are defined as:
- `libs.common` - Common utilities
- `libs.auth.api`, `libs.chat.api`, `libs.content.api`, `libs.practice.api`, `libs.quiz.api`, `libs.user.api` - Service APIs
- `libs.llm.api` - LLM service API

Example usage in build.gradle.kts:
```kotlin
implementation(libs.common)
implementation(libs.content.api)
implementation(libs.llm.api)
```

### Maven Publishing

Common module and service API modules are published to Aliyun Maven Repository.

**Repository URLs:**
- Snapshot: `https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx`
- Release: `https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr`

**Local Authentication:**

Add to `~/.gradle/gradle.properties`:
```properties
aliyunMavenUsername=<your-username>
aliyunMavenPassword=<your-password>
```

**CI/CD Authentication:**

GitHub Actions uses `ALIYUN_MAVEN_USERNAME` and `ALIYUN_MAVEN_PASSWORD` secrets.

**Publishable Modules:**

| Module | Path | Artifact ID |
|--------|------|-------------|
| common | `tiz-backend/common` | `common` |
| llm-api | `tiz-backend/llm-api` | `llm-api` |
| auth-api | `tiz-backend/auth-service/api` | `auth-api` |
| chat-api | `tiz-backend/chat-service/api` | `chat-api` |
| content-api | `tiz-backend/content-service/api` | `content-api` |
| practice-api | `tiz-backend/practice-service/api` | `practice-api` |
| quiz-api | `tiz-backend/quiz-service/api` | `quiz-api` |
| user-api | `tiz-backend/user-service/api` | `user-api` |

**Publish Command:**
```bash
# For standalone projects (common, llm-api)
cd tiz-backend/common
gradle publish

# For service api modules
cd tiz-backend/content-service
gradle :api:publish
```

### Environment Variables

Each service has a `.env.example` template file that documents all required environment variables. To configure a service:

```bash
cd tiz-backend/auth-service
cp .env.example .env.dev
# Edit .env.dev with your values
```

The `.env.example` file serves as documentation and should be kept up to date with all available configuration options.

### AI Service (llm-service)

```bash
cd tiz-backend/llm-service

# Install dependencies
pixi install

# Run dev server
pixi run dev
```

### Start All Backend Services

Use the development startup script:

```bash
cd tiz-backend

# Start all services in dependency order
./start-dev.sh start

# Check service status
./start-dev.sh status

# View logs for a service
./start-dev.sh logs auth-service

# Stop all services
./start-dev.sh stop
```

Logs are written to `tiz-backend/logs/` directory.

### Service Management Scripts (svc.sh)

每个服务都有独立的 `svc.sh` 脚本，提供统一的服务管理命令。

**使用方式:**
```bash
cd tiz-backend/auth-service

./svc.sh help           # 查看所有命令
./svc.sh build          # 构建
./svc.sh test           # 运行测试
./svc.sh run            # 本地运行
./svc.sh run --env staging  # 指定环境运行
./svc.sh publish        # 发布 API 到 Maven
./svc.sh image          # 构建+推送 Docker 镜像
./svc.sh image --local  # 只构建镜像，不推送
./svc.sh version        # 查看版本
./svc.sh version bump   # 版本号+1
./svc.sh validate       # 验证配置
./svc.sh status         # 健康检查
./svc.sh logs           # 查看日志
```

**批量发布:**
```bash
cd tiz-backend

./publish-all.sh           # 发布所有服务
./publish-all.sh --changed # 只发布有变更的服务
./publish-all.sh --dry-run # 预览（不执行）
```

**命令对照表:**

| 命令 | Java 服务 | Python 服务 | 说明 |
|------|----------|-------------|------|
| build | ✓ | ✓ | 构建 |
| test | ✓ | ✓ | 运行测试 |
| run | ✓ | ✓ | 本地运行 |
| publish | ✓ | ✓ | 发布到仓库 |
| image | ✓ | ✓ | Docker 镜像 |
| version | ✓ | ✓ | 版本管理 |
| tag | ✓ | ✓ | Git 标签 |
| validate | ✓ | ✓ | 配置验证 |
| status | ✓ | ✓ | 健康检查 |
| logs | ✓ | ✓ | 日志查看 |
| rollback | ✓ | ✓ | 版本回滚 |
| images | ✓ | ✓ | 镜像管理 |
| deps | ✓ | ✓ | 依赖管理 |
| install | - | ✓ | 安装依赖 |
| lint | - | ✓ | 代码检查 |
| format | - | ✓ | 代码格式化 |

### API Gateway Routes

```
/api/auth/v1/**     → auth-service:8101
/api/chat/v1/**     → chat-service:8102
/api/content/v1/**  → content-service:8103
/api/practice/v1/** → practice-service:8104
/api/quiz/v1/**     → quiz-service:8105
/api/user/v1/**     → user-service:8107
```

## Infrastructure

### Multi-Environment Support

```bash
cd infra

# Start dev environment (default)
./infra.sh start

# Start staging environment
./infra.sh start --env staging

# Start prod environment
./infra.sh start --env prod

# View status
./infra.sh status
```

### Infrastructure Ports (dev)

| Service | Port | Purpose |
|---------|------|---------|
| MySQL | 30001 | Database |
| Redis | 30002 | Cache |
| Elasticsearch | 30003 | Search engine |
| Nacos Console | 30006 | Config center Web UI |
| Nacos API | 30848 | SDK connection address |
| Kafka | 30009 | Message queue |
| Kafka UI | 30010 | Kafka management UI |

### Nacos 3.x Notes

Nacos 3.x has separate ports for Console and API:
- **Console (8080 → 30006)**: Web UI at `http://localhost:30006/`
- **HTTP API (8848 → 30848)**: SDK connects here, API path is `/nacos/v1/...`
- **gRPC (9848 → 31848)**: Auto-calculated as API port + 1000

Services should configure `NACOS_SERVER_ADDR=localhost:30848`.

### Service Configuration

Services use environment variables for configuration (see docker-compose.yml in each service directory).

Each service has `.env.dev`, `.env.staging`, `.env.prod` files for environment-specific values.

### Service Configuration

Each service manages its own configuration through environment variables. Configuration files are placed in each service directory:

```
auth-service/
├── docker-compose.yml
├── .env.dev            # dev environment variables
├── .env.staging        # staging environment variables
└── .env.prod           # production environment variables
```

Deploy with environment file:
```bash
cd tiz-backend/auth-service
docker-compose --env-file .env.prod up -d
```

See docker-compose.yml for environment variable declarations with defaults.

### Environment Differences

| Environment | Data Storage | Resources | Ports | Kafka UI |
|-------------|--------------|-----------|-------|----------|
| dev | Docker volumes (managed) | Low | All exposed | Yes |
| staging | `/opt/dev/dockermnt/tiz-staging` | Medium | All exposed | Yes |
| prod | `/opt/dev/dockermnt/tiz` | High | Internal only | No |

Data path can be overridden via `DATA_PATH` environment variable in `.env` file.

## Service Deployment

Each service is independent with its own Dockerfile and docker-compose.yml:

```bash
# Start any service independently
cd tiz-backend/auth-service
docker-compose up -d

# Build Docker image
docker build -t auth-service:latest .
```

### Docker Images

- **Java services**: Use `eclipse-temurin:21-jre-alpine` (official image)
- **Python service**: Uses `python:3.11-slim`
- **Frontend**: Uses `node:20-alpine` + `nginx:alpine`

All services connect to the `npass` Docker network and communicate via DNS names: `mysql`, `redis`, `kafka`, `nacos`.

**Image naming:** `registry.cn-hangzhou.aliyuncs.com/nxo/<service-name>`
- Example: `nxo/auth-service`, `nxo/chat-service`, `nxo/llm-service`

## Development Workflow

### Full-Stack Development

1. **Start infrastructure**
   ```bash
   cd infra && ./infra.sh start
   ```

2. **Start backend services**
   ```bash
   cd tiz-backend && ./start-dev.sh start
   ```

3. **Start frontend**
   ```bash
   cd tiz-web && pnpm dev
   ```

### Frontend-Only Development

```bash
cd tiz-web
VITE_MOCK=true pnpm dev  # Mock mode, no backend needed
```

### Notes

- API specs and contracts are in `standards/api.md`
- Postman collection available at `standards/postman.json`

### Postman Collection Notes

When editing `standards/postman.json`, the `url.path` array must include `v1`:
```json
// ✅ Correct - v1 included in path array
"url": {
  "raw": "{{base_url}}/auth/v1/login",
  "path": ["auth", "v1", "login"]
}
```
Postman imports URL from `path` array, not `raw` field. Missing `v1` in `path` causes version to be lost on import.

## CI/CD Workflows

### Maven Publish Workflows

Automated publishing to Aliyun Maven Repository when paths change on main branch:

| Workflow | Trigger Path | Artifact |
|----------|--------------|----------|
| publish-common.yml | `tiz-backend/common/**` | common |
| publish-llm-api.yml | `tiz-backend/llm-api/**` | llm-api |
| publish-auth-api.yml | `tiz-backend/auth-service/api/**` | auth-api |
| publish-chat-api.yml | `tiz-backend/chat-service/api/**` | chat-api |
| publish-content-api.yml | `tiz-backend/content-service/api/**` | content-api |
| publish-practice-api.yml | `tiz-backend/practice-service/api/**` | practice-api |
| publish-quiz-api.yml | `tiz-backend/quiz-service/api/**` | quiz-api |
| publish-user-api.yml | `tiz-backend/user-service/api/**` | user-api |

### Docker Build Workflows

Manual trigger to build and push Docker images to Aliyun Container Registry:

**Registry:** `registry.cn-hangzhou.aliyuncs.com/nxo/<service>`

| Workflow | Service | Image |
|----------|---------|-------|
| docker-auth-service.yml | auth-service | `nxo/auth-service` |
| docker-chat-service.yml | chat-service | `nxo/chat-service` |
| docker-content-service.yml | content-service | `nxo/content-service` |
| docker-practice-service.yml | practice-service | `nxo/practice-service` |
| docker-quiz-service.yml | quiz-service | `nxo/quiz-service` |
| docker-user-service.yml | user-service | `nxo/user-service` |
| docker-gateway.yml | gateway | `nxo/gateway` |
| docker-llm-service.yml | llm-service | `nxo/llm-service` |
| docker-tiz-web.yml | tiz-web | `nxo/tiz-web` |

**Image Tags:** `latest` + `sha-<commit>`

**Required Secrets:**
- `ALIYUN_REGISTRY_USERNAME`
- `ALIYUN_REGISTRY_PASSWORD`

