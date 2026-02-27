package io.github.suj1e.content.api.dto;

import java.util.List;
import java.util.UUID;

/**
 * 题库响应.
 */
public record KnowledgeSetResponse(
    UUID id,
    String title,
    String category,
    List<String> tags,
    String difficulty,
    Integer questionCount
) {}
