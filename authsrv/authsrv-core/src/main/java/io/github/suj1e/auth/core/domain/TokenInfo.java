package io.github.suj1e.auth.core.domain;

/**
 * Token information.
 *
 * @author sujie
 */
public record TokenInfo(
        String accessToken,
        String refreshToken,
        Long expiresIn
) {}
