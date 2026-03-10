package io.github.suj1e.llm.api.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * AI配置.
 */
public record AiConfig(
    @NotBlank String preferredModel,
    @DecimalMin("0.0") @DecimalMax("2.0") double temperature,
    @Min(1) int maxTokens,
    @NotBlank String systemPrompt,
    @NotBlank String responseLanguage,
    @NotBlank @Pattern(regexp = "^https://.*") String customApiUrl,
    @NotBlank String customApiKey
) {}
