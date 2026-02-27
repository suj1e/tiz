package io.github.suj1e.practice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * 提交答案请求.
 */
public record SubmitAnswerRequest(
    @NotNull(message = "Question ID is required")
    UUID questionId,

    @NotBlank(message = "Answer is required")
    String answer
) {}
