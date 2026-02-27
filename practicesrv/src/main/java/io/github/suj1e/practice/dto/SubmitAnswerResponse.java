package io.github.suj1e.practice.dto;

import java.math.BigDecimal;

/**
 * 提交答案响应.
 */
public record SubmitAnswerResponse(
    boolean correct,
    BigDecimal score,
    BigDecimal maxScore,
    String correctAnswer,
    String explanation,
    String aiFeedback
) {}
