package io.github.suj1e.content.api.dto;

import java.util.List;

/**
 * 批次题目响应 DTO.
 */
public record BatchResponse(
    List<QuestionResponse> questions,
    BatchInfo batch
) {}
