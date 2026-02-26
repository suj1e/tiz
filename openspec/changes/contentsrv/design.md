# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring Data JPA + QueryDSL
- MySQL, Redis, Elasticsearch (可选)
- HTTP Exchange (调用 llmsrv)

## 2. 项目结构

```
contentsrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/content/
    ├── ContentApplication.java
    ├── controller/
    │   ├── LibraryController.java
    │   ├── CategoryController.java
    │   ├── TagController.java
    │   └── InternalContentController.java
    ├── service/
    │   ├── LibraryService.java
    │   ├── QuestionService.java
    │   ├── CategoryService.java
    │   └── TagService.java
    ├── repository/
    │   ├── KnowledgeSetRepository.java
    │   ├── QuestionRepository.java
    │   ├── CategoryRepository.java
    │   └── TagRepository.java
    ├── entity/
    │   ├── KnowledgeSet.java
    │   ├── Question.java
    │   ├── Category.java
    │   └── Tag.java
    ├── dto/
    │   ├── LibraryRequest.java
    │   └── QuestionResponse.java
    └── client/
        └── LlmClient.java  # HTTP Exchange
```

## 3. API 端点

### 对外 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/content/v1/library` | 题库列表 |
| GET | `/api/content/v1/library/{id}` | 题库详情 |
| PATCH | `/api/content/v1/library/{id}` | 更新题库 |
| DELETE | `/api/content/v1/library/{id}` | 删除题库 |
| GET | `/api/content/v1/categories` | 分类列表 |
| GET | `/api/content/v1/tags` | 标签列表 |

### 内部 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/internal/content/v1/knowledge-sets/{id}` | 获取题库 |
| GET | `/internal/content/v1/knowledge-sets/{id}/questions` | 获取题目列表 |
| GET | `/internal/content/v1/questions/{id}` | 获取单个题目 |

## 4. 数据库表

- `categories` - 分类表
- `tags` - 标签表
- `knowledge_sets` - 题库表 (软删除)
- `knowledge_set_tags` - 题库-标签关联表
- `questions` - 题目表

## 5. 服务依赖

- llmsrv (题目生成)
