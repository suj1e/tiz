## 1. Update Version Catalog (所有服务)

- [x] 1.1 更新 auth-service/gradle/libs.versions.toml - 添加内部 API、webflux、loadbalancer、kafka
- [x] 1.2 更新 chat-service/gradle/libs.versions.toml - 同上
- [x] 1.3 更新 content-service/gradle/libs.versions.toml - 同上
- [x] 1.4 更新 practice-service/gradle/libs.versions.toml - 同上
- [x] 1.5 更新 quiz-service/gradle/libs.versions.toml - 同上
- [x] 1.6 更新 user-service/gradle/libs.versions.toml - 同上
- [x] 1.7 更新 gateway/gradle/libs.versions.toml - 添加内部 API

## 2. Update build.gradle.kts (使用 version catalog)

- [x] 2.1 更新 auth-service/app/build.gradle.kts - 移除硬编码版本，使用 catalog
- [x] 2.2 更新 chat-service/app/build.gradle.kts - 移除硬编码版本、移除重复 webflux，使用 catalog
- [x] 2.3 更新 content-service/app/build.gradle.kts - 移除硬编码版本、移除重复 webflux，使用 catalog
- [x] 2.4 更新 practice-service/app/build.gradle.kts - 移除硬编码版本、移除重复 webflux，使用 catalog
- [x] 2.5 更新 quiz-service/app/build.gradle.kts - 移除硬编码版本、移除重复 webflux，使用 catalog
- [x] 2.6 更新 user-service/app/build.gradle.kts - 移除硬编码版本，使用 catalog

## 3. Add README.md

- [x] 3.1 添加 auth-service/README.md
- [x] 3.2 添加 chat-service/README.md
- [x] 3.3 添加 content-service/README.md
- [x] 3.4 添加 practice-service/README.md
- [x] 3.5 添加 quiz-service/README.md
- [x] 3.6 添加 user-service/README.md
- [x] 3.7 添加 gateway/README.md (已有，检查是否需要更新)
- [x] 3.8 检查 llm-service/README.md 是否需要更新

## 4. Add .env.example

- [x] 4.1 添加 auth-service/.env.example
- [x] 4.2 添加 chat-service/.env.example
- [x] 4.3 添加 content-service/.env.example
- [x] 4.4 添加 practice-service/.env.example
- [x] 4.5 添加 quiz-service/.env.example
- [x] 4.6 添加 user-service/.env.example
- [x] 4.7 添加 gateway/.env.example
- [x] 4.8 检查 llm-service/.env.example 是否需要更新

## 5. Unify application.yaml environment variables

- [x] 5.1 检查 chat-service application.yaml - 确保 content.service.url 有环境变量
- [x] 5.2 检查 practice-service application.yaml - 确保环境变量格式一致
- [x] 5.3 检查 quiz-service application.yaml - 确保环境变量格式一致

## 6. Verification

- [ ] 6.1 验证所有服务可以 `./svc.sh build` 成功
- [ ] 6.2 验证所有服务的 README 和 .env.example 内容正确
