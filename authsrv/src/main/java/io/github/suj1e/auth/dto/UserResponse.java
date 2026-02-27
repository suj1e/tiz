package io.github.suj1e.auth.dto;

import io.github.suj1e.auth.entity.User;

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
    public static UserResponse from(User user) {
        return new UserResponse(
            user.getId(),
            user.getEmail(),
            user.getStatus().name().toLowerCase(),
            user.getCreatedAt()
        );
    }
}
