package io.github.suj1e.quiz.dto;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * 测验完成事件 (Outbox payload).
 */
public record QuizCompletedEvent(
    UUID userId,
    UUID quizId,
    UUID sessionId,
    UUID knowledgeSetId,
    BigDecimal score,
    BigDecimal total,
    Integer correctCount,
    Integer totalQuestions
) {}
