package io.github.suj1e.auth.adapter.service;

import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.core.domain.RefreshToken;
import io.github.suj1e.auth.core.domain.User;

import java.util.Optional;

/**
 * Token service interface.
 *
 * @author sujie
 */
public interface TokenService {

    /**
     * Generate access token for user.
     *
     * @param user the user
     * @return JWT access token string
     */
    String generateAccessToken(User user);

    /**
     * Generate refresh token for user.
     *
     * @param user the user
     * @return refresh token entity
     */
    RefreshToken generateRefreshToken(User user);

    /**
     * Refresh access token using refresh token.
     *
     * @param refreshTokenString the refresh token string
     * @return new access token response
     */
    Optional<TokenResponse> refreshAccessToken(String refreshTokenString);

    /**
     * Validate access token.
     *
     * @param token the token string
     * @return true if token is valid
     */
    boolean validateAccessToken(String token);

    /**
     * Extract username from token.
     *
     * @param token the token string
     * @return username
     */
    String getUsernameFromToken(String token);

    /**
     * Extract user ID from token.
     *
     * @param token the token string
     * @return user ID
     */
    Long getUserIdFromToken(String token);

    /**
     * Revoke refresh token.
     *
     * @param tokenString the token string to revoke
     */
    void revokeRefreshToken(String tokenString);

    /**
     * Revoke all refresh tokens for a user.
     *
     * @param userId the user ID
     */
    void revokeAllUserTokens(Long userId);

    /**
     * Clean up expired and revoked tokens.
     */
    void cleanupExpiredTokens();
}
