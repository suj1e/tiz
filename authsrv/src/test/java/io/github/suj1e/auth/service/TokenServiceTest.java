package io.github.suj1e.auth.service;

import io.github.suj1e.auth.config.JwtProperties;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.entity.RefreshToken;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.RefreshTokenRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * TokenService 测试.
 */
@ExtendWith(MockitoExtension.class)
class TokenServiceTest {

    @Mock
    private JwtProperties jwtProperties;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private StringRedisTemplate redisTemplate;

    @Mock
    private ValueOperations<String, String> valueOperations;

    @InjectMocks
    private TokenService tokenService;

    private User testUser;
    private UUID testUserId;

    // 测试用的密钥（至少 256 位）
    private static final String TEST_SECRET = "TizJwtSecretKey2026VeryLongSecretKeyForSecurity";

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();
        testUser = User.builder()
            .id(testUserId)
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .status(User.UserStatus.ACTIVE)
            .build();

        lenient().when(jwtProperties.getSecret()).thenReturn(TEST_SECRET);
        lenient().when(jwtProperties.getAccessTokenExpiration()).thenReturn(1800L);
        lenient().when(jwtProperties.getRefreshTokenExpiration()).thenReturn(604800L);
        lenient().when(redisTemplate.opsForValue()).thenReturn(valueOperations);
    }

    @Test
    @DisplayName("生成 Token - 成功")
    void generateTokens_Success() {
        // Arrange
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        TokenResponse response = tokenService.generateTokens(testUser);

        // Assert
        assertNotNull(response);
        assertNotNull(response.accessToken());
        assertNotNull(response.refreshToken());
        assertEquals("Bearer", response.tokenType());
        assertEquals(1800L, response.expiresIn());
        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    @DisplayName("刷新 Token - 成功")
    void refreshAccessToken_Success() {
        // Arrange
        // 首先生成一个有效的 refresh token
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        TokenResponse initialTokens = tokenService.generateTokens(testUser);
        String refreshToken = initialTokens.refreshToken();

        // 模拟从数据库找到 refresh token
        RefreshToken storedToken = RefreshToken.builder()
            .id(UUID.randomUUID())
            .userId(testUserId)
            .tokenHash(anyString())
            .expiresAt(Instant.now().plusSeconds(604800))
            .revoked(false)
            .build();

        when(refreshTokenRepository.findByTokenHash(anyString())).thenReturn(Optional.of(storedToken));
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(redisTemplate.hasKey(anyString())).thenReturn(false);

        // Act
        TokenResponse response = tokenService.refreshAccessToken(refreshToken);

        // Assert
        assertNotNull(response);
        assertNotNull(response.accessToken());
        assertNotNull(response.refreshToken());
        assertNotEquals(refreshToken, response.refreshToken());
    }

    @Test
    @DisplayName("刷新 Token - Token 在黑名单中")
    void refreshAccessToken_TokenBlacklisted() {
        // Arrange
        String blacklistedToken = "blacklistedToken";
        when(redisTemplate.hasKey(anyString())).thenReturn(true);

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            tokenService.refreshAccessToken(blacklistedToken);
        });

        assertEquals(AuthErrorCode.AUTH_1005, exception.getErrorCode());
    }

    @Test
    @DisplayName("撤销所有 Token - 成功")
    void revokeAllTokens_Success() {
        // Arrange
        doNothing().when(refreshTokenRepository).revokeAllByUserId(testUserId);

        // Act
        tokenService.revokeAllTokens(testUserId);

        // Assert
        verify(refreshTokenRepository).revokeAllByUserId(testUserId);
    }

    @Test
    @DisplayName("添加到黑名单 - 成功")
    void addToBlacklist_Success() {
        // Arrange
        String token = "testToken";
        long expiration = 3600L;

        // Act
        tokenService.addToBlacklist(token, expiration);

        // Assert
        verify(valueOperations).set(anyString(), eq("revoked"), eq(expiration), eq(TimeUnit.SECONDS));
    }

    @Test
    @DisplayName("检查黑名单 - Token 在黑名单中")
    void isTokenBlacklisted_True() {
        // Arrange
        String token = "blacklistedToken";
        when(redisTemplate.hasKey(anyString())).thenReturn(true);

        // Act
        boolean result = tokenService.isTokenBlacklisted(token);

        // Assert
        assertTrue(result);
    }

    @Test
    @DisplayName("检查黑名单 - Token 不在黑名单中")
    void isTokenBlacklisted_False() {
        // Arrange
        String token = "validToken";
        when(redisTemplate.hasKey(anyString())).thenReturn(false);

        // Act
        boolean result = tokenService.isTokenBlacklisted(token);

        // Assert
        assertFalse(result);
    }
}
