package io.github.suj1e.llm.api.dto;

import java.util.List;
import java.util.UUID;

/**
 * 对话请求.
 */
public record ChatRequest(
    UUID sessionId,
    String message,
    List<ChatMessage> history
) {}
