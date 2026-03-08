-- Add lark_open_id column to users table for Lark/Feishu login
ALTER TABLE users ADD COLUMN lark_open_id VARCHAR(64) NULL;

-- Add unique index for lark_open_id
CREATE UNIQUE INDEX idx_users_lark_open_id ON users(lark_open_id);
