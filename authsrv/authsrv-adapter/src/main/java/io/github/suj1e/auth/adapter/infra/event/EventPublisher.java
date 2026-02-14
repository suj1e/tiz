package io.github.suj1e.auth.adapter.infra.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import io.github.suj1e.auth.adapter.infra.id.SnowflakeIdGenerator;
import io.github.suj1e.auth.adapter.infra.repository.OutboxEventRepository;
import io.github.suj1e.auth.api.event.UserEvent;
import io.github.suj1e.auth.api.event.UserEventType;
import io.github.suj1e.auth.core.domain.OutboxEvent;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Event publisher service using Outbox Pattern.
 *
 * <p>This service publishes events to the outbox table within the same transaction
 * as the business logic. The events are then published to Kafka by a background job.
 *
 * <p>Usage:
 * <pre>
 * eventPublisher.publishUserEvent(UserEventType.USER_CREATED, user);
 * </pre>
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class EventPublisher {

    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;
    private final SnowflakeIdGenerator snowflakeIdGenerator;

    /**
     * Publish a user event to the outbox.
     *
     * @param eventType the event type
     * @param userId    the user ID
     * @param username  the username
     * @param email     the email
     * @param name      the display name
     */
    @Transactional
    public void publishUserEvent(UserEventType eventType, Long userId, String username, String email, String name) {
        publishUserEvent(eventType, userId, username, email, name, null);
    }

    /**
     * Publish a user event with metadata to the outbox.
     *
     * @param eventType the event type
     * @param userId    the user ID
     * @param username  the username
     * @param email     the email
     * @param name      the display name
     * @param metadata  additional metadata
     */
    @Transactional
    public void publishUserEvent(UserEventType eventType, Long userId, String username, String email, String name,
                                 java.util.Map<String, Object> metadata) {
        try {
            // Generate Snowflake ID for event
            String eventId = String.valueOf(snowflakeIdGenerator.nextId());
            UserEvent userEvent = UserEvent.of(eventId, eventType, userId, username, email, name, metadata);
            String payload = objectMapper.writeValueAsString(userEvent);

            String topic = getTopicForEventType(eventType);

            OutboxEvent outboxEvent = OutboxEvent.of(
                eventType.name(),
                topic,
                String.valueOf(userId),
                payload
            );

            outboxEventRepository.save(outboxEvent);

            log.debug("Published outbox event: type={}, userId={}, topic={}", eventType, userId, topic);

        } catch (Exception e) {
            log.error("Failed to publish outbox event: type={}, userId={}", eventType, userId, e);
            throw new RuntimeException("Failed to publish event", e);
        }
    }

    /**
     * Get the Kafka topic for a given event type.
     *
     * @param eventType the event type
     * @return the Kafka topic name
     */
    private String getTopicForEventType(UserEventType eventType) {
        return switch (eventType) {
            case USER_CREATED -> "auth.user.created.v1";
            case USER_LOGIN -> "auth.user.login.v1";
            case USER_LOGOUT -> "auth.user.logout.v1";
            case PASSWORD_CHANGED -> "auth.user.password_changed.v1";
            case ACCOUNT_LOCKED -> "auth.user.locked.v1";
            case ACCOUNT_UNLOCKED -> "auth.user.unlocked.v1";
            case ROLE_ASSIGNED -> "auth.user.role_assigned.v1";
            case ROLE_REVOKED -> "auth.user.role_revoked.v1";
            case SESSION_CREATED -> "auth.session.created.v1";
            case SESSION_EXPIRED -> "auth.session.expired.v1";
            case SESSION_REVOKED -> "auth.session.revoked.v1";
        };
    }
}
