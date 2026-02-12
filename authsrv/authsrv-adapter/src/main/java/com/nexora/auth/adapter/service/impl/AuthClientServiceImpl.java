package com.nexora.auth.adapter.service.impl;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.ratelimiter.annotation.RateLimiter;
import io.github.resilience4j.retry.annotation.Retry;
import io.github.resilience4j.timelimiter.annotation.TimeLimiter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.api.client.AuthClient;
import com.nexora.auth.api.dto.request.LoginRequest;
import com.nexora.auth.api.dto.request.RefreshTokenRequest;
import com.nexora.auth.api.dto.request.RegisterRequest;
import com.nexora.auth.api.dto.response.LoginResponse;
import com.nexora.auth.api.dto.response.MessageResponse;
import com.nexora.auth.api.dto.response.TokenResponse;
import com.nexora.auth.api.dto.response.UserResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.concurrent.CompletableFuture;

/**
 * Auth service client wrapper with Resilience4j annotations.
 *
 * <p>Demonstrates how to use Resilience4j with @HttpExchange:
 * <ul>
 *   <li>@CircuitBreaker - Opens circuit when failure rate exceeds threshold</li>
 *   <li>@Retry - Retries transient failures automatically</li>
 *   <li>@TimeLimiter - Timeout protection</li>
 *   <li>@RateLimiter - Request throttling</li>
 * </ul>
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthClientServiceImpl {

    private final AuthClient authClient;

    /**
     * Validate token with full resilience protection.
     *
     * <p>Used by gateway for authentication.
     */
    @CircuitBreaker(name = "authClient", fallbackMethod = "validateTokenFallback")
    @TimeLimiter(name = "authClient", fallbackMethod = "validateTokenFallback")
    @RateLimiter(name = "authClient", fallbackMethod = "validateTokenFallback")
    public CompletableFuture<UserResponse> validateToken(String authorization) {
        try {
            UserResponse response = authClient.validateToken(authorization);
            return CompletableFuture.completedFuture(response);
        } catch (Exception e) {
            log.error("Failed to validate token: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Get current user with retry support.
     *
     * <p>Read operations can be safely retried.
     */
    @Retry(name = "authClient", fallbackMethod = "getCurrentUserFallback")
    @TimeLimiter(name = "authClient", fallbackMethod = "getCurrentUserFallback")
    public CompletableFuture<UserResponse> getCurrentUser(String authorization) {
        try {
            UserResponse response = authClient.getCurrentUser(authorization);
            return CompletableFuture.completedFuture(response);
        } catch (Exception e) {
            log.error("Failed to get current user: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Login with rate limiting.
     *
     * <p>Write operations are NOT retried, but have timeout protection.
     */
    @CircuitBreaker(name = "authClient", fallbackMethod = "loginFallback")
    @TimeLimiter(name = "authClient", fallbackMethod = "loginFallback")
    @RateLimiter(name = "authClient", fallbackMethod = "loginFallback")
    public CompletableFuture<LoginResponse> login(LoginRequest request) {
        try {
            LoginResponse response = authClient.login(request);
            return CompletableFuture.completedFuture(response);
        } catch (Exception e) {
            log.error("Failed to login: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * Fallback method for validateToken.
     *
     * <p>Returns null when circuit is open or timeout occurs.
     */
    private CompletableFuture<UserResponse> validateTokenFallback(String authorization, Throwable e) {
        log.warn("Token validation fallback triggered: {}", e.getMessage());
        return CompletableFuture.completedFuture(null);
    }

    /**
     * Fallback method for getCurrentUser.
     *
     * <p>Returns empty user when service is unavailable.
     */
    private CompletableFuture<UserResponse> getCurrentUserFallback(String authorization, Throwable e) {
        log.warn("Get current user fallback triggered: {}", e.getMessage());
        return CompletableFuture.completedFuture(
            new UserResponse(null, null, null, null, null, null, null, null, null)
        );
    }

    /**
     * Fallback method for login.
     *
     * <p>Returns error response when service is unavailable.
     */
    private CompletableFuture<LoginResponse> loginFallback(LoginRequest request, Throwable e) {
        log.warn("Login fallback triggered: {}", e.getMessage());
        return CompletableFuture.completedFuture(
            new LoginResponse(null, null, "Bearer", 0L, null)
        );
    }

    // Other methods can be added similarly...

    /**
     * Simple delegation for other methods (can be enhanced with resilience).
     */
    public LoginResponse register(RegisterRequest request) {
        return authClient.register(request);
    }

    public TokenResponse refresh(RefreshTokenRequest request) {
        return authClient.refresh(request);
    }

    public MessageResponse logout(String authorization) {
        return authClient.logout(authorization);
    }
}
