package com.nexora.auth.api.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * Refresh token request DTO.
 *
 * @author sujie
 */
public record RefreshTokenRequest(
    @NotBlank(message = "Refresh token cannot be blank")
    String refreshToken
) {
}
