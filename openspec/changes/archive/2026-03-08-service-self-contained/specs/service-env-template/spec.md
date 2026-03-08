## ADDED Requirements

### Requirement: Each service has an .env.example file

每个微服务 SHALL 在服务根目录包含 `.env.example` 文件，作为环境变量的模板。

#### Scenario: File is ready to copy
- **WHEN** 开发者需要配置环境
- **THEN** 可以复制 `.env.example` 到 `.env` 并填写值

#### Scenario: All variables are listed
- **WHEN** 查看 `.env.example`
- **THEN** 包含服务需要的所有环境变量（application.yaml 中引用的）

### Requirement: Variables have descriptive comments

`.env.example` 中的每个变量 SHALL 有注释说明其用途。

#### Scenario: Comments explain purpose
- **WHEN** 查看变量配置
- **THEN** 上一行有注释说明变量作用

#### Scenario: Sensitive values use placeholders
- **WHEN** 变量包含敏感信息（密码、密钥）
- **THEN** 使用占位符如 `<your-password>` 或 `<your-secret>`

### Requirement: Optional variables have sensible defaults

可选变量 SHALL 显示默认值或说明可选。

#### Scenario: Optional variables are marked
- **WHEN** 变量有默认值
- **THEN** `.env.example` 显示默认值或标记为 `(可选)`

#### Scenario: Required variables are grouped
- **WHEN** 查看 `.env.example`
- **THEN** 必需变量在文件顶部或单独分组
