package io.github.suj1e.llm.api.dto;

import java.util.UUID;

/**
 * 生成题目请求.
 */
public record GenerateRequest(
    UUID sessionId,
    Integer batchSize,
    Integer batchNumber
) {}
