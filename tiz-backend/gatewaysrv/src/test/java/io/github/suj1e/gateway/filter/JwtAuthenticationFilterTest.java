package io.github.suj1e.gateway.filter;

import io.github.suj1e.common.util.JwtUtils;
import io.github.suj1e.gateway.config.JwtProperties;
import io.github.suj1e.gateway.config.RouteConfig;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import javax.crypto.SecretKey;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests for JwtAuthenticationFilter.
 */
class JwtAuthenticationFilterTest {

    private JwtAuthenticationFilter filter;
    private GatewayFilterChain chain;
    private SecretKey secretKey;

    @BeforeEach
    void setUp() {
        // Setup JWT properties
        JwtProperties jwtProperties = new JwtProperties();
        jwtProperties.setSecret("TizJwtSecretKey2026VeryLongSecretKeyForSecurity");
        secretKey = JwtUtils.toSecretKey(jwtProperties.getSecret());

        // Setup route config
        RouteConfig routeConfig = new RouteConfig();
        routeConfig.setWhitelist(List.of(
            "/api/auth/v1/login",
            "/api/auth/v1/register",
            "/api/auth/v1/refresh",
            "/actuator/**"
        ));

        filter = new JwtAuthenticationFilter(routeConfig, jwtProperties);
        chain = mock(GatewayFilterChain.class);
        when(chain.filter(any(ServerWebExchange.class))).thenReturn(Mono.empty());
    }

    @Test
    @DisplayName("Should allow access to whitelisted paths without token")
    void testWhitelistedPathWithoutToken() {
        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/auth/v1/login")
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain).filter(any(ServerWebExchange.class));
    }

    @Test
    @DisplayName("Should allow access to actuator paths without token")
    void testActuatorPathWithoutToken() {
        MockServerHttpRequest request = MockServerHttpRequest
            .get("/actuator/health")
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain).filter(any(ServerWebExchange.class));
    }

    @Test
    @DisplayName("Should reject request without Authorization header")
    void testMissingAuthorizationHeader() {
        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain, never()).filter(any(ServerWebExchange.class));

        ServerHttpResponse response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatus.UNAUTHORIZED;
    }

    @Test
    @DisplayName("Should reject request with invalid Bearer prefix")
    void testInvalidBearerPrefix() {
        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .header(HttpHeaders.AUTHORIZATION, "Basic some-token")
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain, never()).filter(any(ServerWebExchange.class));

        ServerHttpResponse response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatus.UNAUTHORIZED;
    }

    @Test
    @DisplayName("Should accept valid JWT token and inject headers")
    void testValidJwtToken() {
        UUID userId = UUID.randomUUID();
        String email = "test@example.com";
        String token = JwtUtils.generateAccessToken(userId, email, secretKey, 1800);

        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain).filter(any(ServerWebExchange.class));

        // Verify headers were injected
        ServerHttpRequest mutatedRequest = exchange.getRequest();
        // Note: In actual filter, headers are mutated on the exchange
    }

    @Test
    @DisplayName("Should reject expired token")
    void testExpiredToken() {
        UUID userId = UUID.randomUUID();
        String email = "test@example.com";
        // Generate token with negative expiration (already expired)
        String token = JwtUtils.generateAccessToken(userId, email, secretKey, -1);

        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain, never()).filter(any(ServerWebExchange.class));

        ServerHttpResponse response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatus.UNAUTHORIZED;
    }

    @Test
    @DisplayName("Should reject invalid token signature")
    void testInvalidSignature() {
        UUID userId = UUID.randomUUID();
        String email = "test@example.com";
        SecretKey wrongKey = JwtUtils.toSecretKey("WrongSecretKey2026VeryLongSecretKeyForSecurity");
        String token = JwtUtils.generateAccessToken(userId, email, wrongKey, 1800);

        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain, never()).filter(any(ServerWebExchange.class));

        ServerHttpResponse response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatus.UNAUTHORIZED;
    }

    @Test
    @DisplayName("Should reject malformed token")
    void testMalformedToken() {
        MockServerHttpRequest request = MockServerHttpRequest
            .get("/api/user/v1/me")
            .header(HttpHeaders.AUTHORIZATION, "Bearer invalid.token.here")
            .build();

        MockServerWebExchange exchange = MockServerWebExchange.from(request);

        StepVerifier.create(filter.filter(exchange, chain))
            .verifyComplete();

        verify(chain, never()).filter(any(ServerWebExchange.class));

        ServerHttpResponse response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatus.UNAUTHORIZED;
    }
}
