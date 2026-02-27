package io.github.suj1e.content.dto;

import java.util.UUID;

/**
 * 标签响应 DTO.
 */
public record TagResponse(
    UUID id,
    String name
) {}
