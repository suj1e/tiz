package io.github.suj1e.quiz.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 开始测验响应.
 */
public record StartQuizResponse(
    UUID sessionId,
    UUID knowledgeSetId,
    String title,
    Integer timeLimit,
    Integer totalQuestions,
    Instant startedAt,
    List<QuestionItem> questions
) {
    /**
     * 题目项.
     */
    public record QuestionItem(
        UUID id,
        String type,
        String content,
        List<String> options
    ) {}
}
