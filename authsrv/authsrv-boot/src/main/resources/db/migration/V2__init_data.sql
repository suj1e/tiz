-- Insert default roles
INSERT INTO roles (name, description) VALUES
    ('ROLE_USER', 'Standard user role'),
    ('ROLE_ADMIN', 'Administrator role'),
    ('ROLE_SUPER_ADMIN', 'Super administrator role')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Create default admin account (username: admin, password: admin123)
-- BCrypt hash of "admin123" with strength 12
INSERT INTO users (username, email, password_hash, name, auth_provider, enabled, created_by)
VALUES (
    'admin',
    'admin@nexora.org',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5gyOqcCkPxRq2',
    'System Administrator',
    'local',
    true,
    'system'
)
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- Assign super admin role to admin user
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'admin' AND r.name = 'ROLE_SUPER_ADMIN'
ON DUPLICATE KEY UPDATE user_id = VALUES(user_id);

-- Create test user account (username: testuser, password: Test123!)
-- BCrypt hash of "Test123!" with strength 12
INSERT INTO users (username, email, password_hash, name, auth_provider, enabled, created_by)
VALUES (
    'testuser',
    'testuser@nexora.org',
    '$2a$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
    'Test User',
    'local',
    true,
    'system'
)
ON DUPLICATE KEY UPDATE email = VALUES(email);

-- Assign user role to testuser
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'testuser' AND r.name = 'ROLE_USER'
ON DUPLICATE KEY UPDATE user_id = VALUES(user_id);
