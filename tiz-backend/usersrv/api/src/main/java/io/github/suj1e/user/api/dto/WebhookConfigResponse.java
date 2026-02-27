package io.github.suj1e.user.api.dto;

import java.util.List;
import java.util.UUID;

/**
 * Webhook 配置响应.
 */
public record WebhookConfigResponse(
    UUID id,
    String url,
    boolean enabled,
    List<String> events,
    String secret
) {}
