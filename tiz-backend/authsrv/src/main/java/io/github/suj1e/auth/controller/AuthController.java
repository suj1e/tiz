package io.github.suj1e.auth.controller;

import io.github.suj1e.auth.dto.*;
import io.github.suj1e.auth.service.AuthService;
import io.github.suj1e.common.annotation.NoAuth;
import io.github.suj1e.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 认证控制器.
 * 提供对外 API.
 */
@RestController
@RequestMapping("/api/auth/v1")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * 用户注册.
     */
    @NoAuth
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(@Valid @RequestBody RegisterRequest request) {
        UserResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 用户登录.
     */
    @NoAuth
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<TokenResponse>> login(@Valid @RequestBody LoginRequest request) {
        TokenResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 用户登出.
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
        @AuthenticationPrincipal UUID userId,
        @RequestBody(required = false) RefreshTokenRequest request
    ) {
        String refreshToken = request != null ? request.refreshToken() : null;
        authService.logout(userId, refreshToken);
        return ResponseEntity.ok(ApiResponse.empty());
    }

    /**
     * 刷新 Token.
     */
    @NoAuth
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse response = authService.refreshToken(request.refreshToken());
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 获取当前用户.
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal UUID userId) {
        UserResponse response = authService.getCurrentUser(userId);
        return ResponseEntity.ok(ApiResponse.of(response));
    }
}
