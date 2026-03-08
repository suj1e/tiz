## ADDED Requirements

### Requirement: Internal APIs are in version catalog

内部 API 依赖 SHALL 纳入 `libs.versions.toml` 统一管理，而不是硬编码在 `build.gradle.kts` 中。

#### Scenario: Common module uses catalog
- **WHEN** 服务依赖 common 模块
- **THEN** 使用 `implementation(libs.common)` 而非硬编码版本

#### Scenario: Service APIs use catalog
- **WHEN** 服务依赖其他服务的 API
- **THEN** 使用 `implementation(libs.content.api)` 等格式

### Requirement: Missing dependencies are added to catalog

缺失的依赖定义 SHALL 补充到 `libs.versions.toml`。

#### Scenario: WebFlux is in catalog
- **WHEN** 服务需要 WebFlux
- **THEN** 可以使用 `implementation(libs.spring.boot.starter.webflux)`

#### Scenario: LoadBalancer is in catalog
- **WHEN** 服务需要 LoadBalancer
- **THEN** 可以使用 `implementation(libs.spring.cloud.loadbalancer)`

#### Scenario: Kafka is in catalog
- **WHEN** 服务需要 Kafka
- **THEN** 可以使用 `implementation(libs.spring.kafka)`

### Requirement: QueryDSL uses version catalog

QueryDSL 依赖 SHALL 使用 version catalog 而非硬编码版本。

#### Scenario: QueryDSL uses libs reference
- **WHEN** 服务使用 QueryDSL
- **THEN** 使用 `implementation(libs.querydsl.jpa)` 和 `annotationProcessor(libs.querydsl.jpa)`

### Requirement: No hardcoded versions in build.gradle.kts

`build.gradle.kts` 中 SHALL NOT 出现硬编码的版本号（如 `:5.1.0`）。

#### Scenario: Security uses catalog
- **WHEN** 服务使用 Spring Security
- **THEN** 使用 `implementation(libs.spring.boot.starter.security)` 而非 `:4.0.2`

#### Scenario: All versions come from catalog
- **WHEN** 检查 `app/build.gradle.kts`
- **THEN** 没有 `implementation("group:artifact:version")` 格式的硬编码版本

### Requirement: Remove redundant webflux dependency

由于 `llm-api` 已经通过 `api` 依赖暴露了 webflux，依赖 llm-api 的服务 SHALL NOT 再显式添加 webflux 依赖。

#### Scenario: Services using llm-api do not declare webflux
- **WHEN** 服务依赖 llm-api（如 chat, content, practice, quiz）
- **THEN** 不再显式添加 `spring-boot-starter-webflux` 依赖
