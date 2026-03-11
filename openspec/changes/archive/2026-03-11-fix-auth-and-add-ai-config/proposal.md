## Why

用户登录成功后，点击题库立即跳转回登录页，原因是 API 请求没有正确携带认证 token。同时，个人信息和设置页面混在一起，用户无法独立管理个人信息。此外，用户需要配置自己的 AI 才能使用系统的 AI 功能，目前缺少这个配置入口和引导流程。

## What Changes

- **修复认证 token 传递**: `api.ts` 的 `request` 函数当前只在显式传入 `token` 参数时才设置 Authorization header，需改为自动从 `authStore` 获取 token
- **分离个人信息与设置页**: 新建 `/profile` 路由和页面，将个人信息（头像、昵称、邮箱等）从设置页分离出来
- **AI 配置独立页面**: 新建 `/ai-config` 页面，用户必须配置完整的 AI 设置才能使用 AI 功能
- **AI 配置引导流程**: 首次登录后检测 AI 配置，未配置则引导到配置页；开始对话时检测，未配置则跳转配置页
- **AI 配置必填**: 所有 AI 配置字段均为必填（模型、温度、最大 token、系统提示词、回复语言、API URL、API Key）
- **扩展数据库 schema**: `user_settings` 表添加 AI 配置相关字段
- **扩展后端 API**: `user-service` 添加 AI 配置的 CRUD 接口，并提供内部接口供其他服务查询用户 AI 配置
- **llm-service 使用用户配置**: 扩展 llm-service 接收并使用用户 AI 配置，**无 fallback**（用户必须配置）
- **调用方传递配置**: chat-service, practice-service, content-service 调用 llm-service 时传入用户 AI 配置

## Capabilities

### New Capabilities

- `ai-config`: 用户 AI 配置能力（独立页面），包括模型、温度、最大 token、系统提示词、回复语言、API URL 和 API Key。**所有字段必填**，未配置时无法使用 AI 功能。
- `user-profile`: 用户个人信息页面，展示和编辑头像、昵称、邮箱等基本信息
- `ai-config-onboarding`: AI 配置引导流程，首次登录和开始对话时检测配置状态

### Modified Capabilities

- `user-settings`: 现有设置页面，移除账户信息区块（移至 profile 页），移除 AI 配置（独立为 ai-config 页）
- `llm-integration`: llm-service 接口扩展，支持接收用户 AI 配置参数，**无 fallback**

## Impact

- **前端 (tiz-web)**:
  - `src/shared/services/api.ts` - 自动获取 token
  - `src/desktop/router.tsx` / `src/mobile/router.tsx` - 添加 `/profile` 和 `/ai-config` 路由
  - `src/shared/app/(main)/profile/ProfilePage.tsx` - 新建
  - `src/shared/app/(main)/ai-config/AiConfigPage.tsx` - 新建
  - `src/shared/app/(main)/settings/SettingsPage.tsx` - 移除账户信息和 AI 配置
  - `src/shared/components/common/UserMenu.tsx` - 修改导航链接，添加 AI 配置入口
  - `src/shared/services/user.ts` - 添加 AI 配置 API 调用
  - `src/shared/stores/authStore.ts` - 添加 `hasAiConfig` 状态
  - `src/shared/hooks/useAiConfigCheck.ts` - 新建 hook 检测配置状态

- **后端 (user-service)**:
  - `entity/UserSettings.java` - 添加 AI 配置字段
  - `dto/SettingsRequest.java` / `dto/SettingsResponse.java` - 扩展 DTO
  - `dto/AiConfigResponse.java` - 新增内部接口 DTO
  - `dto/AiConfigStatusResponse.java` - 新增配置状态 DTO
  - `service/SettingsService.java` - 处理 AI 配置，校验必填字段
  - `controller/SettingsController.java` - 暴露 AI 配置 API
  - `controller/InternalSettingsController.java` - 新增内部接口供其他服务调用

- **后端 (user-api)**:
  - `dto/AiConfigResponse.java` - 新增 DTO
  - `dto/AiConfigStatusResponse.java` - 新增配置状态 DTO
  - `client/UserClient.java` - 添加 `getAiConfig(userId)` 和 `hasAiConfig(userId)` 方法

- **后端 (llm-api)**:
  - `dto/AiConfig.java` - 新增配置 DTO
  - `dto/ChatRequest.java` - 添加必填 `aiConfig` 字段
  - `dto/GenerateRequest.java` - 添加必填 `aiConfig` 字段
  - `dto/GradeRequest.java` - 添加必填 `aiConfig` 字段

- **后端 (llm-service Python)**:
  - `app/models/chat.py` - ChatRequest 添加必填 ai_config 字段
  - `app/models/question.py` - GenerateRequest 添加必填 ai_config 字段
  - `app/models/grade.py` - GradeRequest 添加必填 ai_config 字段
  - `app/graphs/*.py` - 使用传入配置（无 fallback）
  - `app/nodes/*.py` - 从 state 获取配置

- **后端 (chat-service)**:
  - 调用 llm-service 前获取用户 AI 配置
  - 配置不存在则返回错误，前端引导用户配置

- **后端 (practice-service)**:
  - GradingService 调用 llm-service 前获取用户 AI 配置
  - 配置不存在则返回错误

- **后端 (content-service)**:
  - 调用 llm-service 前获取用户 AI 配置
  - 配置不存在则返回错误

- **数据库 (infra)**:
  - `infra/{dev,staging,prod}/mysql-init/03-tiz-schema.sql` - `user_settings` 表添加字段
