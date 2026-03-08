## Requirements

### Requirement: Controller 方法参数自动注入当前用户 ID

系统 SHALL 支持 `@CurrentUserId` 注解用于 Controller 方法参数，自动从 SecurityContext 获取当前登录用户的 ID。

#### Scenario: 已登录用户访问受保护接口
- **WHEN** 用户已登录且 SecurityContext 中有有效的 Authentication
- **AND** Controller 方法参数带有 `@CurrentUserId UUID userId`
- **THEN** 系统 SHALL 自动注入当前用户的 UUID

#### Scenario: 未登录用户访问受保护接口
- **WHEN** 用户未登录且 SecurityContext 中没有有效的 Authentication
- **AND** Controller 方法参数带有 `@CurrentUserId UUID userId`
- **THEN** 系统 SHALL 注入 null 或抛出异常（取决于接口是否有 @NoAuth）

#### Scenario: 参数类型不是 UUID
- **WHEN** Controller 方法参数带有 `@CurrentUserId`
- **AND** 参数类型不是 `java.util.UUID`
- **THEN** 系统 SHALL 不处理该参数（交由其他 Resolver 处理）
