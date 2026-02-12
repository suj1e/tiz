package com.nexora.gateway.constants;

import org.springframework.http.HttpStatus;

/**
 * Gateway 错误码枚举.
 */
public enum ErrorCode {

    // Authentication (1xxx)
    INVALID_TOKEN("AUTH_1001", HttpStatus.UNAUTHORIZED, "Invalid token"),
    EXPIRED_TOKEN("AUTH_1002", HttpStatus.UNAUTHORIZED, "Token expired"),
    BLACKLISTED_TOKEN("AUTH_1003", HttpStatus.UNAUTHORIZED, "Token is blacklisted"),
    MISSING_TOKEN("AUTH_1004", HttpStatus.UNAUTHORIZED, "Missing token"),

    // Rate Limiting (2xxx)
    RATE_LIMIT_EXCEEDED("RATE_2001", HttpStatus.TOO_MANY_REQUESTS, "Rate limit exceeded"),

    // Circuit Breaker (3xxx)
    SERVICE_UNAVAILABLE("CB_3001", HttpStatus.SERVICE_UNAVAILABLE, "Service unavailable"),
    CIRCUIT_BREAKER_OPEN("CB_3002", HttpStatus.SERVICE_UNAVAILABLE, "Circuit breaker is open"),

    // Gateway (4xxx)
    TIMEOUT("GW_4001", HttpStatus.GATEWAY_TIMEOUT, "Request timeout"),
    BAD_GATEWAY("GW_4002", HttpStatus.BAD_GATEWAY, "Bad gateway"),
    NOT_FOUND("GW_4003", HttpStatus.NOT_FOUND, "Route not found"),

    // Server (5xxx)
    INTERNAL_ERROR("SRV_5001", HttpStatus.INTERNAL_SERVER_ERROR, "Internal server error");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;

    ErrorCode(String code, HttpStatus httpStatus, String message) {
        this.code = code;
        this.httpStatus = httpStatus;
        this.message = message;
    }

    public String getCode() {
        return code;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }

    public String getMessage() {
        return message;
    }
}
