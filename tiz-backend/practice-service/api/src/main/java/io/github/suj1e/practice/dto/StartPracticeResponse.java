package io.github.suj1e.practice.dto;

import java.util.List;
import java.util.UUID;

/**
 * 开始练习响应.
 */
public record StartPracticeResponse(
    UUID sessionId,
    UUID knowledgeSetId,
    String knowledgeSetTitle,
    int totalQuestions,
    List<QuestionResponse> questions
) {
    /**
     * 题目响应 (不含答案).
     */
    public record QuestionResponse(
        UUID id,
        String type,
        String content,
        List<String> options,
        int order
    ) {}
}
