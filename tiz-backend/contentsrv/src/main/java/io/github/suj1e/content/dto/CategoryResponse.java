package io.github.suj1e.content.dto;

import java.util.UUID;

/**
 * 分类响应 DTO.
 */
public record CategoryResponse(
    UUID id,
    String name,
    String description,
    Integer sortOrder
) {}
