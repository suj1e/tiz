-- V2: Create role table
CREATE TABLE IF NOT EXISTS t_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default roles
INSERT INTO t_role (code, name, description, enabled, created_at, updated_at) VALUES
('ROLE_USER', 'User', 'Regular user', TRUE, NOW(), NOW()),
('ROLE_ADMIN', 'Administrator', 'System administrator', TRUE, NOW(), NOW());
