package io.github.suj1e.llm.api.dto;

/**
 * 评分响应.
 */
public record GradeResponse(
    Integer score,
    Integer maxScore,
    Boolean correct,
    String feedback
) {}
