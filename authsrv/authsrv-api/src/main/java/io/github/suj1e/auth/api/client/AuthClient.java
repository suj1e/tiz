package io.github.suj1e.auth.api.client;

import io.github.suj1e.auth.api.dto.request.LoginRequest;
import io.github.suj1e.auth.api.dto.request.RefreshTokenRequest;
import io.github.suj1e.auth.api.dto.request.RegisterRequest;
import io.github.suj1e.auth.api.dto.response.LoginResponse;
import io.github.suj1e.auth.api.dto.response.MessageResponse;
import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.api.dto.response.UserResponse;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;

/**
 * HTTP Client interface for Auth service.
 * Uses @HttpExchange for type-safe service-to-service communication.
 *
 * <p>Usage in other microservices:
 * <pre>
 * &#64;Bean
 * public AuthClient authClient() {
 *     return HttpServiceProxyFactory.builder()
 *         .clientAdapter RestClient.create())
 *         .build()
 *         .createClient(AuthClient.class, "http://authsrv");
 * }
 * </pre>
 *
 * @author sujie
 */
@HttpExchange(url = "/v1", accept = "application/json", contentType = "application/json")
public interface AuthClient {

    /**
     * User login.
     */
    @PostExchange("/login")
    LoginResponse login(@RequestBody LoginRequest request);

    /**
     * User registration.
     */
    @PostExchange("/register")
    LoginResponse register(@RequestBody RegisterRequest request);

    /**
     * Refresh access token.
     */
    @PostExchange("/refresh")
    TokenResponse refresh(@RequestBody RefreshTokenRequest request);

    /**
     * User logout.
     */
    @PostExchange("/logout")
    MessageResponse logout(@RequestHeader("Authorization") String authorization);

    /**
     * Get current user info by token.
     */
    @GetExchange("/me")
    UserResponse getCurrentUser(@RequestHeader("Authorization") String authorization);

    /**
     * Validate token and get user info.
     * Used by gateway for authentication.
     */
    @GetExchange("/validate")
    UserResponse validateToken(@RequestHeader("Authorization") String authorization);
}
