# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tiz is an AI-driven knowledge practice platform. Users interact with AI through conversational chat to generate personalized practice questions and quizzes.

## Monorepo Structure

```
tiz/
├── tiz-web/           # Frontend (React + TypeScript + Vite)
├── tiz-backend/       # Backend microservices (independent Gradle projects)
│   ├── common/        # Shared utilities (published to Maven Local)
│   ├── llmsrv/        # AI service (Python/FastAPI) (:8106)
│   ├── authsrv/       # Authentication service (:8101)
│   │   ├── api/       # DTOs & client interfaces (published to Maven Local)
│   │   └── app/       # Service implementation
│   ├── chatsrv/       # Chat service (:8102)
│   │   ├── api/       # DTOs & client interfaces
│   │   └── app/       # Service implementation
│   ├── contentsrv/    # Content service (:8103)
│   │   ├── api/       # DTOs & client interfaces
│   │   └── app/       # Service implementation
│   ├── practicesrv/   # Practice service (:8104)
│   │   ├── api/       # DTOs & client interfaces
│   │   └── app/       # Service implementation
│   ├── quizsrv/       # Quiz service (:8105)
│   │   ├── api/       # DTOs & client interfaces
│   │   └── app/       # Service implementation
│   ├── usersrv/       # User service (:8107)
│   │   ├── api/       # DTOs & client interfaces
│   │   └── app/       # Service implementation
│   └── gatewaysrv/    # API Gateway (:8080)
├── infra/             # Docker Compose infrastructure
├── standards/         # Development standards (api.md, frontend.md, backend.md)
└── openspec/          # OpenSpec change management
```

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

// Library store with filter actions
interface LibraryState {
  libraries: KnowledgeSetSummary[]
  selectedCategory: string | null
  selectedTags: string[]
  setSelectedCategory: (category: string | null) => void
  toggleTag: (tag: string) => void
  addLibrary: (library: KnowledgeSetSummary) => void
}
```

**User Service:**
```typescript
// src/services/user.ts
export const userService = {
  getSettings: () => api.get('/user/v1/settings'),
  updateSettings: (settings) => api.patch('/user/v1/settings', settings),
  getWebhook: () => api.get('/user/v1/webhook'),
  saveWebhook: (config) => api.post('/user/v1/webhook', config),
  deleteWebhook: () => api.delete('/user/v1/webhook'),
}
```

**Theme System:**
- `ThemeToggle` component available in all pages
- Theme stored in `uiStore` and persisted to localStorage
- Add to new pages: `<ThemeToggle theme={theme} onThemeChange={setTheme} />`

**Responsive Design:**
- Mobile-first approach with Tailwind breakpoints (sm:, md:, lg:, xl:)
- Avoid hardcoded pixel values; use Tailwind spacing utilities
- Use dynamic heights like `min-h-[50vh]` instead of `min-h-[400px]`

```tsx
// ❌ Avoid hardcoded sizes
<div className="h-[50px] w-[50px] min-h-[400px]">

// ✅ Use responsive utilities
<div className="h-12 w-12 sm:h-auto sm:w-auto min-h-[50vh]">
```

**Mock Service (MSW):**
- Enabled via `VITE_MOCK=true` environment variable
- Handlers in `src/mocks/handlers/`
- Mock data in `src/mocks/data/`
- Browser setup in `src/mocks/browser.ts`

**Styling:**
- Use `cn()` utility from `@/lib/utils` for conditional class merging
- Tailwind classes with mobile-first responsive design
- shadcn/ui components in `src/components/ui/`

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

Each Java service is an independent Gradle project with api + app subproject structure:
- **api/**: DTOs and client interfaces (published to Maven Local for inter-service communication)
- **app/**: Service implementation with Spring Boot

### Tech Stack

- **Java 21** + **Spring Boot 4.0.2**
- **Spring Cloud Gateway** (API Gateway)
- **Spring Data JPA** + **QueryDSL**
- **MySQL 9.2** + **Redis 7.4** + **Kafka 7.8**
- **Python 3.11+** + **FastAPI** + **LangGraph** (llmsrv)

### Quick Start

```bash
# Build and publish common module first
cd tiz-backend/common
gradle publishToMavenLocal

# Build and publish a service's API
cd tiz-backend/contentsrv
gradle :api:publishToMavenLocal

# Build and run a service
cd tiz-backend/contentsrv
gradle :app:bootRun
```

### Service Dependencies

Services depend on each other via Maven Local:
- `io.github.suj1e:common:1.0.0-SNAPSHOT` - Shared utilities
- `io.github.suj1e:contentsrv-api:1.0.0-SNAPSHOT` - Content service DTOs
- `io.github.suj1e:llmsrv-api:1.0.0-SNAPSHOT` - LLM service DTOs
- etc.

### AI Service (llmsrv)

```bash
cd tiz-backend/llmsrv

# Install dependencies
pixi install

# Run dev server
pixi run dev
```

### API Gateway Routes

```
/api/auth/v1/**     → authsrv:8101
/api/chat/v1/**     → chatsrv:8102
/api/content/v1/**  → contentsrv:8103
/api/practice/v1/** → practicesrv:8104
/api/quiz/v1/**     → quizsrv:8105
/api/user/v1/**     → usersrv:8107
```

## Development Workflow

1. Frontend development typically uses mock mode (`VITE_MOCK=true`)
2. For full-stack development, start infra via `docker-compose -f infra/docker-compose-lite.yml up -d`
3. API specs and contracts are in `standards/api.md`
4. Postman collection available at `standards/postman.json`

### Deployment

**GitHub Secrets Configuration:**
| Secret | Description |
|--------|-------------|
| SERVER_HOST | Server IP or domain |
| SERVER_USER | SSH username |
| SSH_PRIVATE_KEY | SSH private key |
| DEPLOY_PATH | Deployment directory (/opt/dev/apps/tiz) |

**Deploy via Git Tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Manual Deployment:**
```bash
cd /opt/dev/apps/tiz
docker-compose -f infra/docker-compose-app.yml up -d
```

### Postman Collection Notes

When editing `standards/postman.json`, the `url.path` array must include `v1`:
```json
// ❌ Wrong - v1 missing in path array
"url": {
  "raw": "{{base_url}}/auth/v1/login",
  "path": ["auth", "login"]
}

// ✅ Correct - v1 included in path array
"url": {
  "raw": "{{base_url}}/auth/v1/login",
  "path": ["auth", "v1", "login"]
}
```
Postman imports URL from `path` array, not `raw` field. Missing `v1` in `path` causes version to be lost on import.
