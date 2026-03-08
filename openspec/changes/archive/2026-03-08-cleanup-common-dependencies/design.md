## Context

Common 模块是 tiz-backend 的共享库，被所有微服务依赖。当前存在依赖污染、代码硬编码、构建脚本冗余等问题，需要清理优化。

**约束：**
- 不能破坏下游服务的编译和运行
- 保持向后兼容（除 PageRequest 重命名外）
- common 是库模块，不是可运行服务

## Goals / Non-Goals

**Goals:**
- 移除未使用的依赖，减少依赖传递污染
- 消除代码和构建脚本中的硬编码
- 补全 @CurrentUserId 的 Resolver 实现
- 统一配置管理（删除重复的 JacksonConfig）

**Non-Goals:**
- 不修改各服务的依赖（只清理 common 自身）
- 不修改各服务的 JwtAuthenticationFilter（@NoAuth 重复逻辑）
- 不改变任何业务逻辑

## Decisions

### D1: PageRequest 重命名为 PageQuery

**选择：** 重命名
**原因：** 避免与 `org.springframework.data.domain.PageRequest` 类名冲突，减少 IDE 自动导入错误
**替代方案：** 使用全限定名，但用户体验差

### D2: @CurrentUserId Resolver 放在 common 中

**选择：** 在 common 中实现
**原因：**
- 注解定义在 common
- 解析逻辑是通用的（从 SecurityContext 获取）
- 各服务无需重复实现

**实现方式：**
```java
// CurrentUserIdArgumentResolver.java
public class CurrentUserIdArgumentResolver implements HandlerMethodArgumentResolver {
    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(CurrentUserId.class)
            && parameter.getParameterType() == UUID.class;
    }

    @Override
    public Object resolveArgument(...) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return UUID.fromString(auth.getPrincipal().toString());
    }
}

// CurrentUserIdConfig.java
@Configuration
public class CurrentUserIdConfig implements WebMvcConfigurer {
    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(new CurrentUserIdArgumentResolver());
    }
}
```

### D3: Maven URL 提取到变量

**选择：** 在 build.gradle.kts 顶部定义变量
**原因：** 避免重复 4 次，便于维护

```kotlin
val aliyunMavenSnapshotUrl = "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-snapshot-qazpfx"
val aliyunMavenReleaseUrl = "https://packages.aliyun.com/638a07cb09a6ccfdd6a1f934/maven/2309695-release-epshtr"
```

### D4: GlobalExceptionHandler 使用枚举

**选择：** 抛出带 ErrorCode 的异常，而不是手动构造 ErrorBody
**原因：** 统一错误处理，避免硬编码

```java
// Before
new ErrorBody("validation_error", "COMMON_1001", message)

// After
throw new ValidationException(CommonErrorCode.INVALID_INPUT, message)
// GlobalExceptionHandler 已经有 handleBusinessException 处理
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| PageRequest 重命名导致下游服务编译失败 | 同步更新所有服务的 import |
| 移除 mysql-connector-j 后服务没有数据库驱动 | 各服务已自行声明 mysql-connector-j |
| @CurrentUserId Resolver 可能与现有实现冲突 | 使用 @ConditionalOnMissingBean |

## Migration Plan

1. 先修改 common 模块（构建脚本、代码）
2. 发布 common 到 Maven 仓库
3. 更新各服务的 PageRequest → PageQuery
4. 验证各服务编译通过
