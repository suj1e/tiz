package io.github.suj1e.chat.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * 确认生成请求 DTO.
 */
public record ConfirmRequest(
    /**
     * 会话 ID.
     */
    @NotNull(message = "会话 ID 不能为空")
    UUID sessionId
) {}
