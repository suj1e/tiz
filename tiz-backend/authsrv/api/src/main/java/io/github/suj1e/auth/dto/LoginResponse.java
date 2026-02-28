package io.github.suj1e.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 登录响应 DTO.
 * 包含 token 和用户信息.
 */
public record LoginResponse(
    String token,
    UserResponse user
) {}
