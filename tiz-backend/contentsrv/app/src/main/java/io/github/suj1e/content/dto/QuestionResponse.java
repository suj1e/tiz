package io.github.suj1e.content.dto;

import java.util.List;
import java.util.UUID;

/**
 * 题目响应 DTO.
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
