## 1. 重命名服务目录

- [x] 1.1 重命名 authsrv → auth-service
- [x] 1.2 重命名 chatsrv → chat-service
- [x] 1.3 重命名 contentsrv → content-service
- [x] 1.4 重命名 gatewaysrv → gateway
- [x] 1.5 重命名 llmsrv → llm-service
- [x] 1.6 重命名 llmsrv-api → llm-api
- [x] 1.7 重命名 practicesrv → practice-service
- [x] 1.8 重命名 quizsrv → quiz-service
- [x] 1.9 重命名 usersrv → user-service

## 2. 更新 Gradle 配置

- [x] 2.1 更新 auth-service/settings.gradle.kts 的 rootProject.name
- [x] 2.2 更新 chat-service/settings.gradle.kts 的 rootProject.name
- [x] 2.3 更新 content-service/settings.gradle.kts 的 rootProject.name
- [x] 2.4 更新 gateway-service/settings.gradle.kts 的 rootProject.name
- [x] 2.5 更新 llm-service/settings.gradle.kts 的 rootProject.name (N/A - Python 项目)
- [x] 2.6 更新 llm-api/settings.gradle.kts 的 rootProject.name
- [x] 2.7 更新 practice-service/settings.gradle.kts 的 rootProject.name
- [x] 2.8 更新 quiz-service/settings.gradle.kts 的 rootProject.name
- [x] 2.9 更新 user-service/settings.gradle.kts 的 rootProject.name

## 3. 更新 Maven 坐标

- [x] 3.1 更新 auth-service 的 build.gradle.kts (group/artifact)
- [x] 3.2 更新 chat-service 的 build.gradle.kts
- [x] 3.3 更新 content-service 的 build.gradle.kts
- [x] 3.4 更新 gateway-service 的 build.gradle.kts (N/A - 无 API 模块)
- [x] 3.5 更新 llm-service 的 build.gradle.kts (N/A - Python 项目)
- [x] 3.6 更新 llm-api 的 build.gradle.kts
- [x] 3.7 更新 practice-service 的 build.gradle.kts
- [x] 3.8 更新 quiz-service 的 build.gradle.kts
- [x] 3.9 更新 user-service 的 build.gradle.kts

## 4. 更新服务间依赖引用

- [x] 4.1 更新 common 模块中的依赖引用 (无变化)
- [x] 4.2 更新各服务 app 模块对 *-api 的依赖引用

## 5. 更新 CI/CD 配置

- [x] 5.1 重命名 .github/workflows/publish-*srv-api.yml 文件
- [x] 5.2 更新 workflow 文件内的路径引用
- [x] 5.3 重命名 .github/workflows/docker-*srv.yml 文件
- [x] 5.4 更新 Docker 镜像名配置

## 6. 更新文档

- [x] 6.1 更新 CLAUDE.md 中的服务列表和路径
- [x] 6.2 更新 CLAUDE.md 中的 Maven artifact 列表

## 7. 验证

- [ ] 7.1 运行 ./start-dev.sh 验证所有服务正常启动
- [ ] 7.2 验证服务间调用正常
