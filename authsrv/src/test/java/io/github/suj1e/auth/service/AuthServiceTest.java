package io.github.suj1e.auth.service;

import io.github.suj1e.auth.dto.LoginRequest;
import io.github.suj1e.auth.dto.RegisterRequest;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * AuthService 测试.
 */
@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private TokenService tokenService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private UUID testUserId;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();
        testUser = User.builder()
            .id(testUserId)
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .status(User.UserStatus.ACTIVE)
            .build();
    }

    @Test
    @DisplayName("注册 - 成功")
    void register_Success() {
        // Arrange
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");

        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("hashedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // Act
        var response = authService.register(request);

        // Assert
        assertNotNull(response);
        assertEquals("test@example.com", response.email());
        assertEquals("active", response.status());
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("注册 - 邮箱已存在")
    void register_EmailAlreadyExists() {
        // Arrange
        RegisterRequest request = new RegisterRequest("existing@example.com", "password123");
        when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            authService.register(request);
        });

        assertEquals(AuthErrorCode.AUTH_1002, exception.getErrorCode());
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("登录 - 成功")
    void login_Success() {
        // Arrange
        LoginRequest request = new LoginRequest("test@example.com", "password123");
        TokenResponse tokenResponse = new TokenResponse("accessToken", "refreshToken", 1800L);

        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("password123", "hashedPassword")).thenReturn(true);
        when(tokenService.generateTokens(testUser)).thenReturn(tokenResponse);

        // Act
        TokenResponse response = authService.login(request);

        // Assert
        assertNotNull(response);
        assertEquals("accessToken", response.accessToken());
        assertEquals("refreshToken", response.refreshToken());
    }

    @Test
    @DisplayName("登录 - 用户不存在")
    void login_UserNotFound() {
        // Arrange
        LoginRequest request = new LoginRequest("nonexistent@example.com", "password123");
        when(userRepository.findByEmail("nonexistent@example.com")).thenReturn(Optional.empty());

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            authService.login(request);
        });

        assertEquals(AuthErrorCode.AUTH_1001, exception.getErrorCode());
    }

    @Test
    @DisplayName("登录 - 密码错误")
    void login_WrongPassword() {
        // Arrange
        LoginRequest request = new LoginRequest("test@example.com", "wrongPassword");
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("wrongPassword", "hashedPassword")).thenReturn(false);

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            authService.login(request);
        });

        assertEquals(AuthErrorCode.AUTH_1001, exception.getErrorCode());
    }

    @Test
    @DisplayName("登录 - 用户已被禁用")
    void login_UserBanned() {
        // Arrange
        User bannedUser = User.builder()
            .id(testUserId)
            .email("banned@example.com")
            .passwordHash("hashedPassword")
            .status(User.UserStatus.BANNED)
            .build();

        LoginRequest request = new LoginRequest("banned@example.com", "password123");
        when(userRepository.findByEmail("banned@example.com")).thenReturn(Optional.of(bannedUser));
        when(passwordEncoder.matches("password123", "hashedPassword")).thenReturn(true);

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            authService.login(request);
        });

        assertEquals(AuthErrorCode.AUTH_1008, exception.getErrorCode());
    }

    @Test
    @DisplayName("登出 - 成功")
    void logout_Success() {
        // Arrange
        String refreshToken = "refreshToken";

        // Act
        authService.logout(testUserId, refreshToken);

        // Assert
        verify(tokenService).revokeAllTokens(testUserId);
        verify(tokenService).addToBlacklist(eq(refreshToken), anyLong());
    }

    @Test
    @DisplayName("获取当前用户 - 成功")
    void getCurrentUser_Success() {
        // Arrange
        when(userRepository.findById(testUserId)).thenReturn(Optional.of(testUser));

        // Act
        var response = authService.getCurrentUser(testUserId);

        // Assert
        assertNotNull(response);
        assertEquals(testUserId, response.id());
        assertEquals("test@example.com", response.email());
    }

    @Test
    @DisplayName("获取当前用户 - 用户不存在")
    void getCurrentUser_UserNotFound() {
        // Arrange
        UUID nonExistentUserId = UUID.randomUUID();
        when(userRepository.findById(nonExistentUserId)).thenReturn(Optional.empty());

        // Act & Assert
        AuthException exception = assertThrows(AuthException.class, () -> {
            authService.getCurrentUser(nonExistentUserId);
        });

        assertEquals(AuthErrorCode.AUTH_1009, exception.getErrorCode());
    }
}
