package io.github.suj1e.auth.adapter.infra.domainservice.impl;

import io.github.suj1e.auth.core.domainservice.TokenDomainService;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Token domain service implementation.
 * Uses JJWT for JWT handling with Redis for token blacklist.
 *
 * @author sujie
 */
@Slf4j
@Service
public class TokenDomainServiceImpl implements TokenDomainService {

    private static final String ACCESS_TOKEN_BLACKLIST_PREFIX = "auth:token:blacklist:";
    private static final String REFRESH_TOKEN_PREFIX = "auth:refresh:";
    private static final String TYPE_CLAIM = "type";

    private final SecretKey secretKey;
    private final long accessTokenValidity; // in seconds
    private final long refreshTokenValidity; // in seconds
    private final RedisTemplate<String, Object> redisTemplate;

    public TokenDomainServiceImpl(
            @Value("${nexora.security.jwt.secret}") String secret,
            @Value("${nexora.security.jwt.access-token-validity}") long accessTokenValidity,
            @Value("${nexora.security.jwt.refresh-token-validity}") long refreshTokenValidity,
            RedisTemplate<String, Object> redisTemplate) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenValidity = accessTokenValidity;
        this.refreshTokenValidity = refreshTokenValidity;
        this.redisTemplate = redisTemplate;
    }

    @Override
    public String generateAccessToken(String username) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + accessTokenValidity * 1000);

        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(username)
                .claim(TYPE_CLAIM, "access")
                .issuedAt(now)
                .expiration(validity)
                .signWith(secretKey)
                .compact();
    }

    @Override
    public String generateRefreshToken(String username) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + refreshTokenValidity * 1000);

        String token = Jwts.builder()
                .subject(username)
                .claim(TYPE_CLAIM, "refresh")
                .issuedAt(now)
                .expiration(validity)
                .signWith(secretKey)
                .compact();

        // Store refresh token in Redis
        String redisKey = REFRESH_TOKEN_PREFIX + username;
        redisTemplate.opsForValue().set(redisKey, token, refreshTokenValidity, TimeUnit.SECONDS);

        return token;
    }

    @Override
    public boolean validateAccessToken(String token) {
        try {
            // Check if token is in blacklist
            String tokenId = getTokenId(token);
            if (tokenId != null) {
                String blacklistKey = ACCESS_TOKEN_BLACKLIST_PREFIX + tokenId;
                if (Boolean.TRUE.equals(redisTemplate.hasKey(blacklistKey))) {
                    log.debug("Token is in blacklist: {}", tokenId);
                    return false;
                }
            }

            Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Invalid token: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public String getUsernameFromToken(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getSubject();
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Failed to get username from token: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public String refreshAccessToken(String refreshToken) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(refreshToken)
                    .getPayload();

            // Verify this is a refresh token
            String type = claims.get(TYPE_CLAIM, String.class);
            if (!"refresh".equals(type)) {
                throw new IllegalArgumentException("Invalid token type");
            }

            String username = claims.getSubject();

            // Verify refresh token exists in Redis
            String redisKey = REFRESH_TOKEN_PREFIX + username;
            String storedToken = (String) redisTemplate.opsForValue().get(redisKey);
            if (storedToken == null || !storedToken.equals(refreshToken)) {
                throw new IllegalArgumentException("Refresh token expired or invalid");
            }

            // Generate new access token
            return generateAccessToken(username);
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Failed to refresh access token: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Add token to blacklist (for logout).
     */
    public void addToBlacklist(String token) {
        try {
            String tokenId = getTokenId(token);
            if (tokenId != null) {
                Claims claims = Jwts.parser()
                        .verifyWith(secretKey)
                        .build()
                        .parseSignedClaims(token)
                        .getPayload();

                long expiration = claims.getExpiration().getTime();
                long ttl = Math.max(expiration - System.currentTimeMillis(), 0);
                if (ttl > 0) {
                    String blacklistKey = ACCESS_TOKEN_BLACKLIST_PREFIX + tokenId;
                    redisTemplate.opsForValue().set(blacklistKey, "1", ttl, TimeUnit.MILLISECONDS);
                    log.debug("Added token to blacklist: {}", tokenId);
                }
            }
        } catch (JwtException e) {
            log.debug("Failed to add token to blacklist: {}", e.getMessage());
        }
    }

    /**
     * Extract token ID (jti) from token.
     */
    private String getTokenId(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getId();
        } catch (JwtException e) {
            return null;
        }
    }
}
