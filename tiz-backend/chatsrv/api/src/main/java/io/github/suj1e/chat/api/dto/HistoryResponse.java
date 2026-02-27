package io.github.suj1e.chat.api.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 对话历史响应 DTO.
 */
public record HistoryResponse(
    /**
     * 会话 ID.
     */
    UUID sessionId,

    /**
     * 会话状态.
     */
    String status,

    /**
     * 消息列表.
     */
    List<MessageItem> messages
) {
    /**
     * 消息项.
     */
    public record MessageItem(
        UUID id,
        String role,
        String content,
        Instant createdAt
    ) {}
}
