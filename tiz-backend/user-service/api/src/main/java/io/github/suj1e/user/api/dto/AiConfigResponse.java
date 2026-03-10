package io.github.suj1e.user.api.dto;

/**
 * AI配置响应.
 */
public record AiConfigResponse(
    String preferredModel,
    Double temperature,
    Integer maxTokens,
    String systemPrompt,
    String responseLanguage,
    String customApiUrl,
    String customApiKey
) {}
