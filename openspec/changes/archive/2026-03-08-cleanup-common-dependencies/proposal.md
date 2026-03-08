## Why

Common 模块作为共享库，存在以下问题：
1. **依赖污染** - 包含多个未使用的依赖，下游服务被迫引入
2. **配置重复** - JacksonConfig 代码配置与 YAML 配置重复
3. **命名冲突** - PageRequest 与 Spring Data 的同名类冲突
4. **功能缺失** - @CurrentUserId 注解缺少对应的 Resolver
5. **硬编码** - 代码和构建脚本中存在硬编码值
6. **构建脚本冗余** - group/version 重复定义，Maven URL 多处重复

## What Changes

### 1. 移除未使用的依赖

**build.gradle.kts:**
- ~~`spring-boot-starter-data-redis`~~ - 无 Redis 代码
- ~~`spring-boot-starter-actuator`~~ - 无 actuator 代码
- ~~`logstash-logback-encoder`~~ - 无 logback.xml 配置
- ~~`mysql-connector-j`~~ - 库不应包含数据库驱动，由服务自行声明

**libs.versions.toml:**
- ~~`spring-boot-starter-data-redis`~~
- ~~`spring-boot-starter-actuator`~~
- ~~`spring-boot-starter-webflux`~~
- ~~`spring-cloud-nacos-discovery`~~
- ~~`spring-cloud-nacos-config`~~
- ~~`spring-cloud-loadbalancer`~~
- ~~`logstash-logback-encoder`~~
- ~~`testcontainers-*`~~ (common 无测试目录)

### 2. 清理 application-common.yaml

移除未使用功能的配置：
- ~~`spring.data.redis`~~ - 无 Redis 依赖
- ~~`management`~~ - 无 actuator 依赖

### 3. 删除 JacksonConfig.java

代码配置与 YAML 重复，保留 YAML 配置即可。

### 4. 重命名 PageRequest → PageQuery

避免与 `org.springframework.data.domain.PageRequest` 类名冲突。

需要同步修改的文件：
- `common/.../dto/PageRequest.java` → `PageQuery.java`
- 各服务的 Controller 中使用该类的地方

### 5. 补充 @CurrentUserId 的 Resolver

在 common 中添加完整的实现：
- `CurrentUserIdArgumentResolver.java` - 解析注解，从 SecurityContext 获取用户 ID
- `CurrentUserIdConfig.java` - 注册 Resolver 到 WebMvc

### 6. 删除 UuidGenerator.v7()

方法未被使用，保留 `random()` 即可。

### 7. 修复 GlobalExceptionHandler 硬编码

```java
// Before: 硬编码
new ErrorBody("validation_error", "COMMON_1001", message)

// After: 使用枚举
throw new ValidationException(CommonErrorCode.INVALID_INPUT, message)
```

### 8. 修复 build.gradle.kts 冗余

| 问题 | 修复 |
|------|------|
| `group`/`version` 重复定义 | 删除，使用 gradle.properties 中的值 |
| Maven URL 重复 4 次 | 提取到变量 |
| QueryDSL 版本硬编码 | 改用 `libs.querydsl.jpa` + classifier |

### 保留的依赖

| 依赖 | 原因 |
|------|------|
| `spring-boot-starter-web` | @RestControllerAdvice, ResponseEntity |
| `spring-boot-starter-data-jpa` | @Entity, JPA 审计 |
| `spring-boot-starter-validation` | @Valid, @Min, @Max |
| `spring-boot-starter-security` | SecurityContextHolder |
| `querydsl-jpa` | JPAQueryFactory |
| `jjwt-*` | JwtUtils |
| `jackson-*` | @JsonInclude, ObjectMapper |
| `lombok` | @Getter, @Setter |
| `mapstruct` | 保留供未来使用 |

## Capabilities

### New Capabilities

- **@CurrentUserId 自动注入** - Controller 方法参数使用此注解可自动获取当前登录用户 ID

### Modified Capabilities

- **PageQuery** - 原 PageRequest 重命名，功能不变

## Impact

**受影响的代码：**
- `tiz-backend/common/build.gradle.kts`
- `tiz-backend/common/gradle/libs.versions.toml`
- `tiz-backend/common/src/main/resources/application-common.yaml`
- `tiz-backend/common/src/main/java/.../config/JacksonConfig.java` (删除)
- `tiz-backend/common/src/main/java/.../dto/PageRequest.java` (重命名)
- `tiz-backend/common/src/main/java/.../util/UuidGenerator.java` (删除 v7)
- `tiz-backend/common/src/main/java/.../exception/GlobalExceptionHandler.java` (修复硬编码)
- `tiz-backend/common/src/main/java/.../annotation/` (新增 Resolver)

**下游服务需要同步修改：**
- PageRequest → PageQuery 的 import 和类名
- 确保自己声明需要的依赖（如 MySQL 驱动）
