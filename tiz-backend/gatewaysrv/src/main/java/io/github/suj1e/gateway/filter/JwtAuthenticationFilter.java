package io.github.suj1e.gateway.filter;

import io.github.suj1e.gateway.config.JwtProperties;
import io.github.suj1e.gateway.config.RouteConfig;
import io.github.suj1e.gateway.handler.GatewayErrorResponse;
import io.github.suj1e.common.util.JwtUtils;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.SignatureException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

/**
 * JWT Authentication Filter.
 * Validates JWT tokens and injects user information into request headers.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();

    private final RouteConfig routeConfig;
    private final JwtProperties jwtProperties;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();

        // Check if path is in whitelist
        if (isWhitelisted(path)) {
            log.debug("Path {} is whitelisted, skipping authentication", path);
            return chain.filter(exchange);
        }

        // Extract Authorization header
        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            log.warn("Missing or invalid Authorization header for path: {}", path);
            return onError(exchange, "token_missing", "Authorization header is required", HttpStatus.UNAUTHORIZED);
        }

        String token = authHeader.substring(BEARER_PREFIX.length());

        try {
            // Validate token and extract claims
            SecretKey key = JwtUtils.toSecretKey(jwtProperties.getSecret());
            Claims claims = JwtUtils.parseToken(token, key);

            // Extract user information
            String userId = claims.getSubject();
            String email = claims.get("email", String.class);

            // Validate token type
            String tokenType = claims.get("type", String.class);
            if (!"access".equals(tokenType)) {
                log.warn("Invalid token type: {} for path: {}", tokenType, path);
                return onError(exchange, "token_invalid", "Invalid token type", HttpStatus.UNAUTHORIZED);
            }

            log.debug("Token validated successfully for user: {}", userId);

            // Inject user information into request headers
            ServerHttpRequest mutatedRequest = request.mutate()
                .header("X-User-Id", userId)
                .header("X-User-Email", email)
                .build();

            return chain.filter(exchange.mutate().request(mutatedRequest).build());

        } catch (ExpiredJwtException e) {
            log.warn("Token expired for path: {}", path);
            return onError(exchange, "token_expired", "Token has expired", HttpStatus.UNAUTHORIZED);
        } catch (SignatureException e) {
            log.warn("Invalid token signature for path: {}", path);
            return onError(exchange, "token_invalid", "Invalid token signature", HttpStatus.UNAUTHORIZED);
        } catch (MalformedJwtException e) {
            log.warn("Malformed token for path: {}", path);
            return onError(exchange, "token_invalid", "Malformed token", HttpStatus.UNAUTHORIZED);
        } catch (JwtException e) {
            log.warn("JWT validation failed for path {}: {}", path, e.getMessage());
            return onError(exchange, "token_invalid", "Token validation failed", HttpStatus.UNAUTHORIZED);
        } catch (Exception e) {
            log.error("Unexpected error during JWT validation for path: {}", path, e);
            return onError(exchange, "internal_error", "Internal server error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Check if the path is in the whitelist.
     */
    private boolean isWhitelisted(String path) {
        return routeConfig.getWhitelist().stream()
            .anyMatch(pattern -> PATH_MATCHER.match(pattern, path));
    }

    /**
     * Return error response.
     */
    private Mono<Void> onError(ServerWebExchange exchange, String code, String message, HttpStatus status) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(status);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);

        GatewayErrorResponse errorResponse = new GatewayErrorResponse(
            "authentication_error",
            code,
            message
        );

        String body = errorResponse.toJson();
        DataBuffer buffer = response.bufferFactory().wrap(body.getBytes(StandardCharsets.UTF_8));

        return response.writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return -100; // High priority
    }
}
