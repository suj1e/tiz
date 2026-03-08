package io.github.suj1e.llm.api.dto;

import java.util.List;

/**
 * 生成题目响应.
 */
public record GenerateResponse(
    List<QuestionDto> questions,
    BatchInfo batch
) {
    public record QuestionDto(
        String type,
        String content,
        List<String> options,
        String answer,
        String explanation,
        String rubric
    ) {}
}
