## MODIFIED Requirements

### Requirement: 分页请求参数封装

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
