package io.github.suj1e.user.service;

import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.user.dto.WebhookRequest;
import io.github.suj1e.user.entity.Webhook;
import io.github.suj1e.user.repository.WebhookRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Webhook 服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WebhookService {

    private final WebhookRepository webhookRepository;

    /**
     * 获取用户的 Webhook 配置.
     */
    @Transactional(readOnly = true)
    public Webhook getWebhook(UUID userId) {
        return webhookRepository.findByUserId(userId)
            .orElseThrow(() -> new NotFoundException("Webhook", userId));
    }

    /**
     * 保存或更新用户的 Webhook 配置.
     * 每个用户只能有一个 Webhook 配置.
     */
    @Transactional
    public Webhook saveWebhook(UUID userId, WebhookRequest request) {
        return webhookRepository.findByUserId(userId)
            .map(existing -> {
                // 更新现有配置
                log.info("Updating webhook for user: {}", userId);
                existing.setUrl(request.url());
                existing.setEnabled(request.enabled());
                existing.setEvents(request.events());
                existing.setSecret(request.secret());
                return webhookRepository.save(existing);
            })
            .orElseGet(() -> {
                // 创建新配置
                log.info("Creating webhook for user: {}", userId);
                Webhook webhook = Webhook.builder()
                    .userId(userId)
                    .url(request.url())
                    .enabled(request.enabled())
                    .events(request.events())
                    .secret(request.secret())
                    .build();
                return webhookRepository.save(webhook);
            });
    }

    /**
     * 删除用户的 Webhook 配置.
     */
    @Transactional
    public void deleteWebhook(UUID userId) {
        Webhook webhook = getWebhook(userId);
        webhookRepository.delete(webhook);
        log.info("Deleted webhook for user: {}", userId);
    }

    /**
     * 检查用户是否有启用的 Webhook.
     */
    @Transactional(readOnly = true)
    public boolean hasEnabledWebhook(UUID userId) {
        return webhookRepository.findByUserIdAndEnabled(userId, true).isPresent();
    }
}
