package io.github.suj1e.llm.api.dto;

import java.util.UUID;

/**
 * 评分请求.
 */
public record GradeRequest(
    UUID questionId,
    String questionContent,
    String correctAnswer,
    String rubric,
    String userAnswer
) {}
