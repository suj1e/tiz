## 1. Common 模块更新

- [ ] 1.1 修改 PagedResponse.java 字段名: items→data, limit→page_size
- [ ] 1.2 PagedResponse 新增 totalPages 字段
- [ ] 1.3 发布 common 模块到 Maven Local: `gradle :common:publishToMavenLocal`

## 2. Auth 服务响应格式修改

- [ ] 2.1 创建 LoginResponse.java record (token + user 字段)
- [ ] 2.2 创建 RegisterResponse.java record (token + user 字段)
- [ ] 2.3 修改 UserResponse.java 添加 settings 字段
- [ ] 2.4 修改 AuthController.login() 返回 LoginResponse
- [ ] 2.5 修改 AuthController.register() 返回 RegisterResponse
- [ ] 2.6 更新 authsrv-api 并发布到 Maven Local
- [ ] 2.7 更新 AuthController 测试用例

## 3. Quiz 服务参数格式修改

- [ ] 3.1 创建 StartQuizRequest.java record (knowledgeSetId, timeLimit)
- [ ] 3.2 修改 QuizController.startQuiz() 使用 @RequestBody
- [ ] 3.3 更新 QuizController 测试用例
- [ ] 3.4 更新 quizsrv-api 并发布到 Maven Local

## 4. Content 服务 - 分类/标签响应修改

- [ ] 4.1 修改 CategoryResponse.java 添加 count 字段
- [ ] 4.2 修改 TagResponse.java 添加 count 字段
- [ ] 4.3 修改 CategoryService 计算 count
- [ ] 4.4 修改 TagService 计算 count
- [ ] 4.5 更新 CategoryController/TagController 测试用例
- [ ] 4.6 更新 contentsrv-api 并发布到 Maven Local

## 5. Content 服务 - 生成接口实现

- [ ] 5.1 创建 GenerateRequest.java record
- [ ] 5.2 创建 GenerateResponse.java record
- [ ] 5.3 创建 BatchResponse.java record
- [ ] 5.4 创建 GenerateController.java
- [ ] 5.5 创建 GenerateService.java (调用 llmsrv)
- [ ] 5.6 实现 POST /api/content/v1/generate
- [ ] 5.7 实现 GET /api/content/v1/generate/:id/batch
- [ ] 5.8 更新 contentsrv-api 并发布到 Maven Local
- [ ] 5.9 编写 GenerateController 集成测试

## 6. 前端验证

- [ ] 6.1 确认 content.ts generateQuestions 调用正确
- [ ] 6.2 确认 types/api.ts PaginatedResponse 字段名正确
- [ ] 6.3 确认 types/library.ts Category/Tag 包含 count
- [ ] 6.4 关闭 MSW mock 连接真实后端测试
- [ ] 6.5 修复前后端对接中发现的问题

## 7. 文档更新

- [ ] 7.1 更新 standards/api.md 分类/标签响应格式
- [ ] 7.2 更新 standards/postman.json 接口定义
- [ ] 7.3 更新 CLAUDE.md 如有必要
