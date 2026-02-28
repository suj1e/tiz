## MODIFIED Requirements

### Requirement: Login response format

The system SHALL return login responses in a combined format with token and user info.

#### Scenario: Successful login
- **WHEN** user logs in with valid credentials
- **THEN** system returns HTTP 200 with response body:
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "created_at": "2024-02-26T00:00:00Z",
      "settings": {
        "theme": "system"
      }
    }
  }
}
```

#### Scenario: Invalid credentials
- **WHEN** user logs in with invalid credentials
- **THEN** system returns HTTP 401 with error:
```json
{
  "error": {
    "type": "authentication_error",
    "code": "invalid_credentials",
    "message": "邮箱或密码错误"
  }
}
```

### Requirement: Register response format

The system SHALL return registration responses in the same combined format as login.

#### Scenario: Successful registration
- **WHEN** user registers with valid email and password
- **THEN** system returns HTTP 200 with response body:
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "created_at": "2024-02-26T00:00:00Z",
      "settings": {
        "theme": "system"
      }
    }
  }
}
```

#### Scenario: Email already exists
- **WHEN** user registers with existing email
- **THEN** system returns HTTP 400 with error:
```json
{
  "error": {
    "type": "validation_error",
    "code": "email_exists",
    "message": "该邮箱已被注册"
  }
}
```
