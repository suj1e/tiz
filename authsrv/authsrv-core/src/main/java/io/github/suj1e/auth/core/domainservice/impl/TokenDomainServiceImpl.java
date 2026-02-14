package io.github.suj1e.auth.core.domainservice.impl;

import lombok.extern.slf4j.Slf4j;
import io.github.suj1e.auth.core.domainservice.TokenDomainService;
import io.github.suj1e.auth.core.domain.RefreshToken;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;

/**
 * Token domain service implementation.
 *
 * @author sujie
 */
@Slf4j
public class TokenDomainServiceImpl implements TokenDomainService {

    private static final int TOKEN_BYTES = 64;
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    public Instant calculateAccessTokenExpiry(int expiryMinutes) {
        return Instant.now().plusSeconds(expiryMinutes * 60L);
    }

    @Override
    public Instant calculateRefreshTokenExpiry(int expiryDays) {
        return Instant.now().plusSeconds(expiryDays * 24L * 60 * 60);
    }

    @Override
    public boolean needsRefresh(Instant issuedAt, int expiryMinutes, int refreshThresholdMinutes) {
        Instant threshold = Instant.now().plusSeconds(refreshThresholdMinutes * 60L);
        Instant expiry = issuedAt.plusSeconds(expiryMinutes * 60L);
        return expiry.isBefore(threshold);
    }

    @Override
    public void validateRefreshToken(RefreshToken refreshToken) {
        if (refreshToken == null) {
            throw new IllegalArgumentException("Refresh token cannot be null");
        }
        if (!refreshToken.isValid()) {
            if (refreshToken.getRevoked()) {
                throw new IllegalArgumentException("Refresh token has been revoked");
            }
            if (refreshToken.isExpired()) {
                throw new IllegalArgumentException("Refresh token has expired");
            }
        }
    }

    @Override
    public boolean isExpired(Instant expiresAt) {
        return expiresAt != null && Instant.now().isAfter(expiresAt);
    }

    @Override
    public String generateTokenString() {
        byte[] tokenBytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }
}
