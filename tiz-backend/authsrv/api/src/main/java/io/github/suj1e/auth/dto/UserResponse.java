package io.github.suj1e.auth.dto;

import java.time.Instant;
import java.util.UUID;

/**
 * 用户响应 DTO.
 */
public record UserResponse(
    UUID id,
    String email,
    String status,
    Instant createdAt
) {
}
