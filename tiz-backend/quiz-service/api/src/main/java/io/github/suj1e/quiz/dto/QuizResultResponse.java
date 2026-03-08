package io.github.suj1e.quiz.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 测验结果响应.
 */
public record QuizResultResponse(
    UUID resultId,
    UUID sessionId,
    UUID knowledgeSetId,
    String title,
    BigDecimal score,
    BigDecimal total,
    Integer correctCount,
    Integer totalQuestions,
    Integer timeSpent,
    Instant completedAt,
    List<ResultDetailItem> details
) {
    /**
     * 结果详情项.
     */
    public record ResultDetailItem(
        UUID questionId,
        String questionType,
        String questionContent,
        List<String> options,
        String correctAnswer,
        String userAnswer,
        Boolean isCorrect,
        BigDecimal score,
        String explanation,
        String aiFeedback
    ) {}
}
