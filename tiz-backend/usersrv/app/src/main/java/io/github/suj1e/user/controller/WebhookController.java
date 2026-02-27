package io.github.suj1e.user.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.user.dto.WebhookRequest;
import io.github.suj1e.user.dto.WebhookResponse;
import io.github.suj1e.user.entity.Webhook;
import io.github.suj1e.user.service.WebhookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Webhook 控制器.
 * 提供对外 API.
 */
@RestController
@RequestMapping("/api/user/v1")
@RequiredArgsConstructor
public class WebhookController {

    private final WebhookService webhookService;

    /**
     * 获取 Webhook 配置.
     */
    @GetMapping("/webhook")
    public ResponseEntity<ApiResponse<WebhookResponse>> getWebhook(@AuthenticationPrincipal UUID userId) {
        Webhook webhook = webhookService.getWebhook(userId);
        return ResponseEntity.ok(ApiResponse.of(WebhookResponse.from(webhook)));
    }

    /**
     * 保存 Webhook 配置（创建或更新）.
     */
    @PostMapping("/webhook")
    public ResponseEntity<ApiResponse<WebhookResponse>> saveWebhook(
        @AuthenticationPrincipal UUID userId,
        @Valid @RequestBody WebhookRequest request
    ) {
        Webhook webhook = webhookService.saveWebhook(userId, request);
        return ResponseEntity.ok(ApiResponse.of(WebhookResponse.from(webhook)));
    }

    /**
     * 删除 Webhook 配置.
     */
    @DeleteMapping("/webhook")
    public ResponseEntity<ApiResponse<Void>> deleteWebhook(@AuthenticationPrincipal UUID userId) {
        webhookService.deleteWebhook(userId);
        return ResponseEntity.ok(ApiResponse.empty());
    }
}
