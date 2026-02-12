package com.nexora.auth.adapter.service.impl;

import com.nexora.security.jwt.JwtTokenProvider;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.api.dto.response.TokenResponse;
import com.nexora.auth.adapter.infra.repository.RefreshTokenRepository;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import com.nexora.auth.core.domainservice.TokenDomainService;
import com.nexora.auth.core.domain.RefreshToken;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.core.support.Entities;
import com.nexora.auth.adapter.service.TokenService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Token service implementation.
 *
 * <p>Optimized with:
 * - Single-query token cleanup
 * - Bulk token revocation
 * - Token validation caching
 * - Uses nexora-spring-boot-starter-security's JwtTokenProvider
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TokenServiceImpl implements TokenService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final TokenDomainService tokenDomainService;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${auth.session.max-concurrent:5}")
    private int maxConcurrentSessions;

    @Value("${auth.jwt.refresh-token-expiry:7d}")
    private String refreshTokenExpiry;

    @Value("${auth.jwt.access-token-expiry-seconds:900}")
    private long accessTokenExpirySeconds;

    @Override
    public String generateAccessToken(User user) {
        // Build claims map for the token
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId());
        claims.put("username", user.getUsername());
        claims.put("email", user.getEmail());
        claims.put("roles", user.getRoles().stream().map(r -> r.getName()).toList());

        // Use user ID as subject
        return jwtTokenProvider.generateToken(user.getId().toString(), claims);
    }

    @Override
    @Transactional
    public RefreshToken generateRefreshToken(User user) {
        Instant now = Instant.now();

        // Use optimized single query to get oldest tokens
        long currentTokenCount = refreshTokenRepository.countValidTokensByUserId(user.getId(), now);

        if (currentTokenCount >= maxConcurrentSessions) {
            // Revoke oldest tokens instead of loading all tokens
            int tokensToRevoke = (int) (currentTokenCount - maxConcurrentSessions + 1);
            List<RefreshToken> oldestTokens = refreshTokenRepository.findOldestValidTokensByUserId(user.getId(), now)
                .stream()
                .limit(tokensToRevoke)
                .toList();

            if (!oldestTokens.isEmpty()) {
                oldestTokens.forEach(RefreshToken::revoke);
                refreshTokenRepository.saveAll(oldestTokens);
                log.debug("Revoked {} old tokens for user {}", oldestTokens.size(), user.getId());
            }
        }

        int expiryDays = parseExpiryDays(refreshTokenExpiry);
        String tokenString = tokenDomainService.generateTokenString();
        Instant expiresAt = tokenDomainService.calculateRefreshTokenExpiry(expiryDays);

        return Entities.create(refreshTokenRepository)
            .supply(() -> RefreshToken.create(tokenString, user.getId(), expiresAt))
            .execute()
            .orElseThrow();
    }

    @Override
    @Transactional
    @CacheEvict(value = "token-blacklist", allEntries = true)
    public Optional<TokenResponse> refreshAccessToken(String refreshTokenString) {
        return refreshTokenRepository.findByToken(refreshTokenString)
            .map(token -> {
                tokenDomainService.validateRefreshToken(token);

                return userRepository.findById(token.getUserId())
                    .map(user -> {
                        String newAccessToken = generateAccessToken(user);

                        // Rotate refresh token for security
                        token.revoke();
                        refreshTokenRepository.save(token);
                        RefreshToken newRefreshToken = generateRefreshToken(user);

                        log.info("Token refreshed for user: {}", user.getUsername());
                        return TokenResponse.of(newAccessToken, accessTokenExpirySeconds);
                    })
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            })
            .or(() -> {
                log.warn("Invalid or expired refresh token");
                return Optional.empty();
            });
    }

    @Override
    @Cacheable(value = "token-blacklist", key = "#token", unless = "#result == true")
    public boolean validateAccessToken(String token) {
        return jwtTokenProvider.validateToken(token);
    }

    @Override
    public String getUsernameFromToken(String token) {
        // Try to get username from custom claims first, fallback to subject
        String username = jwtTokenProvider.getUsername(token);
        if (username != null) {
            return username;
        }
        return jwtTokenProvider.getSubject(token);
    }

    @Override
    public Long getUserIdFromToken(String token) {
        Claims claims = jwtTokenProvider.getClaims(token);
        return claims.get("userId", Long.class);
    }

    @Override
    @Transactional
    public void revokeRefreshToken(String tokenString) {
        refreshTokenRepository.findByToken(tokenString).ifPresent(token -> {
            token.revoke();
            refreshTokenRepository.save(token);
        });
    }

    @Override
    @Transactional
    public void revokeAllUserTokens(Long userId) {
        // Use bulk update for better performance
        int revokedCount = refreshTokenRepository.revokeAllUserTokens(userId, Instant.now());
        log.info("Revoked {} tokens for user: {}", revokedCount, userId);
    }

    @Override
    @Transactional
    public void cleanupExpiredTokens() {
        int deletedExpired = refreshTokenRepository.deleteExpiredTokens(Instant.now());
        int deletedRevoked = refreshTokenRepository.deleteRevokedTokens();
        log.info("Cleaned up tokens: {} expired, {} revoked", deletedExpired, deletedRevoked);
    }

    private int parseExpiryDays(String expiry) {
        if (expiry.endsWith("d")) {
            return Integer.parseInt(expiry.substring(0, expiry.length() - 1));
        } else if (expiry.endsWith("h")) {
            return Integer.parseInt(expiry.substring(0, expiry.length() - 1)) / 24;
        } else if (expiry.endsWith("m")) {
            return Integer.parseInt(expiry.substring(0, expiry.length() - 1)) / (24 * 60);
        }
        return 7;
    }
}
