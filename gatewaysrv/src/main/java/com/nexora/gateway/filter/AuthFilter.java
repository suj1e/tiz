package com.nexora.gateway.filter;

import com.nexora.gateway.constants.ErrorCode;
import com.nexora.gateway.constants.GatewayConstants;
import com.nexora.gateway.exception.AuthenticationException;
import com.nexora.gateway.util.ResponseUtils;
import com.nexora.security.jwt.ReactiveJwtTokenProvider;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeoutException;

/**
 * JWT authentication filter (using native Reactive API).
 *
 * <p>Validates JWT token in request headers and adds user information
 * to downstream request headers.
 *
 * @author sujie
 */
@Slf4j
@Component
public class AuthFilter extends AbstractGatewayFilterFactory<AuthFilter.Config> {

    private final ReactiveJwtTokenProvider jwtProvider;

    @Autowired
    public AuthFilter(ReactiveJwtTokenProvider jwtProvider) {
        super(Config.class);
        this.jwtProvider = jwtProvider;
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            var request = exchange.getRequest();
            var path = request.getPath().value();

            // Skip public paths
            if (isPublicPath(path)) {
                return chain.filter(exchange);
            }

            // Extract JWT Token
            var token = extractToken(request);
            if (token == null) {
                return ResponseUtils.unauthorized(exchange, "Missing or invalid Authorization header");
            }

            // Validate JWT with timeout and fine-grained error handling
            return jwtProvider.validateToken(token)
                    .timeout(GatewayConstants.JWT_VALIDATION_TIMEOUT)
                    .flatMap(claims -> {
                        // Add user context to request headers
                        var mutatedRequest = addUserContext(request, claims);
                        log.debug("Authenticated request for user: {} to path: {}", claims.getSubject(), path);
                        return chain.filter(exchange.mutate().request(mutatedRequest).build());
                    })
                    .onErrorResume(TimeoutException.class, e -> {
                        log.error("JWT validation timeout for path: {}", path);
                        return ResponseUtils.writeErrorResponse(
                            exchange,
                            ErrorCode.TIMEOUT.getHttpStatus(),
                            "Authentication timeout"
                        );
                    })
                    .onErrorResume(AuthenticationException.class, e -> {
                        log.warn("Authentication failed for path {}: {}", path, e.getMessage());
                        return ResponseUtils.writeErrorResponse(exchange, e);
                    })
                    .onErrorResume(ExpiredJwtException.class, e -> {
                        log.warn("JWT expired for path {}: {}", path, e.getMessage());
                        return ResponseUtils.writeErrorResponse(
                            exchange,
                            ErrorCode.EXPIRED_TOKEN
                        );
                    })
                    .onErrorResume(Exception.class, e -> {
                        log.error("Unexpected error during JWT validation for path {}: {}", path, e.getMessage(), e);
                        return ResponseUtils.writeErrorResponse(
                            exchange,
                            ErrorCode.INTERNAL_ERROR
                        );
                    })
                    .doOnCancel(() -> {
                        log.warn("Authentication request cancelled for path: {}", path);
                    });
        };
    }

    /**
     * Extract token from request headers.
     */
    private String extractToken(org.springframework.http.server.reactive.ServerHttpRequest request) {
        var authHeader = request.getHeaders().getFirst(GatewayConstants.AUTHORIZATION_HEADER);
        if (authHeader == null || !authHeader.startsWith(GatewayConstants.BEARER_PREFIX)) {
            log.debug("No valid Authorization header found");
            return null;
        }
        return authHeader.substring(GatewayConstants.BEARER_PREFIX.length());
    }

    /**
     * Check if path is public (requires no authentication).
     */
    private boolean isPublicPath(String path) {
        return GatewayConstants.PUBLIC_PATHS.stream()
                .anyMatch(path::startsWith);
    }

    /**
     * Add user context to request headers.
     */
    private org.springframework.http.server.reactive.ServerHttpRequest addUserContext(
            org.springframework.http.server.reactive.ServerHttpRequest request,
            Claims claims) {
        String userId = claims.getSubject();
        List<String> roles = claims.get("roles", List.class);
        String username = claims.get("username", String.class);

        return request.mutate()
                .header(GatewayConstants.X_USER_ID, userId)
                .header(GatewayConstants.X_USER_NAME, username != null ? username : userId)
                .header(GatewayConstants.X_USER_ROLES, String.join(",", roles != null ? roles : List.of()))
                .build();
    }

    public static class Config {
        // Configuration properties (if needed)
    }
}
