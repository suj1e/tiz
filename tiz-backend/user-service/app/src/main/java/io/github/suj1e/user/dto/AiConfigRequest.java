package io.github.suj1e.user.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * AI 配置请求 DTO.
 */
public record AiConfigRequest(
    @NotBlank(message = "模型不能为空")
    String preferredModel,

    @DecimalMin(value = "0.0", message = "温度必须 >= 0.0")
    @DecimalMax(value = "2.0", message = "温度必须 <= 2.0")
    Double temperature,

    @Min(value = 1, message = "最大 token 数必须 >= 1")
    Integer maxTokens,

    @NotBlank(message = "系统提示词不能为空")
    String systemPrompt,

    @NotBlank(message = "响应语言不能为空")
    String responseLanguage,

    @NotBlank(message = "自定义 API URL 不能为空")
    @Pattern(regexp = "^https://.*", message = "API URL 必须以 https:// 开头")
    String customApiUrl,

    @NotBlank(message = "自定义 API Key 不能为空")
    String customApiKey
) {}
