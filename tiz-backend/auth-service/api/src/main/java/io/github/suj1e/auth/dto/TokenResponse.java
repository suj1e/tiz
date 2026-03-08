package io.github.suj1e.auth.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Token 响应 DTO.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record TokenResponse(
    String accessToken,
    String refreshToken,
    String tokenType,
    Long expiresIn
) {
    public TokenResponse(String accessToken, String refreshToken, Long expiresIn) {
        this(accessToken, refreshToken, "Bearer", expiresIn);
    }
}
