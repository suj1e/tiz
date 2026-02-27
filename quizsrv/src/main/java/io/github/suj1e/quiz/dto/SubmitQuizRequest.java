package io.github.suj1e.quiz.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

/**
 * 批量提交测验请求.
 */
public record SubmitQuizRequest(
    @NotEmpty(message = "Answers cannot be empty")
    @Valid
    List<AnswerItem> answers
) {
    /**
     * 答案项.
     */
    public record AnswerItem(
        @NotNull(message = "Question ID is required")
        UUID questionId,

        @NotNull(message = "Answer is required")
        String answer
    ) {}
}
