package com.nexora.gateway.handler;

import com.nexora.gateway.constants.GatewayConstants;
import com.nexora.gateway.util.ResponseUtils;
import com.nexora.resilience.handler.FallbackHandler;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Gateway fallback handlers.
 *
 * <p>Wraps nexora's FallbackHandler with gateway-specific logic.
 *
 * @author sujie
 */
@Slf4j
@Component
public class GatewayFallbackHandler {

    private final FallbackHandler fallbackHandler;

    public GatewayFallbackHandler(FallbackHandler fallbackHandler) {
        this.fallbackHandler = fallbackHandler;
    }

    /**
     * Mix service fallback.
     */
    public Mono<ServerResponse> mixFallback(ServerRequest request) {
        log.warn("Mix service circuit breaker activated for path: {}", request.path());

        // Return structured fallback response
        return ServerResponse
                .status(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(Map.of(
                        "timestamp", Instant.now(),
                        "path", request.path(),
                        "service", "mixsrv",
                        "message", "Mix service is temporarily unavailable",
                        "fallback", true,
                        "retryAfter", 60
                ));
    }

    /**
     * Recommend service fallback with default recommendations.
     */
    public Mono<ServerResponse> recommendFallback(ServerRequest request) {
        log.warn("Recommend service circuit breaker activated for path: {}", request.path());

        // Return default recommendations
        var defaultRecommendations = getDefaultRecommendations();

        return ServerResponse
                .ok()
                .header(GatewayConstants.X_RESPONSE_TIME, String.valueOf(System.currentTimeMillis()))
                .bodyValue(Map.of(
                        "timestamp", Instant.now(),
                        "message", "Using default recommendations",
                        "fallback", true,
                        "recommendations", defaultRecommendations
                ));
    }

    /**
     * Get default recommendations when service is unavailable.
     */
    private List<Map<String, Object>> getDefaultRecommendations() {
        return List.of(
                Map.of("id", "default-1", "name", "Popular Item 1", "category", "default"),
                Map.of("id", "default-2", "name", "Popular Item 2", "category", "default"),
                Map.of("id", "default-3", "name", "Popular Item 3", "category", "default")
        );
    }
}
