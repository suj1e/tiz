package io.github.suj1e.auth.controller;

import io.github.suj1e.auth.dto.*;
import io.github.suj1e.auth.service.AuthService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

import java.time.Instant;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

/**
 * AuthController 单元测试.
 */
@ExtendWith(MockitoExtension.class)
class AuthControllerTest {

    @Mock
    private AuthService authService;

    @InjectMocks
    private AuthController authController;

    @Test
    @DisplayName("注册 - 成功")
    void register_Success() {
        // Arrange
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");
        UserResponse userResponse = new UserResponse(
            UUID.randomUUID(),
            "test@example.com",
            Instant.now(),
            new UserSettingsResponse("system")
        );
        RegisterResponse response = new RegisterResponse("accessToken", userResponse);

        when(authService.register(any())).thenReturn(response);

        // Act
        ResponseEntity<?> result = authController.register(request);

        // Assert
        assertNotNull(result);
        assertEquals(200, result.getStatusCode().value());
    }

    @Test
    @DisplayName("登录 - 成功")
    void login_Success() {
        // Arrange
        LoginRequest request = new LoginRequest("test@example.com", "password123");
        UserResponse userResponse = new UserResponse(
            UUID.randomUUID(),
            "test@example.com",
            Instant.now(),
            new UserSettingsResponse("system")
        );
        LoginResponse response = new LoginResponse("accessToken", userResponse);

        when(authService.login(any())).thenReturn(response);

        // Act
        ResponseEntity<?> result = authController.login(request);

        // Assert
        assertNotNull(result);
        assertEquals(200, result.getStatusCode().value());
    }
}
