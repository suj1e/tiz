package io.github.suj1e.llm.api.dto;

/**
 * 对话消息.
 */
public record ChatMessage(
    String role,
    String content
) {}
