package io.github.suj1e.chat.dto;

import io.github.suj1e.chat.entity.ChatMessage;

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
    ) {
        /**
         * 从实体转换.
         */
        public static MessageItem from(ChatMessage message) {
            return new MessageItem(
                message.getId(),
                message.getRole().name().toLowerCase(),
                message.getContent(),
                message.getCreatedAt()
            );
        }
    }
}
