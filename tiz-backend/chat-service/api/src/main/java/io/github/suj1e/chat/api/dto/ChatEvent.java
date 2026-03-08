package io.github.suj1e.chat.api.dto;

/**
 * SSE 聊天事件 DTO.
 * 与 llmsrv-api 的 ChatEvent 保持一致.
 */
public record ChatEvent(
    /**
     * 事件类型: message, confirm, error.
     */
    String type,

    /**
     * 事件数据.
     */
    String data
) {}
