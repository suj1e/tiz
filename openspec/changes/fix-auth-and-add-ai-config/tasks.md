## 1. Fix Auth Token

- [ ] 1.1 Modify `api.ts` to automatically get token from `useAuthStore.getState().token`
- [ ] 1.2 Remove the optional `token` parameter from request function
- [ ] 1.3 Test login → library navigation flow

## 2. Database Schema

- [ ] 2.1 Update `infra/dev/mysql-init/03-tiz-schema.sql` - add AI config fields to user_settings
- [ ] 2.2 Update `infra/staging/mysql-init/03-tiz-schema.sql` - same changes
- [ ] 2.3 Update `infra/prod/mysql-init/03-tiz-schema.sql` - same changes
- [ ] 2.4 Create ALTER TABLE migration script for existing databases

## 3. Backend - User Service Entity & DTO

- [ ] 3.1 Add AI config fields to `UserSettings.java` entity (all required)
- [ ] 3.2 Create `AiConfigRequest.java` with validation annotations
- [ ] 3.3 Create `AiConfigResponse.java` for external API
- [ ] 3.4 Create `AiConfigStatusResponse.java` with `configured` boolean
- [ ] 3.5 Update `SettingsService.java` - add AI config CRUD with validation
- [ ] 3.6 Add `AiConfigController.java` - public API at `/user/v1/ai-config`
- [ ] 3.7 Add `InternalAiConfigController.java` - internal API at `/internal/user/v1/ai-config`

## 4. Backend - User API (Feign Client)

- [ ] 4.1 Create `AiConfigResponse.java` in user-api
- [ ] 4.2 Create `AiConfigStatusResponse.java` in user-api
- [ ] 4.3 Add `getAiConfig(userId)` method to `UserClient.java`
- [ ] 4.4 Add `hasAiConfig(userId)` method to `UserClient.java`

## 5. Backend - LLM API DTO

- [ ] 5.1 Create `AiConfig.java` DTO with all required fields
- [ ] 5.2 Update `ChatRequest.java` - add required `aiConfig` field
- [ ] 5.3 Update `GenerateRequest.java` - add required `aiConfig` field
- [ ] 5.4 Update `GradeRequest.java` - add required `aiConfig` field

## 6. Backend - LLM Service (Python)

- [ ] 6.1 Create `AiConfig` model in `app/models/ai_config.py`
- [ ] 6.2 Update `ChatRequest` in `app/models/chat.py` - add required `ai_config`
- [ ] 6.3 Update `GenerateRequest` in `app/models/question.py` - add required `ai_config`
- [ ] 6.4 Update `GradeRequest` in `app/models/grade.py` - add required `ai_config`
- [ ] 6.5 Update graph nodes to use `ai_config` from state (no fallback)
- [ ] 6.6 Add URL validation in LLM client

## 7. Backend - Chat Service

- [ ] 7.1 Inject `UserClient` into `ChatService`
- [ ] 7.2 Fetch user AI config before calling llm-service
- [ ] 7.3 Return `AI_CONFIG_REQUIRED` error if config not found
- [ ] 7.4 Pass ai_config to llm-service request

## 8. Backend - Practice Service

- [ ] 8.1 Inject `UserClient` into `GradingService`
- [ ] 8.2 Fetch user AI config before calling llm-service
- [ ] 8.3 Return `AI_CONFIG_REQUIRED` error if config not found
- [ ] 8.4 Pass ai_config to llm-service request

## 9. Backend - Content Service

- [ ] 9.1 Inject `UserClient` into question generation service
- [ ] 9.2 Fetch user AI config before calling llm-service
- [ ] 9.3 Return `AI_CONFIG_REQUIRED` error if config not found
- [ ] 9.4 Pass ai_config to llm-service request

## 10. Frontend - Profile Page

- [ ] 10.1 Create `src/shared/app/(main)/profile/ProfilePage.tsx`
- [ ] 10.2 Add `/profile` route to desktop and mobile routers
- [ ] 10.3 Update `UserMenu.tsx` - change "个人信息" to navigate to `/profile`

## 11. Frontend - AI Config Page

- [ ] 11.1 Create `src/shared/app/(main)/ai-config/AiConfigPage.tsx`
- [ ] 11.2 Add `/ai-config` route to desktop and mobile routers
- [ ] 11.3 Implement form with all required fields (model, temperature, max_tokens, system_prompt, language, api_url, api_key)
- [ ] 11.4 Add field validation
- [ ] 11.5 Add save API integration
- [ ] 11.6 Add masked API key display
- [ ] 11.7 Update `UserMenu.tsx` - add "AI 配置" menu item

## 12. Frontend - Settings Page Cleanup

- [ ] 12.1 Remove 账户信息 section from `SettingsPage.tsx`
- [ ] 12.2 Keep only theme, notifications, webhook sections

## 13. Frontend - AI Config Onboarding

- [ ] 13.1 Add `hasAiConfig` state to `authStore.ts`
- [ ] 13.2 Add `checkAiConfig()` action to fetch config status
- [ ] 13.3 Update login flow - check AI config after login, redirect to `/ai-config` if not configured
- [ ] 13.4 Create `useAiConfigCheck.ts` hook
- [ ] 13.5 Add check in ChatPage - redirect to `/ai-config` if not configured
- [ ] 13.6 Handle `AI_CONFIG_REQUIRED` error globally - redirect to `/ai-config`

## 14. Frontend - API Service

- [ ] 14.1 Add `getAiConfig()` and `updateAiConfig()` to `src/shared/services/user.ts`
- [ ] 14.2 Add `getAiConfigStatus()` to check if configured
- [ ] 14.3 Add TypeScript types for AI config

## 15. Testing

- [ ] 15.1 Test login flow and token persistence
- [ ] 15.2 Test profile page navigation and display
- [ ] 15.3 Test AI config page - save and load
- [ ] 15.4 Test AI config validation (all fields required)
- [ ] 15.5 Test first login redirect to AI config
- [ ] 15.6 Test chat redirect when AI not configured
- [ ] 15.7 Test masked API key display
- [ ] 15.8 Test end-to-end: configure AI → start chat → receive response
