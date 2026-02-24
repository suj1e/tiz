-- V3__create_content_table.sql
-- Create content table

CREATE TABLE IF NOT EXISTS t_content (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    content_url VARCHAR(500),
    type VARCHAR(20) NOT NULL DEFAULT 'ARTICLE',
    category_id BIGINT,
    author_id BIGINT,
    author_name VARCHAR(100),
    view_count INT NOT NULL DEFAULT 0,
    like_count INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_trending BOOLEAN NOT NULL DEFAULT FALSE,
    published_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_published_at (published_at),
    INDEX idx_is_featured (is_featured),
    INDEX idx_is_trending (is_trending),
    INDEX idx_view_count (view_count),
    INDEX idx_title_description (title(100), description(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
