package io.github.suj1e.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

/**
 * 对话请求 DTO.
 */
public record ChatRequest(
    /**
     * 会话 ID（可选，首次对话为空）.
     */
    UUID sessionId,

    /**
     * 用户消息内容.
     */
    @NotBlank(message = "消息内容不能为空")
    @Size(max = 4000, message = "消息内容不能超过 4000 字符")
    String message
) {}
