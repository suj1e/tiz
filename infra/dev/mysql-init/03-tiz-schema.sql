-- ============================================================
-- Tiz Platform Database Schema
-- ============================================================

-- 使用 tiz 数据库
USE tiz;

-- ============================================================
-- authsrv: 认证服务
-- ============================================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BINARY(16) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status ENUM('active', 'inactive', 'banned') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_email (email),
    KEY idx_users_status (status),
    KEY idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 刷新令牌表
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP(6) NOT NULL,
    revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    PRIMARY KEY (id),
    UNIQUE KEY uk_refresh_tokens_hash (token_hash),
    KEY idx_refresh_tokens_user_id (user_id),
    KEY idx_refresh_tokens_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- usersrv: 用户服务
-- ============================================================

-- 用户设置表
CREATE TABLE IF NOT EXISTS user_settings (
    user_id BINARY(16) NOT NULL,
    theme VARCHAR(20) NOT NULL DEFAULT 'system',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Webhook 配置表
CREATE TABLE IF NOT EXISTS webhooks (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    url VARCHAR(500) NOT NULL,
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    events JSON NOT NULL,
    secret VARCHAR(255),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_webhooks_user_id (user_id),
    KEY idx_webhooks_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- contentsrv: 内容服务
-- ============================================================

-- 分类表
CREATE TABLE IF NOT EXISTS categories (
    id BINARY(16) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    PRIMARY KEY (id),
    UNIQUE KEY uk_categories_name (name),
    KEY idx_categories_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 标签表
CREATE TABLE IF NOT EXISTS tags (
    id BINARY(16) NOT NULL,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    PRIMARY KEY (id),
    UNIQUE KEY uk_tags_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 题库表 (支持软删除)
CREATE TABLE IF NOT EXISTS knowledge_sets (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    title VARCHAR(255) NOT NULL,
    category_id BINARY(16),
    difficulty ENUM('easy', 'medium', 'hard') NOT NULL DEFAULT 'medium',
    question_count INT NOT NULL DEFAULT 0,
    deleted_at TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_knowledge_sets_user_id (user_id),
    KEY idx_knowledge_sets_category_id (category_id),
    KEY idx_knowledge_sets_difficulty (difficulty),
    KEY idx_knowledge_sets_deleted_at (deleted_at),
    KEY idx_knowledge_sets_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 题库-标签关联表
CREATE TABLE IF NOT EXISTS knowledge_set_tags (
    knowledge_set_id BINARY(16) NOT NULL,
    tag_id BINARY(16) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (knowledge_set_id, tag_id),
    KEY idx_knowledge_set_tags_tag_id (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 题目表
CREATE TABLE IF NOT EXISTS questions (
    id BINARY(16) NOT NULL,
    knowledge_set_id BINARY(16) NOT NULL,
    type ENUM('choice', 'essay') NOT NULL,
    content TEXT NOT NULL,
    options JSON,
    answer TEXT NOT NULL,
    explanation TEXT,
    rubric TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_questions_knowledge_set_id (knowledge_set_id),
    KEY idx_questions_type (type),
    KEY idx_questions_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- chatsrv: 对话服务
-- ============================================================

-- 对话会话表
CREATE TABLE IF NOT EXISTS chat_sessions (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    status ENUM('active', 'confirmed', 'expired') NOT NULL DEFAULT 'active',
    generated_summary JSON,
    confirmed_knowledge_set_id BINARY(16),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_chat_sessions_user_id (user_id),
    KEY idx_chat_sessions_status (status),
    KEY idx_chat_sessions_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 对话消息表
CREATE TABLE IF NOT EXISTS chat_messages (
    id BINARY(16) NOT NULL,
    session_id BINARY(16) NOT NULL,
    role ENUM('user', 'assistant') NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_chat_messages_session_id (session_id),
    KEY idx_chat_messages_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- practicesrv: 练习服务
-- ============================================================

-- 练习会话表
CREATE TABLE IF NOT EXISTS practice_sessions (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    knowledge_set_id BINARY(16) NOT NULL,
    status ENUM('in_progress', 'completed', 'abandoned') NOT NULL DEFAULT 'in_progress',
    total_questions INT NOT NULL DEFAULT 0,
    correct_count INT NOT NULL DEFAULT 0,
    score DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    completed_at TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_practice_sessions_user_id (user_id),
    KEY idx_practice_sessions_knowledge_set_id (knowledge_set_id),
    KEY idx_practice_sessions_status (status),
    KEY idx_practice_sessions_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 练习答案表
CREATE TABLE IF NOT EXISTS practice_answers (
    id BINARY(16) NOT NULL,
    session_id BINARY(16) NOT NULL,
    question_id BINARY(16) NOT NULL,
    user_answer TEXT NOT NULL,
    is_correct TINYINT(1) NOT NULL DEFAULT 0,
    score DECIMAL(5,2),
    ai_feedback TEXT,
    answered_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_practice_answers_session_question (session_id, question_id),
    KEY idx_practice_answers_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- quizsrv: 测验服务
-- ============================================================

-- 测验会话表
CREATE TABLE IF NOT EXISTS quiz_sessions (
    id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    knowledge_set_id BINARY(16) NOT NULL,
    status ENUM('in_progress', 'completed', 'expired') NOT NULL DEFAULT 'in_progress',
    time_limit INT,
    total_questions INT NOT NULL DEFAULT 0,
    started_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    completed_at TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    KEY idx_quiz_sessions_user_id (user_id),
    KEY idx_quiz_sessions_knowledge_set_id (knowledge_set_id),
    KEY idx_quiz_sessions_status (status),
    KEY idx_quiz_sessions_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 测验答案表 (批量提交前暂存)
CREATE TABLE IF NOT EXISTS quiz_answers (
    id BINARY(16) NOT NULL,
    session_id BINARY(16) NOT NULL,
    question_id BINARY(16) NOT NULL,
    user_answer TEXT NOT NULL,
    answered_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_quiz_answers_session_question (session_id, question_id),
    KEY idx_quiz_answers_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 测验结果表
CREATE TABLE IF NOT EXISTS quiz_results (
    id BINARY(16) NOT NULL,
    session_id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    knowledge_set_id BINARY(16) NOT NULL,
    score DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    correct_count INT NOT NULL DEFAULT 0,
    time_spent INT NOT NULL DEFAULT 0,
    completed_at TIMESTAMP(6) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    created_by BINARY(16),
    updated_by BINARY(16),
    PRIMARY KEY (id),
    UNIQUE KEY uk_quiz_results_session_id (session_id),
    KEY idx_quiz_results_user_id (user_id),
    KEY idx_quiz_results_knowledge_set_id (knowledge_set_id),
    KEY idx_quiz_results_completed_at (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 测验结果详情表
CREATE TABLE IF NOT EXISTS quiz_result_details (
    id BINARY(16) NOT NULL,
    result_id BINARY(16) NOT NULL,
    question_id BINARY(16) NOT NULL,
    question_snapshot JSON NOT NULL,
    user_answer TEXT NOT NULL,
    is_correct TINYINT(1) NOT NULL DEFAULT 0,
    score DECIMAL(5,2),
    ai_feedback TEXT,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_quiz_result_details_result_question (result_id, question_id),
    KEY idx_quiz_result_details_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Outbox: 事务性消息 (所有服务共享)
-- ============================================================

CREATE TABLE IF NOT EXISTS outbox_events (
    id BINARY(16) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    aggregate_id BINARY(16) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSON NOT NULL,
    status ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    retry_count INT NOT NULL DEFAULT 0,
    error_message TEXT,
    sent_at TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_outbox_events_status (status),
    KEY idx_outbox_events_aggregate (aggregate_type, aggregate_id),
    KEY idx_outbox_events_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 初始化数据
-- ============================================================

-- 插入默认分类
INSERT INTO categories (id, name, description, sort_order) VALUES
    (UUID_TO_BIN(UUID()), '前端开发', 'Frontend Development', 1),
    (UUID_TO_BIN(UUID()), '后端开发', 'Backend Development', 2),
    (UUID_TO_BIN(UUID()), '数据库', 'Database', 3),
    (UUID_TO_BIN(UUID()), '系统设计', 'System Design', 4),
    (UUID_TO_BIN(UUID()), 'DevOps', 'DevOps & Infrastructure', 5),
    (UUID_TO_BIN(UUID()), '人工智能', 'AI & Machine Learning', 6),
    (UUID_TO_BIN(UUID()), '其他', 'Other', 99);
