## Context

当前系统存在四个独立但相关的问题：

1. **认证 token 传递问题**: `api.ts` 中的 `request` 函数只在显式传入 `token` 参数时才设置 Authorization header。大多数服务调用没有传 token，导致 API 请求无认证信息，后端返回 401，触发跳转登录页。

2. **页面结构问题**: `UserMenu.tsx` 中"个人信息"和"设置"菜单项都导航到 `/settings`，没有独立的个人信息页面。

3. **缺少 AI 配置**: 系统需要用户配置自己的 AI 才能使用，目前缺少配置入口和引导流程。

4. **llm-service 无法使用用户配置**: llm-service 使用全局环境变量配置，无法使用用户级别的配置。

**核心产品决策**:
- **用户必须配置 AI 才能使用 AI 功能**，无全局 fallback
- **AI 配置独立页面**，不在设置页中
- **首次登录和开始对话时引导配置**

**约束**:
- 前端使用 React 19 + Zustand
- 后端使用 Spring Boot + JPA
- llm-service 使用 Python + FastAPI + LangGraph
- 数据库变更需要兼容三个环境 (dev/staging/prod)
- API Key 属于敏感信息，需要安全存储

## Goals / Non-Goals

**Goals:**
- 修复 API 请求自动携带 token
- 创建独立的 `/profile` 页面
- 创建独立的 `/ai-config` 页面，**所有字段必填**
- 实现 AI 配置引导流程（首次登录 + 开始对话时检测）
- 后端提供 AI 配置的 CRUD 接口，**校验必填字段**
- llm-service **只使用用户配置**，无 fallback
- 调用方服务配置不存在时返回明确错误

**Non-Goals:**
- 不实现 API Key 加密（后续迭代）
- 不实现 AI 配置测试功能
- 不实现试用/免费额度功能

## Decisions

### D1: Token 自动注入

**决定**: 在 `api.ts` 的 `request` 函数中自动从 `useAuthStore.getState().token` 获取 token

### D2: AI 配置独立页面

**决定**: 创建独立的 `/ai-config` 页面，不在 `/settings` 中

**理由**:
- AI 配置是使用系统的**前提条件**，需要突出显示
- 独立页面便于实现引导流程
- 与"系统设置"概念分离

### D3: AI 配置必填字段

**决定**: 所有字段必填，包括：

| 字段 | 类型 | 校验 |
|------|------|------|
| preferred_model | string | 非空 |
| temperature | float | 0.0-2.0 |
| max_tokens | int | > 0 |
| system_prompt | string | 非空（可为默认提示词） |
| response_language | string | zh/en |
| custom_api_url | string | 有效 URL |
| custom_api_key | string | 非空 |

**理由**:
- 无全局 fallback，用户必须完整配置
- 简化后端逻辑，不需要处理部分配置的情况

### D4: AI 配置引导流程

**决定**: 两个触发点：
1. **首次登录后**: 检测 AI 配置，未配置则跳转 `/ai-config`
2. **开始对话时**: 检测 AI 配置，未配置则跳转 `/ai-config`

**实现**:
```typescript
// authStore 添加状态
interface AuthState {
  // ...
  hasAiConfig: boolean | null  // null = 未检测
  checkAiConfig: () => Promise<boolean>
}

// 登录成功后
login() {
  // ...
  const hasConfig = await checkAiConfig()
  if (!hasConfig) {
    navigate('/ai-config')
  } else {
    navigate('/home')
  }
}

// 开始对话时（ChatPage 或 ChatPanel）
useEffect(() => {
  if (hasAiConfig === false) {
    navigate('/ai-config')
  }
}, [hasAiConfig])
```

### D5: 后端配置校验

**决定**: user-service 在保存 AI 配置时校验所有必填字段

```java
public void validateAiConfig(AiConfigRequest request) {
    Assert.hasText(request.preferredModel(), "模型不能为空");
    Assert.hasText(request.customApiUrl(), "API URL 不能为空");
    Assert.hasText(request.customApiKey(), "API Key 不能为空");
    // ... 其他字段
}
```

### D6: 配置不存在时的错误处理

**决定**: 调用方服务在 AI 配置不存在时返回特定错误码

```json
{
  "error": {
    "type": "validation_error",
    "code": "AI_CONFIG_REQUIRED",
    "message": "请先配置 AI 设置"
  }
}
```

前端收到此错误后跳转到 `/ai-config`

### D7: llm-service 无 fallback

**决定**: llm-service 请求中的 `ai_config` 为必填，不提供 fallback

```python
class ChatRequest(BaseModel):
    message: str
    ai_config: AiConfig  # 必填，无默认值
    history: list = []
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 新用户可能不知道如何配置 | 提供默认值提示和配置说明 |
| API Key 明文存储 | 后续迭代添加加密 |
| 配置错误导致无法使用 | 提供配置测试功能（后续迭代） |
| 用户更换 API 后需要重新配置 | 独立页面便于随时修改 |
