package io.github.suj1e.user.api.client;

import io.github.suj1e.user.api.dto.WebhookConfigResponse;
import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

import java.util.UUID;

/**
 * Webhook 服务客户端.
 */
@HttpExchange
public interface WebhookClient {

    @GetExchange("/internal/user/v1/webhooks/{userId}")
    ApiResponse<WebhookConfigResponse> getWebhookConfig(@PathVariable UUID userId);
}
