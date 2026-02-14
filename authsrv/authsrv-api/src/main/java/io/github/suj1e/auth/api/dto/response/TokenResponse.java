package io.github.suj1e.auth.api.dto.response;

/**
 * Token response.
 *
 * @author sujie
 */
public record TokenResponse(
        String accessToken,
        String refreshToken,
        Long expiresIn
) {}
