## Context

当前 tiz 项目前端 (tiz-web) 使用 MSW mock 进行开发，后端 (tiz-backend) 各微服务已基本实现。经分析发现多处 API 契约不一致：

1. **Quiz start 参数格式**: 后端用 `@RequestParam`，前端发送 JSON body
2. **Auth 响应结构**: 后端返回 `{ accessToken, refreshToken }`，前端期望 `{ token, user }`
3. **分页响应字段**: 后端用 `items/limit`，前端期望 `data/page_size`
4. **分类/标签统计**: 后端不返回 `count`，前端需要
5. **内容生成接口**: 后端未实现，前端已定义调用

本项目采用微服务架构，服务间通过 Maven Local 共享 DTO。变更需考虑向后兼容性和服务间影响。

## Goals / Non-Goals

**Goals:**

- 统一前后端 API 契约，以 `standards/api.md` 为准
- 实现缺失的 content generation 接口
- 保持服务间 DTO 兼容性
- 更新 API 文档和 Postman collection

**Non-Goals:**

- 不改变业务逻辑，仅调整接口契约
- 不修改数据库 schema
- 不涉及 llmsrv 内部实现

## Decisions

### D1: Quiz Start 参数格式

**决策**: 后端改用 `@RequestBody` 接收 JSON

**理由**:
- 符合 RESTful 最佳实践（创建资源用 JSON body）
- 与 API 规范一致
- 前端已按此实现

**替代方案**: 前端改用 query params（否决 - 不符合规范）

**实现**:
```java
// QuizController.java
@PostMapping("/start")
public ApiResponse<StartQuizResponse> startQuiz(
    @CurrentUserId UUID userId,
    @Valid @RequestBody StartQuizRequest request  // 改为 @RequestBody
) { ... }

// 新增 StartQuizRequest.java
public record StartQuizRequest(
    @NotNull UUID knowledgeSetId,
    Integer timeLimit
) {}
```

### D2: Auth 响应结构

**决策**: 新增 `LoginResponse` 包装类，返回 `{ token, user }`

**理由**:
- 前端 authStore 期望此结构
- 减少前端请求次数（一次获取 token 和 user）
- 符合 API 规范

**实现**:
```java
// LoginResponse.java (新增)
public record LoginResponse(
    String token,
    UserResponse user
) {}

// AuthController.java 修改返回类型
@PostMapping("/login")
public ResponseEntity<ApiResponse<LoginResponse>> login(...) {
    TokenResponse tokens = authService.login(request);
    UserResponse user = authService.getCurrentUser(userId);
    return ResponseEntity.ok(ApiResponse.of(new LoginResponse(
        tokens.accessToken(),
        user
    )));
}
```

### D3: 分页响应格式（游标分页）

**决策**: 采用游标分页（Cursor-based Pagination）

**请求参数**:
| 参数 | 说明 |
|------|------|
| page_size | 每页数量，默认 10，最大 100 |
| page_token | 游标，来自上次响应的 next_token |

**响应格式**:
```json
{
  "data": [...],
  "has_more": true,
  "next_token": "eyJpZDoxMDA..."
}
```

**理由**:
- 项目以移动端为主，无限滚动是标准交互
- 大厂（Stripe/Google/AWS）都采用游标分页
- 性能更好，不随数据量增加而变慢
- 实时数据不会出现漏数据或重复

**实现**:
```java
public record CursorResponse<T>(
    List<T> data,
    boolean hasMore,
    String nextToken
) {
    public static <T> CursorResponse<T> of(List<T> data, boolean hasMore, String nextToken) {
        return new CursorResponse<>(data, hasMore, hasMore ? nextToken : null);
    }
}
```

### D4: Category/Tag Count 字段

**决策**: 后端增加 `count` 字段

**理由**:
- 前端 UI 显示需要（如 "JavaScript (8)"）
- 减少前端额外请求

**实现**:
```java
// CategoryResponse.java
public record CategoryResponse(
    UUID id,
    String name,
    String description,
    Integer sortOrder,
    Long count          // 新增：该分类下题库数量
) {}

// TagResponse.java
public record TagResponse(
    UUID id,
    String name,
    Long count          // 新增：该标签下题库数量
) {}
```

### D5: Content Generation 接口

**决策**: 在 contentsrv 新增 `GenerateController`

**理由**:
- 符合服务职责划分（contentsrv 负责内容管理）
- 调用 llmsrv 生成题目，存储到数据库

**API 设计**:
```
POST /api/content/v1/generate
Request:  { session_id, question_types?, difficulty?, question_count? }
Response: { knowledge_set_id, questions, batch: { current, total, has_more } }

GET /api/content/v1/generate/:id/batch?page=N
Response: { questions, batch: { current, total, has_more } }
```

**实现**:
```java
@RestController
@RequestMapping("/api/content/v1")
public class GenerateController {
    @PostMapping("/generate")
    public ApiResponse<GenerateResponse> generate(...);

    @GetMapping("/generate/{id}/batch")
    public ApiResponse<BatchResponse> getBatch(...);
}
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| Breaking change 影响现有客户端 | 后端处于开发阶段，暂无外部客户端 |
| PagedResponse 修改影响多个服务 | common 模块需先发布到 Maven Local |
| GenerateController 依赖 llmsrv | llmsrv 需先实现 `/internal/ai/generate` |
| 分类/标签 count 查询性能 | 使用缓存或定时任务预计算 |

## Migration Plan

### 阶段 1: Common 模块更新
1. 修改 `PagedResponse.java`
2. 发布到 Maven Local: `gradle :common:publishToMavenLocal`

### 阶段 2: 各服务按依赖顺序更新
1. **contentsrv**: 更新 PagedResponse 引用，新增 GenerateController
2. **authsrv**: 修改响应结构
3. **quizsrv**: 修改参数接收方式
4. **其他服务**: 更新 PagedResponse 引用

### 阶段 3: 前端验证
1. 关闭 MSW mock
2. 连接真实后端测试
3. 修复遗漏问题

### 回滚策略
- 每个服务独立部署，可单独回滚
- common 模块版本化，可回退到旧版本

## Open Questions

1. ~~llmsrv 的 `/internal/ai/generate` 是否已实现？~~ → 需确认
2. 分类/标签 count 是否需要实时计算，还是可以接受延迟？
3. 是否需要保留旧版 API 做向后兼容？（建议：不需要，开发阶段）
