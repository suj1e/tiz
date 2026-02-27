# 任务清单

## 1. 精简 common 模块

- [x] 1.1 从 common 移除 client 目录
- [x] 1.2 更新 common/build.gradle.kts
- [x] 1.3 发布 common 到 Maven Local

## 2. 创建 llmsrv-api

- [x] 2.1 创建独立的 Gradle 配置
- [x] 2.2 移动 LlmClient 和 DTO
- [x] 2.3 发布到 Maven Local

## 3. 重构 contentsrv（api + app 子模块）

- [x] 3.1 创建 settings.gradle.kts（include api, app）
- [x] 3.2 创建 build.gradle.kts（父配置）
- [x] 3.3 创建 api/build.gradle.kts（maven-publish）
- [x] 3.4 创建 app/build.gradle.kts（spring-boot）
- [x] 3.5 移动 dto 到 api/src/
- [x] 3.6 移动 client 到 api/src/
- [x] 3.7 移动其他代码到 app/src/
- [x] 3.8 修复 DTO 对 entity 的依赖
- [x] 3.9 发布 contentsrv-api 到 Maven Local
- [x] 3.10 测试 app 编译

## 4. 重构 usersrv（api + app 子模块）

- [x] 4.1 创建 api + app 子模块结构
- [x] 4.2 移动 dto/client 到 api
- [x] 4.3 移动其他代码到 app
- [x] 4.4 发布 usersrv-api 到 Maven Local
- [x] 4.5 测试 app 编译

## 5. 重构 authsrv（api + app 子模块）

- [x] 5.1 创建 api + app 子模块结构
- [x] 5.2 移动 dto 到 api
- [x] 5.3 移动其他代码到 app
- [x] 5.4 修复 DTO 对 entity 的依赖
- [x] 5.5 发布 authsrv-api 到 Maven Local
- [x] 5.6 测试 app 编译

## 6. 重构 chatsrv（api + app 子模块）

- [x] 6.1 创建 api + app 子模块结构
- [x] 6.2 移动 dto 到 api
- [x] 6.3 移动其他代码到 app
- [x] 6.4 修复 DTO 对 entity 的依赖
- [x] 6.5 修复 ChatMessage 类名冲突（与 llmsrv-api 的 ChatMessage）
- [x] 6.6 发布 chatsrv-api 到 Maven Local
- [x] 6.7 测试 app 编译

## 7. 重构 practicesrv（api + app 子模块）

- [x] 7.1 创建 api + app 子模块结构
- [x] 7.2 移动 dto 到 api
- [x] 7.3 移动其他代码到 app
- [x] 7.4 发布 practicesrv-api 到 Maven Local
- [x] 7.5 测试 app 编译

## 8. 重构 quizsrv（api + app 子模块）

- [x] 8.1 创建 api + app 子模块结构
- [x] 8.2 移动 dto 到 api
- [x] 8.3 移动其他代码到 app
- [x] 8.4 发布 quizsrv-api 到 Maven Local
- [x] 8.5 测试 app 编译

## 9. 重构 gatewaysrv

- [x] 9.1 更新为独立的 Gradle 配置（不需要 api 子模块）
- [x] 9.2 测试独立构建

## 10. 清理根目录

- [x] 10.1 删除 tiz-backend/settings.gradle.kts
- [x] 10.2 删除 tiz-backend/build.gradle.kts
- [x] 10.3 删除 tiz-backend/gradle/

## 11. 更新文档

- [x] 11.1 更新 CLAUDE.md
- [x] 11.2 提交变更
