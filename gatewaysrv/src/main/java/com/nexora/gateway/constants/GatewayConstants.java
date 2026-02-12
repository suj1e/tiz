package com.nexora.gateway.constants;

import java.time.Duration;
import java.util.List;

/**
 * Gateway 常量定义.
 */
public final class GatewayConstants {

    private GatewayConstants() {
        // 工具类私有构造
    }

    // HTTP Headers
    public static final String AUTHORIZATION_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";
    public static final String X_USER_ID = "X-User-Id";
    public static final String X_USER_NAME = "X-User-Name";
    public static final String X_USER_ROLES = "X-User-Roles";
    public static final String X_REQUEST_ID = "X-Request-Id";
    public static final String X_RESPONSE_TIME = "X-Response-Time";

    // Public Paths (无需认证)
    public static final List<String> PUBLIC_PATHS = List.of(
        "/api/v1/auth/login",
        "/api/v1/auth/register",
        "/actuator/health",
        "/actuator/info",
        "/fallback/"
    );

    // Cache Keys
    public static final String CACHE_PREFIX = "gateway:cache:";
    public static final String BLACKLIST_PREFIX = "gateway:blacklist:";
    public static final String RATE_LIMIT_PREFIX = "gateway:ratelimit:";

    // Timeouts
    public static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(10);
    public static final Duration AUTH_TIMEOUT = Duration.ofSeconds(3);
    public static final Duration JWT_VALIDATION_TIMEOUT = Duration.ofSeconds(2);

    // JWT
    public static final int MIN_JWT_SECRET_LENGTH = 32;

    // Metrics
    public static final String METRIC_ROUTE_REQUESTS = "gateway_route_requests_total";
    public static final String METRIC_ROUTE_FAILURES = "gateway_route_failures_total";
    public static final String METRIC_ROUTE_DURATION = "gateway_route_duration_seconds";
}
