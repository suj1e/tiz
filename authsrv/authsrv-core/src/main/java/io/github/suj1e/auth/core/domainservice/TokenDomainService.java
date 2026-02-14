package io.github.suj1e.auth.core.domainservice;

/**
 * Token domain service interface.
 *
 * @author sujie
 */
public interface TokenDomainService {

    /**
     * Generate access token.
     */
    String generateAccessToken(String username);

    /**
     * Generate refresh token.
     */
    String generateRefreshToken(String username);

    /**
     * Validate access token.
     */
    boolean validateAccessToken(String token);

    /**
     * Get username from token.
     */
    String getUsernameFromToken(String token);

    /**
     * Refresh access token.
     */
    String refreshAccessToken(String refreshToken);
}
