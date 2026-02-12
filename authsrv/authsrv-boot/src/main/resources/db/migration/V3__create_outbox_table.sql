-- Outbox Pattern table for reliable event publishing to Kafka
-- This table stores events that need to be published to Kafka
-- Events are written within the same transaction as business logic
-- A background job scans and publishes them

CREATE TABLE IF NOT EXISTS outbox_event (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(64) NOT NULL,
    topic VARCHAR(128) NOT NULL,
    biz_id VARCHAR(64) NOT NULL,
    payload JSON NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'NEW',
    retry_count INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    sent_at DATETIME,
    error_message TEXT,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT chk_outbox_status CHECK (status IN ('NEW', 'SENT', 'FAILED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Outbox pattern table for reliable event publishing to Kafka';

-- Index for efficient scanning of pending events
CREATE INDEX idx_outbox_status_created ON outbox_event(status, created_at);

-- Index for Kafka topic queries
CREATE INDEX idx_outbox_topic ON outbox_event(topic);

-- Add column comments (MySQL syntax)
ALTER TABLE outbox_event
    MODIFY COLUMN event_type VARCHAR(64) NOT NULL COMMENT 'Type of event (e.g., USER_CREATED, USER_LOGIN)',
    MODIFY COLUMN topic VARCHAR(128) NOT NULL COMMENT 'Kafka topic to publish to',
    MODIFY COLUMN biz_id VARCHAR(64) NOT NULL COMMENT 'Business key for Kafka partitioning (usually userId)',
    MODIFY COLUMN payload JSON NOT NULL COMMENT 'Event payload as JSON',
    MODIFY COLUMN status VARCHAR(16) NOT NULL DEFAULT 'NEW' COMMENT 'Delivery status: NEW, SENT, or FAILED',
    MODIFY COLUMN retry_count INT NOT NULL DEFAULT 0 COMMENT 'Number of delivery attempts',
    MODIFY COLUMN sent_at DATETIME COMMENT 'When the event was successfully sent to Kafka',
    MODIFY COLUMN error_message TEXT COMMENT 'Error message if delivery failed';
