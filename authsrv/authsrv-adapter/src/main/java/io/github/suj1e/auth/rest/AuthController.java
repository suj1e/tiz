package io.github.suj1e.auth.adapter.rest;

import io.github.suj1e.auth.exception.BusinessException;
import io.github.suj1e.auth.exception.ErrorCode;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import io.github.suj1e.auth.api.dto.request.LoginRequest;
import io.github.suj1e.auth.api.dto.request.RefreshTokenRequest;
import io.github.suj1e.auth.api.dto.request.RegisterRequest;
import io.github.suj1e.auth.api.dto.response.LoginResponse;
import io.github.suj1e.auth.api.dto.response.MessageResponse;
import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.adapter.service.AuthService;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication REST controller.
 *
 * <p>Returns DTOs directly - wrapped by nexora-spring-boot-starter-web as Result<T>
 *
 * @author sujie
 */
@Slf4j
@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * User login.
     */
    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request)
            .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_CREDENTIALS));
    }

    /**
     * User registration.
     */
    @PostMapping("/register")
    public LoginResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request)
            .orElseThrow(() -> new BusinessException(ErrorCode.VALIDATION_ERROR));
    }

    /**
     * Refresh access token.
     */
    @PostMapping("/refresh")
    public TokenResponse refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return authService.refreshToken(request)
            .orElseThrow(() -> new BusinessException(ErrorCode.REFRESH_TOKEN_INVALID));
    }

    /**
     * User logout.
     */
    @PostMapping("/logout")
    public MessageResponse logout(@RequestHeader("Authorization") String authorization) {
        String token = authorization.replace("Bearer ", "");
        authService.logout(token);
        return MessageResponse.of("Logged out successfully");
    }

    /**
     * Get current user info.
     */
    @GetMapping("/me")
    public UserResponse getCurrentUser(@RequestHeader("Authorization") String authorization) {
        String token = authorization.replace("Bearer ", "");
        return authService.getCurrentUser(token)
            .orElseThrow(() -> new BusinessException(ErrorCode.TOKEN_INVALID));
    }

    /**
     * Validate token and return user info.
     * Used by gateway for authentication.
     * Compatible with @HttpExchange client interface.
     */
    @GetMapping("/validate")
    public UserResponse validateToken(@RequestHeader("Authorization") String authorization) {
        String token = authorization.replace("Bearer ", "");
        return authService.getCurrentUser(token)
            .orElseThrow(() -> new BusinessException(ErrorCode.TOKEN_INVALID));
    }

    /**
     * OAuth2 login success endpoint (redirect target).
     */
    @GetMapping("/oauth2/success")
    public String oauth2Success(@RequestParam("token") String token) {
        return "OAuth2 login successful. Token: " + token.substring(0, Math.min(20, token.length())) + "...";
    }
}
