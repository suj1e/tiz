package io.github.suj1e.user.dto;

import io.github.suj1e.user.entity.Webhook;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Webhook 响应 DTO.
 */
public record WebhookResponse(
    UUID id,
    String url,
    boolean enabled,
    List<String> events,
    String secret,
    Instant createdAt,
    Instant updatedAt
) {
    public static WebhookResponse from(Webhook webhook) {
        return new WebhookResponse(
            webhook.getId(),
            webhook.getUrl(),
            webhook.getEnabled(),
            webhook.getEvents(),
            webhook.getSecret(),
            webhook.getCreatedAt(),
            webhook.getUpdatedAt()
        );
    }
}
