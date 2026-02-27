package io.github.suj1e.content.dto;

import java.util.List;
import java.util.UUID;

/**
 * 内部题库响应 DTO.
 */
public record KnowledgeSetInternalResponse(
    UUID id,
    String title,
    String category,
    List<String> tags,
    String difficulty,
    Integer questionCount
) {}
