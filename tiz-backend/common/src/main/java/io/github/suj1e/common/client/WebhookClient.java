package io.github.suj1e.common.client;

import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

import java.util.List;
import java.util.UUID;

/**
 * Webhook 服务客户端.
 */
@HttpExchange
public interface WebhookClient {

    @GetExchange("/internal/user/v1/webhooks/{userId}")
    ApiResponse<WebhookConfigResponse> getWebhookConfig(@PathVariable UUID userId);

    /**
     * Webhook 配置响应.
     */
    record WebhookConfigResponse(
        UUID id,
        String url,
        boolean enabled,
        List<String> events,
        String secret
    ) {}
}
