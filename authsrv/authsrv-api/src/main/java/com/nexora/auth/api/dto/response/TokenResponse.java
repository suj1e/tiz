package com.nexora.auth.api.dto.response;

/**
 * Token response DTO.
 *
 * @author sujie
 */
public record TokenResponse(
    String accessToken,
    String tokenType,
    Long expiresIn
) {
    public static TokenResponse of(String accessToken, Long expiresIn) {
        return new TokenResponse(
            accessToken,
            "Bearer",
            expiresIn
        );
    }
}
