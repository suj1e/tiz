package io.github.suj1e.auth.core.domainservice;

import io.github.suj1e.auth.core.domain.RefreshToken;
import io.github.suj1e.auth.core.domain.User;

import java.time.Instant;

/**
 * Token domain service interface.
 *
 * <p>Handles token generation and validation business logic.
 *
 * @author sujie
 */
public interface TokenDomainService {

    /**
     * Calculate access token expiration time.
     *
     * @param expiryMinutes minutes until expiration
     * @return expiration instant
     */
    Instant calculateAccessTokenExpiry(int expiryMinutes);

    /**
     * Calculate refresh token expiration time.
     *
     * @param expiryDays days until expiration
     * @return expiration instant
     */
    Instant calculateRefreshTokenExpiry(int expiryDays);

    /**
     * Check if access token needs refresh.
     *
     * @param issuedAt token issued time
     * @param expiryMinutes token lifetime in minutes
     * @param refreshThresholdMinutes threshold before expiration to trigger refresh
     * @return true if token should be refreshed
     */
    boolean needsRefresh(Instant issuedAt, int expiryMinutes, int refreshThresholdMinutes);

    /**
     * Validate refresh token.
     *
     * @param refreshToken the refresh token to validate
     * @throws IllegalArgumentException if token is invalid
     */
    void validateRefreshToken(RefreshToken refreshToken);

    /**
     * Check if token is expired.
     *
     * @param expiresAt expiration time
     * @return true if expired
     */
    boolean isExpired(Instant expiresAt);

    /**
     * Generate unique token string.
     *
     * @return unique token string
     */
    String generateTokenString();
}
