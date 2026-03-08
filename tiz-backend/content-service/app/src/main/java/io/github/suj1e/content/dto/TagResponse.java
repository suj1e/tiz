package io.github.suj1e.content.dto;

import java.util.UUID;

/**
 * 标签响应 DTO.
 */
public record TagResponse(
    UUID id,
    String name,
    long count
) {
    /**
     * 简化构造函数 (用于内部 API).
     */
    public TagResponse(UUID id, String name) {
        this(id, name, 0);
    }
}
