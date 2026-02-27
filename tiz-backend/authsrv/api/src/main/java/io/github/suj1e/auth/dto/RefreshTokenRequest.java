package io.github.suj1e.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 刷新令牌请求 DTO.
 */
public record RefreshTokenRequest(
    @NotBlank(message = "刷新令牌不能为空")
    String refreshToken
) {}
