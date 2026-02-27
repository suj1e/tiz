## Why

tiz-web 前端与 tiz-backend 后端存在多处 API 契约不一致，导致前后端无法正常对接。这些不一致包括：缺失的接口、参数格式不匹配、响应结构差异。当前前端依赖 MSW mock 运行，无法连接真实后端。需要以 `standards/api.md` 规范为准进行双向对齐，使前后端能够正常通信。

## What Changes

### 后端变更

- **BREAKING** `quizsrv`: QuizController `/start` 接口改用 `@RequestBody` 接收 JSON，替代 `@RequestParam`
- **BREAKING** `authsrv`: 登录/注册响应改为返回 `{ token, user }` 组合结构，替代分离的 `accessToken/user`
- **BREAKING** `common`: PagedResponse 字段重命名 `items → data`，`limit → page_size`，新增 `total_pages`
- **BREAKING** `contentsrv`: CategoryResponse/TagResponse 增加 `count` 字段
- `contentsrv`: 新增 GenerateController，实现 `/content/v1/generate` 和 `/content/v1/generate/:id/batch`

### 前端变更

- `content.ts`: 新增对 `/content/v1/generate` 接口的调用（当前只有 MSW mock）
- `types/api.ts`: PaginatedResponse 字段名已正确，无需修改
- `types/library.ts`: Category/Tag 类型已包含 `count`，无需修改

### 规范文档

- `standards/api.md`: 更新分类/标签响应格式，明确返回 `{ data: { categories: [...] } }` vs `{ data: [...] }`

## Capabilities

### New Capabilities

- `content-generation`: 题目生成接口，支持从对话会话生成题目并分批获取

### Modified Capabilities

- `auth-api`: 认证接口响应格式变更，登录/注册返回 `{ token, user }` 组合
- `quiz-api`: 测验启动接口参数格式变更，从 query params 改为 JSON body
- `pagination`: 分页响应格式标准化，统一字段命名
- `content-api`: 内容接口扩展，分类/标签响应增加统计字段

## Impact

### 后端影响

| 服务 | 文件 | 变更类型 |
|------|------|----------|
| quizsrv | QuizController.java | 参数接收方式修改 |
| quizsrv | StartQuizRequest.java (新增) | DTO 新增 |
| authsrv | AuthController.java | 响应结构调整 |
| authsrv | LoginResponse.java (新增或修改) | DTO 修改 |
| common | PagedResponse.java | 字段重命名 |
| contentsrv | GenerateController.java (新增) | 控制器新增 |
| contentsrv | GenerateService.java (新增) | 服务新增 |
| contentsrv | CategoryResponse.java | 增加 count |
| contentsrv | TagResponse.java | 增加 count |

### 前端影响

| 模块 | 文件 | 变更类型 |
|------|------|----------|
| services | content.ts | 确认 generate 接口调用 |
| types | api.ts | 无需修改（已对齐） |
| types | library.ts | 无需修改（已对齐） |

### API 契约影响

- 5 个接口响应格式变更（breaking change）
- 2 个新接口（content generation）
- 需同步更新 Postman collection (`standards/postman.json`)
