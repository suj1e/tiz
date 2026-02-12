package com.nexora.auth.api.event;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * User event for Kafka messaging.
 *
 * <p>Event structure following the microservices architecture standard:
 * <pre>
 * {
 *   "eventId": "snowflake-id",
 *   "eventType": "USER_CREATED",
 *   "bizId": "123456",
 *   "occurredAt": "2025-01-28T10:30:00Z",
 *   "payload": {
 *     "userId": 123456,
 *     "username": "john.doe",
 *     "email": "john@example.com",
 *     "metadata": { ... }
 *   }
 * }
 * </pre>
 *
 * @author sujie
 */
public record UserEvent(
    String eventId,
    String eventType,
    String bizId,
    Instant occurredAt,
    Payload payload
) {
    /**
     * Event payload containing user information.
     */
    public record Payload(
        Long userId,
        String username,
        String email,
        String name,
        Map<String, Object> metadata
    ) {
        public static Payload of(Long userId, String username, String email, String name) {
            return new Payload(userId, username, email, name, Map.of());
        }

        public static Payload of(Long userId, String username, String email, String name, Map<String, Object> metadata) {
            return new Payload(userId, username, email, name, metadata);
        }
    }

    /**
     * Create a new user event with UUID.
     *
     * @param eventType the event type
     * @param userId    the user ID
     * @param username  the username
     * @param email     the email
     * @param name      the display name
     * @return the user event
     */
    public static UserEvent of(UserEventType eventType, Long userId, String username, String email, String name) {
        return new UserEvent(
            UUID.randomUUID().toString(),
            eventType.name(),
            String.valueOf(userId),
            Instant.now(),
            Payload.of(userId, username, email, name)
        );
    }

    /**
     * Create a new user event with UUID and metadata.
     *
     * @param eventType the event type
     * @param userId    the user ID
     * @param username  the username
     * @param email     the email
     * @param name      the display name
     * @param metadata  additional metadata
     * @return the user event
     */
    public static UserEvent of(UserEventType eventType, Long userId, String username, String email, String name, Map<String, Object> metadata) {
        return new UserEvent(
            UUID.randomUUID().toString(),
            eventType.name(),
            String.valueOf(userId),
            Instant.now(),
            Payload.of(userId, username, email, name, metadata)
        );
    }

    /**
     * Create a new user event with custom event ID (e.g., Snowflake ID).
     *
     * @param eventId   the event ID
     * @param eventType the event type
     * @param userId    the user ID
     * @param username  the username
     * @param email     the email
     * @param name      the display name
     * @param metadata  additional metadata
     * @return the user event
     */
    public static UserEvent of(String eventId, UserEventType eventType, Long userId, String username, String email, String name, Map<String, Object> metadata) {
        return new UserEvent(
            eventId,
            eventType.name(),
            String.valueOf(userId),
            Instant.now(),
            Payload.of(userId, username, email, name, metadata)
        );
    }
}
