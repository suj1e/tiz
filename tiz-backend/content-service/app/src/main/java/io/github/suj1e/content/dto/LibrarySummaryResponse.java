package io.github.suj1e.content.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 题库列表项响应 DTO.
 */
public record LibrarySummaryResponse(
    UUID id,
    String title,
    String category,
    List<String> tags,
    String difficulty,
    Integer questionCount,
    Instant createdAt
) {}
