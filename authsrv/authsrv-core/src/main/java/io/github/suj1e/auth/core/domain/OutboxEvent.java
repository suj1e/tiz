package io.github.suj1e.auth.core.domain;

import jakarta.persistence.*;
import lombok.Getter;
import com.nexora.datajp.support.BaseEntity;

import java.time.Instant;

/**
 * Outbox event for reliable event publishing.
 *
 * <p>Implements the Outbox Pattern to guarantee at-least-once delivery of events to Kafka.
 * Events are written to this table within the same transaction as the business logic,
 * then a background job scans and publishes them to Kafka.
 *
 * @author sujie
 */
@Getter
@Entity
@Table(name = "outbox_event", indexes = {
    @Index(name = "idx_outbox_status_created", columnList = "status, created_at")
})
public class OutboxEvent extends BaseEntity {

    /**
     * Event type (e.g., USER_CREATED, USER_LOGIN).
     */
    @Column(name = "event_type", nullable = false, length = 64)
    private String eventType;

    /**
     * Kafka topic to publish to.
     */
    @Column(name = "topic", nullable = false, length = 128)
    private String topic;

    /**
     * Business key (e.g., userId) for Kafka partitioning.
     */
    @Column(name = "biz_id", nullable = false, length = 64)
    private String bizId;

    /**
     * Event payload as JSON.
     */
    @Column(name = "payload", nullable = false, columnDefinition = "JSONB")
    private String payload;

    /**
     * Delivery status: NEW, SENT, FAILED.
     */
    @Column(name = "status", nullable = false, length = 16)
    @Enumerated(EnumType.STRING)
    private OutboxStatus status = OutboxStatus.NEW;

    /**
     * Number of delivery attempts.
     */
    @Column(name = "retry_count", nullable = false)
    private int retryCount = 0;

    /**
     * When the event was successfully sent.
     */
    @Column(name = "sent_at")
    private Instant sentAt;

    /**
     * Error message if delivery failed.
     */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /**
     * Delivery status enum.
     */
    public enum OutboxStatus {
        NEW,    // Not yet sent
        SENT,   // Successfully sent
        FAILED  // Failed after max retries
    }

    /**
     * Mark the event as successfully sent.
     */
    public void markSent() {
        this.status = OutboxStatus.SENT;
        this.sentAt = Instant.now();
        this.errorMessage = null;
    }

    /**
     * Increment retry count and check if max retries exceeded.
     *
     * @param maxRetries maximum allowed retries
     * @return true if max retries exceeded
     */
    public boolean incrementRetry(int maxRetries) {
        this.retryCount++;
        if (this.retryCount >= maxRetries) {
            this.status = OutboxStatus.FAILED;
            return true;
        }
        return false;
    }

    /**
     * Mark the event as failed.
     *
     * @param errorMessage the error message
     */
    public void markFailed(String errorMessage) {
        this.status = OutboxStatus.FAILED;
        this.errorMessage = errorMessage;
    }

    /**
     * Create a new outbox event.
     *
     * @param eventType the event type
     * @param topic     the Kafka topic
     * @param bizId     the business key for partitioning
     * @param payload   the event payload as JSON
     * @return the outbox event
     */
    public static OutboxEvent of(String eventType, String topic, String bizId, String payload) {
        OutboxEvent event = new OutboxEvent();
        event.eventType = eventType;
        event.topic = topic;
        event.bizId = bizId;
        event.payload = payload;
        event.status = OutboxStatus.NEW;
        event.retryCount = 0;
        return event;
    }
}
