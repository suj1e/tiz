## 1. Common 模块更新（游标分页）

- [x] 1.1 创建 CursorResponse.java record (data, has_more, next_token)
- [x] 1.2 删除或保留 PagedResponse.java（向后兼容）
- [x] 1.3 发布 common 模块到 Maven Local: `gradle :common:publishToMavenLocal`

## 2. Auth 服务响应格式修改

- [x] 2.1 创建 LoginResponse.java record (token + user 字段)
- [x] 2.2 创建 RegisterResponse.java record (token + user 字段)
- [x] 2.3 修改 UserResponse.java 添加 settings 字段
- [x] 2.4 修改 AuthController.login() 返回 LoginResponse
- [x] 2.5 修改 AuthController.register() 返回 RegisterResponse
- [x] 2.6 更新 authsrv-api 并发布到 Maven Local
- [x] 2.7 更新 AuthController 测试用例

## 3. Quiz 服务参数格式修改

- [x] 3.1 创建 StartQuizRequest.java record (knowledgeSetId, timeLimit)
- [x] 3.2 修改 QuizController.startQuiz() 使用 @RequestBody
- [x] 3.3 更新 QuizController 测试用例
- [x] 3.4 更新 quizsrv-api 并发布到 Maven Local

## 4. Content 服务 - 分类/标签响应修改

- [x] 4.1 修改 CategoryResponse.java 添加 count 字段
- [x] 4.2 修改 TagResponse.java 添加 count 字段
- [x] 4.3 修改 CategoryService 计算 count
- [x] 4.4 修改 TagService 计算 count
- [x] 4.5 更新 CategoryController/TagController 测试用例
- [x] 4.6 更新 contentsrv-api 并发布到 Maven Local

## 5. Content 服务 - 生成接口实现

- [x] 5.1 创建 GenerateRequest.java record
- [x] 5.2 创建 GenerateResponse.java record
- [x] 5.3 创建 BatchResponse.java record
- [x] 5.4 创建 GenerateController.java
- [x] 5.5 创建 GenerateService.java (调用 llmsrv)
- [x] 5.6 实现 POST /api/content/v1/generate
- [x] 5.7 实现 GET /api/content/v1/generate/:id/batch
- [x] 5.8 更新 contentsrv-api 并发布到 Maven Local
- [x] 5.9 编写 GenerateController 集成测试

## 6. 前端验证

- [x] 6.1 确认 content.ts generateQuestions 调用正确
- [x] 6.2 修改 types/api.ts PaginatedResponse 改为 CursorResponse (data, has_more, next_token)
- [x] 6.3 确认 types/library.ts Category/Tag 包含 count
- [x] 6.4 更新前端分页组件支持游标分页/无限滚动
- [x] 6.5 更新 MSW mock handlers 适配新 API 格式
- [x] 6.6 验证 mock 数据格式与 api.md 一致
- [x] 6.7 修复发现的问题

## 7. 文档更新

- [x] 7.1 更新 standards/api.md 分类/标签响应格式
- [x] 7.2 更新 standards/postman.json 接口定义
- [x] 7.3 更新 CLAUDE.md 如有必要
- [x] 7.4 更新 README.md 说明 API 变更
