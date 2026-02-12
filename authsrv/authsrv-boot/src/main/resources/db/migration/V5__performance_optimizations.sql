-- Performance optimization migration for MySQL
-- Note: MySQL does not support partial indexes (indexes with WHERE clauses)
-- Alternative strategies are used where applicable

-- Add composite index for account unlock queries
-- MySQL doesn't support partial indexes, so we create a regular composite index
CREATE INDEX idx_users_locked_unlock_time ON users(locked, locked_until);

-- Add index for failed login attempts cleanup
CREATE INDEX idx_users_failed_attempts ON users(failed_login_attempts, last_failed_login);

-- Optimize refresh_tokens query for cleanup
CREATE INDEX idx_refresh_tokens_cleanup ON refresh_tokens(expires_at, revoked);

-- Optimize audit_logs for recent entries query
-- Create a composite index for user_id and created_at queries
CREATE INDEX idx_audit_logs_user_created ON audit_logs(user_id, created_at DESC);

-- Add index for outbox event processing
CREATE INDEX idx_outbox_processing ON outbox_event(status, created_at);

-- Add covering index for active users (frequent query optimization)
-- Since MySQL doesn't support partial indexes, we include all users but query should filter
CREATE INDEX idx_users_active_lookup ON users(enabled, locked, expired, id, username, email);
