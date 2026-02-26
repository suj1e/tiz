# 设计文档

## 1. 技术栈

- Java 21, Spring Boot 4.0.2
- Spring Data JPA + QueryDSL
- MySQL

## 2. 项目结构

```
usersrv/
├── build.gradle.kts
└── src/main/java/io/github/suj1e/user/
    ├── UserApplication.java
    ├── controller/
    │   ├── SettingsController.java
    │   ├── WebhookController.java
    │   └── InternalWebhookController.java
    ├── service/
    │   ├── SettingsService.java
    │   └── WebhookService.java
    ├── repository/
    │   ├── UserSettingsRepository.java
    │   └── WebhookRepository.java
    ├── entity/
    │   ├── UserSettings.java
    │   └── Webhook.java
    └── dto/
        ├── SettingsRequest.java
        └── WebhookRequest.java
```

## 3. API 端点

### 对外 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/user/v1/settings` | 获取设置 |
| PATCH | `/api/user/v1/settings` | 更新设置 |
| GET | `/api/user/v1/webhook` | 获取 Webhook |
| POST | `/api/user/v1/webhook` | 保存 Webhook |
| DELETE | `/api/user/v1/webhook` | 删除 Webhook |

### 内部 API

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/internal/user/v1/webhooks/{userId}` | 获取用户 Webhook 配置 |

## 4. 数据库表

- `user_settings` - 用户设置表
- `webhooks` - Webhook 配置表
