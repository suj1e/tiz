package io.github.suj1e.common.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.experimental.UtilityClass;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

/**
 * JWT 工具类.
 */
@UtilityClass
public class JwtUtils {

    /**
     * 生成 Access Token.
     */
    public String generateAccessToken(UUID userId, String email, SecretKey key, long expirationSeconds) {
        Instant now = Instant.now();
        return Jwts.builder()
            .subject(userId.toString())
            .claim("email", email)
            .claim("type", "access")
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(expirationSeconds)))
            .signWith(key)
            .compact();
    }

    /**
     * 生成 Refresh Token.
     */
    public String generateRefreshToken(UUID userId, SecretKey key, long expirationSeconds) {
        Instant now = Instant.now();
        return Jwts.builder()
            .subject(userId.toString())
            .claim("type", "refresh")
            .id(UUID.randomUUID().toString())
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(expirationSeconds)))
            .signWith(key)
            .compact();
    }

    /**
     * 解析 Token.
     */
    public Claims parseToken(String token, SecretKey key) {
        return Jwts.parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    /**
     * 验证 Token 是否有效.
     */
    public boolean isValid(String token, SecretKey key) {
        try {
            parseToken(token, key);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 从 Token 中提取用户 ID.
     */
    public UUID extractUserId(String token, SecretKey key) {
        Claims claims = parseToken(token, key);
        return UUID.fromString(claims.getSubject());
    }

    /**
     * 从 Token 中提取邮箱.
     */
    public String extractEmail(String token, SecretKey key) {
        Claims claims = parseToken(token, key);
        return claims.get("email", String.class);
    }

    /**
     * 从 Token 中提取类型 (access/refresh).
     */
    public String extractType(String token, SecretKey key) {
        Claims claims = parseToken(token, key);
        return claims.get("type", String.class);
    }

    /**
     * 字符串密钥转换为 SecretKey.
     */
    public SecretKey toSecretKey(String secret) {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
}
