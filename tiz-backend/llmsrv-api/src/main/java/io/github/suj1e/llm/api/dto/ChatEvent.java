package io.github.suj1e.llm.api.dto;

/**
 * 对话事件.
 */
public record ChatEvent(
    String type,
    Object data
) {}
