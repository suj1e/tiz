package io.github.suj1e.content.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 题库响应 DTO.
 */
public record LibraryResponse(
    UUID id,
    String title,
    UUID categoryId,
    String categoryName,
    List<String> tags,
    String difficulty,
    Integer questionCount,
    Instant createdAt,
    Instant updatedAt
) {}
