package io.github.suj1e.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.auth.dto.LoginRequest;
import io.github.suj1e.auth.dto.RegisterRequest;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.dto.UserResponse;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.service.AuthService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * AuthController 测试.
 */
@WebMvcTest(AuthController.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private AuthService authService;

    @Test
    @DisplayName("注册 - 成功")
    void register_Success() throws Exception {
        // Arrange
        RegisterRequest request = new RegisterRequest("test@example.com", "password123");
        UserResponse response = new UserResponse(UUID.randomUUID(), "test@example.com", "active", Instant.now());

        when(authService.register(any())).thenReturn(response);

        // Act & Assert
        mockMvc.perform(post("/api/auth/v1/register")
                .with(csrf().ignoringRequestMatchers("/api/**"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.email").value("test@example.com"))
            .andExpect(jsonPath("$.data.status").value("active"));
    }

    @Test
    @DisplayName("注册 - 邮箱已存在")
    void register_EmailAlreadyExists() throws Exception {
        // Arrange
        RegisterRequest request = new RegisterRequest("existing@example.com", "password123");

        when(authService.register(any()))
            .thenThrow(new AuthException(AuthErrorCode.AUTH_1002));

        // Act & Assert
        mockMvc.perform(post("/api/auth/v1/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isConflict());
    }

    @Test
    @DisplayName("登录 - 成功")
    void login_Success() throws Exception {
        // Arrange
        LoginRequest request = new LoginRequest("test@example.com", "password123");
        TokenResponse response = new TokenResponse("accessToken", "refreshToken", 1800L);

        when(authService.login(any())).thenReturn(response);

        // Act & Assert
        mockMvc.perform(post("/api/auth/v1/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.accessToken").value("accessToken"))
            .andExpect(jsonPath("$.data.refreshToken").value("refreshToken"));
    }

    @Test
    @DisplayName("登录 - 凭证错误")
    void login_InvalidCredentials() throws Exception {
        // Arrange
        LoginRequest request = new LoginRequest("test@example.com", "wrongPassword");

        when(authService.login(any()))
            .thenThrow(new AuthException(AuthErrorCode.AUTH_1001));

        // Act & Assert
        mockMvc.perform(post("/api/auth/v1/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("获取当前用户 - 成功")
    @WithMockUser
    void getCurrentUser_Success() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UserResponse response = new UserResponse(userId, "test@example.com", "active", Instant.now());

        when(authService.getCurrentUser(any())).thenReturn(response);

        // Act & Assert
        mockMvc.perform(get("/api/auth/v1/me"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.email").value("test@example.com"));
    }
}
