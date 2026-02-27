package io.github.suj1e.user.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * Webhook 请求 DTO.
 */
public record WebhookRequest(
    @NotBlank(message = "URL 不能为空")
    @Size(max = 500, message = "URL 长度不能超过 500 个字符")
    @Pattern(regexp = "^https?://.*", message = "URL 必须以 http:// 或 https:// 开头")
    String url,

    boolean enabled,

    @NotEmpty(message = "至少需要订阅一个事件")
    @Valid
    List<@Pattern(regexp = "^(practice\\.completed|quiz\\.completed|chat\\.confirmed)$",
                  message = "事件类型必须是 practice.completed、quiz.completed 或 chat.confirmed") String> events,

    @Size(max = 255, message = "Secret 长度不能超过 255 个字符")
    String secret
) {}
