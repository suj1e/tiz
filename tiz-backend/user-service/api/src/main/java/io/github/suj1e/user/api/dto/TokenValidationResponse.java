package io.github.suj1e.user.api.dto;

import java.util.UUID;

/**
 * Token 验证响应.
 */
public record TokenValidationResponse(
    boolean valid,
    UUID userId,
    String email
) {}
