package io.github.suj1e.auth.api.client;

import io.github.suj1e.auth.api.dto.request.LoginRequest;
import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.api.dto.response.TokenValidationResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;

/**
 * Auth service HTTP client for other services.
 *
 * @author sujie
 */
@HttpExchange(url = "/auth/v1", accept = "application/json")
public interface AuthClient {

    /**
     * Validate an access token.
     */
    @GetExchange("/validate")
    TokenValidationResponse validateToken(@RequestParam("token") String token);

    /**
     * Login and get tokens.
     */
    @PostExchange("/login")
    ResponseEntity<TokenResponse> login(LoginRequest request);

    /**
     * Refresh access token.
     */
    @PostExchange("/refresh")
    ResponseEntity<TokenResponse> refresh(@RequestParam("refreshToken") String refreshToken);
}
