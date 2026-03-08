package io.github.suj1e.auth.service;

import io.github.suj1e.auth.config.JwtProperties;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.entity.RefreshToken;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.RefreshTokenRepository;
import io.github.suj1e.common.util.JwtUtils;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Token 服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TokenService {

    private final JwtProperties jwtProperties;
    private final RefreshTokenRepository refreshTokenRepository;
    private final StringRedisTemplate redisTemplate;

    private static final String TOKEN_BLACKLIST_PREFIX = "auth:token:blacklist:";

    /**
     * 生成 Token 响应.
     */
    @Transactional
    public TokenResponse generateTokens(User user) {
        SecretKey key = getSecretKey();

        // 生成 Access Token
        String accessToken = JwtUtils.generateAccessToken(
            user.getId(),
            user.getEmail(),
            key,
            jwtProperties.getAccessTokenExpiration()
        );

        // 生成 Refresh Token
        String refreshToken = JwtUtils.generateRefreshToken(
            user.getId(),
            key,
            jwtProperties.getRefreshTokenExpiration()
        );

        // 保存 Refresh Token 到数据库
        saveRefreshToken(user.getId(), refreshToken);

        return new TokenResponse(accessToken, refreshToken, jwtProperties.getAccessTokenExpiration());
    }

    /**
     * 刷新 Access Token.
     */
    @Transactional
    public TokenResponse refreshAccessToken(String refreshToken) {
        // 检查是否在黑名单中
        if (isTokenBlacklisted(refreshToken)) {
            throw new AuthException(AuthErrorCode.AUTH_1005);
        }

        SecretKey key = getSecretKey();

        // 验证 Refresh Token 格式
        if (!JwtUtils.isValid(refreshToken, key)) {
            throw new AuthException(AuthErrorCode.AUTH_1003);
        }

        // 检查 Token 类型
        String tokenType = JwtUtils.extractType(refreshToken, key);
        if (!"refresh".equals(tokenType)) {
            throw new AuthException(AuthErrorCode.AUTH_1003);
        }

        // 从数据库验证 Refresh Token
        String tokenHash = hashToken(refreshToken);
        RefreshToken storedToken = refreshTokenRepository.findByTokenHash(tokenHash)
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1003));

        // 检查是否已撤销
        if (storedToken.getRevoked()) {
            throw new AuthException(AuthErrorCode.AUTH_1005);
        }

        // 检查是否过期
        if (storedToken.getExpiresAt().isBefore(Instant.now())) {
            throw new AuthException(AuthErrorCode.AUTH_1004);
        }

        // 获取用户 ID
        UUID userId = JwtUtils.extractUserId(refreshToken, key);

        // 撤销旧的 Refresh Token
        storedToken.setRevoked(true);
        refreshTokenRepository.save(storedToken);

        // 生成新的 Token
        String newAccessToken = JwtUtils.generateAccessToken(
            userId,
            null, // email 从数据库获取
            key,
            jwtProperties.getAccessTokenExpiration()
        );

        String newRefreshToken = JwtUtils.generateRefreshToken(
            userId,
            key,
            jwtProperties.getRefreshTokenExpiration()
        );

        // 保存新的 Refresh Token
        saveRefreshToken(userId, newRefreshToken);

        return new TokenResponse(newAccessToken, newRefreshToken, jwtProperties.getAccessTokenExpiration());
    }

    /**
     * 撤销用户的所有令牌.
     */
    @Transactional
    public void revokeAllTokens(UUID userId) {
        refreshTokenRepository.revokeAllByUserId(userId);
    }

    /**
     * 将令牌加入黑名单.
     */
    public void addToBlacklist(String token, long expirationSeconds) {
        String tokenHash = hashToken(token);
        String key = TOKEN_BLACKLIST_PREFIX + tokenHash;
        redisTemplate.opsForValue().set(key, "revoked", expirationSeconds, TimeUnit.SECONDS);
    }

    /**
     * 检查令牌是否在黑名单中.
     */
    public boolean isTokenBlacklisted(String token) {
        String tokenHash = hashToken(token);
        String key = TOKEN_BLACKLIST_PREFIX + tokenHash;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    /**
     * 保存 Refresh Token 到数据库.
     */
    private void saveRefreshToken(UUID userId, String refreshToken) {
        String tokenHash = hashToken(refreshToken);
        Instant expiresAt = Instant.now().plusSeconds(jwtProperties.getRefreshTokenExpiration());

        RefreshToken token = RefreshToken.builder()
            .userId(userId)
            .tokenHash(tokenHash)
            .expiresAt(expiresAt)
            .revoked(false)
            .createdBy(userId)
            .build();

        refreshTokenRepository.save(token);
    }

    /**
     * 获取签名密钥.
     */
    private SecretKey getSecretKey() {
        return JwtUtils.toSecretKey(jwtProperties.getSecret());
    }

    /**
     * 对令牌进行哈希.
     */
    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to hash token", e);
        }
    }
}
