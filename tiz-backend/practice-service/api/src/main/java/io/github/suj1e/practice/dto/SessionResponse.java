package io.github.suj1e.practice.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 练习会话响应.
 */
public record SessionResponse(
    UUID id,
    UUID knowledgeSetId,
    String knowledgeSetTitle,
    String status,
    int totalQuestions,
    int answeredCount,
    int correctCount,
    BigDecimal score,
    Instant completedAt,
    Instant createdAt,
    List<AnswerResponse> answers
) {
    /**
     * 答案响应.
     */
    public record AnswerResponse(
        UUID questionId,
        String questionContent,
        String questionType,
        String userAnswer,
        boolean correct,
        BigDecimal score,
        String correctAnswer,
        String explanation,
        String aiFeedback,
        Instant answeredAt
    ) {}
}
