package io.github.suj1e.content.api.dto;

import java.util.List;
import java.util.UUID;

/**
 * 题目响应.
 */
public record QuestionResponse(
    UUID id,
    String type,
    String content,
    List<String> options,
    String answer,
    String explanation,
    String rubric
) {}
