## 1. 依赖清理

- [x] 1.1 移除 build.gradle.kts 中未使用的依赖 (data-redis, actuator, logstash, mysql-connector-j)
- [x] 1.2 移除 libs.versions.toml 中未使用的库定义
- [x] 1.3 清理 application-common.yaml 中的 redis 和 management 配置

## 2. 代码重构

- [x] 2.1 删除 JacksonConfig.java
- [x] 2.2 重命名 PageRequest.java → PageQuery.java
- [x] 2.3 删除 UuidGenerator.v7() 方法
- [x] 2.4 修复 GlobalExceptionHandler 硬编码，使用 CommonErrorCode 枚举

## 3. 新增功能

- [x] 3.1 创建 CurrentUserIdArgumentResolver.java
- [x] 3.2 创建 CurrentUserIdConfig.java 注册 Resolver

## 4. 构建脚本优化

- [x] 4.1 删除 build.gradle.kts 中冗余的 group/version
- [x] 4.2 提取 Maven URL 到变量
- [x] 4.3 修复 QueryDSL 版本硬编码，使用 version catalog

## 5. 下游服务同步

- [x] 5.1 更新 content-service 的 PageRequest → PageQuery (唯一使用 common.PageRequest 的服务)
- [x] 5.2 其他服务未使用 common.PageRequest，无需更新

## 6. 验证

- [x] 6.1 编译 common 模块 ✓ (BUILD SUCCESSFUL)
- [ ] 6.2 编译所有服务模块 (需要 Maven 仓库凭证)
