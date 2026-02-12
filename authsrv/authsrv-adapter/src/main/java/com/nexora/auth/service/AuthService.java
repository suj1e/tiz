package com.nexora.auth.adapter.service;

import com.nexora.auth.api.dto.request.LoginRequest;
import com.nexora.auth.api.dto.request.RefreshTokenRequest;
import com.nexora.auth.api.dto.request.RegisterRequest;
import com.nexora.auth.api.dto.response.LoginResponse;
import com.nexora.auth.api.dto.response.TokenResponse;
import com.nexora.auth.api.dto.response.UserResponse;

import java.util.Optional;

/**
 * Authentication service interface.
 *
 * @author sujie
 */
public interface AuthService {

    /**
     * Authenticate user with username and password.
     *
     * @param request login request
     * @return login response with tokens
     */
    Optional<LoginResponse> login(LoginRequest request);

    /**
     * Register new user.
     *
     * @param request registration request
     * @return login response with tokens
     */
    Optional<LoginResponse> register(RegisterRequest request);

    /**
     * Refresh access token using refresh token.
     *
     * @param request refresh token request
     * @return token response with new access token
     */
    Optional<TokenResponse> refreshToken(RefreshTokenRequest request);

    /**
     * Logout user and revoke tokens.
     *
     * @param token access token to revoke
     */
    void logout(String token);

    /**
     * Get current user from token.
     *
     * @param token access token
     * @return user response
     */
    Optional<UserResponse> getCurrentUser(String token);
}
