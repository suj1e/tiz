## Requirements

### Requirement: Cursor-based pagination format

The system SHALL return paginated responses using cursor-based pagination for better performance and mobile-friendly infinite scrolling.

#### Scenario: First page request
- **WHEN** client requests paginated data without a token
- **THEN** query parameter is: page_size (default 10)
- **AND** response body uses this format:
```json
{
  "data": [...],
  "has_more": true,
  "next_token": "eyJpZDoxMDA..."
}
```

#### Scenario: Subsequent page request
- **WHEN** client requests next page with page_token
- **THEN** query parameters are: page_size (default 10), page_token (from previous response)
- **AND** response returns items after the cursor position

#### Scenario: Empty result set
- **WHEN** API returns no results
- **THEN** data array is empty
- **AND** has_more is false
- **AND** next_token is null or absent

#### Scenario: Last page
- **WHEN** client requests the last page
- **THEN** has_more is false
- **AND** next_token is null or absent

### Requirement: Pagination parameter names

The system SHALL use cursor-based pagination parameters.

#### Scenario: Request parameters
- **WHEN** client requests paginated data
- **THEN** query parameters are:
  - page_size (optional, default 10, max 100)
  - page_token (optional, cursor from previous response)

#### Scenario: Custom page size
- **WHEN** client specifies page_size=20
- **THEN** response contains up to 20 items
- **AND** has_more indicates if more items exist

### Requirement: Cursor token format

The system SHALL encode cursor tokens in a secure and stateless manner.

#### Scenario: Token encoding
- **WHEN** system generates a next_token
- **THEN** token is a base64-encoded JSON string containing the cursor position
- **AND** token typically contains the last item's ID or timestamp

### Requirement: PageQuery 分页请求参数封装

系统 SHALL 提供 PageQuery 类用于封装分页请求参数，支持页码、每页大小、排序字段和排序方向。

#### Scenario: 默认分页参数
- **WHEN** 不提供任何参数
- **THEN** 系统 SHALL 使用默认值 page=1, pageSize=10

#### Scenario: 自定义分页参数
- **WHEN** 提供 page=2, pageSize=20
- **THEN** 系统 SHALL 返回第 2 页，每页 20 条记录

#### Scenario: 转换为 Spring Data Pageable
- **WHEN** 调用 toPageable() 方法
- **THEN** 系统 SHALL 返回对应的 `org.springframework.data.domain.Pageable` 对象

#### Scenario: 计算偏移量
- **WHEN** 调用 offset() 方法
- **THEN** 系统 SHALL 返回正确的数据库偏移量 (page-1) * pageSize

#### Scenario: 参数校验
- **WHEN** 提供 page < 1 或 pageSize > 100
- **THEN** 系统 SHALL 拒绝请求并返回校验错误
