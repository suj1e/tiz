package io.github.suj1e.auth.dto;

/**
 * 注册响应 DTO.
 * 包含 token 和用户信息.
 */
public record RegisterResponse(
    String token,
    UserResponse user
) {}
