package io.github.suj1e.content.dto;

import java.util.UUID;

/**
 * 分类响应 DTO.
 */
public record CategoryResponse(
    UUID id,
    String name,
    String description,
    Integer sortOrder,
    long count
) {
    /**
     * 简化构造函数 (用于内部 API).
     */
    public CategoryResponse(UUID id, String name, String description, Integer sortOrder) {
        this(id, name, description, sortOrder, 0);
    }
}
