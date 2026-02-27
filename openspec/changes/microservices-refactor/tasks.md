# 任务清单

## 1. 精简 common 模块

- [x] 1.1 从 common 移除 client 目录 (ContentClient, UserClient, WebhookClient 移到对应服务；LlmClient 移到 llmsrv-api)
- [x] 1.2 更新 common/build.gradle.kts（移除 HTTP Exchange 相关依赖）
- [ ] 1.3 发布 common 到 Maven Local

## 2. 重构 contentsrv（模板服务）

- [x] 2.1 创建独立的 settings.gradle.kts
- [x] 2.2 创建独立的 build.gradle.kts
- [x] 2.3 创建 gradle/libs.versions.toml
- [x] 2.4 添加 gradle/wrapper/
- [x] 2.5 创建 api 包结构 (api/client/, api/dto/)
- [x] 2.6 移动 ContentClient 到 api/client/
- [x] 2.7 移动 DTO 到 api/dto/
- [x] 2.8 更新 import 语句
- [ ] 2.9 测试独立构建
- [ ] 2.10 发布到 Maven Local

## 3. 重构 usersrv

- [x] 3.1 创建独立的 Gradle 配置
- [x] 3.2 创建 api 包结构
- [x] 3.3 移动 UserClient, WebhookClient 到 api/client/
- [x] 3.4 更新依赖和 import
- [ ] 3.5 测试独立构建
- [ ] 3.6 发布到 Maven Local

## 4. 重构 authsrv

- [x] 4.1 创建独立的 Gradle 配置
- [x] 4.2 更新依赖和 import
- [ ] 4.3 测试独立构建
- [ ] 4.4 发布到 Maven Local

## 5. 重构 chatsrv

- [x] 5.1 创建独立的 Gradle 配置
- [x] 5.2 更新依赖（引用 contentsrv, llmsrv-api from Maven Local）
- [x] 5.3 更新 import 语句
- [ ] 5.4 测试独立构建

## 6. 重构 practicesrv

- [x] 6.1 创建独立的 Gradle 配置
- [x] 6.2 更新依赖（引用 contentsrv, llmsrv-api from Maven Local）
- [x] 6.3 更新 import 语句
- [ ] 6.4 测试独立构建

## 7. 重构 quizsrv

- [x] 7.1 创建独立的 Gradle 配置
- [x] 7.2 更新依赖（引用 contentsrv, llmsrv-api from Maven Local）
- [x] 7.3 更新 import 语句
- [ ] 7.4 测试独立构建

## 8. 重构 gatewaysrv

- [x] 8.1 更新为独立的 Gradle 配置
- [x] 8.2 更新依赖（引用 common from Maven Local）
- [ ] 8.3 测试独立构建

## 9. 创建 llmsrv-api

- [x] 9.1 创建独立的 Gradle 配置
- [x] 9.2 创建 api 包结构
- [x] 9.3 移动 LlmClient 和 DTO 到 api/
- [ ] 9.4 测试独立构建
- [ ] 9.5 发布到 Maven Local

## 10. 清理根目录

- [x] 10.1 删除 tiz-backend/settings.gradle.kts
- [x] 10.2 删除 tiz-backend/build.gradle.kts
- [x] 10.3 删除 tiz-backend/gradle/

## 11. 更新文档

- [ ] 11.1 更新 CLAUDE.md
- [ ] 11.2 更新 README.md
- [ ] 11.3 提交变更
