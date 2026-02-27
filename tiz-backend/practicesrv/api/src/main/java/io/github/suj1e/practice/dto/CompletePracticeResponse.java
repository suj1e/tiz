package io.github.suj1e.practice.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * 完成练习响应.
 */
public record CompletePracticeResponse(
    UUID sessionId,
    String status,
    int totalQuestions,
    int correctCount,
    BigDecimal score,
    BigDecimal accuracy,
    Instant completedAt
) {}
