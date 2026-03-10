package io.github.suj1e.user.dto;

import io.github.suj1e.user.entity.UserSettings;

import java.time.Instant;

/**
 * AI 配置响应 DTO.
 */
public record AiConfigResponse(
    String preferredModel,
    Double temperature,
    Integer maxTokens,
    String systemPrompt,
    String responseLanguage,
    String customApiUrl,
    String customApiKey,
    Instant updatedAt
) {
    public static AiConfigResponse from(UserSettings settings) {
        return new AiConfigResponse(
            settings.getPreferredModel(),
            settings.getTemperature(),
            settings.getMaxTokens(),
            settings.getSystemPrompt(),
            settings.getResponseLanguage(),
            settings.getCustomApiUrl(),
            settings.getCustomApiKey(),
            settings.getUpdatedAt()
        );
    }
}
