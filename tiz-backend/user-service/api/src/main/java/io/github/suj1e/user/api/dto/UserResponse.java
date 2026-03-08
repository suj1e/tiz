package io.github.suj1e.user.api.dto;

import java.util.UUID;

/**
 * 用户响应.
 */
public record UserResponse(
    UUID id,
    String email,
    String status
) {}
