package io.github.suj1e.user.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.user.entity.Webhook;
import io.github.suj1e.user.service.WebhookService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 内部 Webhook 控制器.
 * 供其他微服务调用.
 */
@RestController
@RequestMapping("/internal/user/v1")
@RequiredArgsConstructor
public class InternalWebhookController {

    private final WebhookService webhookService;

    /**
     * 获取用户的 Webhook 配置.
     * 供其他服务查询用户的 Webhook 配置以便发送通知.
     */
    @GetMapping("/webhooks/{userId}")
    public ResponseEntity<ApiResponse<WebhookConfigResponse>> getWebhookConfig(@PathVariable UUID userId) {
        Optional<Webhook> webhookOpt = webhookService.hasEnabledWebhook(userId)
            ? Optional.of(webhookService.getWebhook(userId))
            : Optional.empty();

        if (webhookOpt.isEmpty()) {
            return ResponseEntity.ok(ApiResponse.of(null));
        }

        Webhook webhook = webhookOpt.get();
        WebhookConfigResponse response = new WebhookConfigResponse(
            webhook.getId(),
            webhook.getUrl(),
            webhook.getEnabled(),
            webhook.getEvents(),
            webhook.getSecret()
        );

        return ResponseEntity.ok(ApiResponse.of(response));
    }

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
}
